-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- This query creates the table `ur_transform_html_flattened_email_anchor_cached`,
-- which extracts and organizes anchor (`<a>`) tag data from HTML content stored
-- in the `uniform_resource_transform` table. The extracted data includes:
-- 1. `anchor`: The `href` attribute of each anchor tag.
-- 2. `anchor_text`: The text content of the anchor tag (first child).
-- The `json_each` function is used to iterate over the JSON `content` field,
-- allowing extraction of attributes and text from each anchor tag. This cached
-- table facilitates efficient querying of flattened HTML anchors from emails.


DROP TABLE IF EXISTS ur_transform_html_flattened_email_anchor_cached;
CREATE TABLE ur_transform_html_flattened_email_anchor_cached AS
SELECT
    uniform_resource_transform_id,
    uniform_resource_id,
    json_extract(json_each.value, '$.attributes.href') AS anchor,
    json_extract(json_each.value, '$.children[0]') AS anchor_text
FROM
    uniform_resource_transform,
    json_each(content);


-- This query creates the table `ur_transform_html_email_anchor_subscription_filter_chached`,
-- which categorizes email anchor links (`anchor`) based on their purpose or intent.
-- The categorization is done using a `CASE` statement with `regexp_like` to identify
-- specific keywords in the anchor URLs. The `anchor_type` field assigns labels like:
--   - 'Unsubscribe' for links with keywords like 'unsubscribe' or 'list-unsubscribe'.
--   - 'Optout' for 'optout' or 'opt-out'.
--   - 'Preferences', 'Remove', 'Manage', etc., for respective keywords.
--   - 'mailto' for email links, and others as defined.
-- The source data is fetched from `ur_transform_html_flattened_email_anchor_cached`,
-- which contains flattened anchor tags and their associated text (`anchor_text`).
-- This table is useful for identifying and categorizing subscription-related links in emails.


DROP TABLE IF EXISTS ur_transform_html_email_anchor_subscription_filter_chached;
CREATE TABLE ur_transform_html_email_anchor_subscription_filter_chached AS
SELECT 
    uniform_resource_transform_id,
    uniform_resource_id,
    anchor,
    CASE
        WHEN regexp_like(anchor, '(?i)unsubscribe|list-unsubscribe') THEN 'Unsubscribe'
        WHEN regexp_like(anchor, '(?i)optout|opt-out') THEN 'Optout'
        WHEN regexp_like(anchor, '(?i)preferences') THEN 'Preferences'
        WHEN regexp_like(anchor, '(?i)remove') THEN 'Remove'
        WHEN regexp_like(anchor, '(?i)manage') THEN 'Manage'
        WHEN regexp_like(anchor, '(?i)email-settings') THEN 'Email-settings'
        WHEN regexp_like(anchor, '(?i)subscription|subscribe') THEN 'Subscribe'
        WHEN regexp_like(anchor, '(?i)mailto:') THEN 'mailto'
        WHEN regexp_like(anchor, '(?i)#main:') THEN 'main'
    END AS anchor_type,
    anchor_text
FROM
    ur_transform_html_flattened_email_anchor_cached;

-- This query creates the table `ur_transform_html_email_anchor_cached` to cache and classify
-- email anchor links (`anchor`) based on their intent. It uses a `CASE` statement with
-- `regexp_like` to label the `anchor_type` field with values like 'Unsubscribe', 'Optout',
-- 'Preferences', etc., based on the keywords found in the `anchor` URL.
-- The data is sourced from `ur_transform_html_flattened_email_anchor_cached`, which contains
-- flattened anchor tags and their associated text (`anchor_text`).
-- Additionally, the `WHERE` clause filters out anchors already matching any of the defined
-- categories, ensuring only unclassified or non-matching links are included in this table.


DROP TABLE IF EXISTS ur_transform_html_email_anchor_cached;
CREATE TABLE ur_transform_html_email_anchor_cached AS
SELECT
    uniform_resource_transform_id,
    uniform_resource_id,
    CASE
        WHEN regexp_like(anchor, '(?i)unsubscribe|list-unsubscribe') THEN 'Unsubscribe'
        WHEN regexp_like(anchor, '(?i)optout|opt-out') THEN 'Optout'
        WHEN regexp_like(anchor, '(?i)preferences') THEN 'Preferences'
        WHEN regexp_like(anchor, '(?i)remove') THEN 'Remove'
        WHEN regexp_like(anchor, '(?i)manage') THEN 'Manage'
        WHEN regexp_like(anchor, '(?i)email-settings') THEN 'Email-settings'
        WHEN regexp_like(anchor, '(?i)subscription|subscribe') THEN 'Subscribe'
        WHEN regexp_like(anchor, '(?i)mailto:') THEN 'mailto'
        WHEN regexp_like(anchor, '(?i)#main:') THEN 'main'
    END AS anchor_type,
    anchor,
    anchor_text
FROM
    ur_transform_html_flattened_email_anchor_cached
    WHERE NOT regexp_like(anchor, '(?i)unsubscribe|optout|opt-out|preferences|remove|manage|email-settings|subscription|subscribe|list-unsubscribe|mailto:|#main');


-- This query creates a table `ur_periodical_chached` to cache email message details
-- and their associated uniform resources. It retrieves information such as the sender,
-- recipient, subject, and date of email messages, linking them to uniform resources
-- based on a hierarchical relationship. The query specifically filters resources
-- where the URI ends with '/html' (case-insensitive). This cached data can be used
-- for efficient retrieval and analysis of periodical email messages tied to HTML resources.

DROP TABLE IF EXISTS ur_periodical_chached;
CREATE TABLE ur_periodical_chached AS
SELECT
    ur_extended.uniform_resource_id AS periodical_uniform_resource_id,
    imap_msg."from" AS message_from,
    imap_account.email AS message_to,
    imap_msg."subject" AS message_subject,
    imap_msg."date" AS message_date,
    ur_base.uniform_resource_id  AS base_uniform_resource_id,
    ur_extended.uri AS extended_uri
FROM
    ur_ingest_session_imap_acct_folder_message imap_msg
    INNER JOIN ur_ingest_session_imap_acct_folder imap_folder ON imap_folder.ur_ingest_session_imap_acct_folder_id = imap_msg.ingest_imap_acct_folder_id
    INNER JOIN ur_ingest_session_imap_account imap_account ON imap_account.ur_ingest_session_imap_account_id = imap_folder.ingest_account_id
    INNER JOIN uniform_resource_edge edge ON edge.node_id = imap_msg.ur_ingest_session_imap_acct_folder_message_id
    INNER JOIN uniform_resource ur_base ON ur_base.uniform_resource_id = edge.uniform_resource_id
    INNER JOIN uniform_resource ur_extended ON ur_extended.uri = ur_base.uri || '/html'
WHERE
    regexp_like(ur_extended.uri,'(?i)/html');

-- This query creates the table `ur_transform_html_email_anchor_http_cached`, which caches
-- HTTP response data for a subset of email anchor links. For each record:
-- 1. `uniform_resource_transform_id` and `uniform_resource_id` are identifiers for tracking.
-- 2. `anchor` represents the URL of the anchor link.
-- 3. `http_get_body(anchor)` fetches the HTML body of the linked resource via an HTTP GET request.
-- The data is sourced from `ur_transform_html_email_anchor_cached` and limited to 20 rows,
-- likely for testing or performance considerations.
-- This table can be used to analyze the content retrieved from anchor links in emails.


DROP TABLE IF EXISTS ur_transform_html_email_anchor_http_cached;
CREATE TABLE ur_transform_html_email_anchor_http_cached AS
SELECT
        uniform_resource_transform_id,
        uniform_resource_id,
        anchor,
        http_get_body(anchor) as html_body
    FROM ur_transform_html_email_anchor_cached LIMIT 20;

-- This query creates the table `ur_transform_html_email_anchor_canonical_cached` to cache
-- canonical link information extracted from HTML documents retrieved from email anchor links.
-- For each record:
-- 1. `uniform_resource_transform_id` and `uniform_resource_id` track the resource identifiers.
-- 2. `anchor` represents the original anchor URL.
-- 3. `property_name` extracts the `rel` attribute of `<link>` tags to identify properties like 'canonical'.
-- 4. `canonical_link` extracts the `href` attribute of `<link>` tags that are marked as 'canonical'.
-- The data is sourced from `ur_transform_html_email_anchor_http_cached`, where the HTML body
-- content is processed using `html_each` to iterate over `<link>` tags.
-- The `WHERE` clause ensures only `<link>` tags with a `rel="canonical"` attribute are included.
-- This table is useful for identifying canonical URLs associated with email links.


DROP TABLE IF EXISTS ur_transform_html_email_anchor_canonical_cached;
CREATE TABLE ur_transform_html_email_anchor_canonical_cached AS
SELECT
        eah.uniform_resource_transform_id,
        eah.uniform_resource_id,
        eah.anchor,
        html_attr_get(h.html, 'link', 'rel') AS property_name,   -- Extracts the Open Graph property name
        html_attr_get(h.html, 'link', 'href') AS canonical_link
    FROM ur_transform_html_email_anchor_http_cached eah,
        html_each(eah.html_body, 'link') AS h WHERE html_attr_get(h.html, 'link', 'rel')='canonical';


-- This query creates the table `ur_transform_html_email_anchor_meta_cached` to cache metadata
-- extracted from HTML documents retrieved from email anchor links. For each record:
-- 1. `uniform_resource_transform_id` and `uniform_resource_id` track the resource identifiers.
-- 2. `anchor` represents the original anchor URL.
-- 3. `property_name` extracts the `name` attribute of `<meta>` tags, identifying metadata properties.
-- 4. `content` extracts the `content` attribute of `<meta>` tags, which holds the metadata value.
-- The data is sourced from `ur_transform_html_email_anchor_http_cached`, where the HTML body
-- is processed using `html_each` to iterate over `<meta>` tags.
-- This table provides a structured way to analyze metadata associated with email links,
-- such as Open Graph tags, SEO information, or other descriptive properties.

DROP TABLE IF EXISTS ur_transform_html_email_anchor_meta_cached;
CREATE TABLE ur_transform_html_email_anchor_meta_cached AS
SELECT
        eah.uniform_resource_transform_id,
        eah.uniform_resource_id,
        eah.anchor,
        html_attr_get(h.html, 'meta', 'name') AS property_name,   -- Extracts the Open Graph property name
        html_attr_get(h.html, 'meta', 'content') AS content
    FROM ur_transform_html_email_anchor_http_cached eah,
        html_each(eah.html_body, 'meta') AS h;


-- This query creates the table `ur_transform_html_email_anchor_title_cached`, which caches
-- the title of HTML documents retrieved from email anchor links. For each record:
-- 1. `uniform_resource_transform_id` and `uniform_resource_id` are identifiers for tracking resources.
-- 2. `anchor` represents the original anchor URL.
-- 3. `title` extracts the text content of the `<title>` tag from the HTML document.
-- The data is sourced from `ur_transform_html_email_anchor_http_cached`, and the HTML body is
-- processed using `html_each` to locate the `<title>` tag.
-- This table is useful for analyzing the titles of linked HTML pages, providing insights into
-- the content or purpose of the anchor links.

DROP TABLE IF EXISTS ur_transform_html_email_anchor_title_cached;
CREATE TABLE ur_transform_html_email_anchor_title_cached AS
SELECT
        eah.uniform_resource_transform_id,
        eah.uniform_resource_id,
        eah.anchor,
        html_text(h.html,'title') as title
    FROM ur_transform_html_email_anchor_http_cached eah,
        html_each(eah.html_body, 'title') AS h;

-- This query creates the 'ur_periodical_anchor_text_json_filter_cached' table by extracting and processing data from the 'anchor_text' field in the 'ur_transform_html_email_anchor_cached' table.
-- Purpose:
--   - To extract meaningful text or attributes (e.g., 'alt', 'name') from JSON structures in 'anchor_text'.
--   - To handle different HTML element types (e.g., img, span, table) with specific logic for each.
--   - To generate a 'url_text' field that categorizes and provides useful information or defaults (e.g., '[No Title]') for missing data.
--
-- Key Features:
--   - JSON Extraction: Extracts attributes like 'alt' and 'name' from JSON.
--   - Deep Children Handling: Handles nested child elements using 'text_count' for dynamic extraction based on array depth.
--   - Conditional Logic: Tailored extraction logic for elements like 'img', 'span', 'table', 'mark', with fallbacks to '[No Title]' or 'Not object'.
--   - Filtering: Only valid JSON objects are processed, ensuring the integrity of data with 'json_valid' and 'json_type' checks.
-- Result: The 'url_text' field provides categorized and extracted text from the 'anchor_text' JSON structure, supporting further analysis.

DROP TABLE IF EXISTS ur_periodical_anchor_text_json_filter_cached;
CREATE TABLE ur_periodical_anchor_text_json_filter_cached AS
SELECT
    anchor,
    anchor_text,
    json_extract(anchor_text, '$.attributes.alt') AS child,
    json_extract(anchor_text, '$.name') AS name,
    text_count(json_extract(anchor_text, '$.children[0]'), 'children') AS type,
    CASE
        WHEN json_extract(anchor_text, '$.name') = 'img' THEN
            CASE
                WHEN json_extract(anchor_text, '$.attributes.alt') IS NOT NULL AND json_extract(anchor_text, '$.attributes.alt') <> '' THEN json_extract(anchor_text, '$.attributes.alt')
                ELSE
                '[No Title]'
                END
        WHEN json_extract(anchor_text, '$.name') = 'span' THEN
            CASE
                WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                CASE
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                END
            ELSE
                'Not object'
            END
        WHEN json_extract(anchor_text, '$.name') = 'table' THEN
            CASE
                WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                CASE
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                END
            ELSE
                'Not object'
            END
        WHEN json_extract(anchor_text, '$.name') = 'strong' THEN
            CASE
                WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
            ELSE
                '[No Title]'
            END
        WHEN json_extract(anchor_text, '$.name') = 'u' THEN
            CASE
                WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
            ELSE
                '[No Title]'
            END
        WHEN json_extract(anchor_text, '$.name') = 'b' THEN
            CASE
                WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
            ELSE
                '[No Title]'
            END
        WHEN json_extract(anchor_text, '$.name') = 'mark' THEN
            CASE
                WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                CASE
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                    WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                END
            ELSE
                'Not object'
            END
        ELSE 'not added'
    END AS url_text
FROM
    ur_transform_html_email_anchor_cached
WHERE
    json_valid(anchor_text) -- Only select rows with valid JSON
    AND json_type(anchor_text) = 'object';

-- The following SQL script creates a table called 'ur_periodical_anchor_text_cached'
-- by selecting data from the 'ur_transform_html_email_anchor_cached' table. This table
-- is intended to extract and process the 'anchor' and 'anchor_text' data, ensuring that
-- the extracted text is clean and processed correctly, especially when the 'anchor_text'
-- is in JSON format.

-- Step-by-Step Explanation:

-- 1. The query starts by checking if the 'ur_periodical_anchor_text_cached' table already exists.
--    If it does, it is dropped to ensure the script creates a fresh table.
-- 2. A new table 'ur_periodical_anchor_text_cached' is created using the result of a SELECT statement
--    which processes data from 'ur_transform_html_email_anchor_cached'

DROP TABLE IF EXISTS ur_periodical_anchor_text_cached;
CREATE TABLE ur_periodical_anchor_text_cached AS
SELECT
    parent.anchor,
    -- Select the 'anchor_text' field from the parent table.
    parent.anchor_text,
     -- 3. Check if the 'anchor_text' is a valid JSON structure and contains objects (using regexp_like).
    CASE
        WHEN regexp_like(anchor_text, '^\s*(\{(?:[^{}]|(?1))*\}|\[(?:[^[\]]|(?1))*\])\s*$') THEN -- check the field chaving string or json if json extract link text
             (SELECT
                CASE
                 -- 4. Check if the JSON structure corresponds to an image ('img').
                    WHEN json_extract(anchor_text, '$.name') = 'img' THEN -- if json name is img
                        CASE
                         -- 5. If the 'alt' attribute is not NULL or empty, use it; otherwise, use '[No Title]'.
                            WHEN json_extract(anchor_text, '$.attributes.alt') IS NOT NULL AND json_extract(anchor_text, '$.attributes.alt') <> '' THEN json_extract(anchor_text, '$.attributes.alt')
                            ELSE
                            '[No Title]'  -- Default text when 'alt' attribute is not present.
                            END
                             -- 6. Handle other possible JSON elements like 'span', 'table', 'strong', 'u', 'b', 'mark'.
                    WHEN json_extract(anchor_text, '$.name') = 'span' THEN
                     -- Check for children and extract nested text.
                        CASE
                            WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                            CASE
                            -- Recursively check for up to 9 nested levels within the 'children' array.
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                            END
                        ELSE
                            'Not object'
                        END
                         -- Similar checks for 'table', 'strong', 'u', 'b', and 'mark' tags,
                    -- extracting text from their respective 'children' or providing default '[No Title]'
                    WHEN json_extract(anchor_text, '$.name') = 'table' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                            CASE
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                            END
                        ELSE
                            'Not object'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'strong' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
                        ELSE
                            '[No Title]'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'u' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
                        ELSE
                            '[No Title]'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'b' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
                        ELSE
                            '[No Title]'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'mark' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                            CASE
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                            END
                        ELSE
                            'Not object'
                        END
                    ELSE 'not added'
                END AS url_text
            FROM
                ur_transform_html_email_anchor_cached
            WHERE
                json_valid(anchor_text) -- Only select rows with valid JSON
                AND json_type(anchor_text) = 'object' AND parent.anchor = anchor)
        ELSE
            (SELECT
                anchor_text
            FROM
                ur_transform_html_email_anchor_cached
            WHERE
                parent.anchor = anchor)
        END
        AS url_text
FROM ur_transform_html_email_anchor_cached as parent;




DROP TABLE IF EXISTS ur_removed_anchor_text_cached;
CREATE TABLE ur_removed_anchor_text_cached AS
SELECT
    parent.uniform_resource_transform_id,
    parent.uniform_resource_id,
    parent.anchor,
    parent.anchor_type,
    parent.anchor_text as org_anchor_text,
    CASE
        WHEN regexp_like(anchor_text, '^\s*(\{(?:[^{}]|(?1))*\}|\[(?:[^[\]]|(?1))*\])\s*$') THEN -- check the field chaving string or json if json extract link text
             (SELECT
                CASE
                    WHEN json_extract(anchor_text, '$.name') = 'img' THEN -- if json name is img
                        CASE
                            WHEN json_extract(anchor_text, '$.attributes.alt') IS NOT NULL AND json_extract(anchor_text, '$.attributes.alt') <> '' THEN json_extract(anchor_text, '$.attributes.alt')
                            ELSE
                            '[No Title]' -- if attribute.alt not present
                            END
                    WHEN json_extract(anchor_text, '$.name') = 'span' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                            CASE
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                            END
                        ELSE
                            'Not object'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'table' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                            CASE
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                            END
                        ELSE
                            'Not object'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'strong' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
                        ELSE
                            '[No Title]'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'u' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
                        ELSE
                            '[No Title]'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'b' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children[0]') IS NOT NULL AND json_extract(anchor_text, '$.children[0]') <> '' THEN json_extract(anchor_text, '$.children[0]')
                        ELSE
                            '[No Title]'
                        END
                    WHEN json_extract(anchor_text, '$.name') = 'mark' THEN
                        CASE
                            WHEN json_extract(anchor_text, '$.children') NOT NULL THEN
                            CASE
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 0 THEN json_extract(anchor_text, '$.children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 1 THEN json_extract(anchor_text, '$.children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 2 THEN json_extract(anchor_text, '$.children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 3 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 4 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 5 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 6 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 7 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 8 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                                WHEN text_count(json_extract(anchor_text, '$.children[0]'), 'children') = 9 THEN json_extract(anchor_text, '$.children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0].children[0]')
                            END
                        ELSE
                            'Not object'
                        END
                    ELSE 'not added'
                END AS url_text
            FROM
                ur_transform_html_email_anchor_subscription_filter_chached
            WHERE
                json_valid(anchor_text) -- Only select rows with valid JSON
                AND json_type(anchor_text) = 'object' AND parent.anchor = anchor AND parent.uniform_resource_transform_id=uniform_resource_transform_id
                AND parent.uniform_resource_transform_id=uniform_resource_transform_id)
        ELSE
            (SELECT
                anchor_text
            FROM
                ur_transform_html_email_anchor_subscription_filter_chached
            WHERE
                parent.anchor = anchor AND parent.uniform_resource_transform_id=uniform_resource_transform_id
                AND parent.uniform_resource_transform_id=uniform_resource_transform_id)
        END
        AS url_text
FROM ur_transform_html_email_anchor_subscription_filter_chached as parent WHERE parent.anchor_type NOT NULL;
DROP VIEW IF EXISTS periodicals_from_count;
CREATE VIEW periodicals_from_count AS
SELECT
    COUNT(DISTINCT message_from) AS dashboard_from_count
FROM
    ur_periodical_chached;

DROP VIEW IF EXISTS periodical_filtered_count;
CREATE VIEW periodical_filtered_count AS
SELECT
    COUNT(anchor) AS dashboard_periodical_filtered_count
FROM
    ur_transform_html_email_anchor_cached;

DROP VIEW IF EXISTS anchor_removed_count;
CREATE VIEW anchor_removed_count AS
SELECT
    COUNT(anchor) AS dashboard_anchor_removed_count
FROM
    ur_transform_html_email_anchor_subscription_filter_chached WHERE anchor_type NOT NULL;

DROP VIEW IF EXISTS anchor_total_count;
CREATE VIEW anchor_total_count AS
SELECT
    COUNT(anchor) AS dashboard_anchor_total_count
FROM
    ur_transform_html_email_anchor_subscription_filter_chached;



DROP VIEW IF EXISTS periodicals_from;
CREATE VIEW periodicals_from AS
    SELECT
        pc.message_from, COUNT(pc.message_subject) as subject_count,
        (SELECT
            COUNT(eac.anchor)
        FROM
            ur_transform_html_email_anchor_cached eac
        INNER JOIN ur_periodical_anchor_text_cached lnktxt ON lnktxt.anchor=eac.anchor
        INNER JOIN ur_transform_html_email_anchor_canonical_cached acc ON acc.anchor=eac.anchor WHERE eac.uniform_resource_id=pc.periodical_uniform_resource_id) as periodical_count
    FROM
        ur_periodical_chached pc
    GROUP BY pc.message_from;


DROP VIEW IF EXISTS periodicals_subject;
CREATE VIEW periodicals_subject AS
    SELECT
    periodical_uniform_resource_id,
    message_from,
    message_to,
    message_subject,
    message_date
    FROM
        ur_periodical_chached;


DROP VIEW IF EXISTS periodical_anchor;
CREATE VIEW periodical_anchor AS
    SELECT
        eac.uniform_resource_id,
        eac.uniform_resource_transform_id,
        eac.anchor as orginal_url,
        acc.canonical_link,
        lnktxt.url_text
    FROM
        ur_transform_html_email_anchor_cached eac
    INNER JOIN ur_periodical_anchor_text_cached lnktxt ON lnktxt.anchor=eac.anchor
    INNER JOIN ur_transform_html_email_anchor_canonical_cached acc ON acc.anchor=eac.anchor;


DROP VIEW IF EXISTS removed_anchor_list;
CREATE VIEW removed_anchor_list AS
    SELECT
        rmlst.uniform_resource_id,
        rmlst.anchor,
        rmlst.anchor_type,
        rmtxt.url_text
    FROM
        ur_transform_html_email_anchor_subscription_filter_chached rmlst
        INNER JOIN ur_removed_anchor_text_cached rmtxt ON rmtxt.uniform_resource_id=rmlst.uniform_resource_id AND rmtxt.uniform_resource_transform_id=rmlst.uniform_resource_transform_id
                AND rmlst.anchor=rmlst.anchor
        WHERE rmlst.anchor_type NOT NULL;


-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.
-- select 'test' into absolute_url;
DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS

SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    'console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    'console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    tbl.sql as sql_ddl
FROM sqlite_master tbl
JOIN pragma_table_info(tbl.name) col
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with view-specific information
DROP VIEW IF EXISTS console_information_schema_view;
CREATE VIEW console_information_schema_view AS
SELECT
    vw.name AS view_name,
    col.name AS column_name,
    col.type AS data_type,
    '/console/info-schema/view.sql?name=' || vw.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    vw.sql as sql_ddl
FROM sqlite_master vw
JOIN pragma_table_info(vw.name) col
WHERE vw.type = 'view' AND vw.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS console_content_tabular;
CREATE VIEW console_content_tabular AS
  SELECT 'table' as tabular_nature,
         table_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_table
  UNION ALL
  SELECT 'view' as tabular_nature,
         view_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_view;

-- Populate the table with table column foreign keys
DROP VIEW IF EXISTS console_information_schema_table_col_fkey;
CREATE VIEW console_information_schema_table_col_fkey AS
SELECT
    tbl.name AS table_name,
    f."from" AS column_name,
    f."from" || ' references ' || f."table" || '.' || f."to" AS foreign_key
FROM sqlite_master tbl
JOIN pragma_foreign_key_list(tbl.name) f
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with table column indexes
DROP VIEW IF EXISTS console_information_schema_table_col_index;
CREATE VIEW console_information_schema_table_col_index AS
SELECT
    tbl.name AS table_name,
    pi.name AS column_name,
    idx.name AS index_name
FROM sqlite_master tbl
JOIN pragma_index_list(tbl.name) idx
JOIN pragma_index_info(idx.name) pi
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Drop and create the table for storing navigation entries
-- for testing only: DROP TABLE IF EXISTS sqlpage_aide_navigation;
CREATE TABLE IF NOT EXISTS sqlpage_aide_navigation (
    path TEXT NOT NULL, -- the "primary key" within namespace
    caption TEXT NOT NULL, -- for human-friendly general-purpose name
    namespace TEXT NOT NULL, -- if more than one navigation tree is required
    parent_path TEXT, -- for defining hierarchy
    sibling_order INTEGER, -- orders children within their parent(s)
    url TEXT, -- for supplying links, if different from path
    title TEXT, -- for full titles when elaboration is required, default to caption if NULL
    abbreviated_caption TEXT, -- for breadcrumbs and other "short" form, default to caption if NULL
    description TEXT, -- for elaboration or explanation
    elaboration TEXT, -- optional attributes for e.g. { "target": "__blank" }
    -- TODO: figure out why Rusqlite does not allow this but sqlite3 does
    -- CONSTRAINT fk_parent_path FOREIGN KEY (namespace, parent_path) REFERENCES sqlpage_aide_navigation(namespace, path),
    CONSTRAINT unq_ns_path UNIQUE (namespace, parent_path, path)
);
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'index.sql';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', NULL, 1, 'index.sql', 'index.sql', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)', NULL),
    ('prime', 'index.sql', 999, 'console/index.sql', 'console/index.sql', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files', NULL),
    ('prime', 'console/index.sql', 1, 'console/info-schema/index.sql', 'console/info-schema/index.sql', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/index.sql', 'console/sqlpage-files/index.sql', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/content.sql', 'console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-nav/index.sql', 'console/sqlpage-nav/index.sql', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table', NULL),
    ('prime', 'console/index.sql', 2, 'console/notebooks/index.sql', 'console/notebooks/index.sql', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks', NULL),
    ('prime', 'console/index.sql', 2, 'console/migrations/index.sql', 'console/migrations/index.sql', 'RSSD Lifecycle (migrations)', 'Migrations', NULL, 'Explore RSSD Migrations to determine what was executed and not', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;

INSERT OR REPLACE INTO code_notebook_cell (notebook_kernel_id, code_notebook_cell_id, notebook_name, cell_name, interpretable_code, interpretable_code_hash, description) VALUES (
  'SQL',
  'web-ui.auto_generate_console_content_tabular_sqlpage_files',
  'Web UI',
  'auto_generate_console_content_tabular_sqlpage_files',
  '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows',
  'TODO',
  'A series of idempotent INSERT statements which will auto-generate "default" content for all tables and views'
);
      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in '*.auto.sql' with redirects
      DELETE FROM sqlpage_files WHERE path like 'console/content/table/%.auto.sql';
      DELETE FROM sqlpage_files WHERE path like 'console/content/view/%.auto.sql';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql',
            'SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

              SELECT ''breadcrumb'' AS component;
              SELECT ''Home'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
              SELECT ''Console'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console'' AS link;
              SELECT ''Content'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content'' AS link;
              SELECT ''' || tabular_name  || ' ' || tabular_nature || ''' as title, ''#'' AS link;

              SELECT ''title'' AS component, ''' || tabular_name || ' (' || tabular_nature || ') Content'' as contents;

              SET total_rows = (SELECT COUNT(*) FROM ' || tabular_name || ');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''text'' AS component, ''' || info_schema_link_full_md || ''' AS contents_md
              SELECT ''text'' AS component,
                ''- Start Row: '' || $offset || ''
'' ||
                ''- Rows per Page: '' || $limit || ''
'' ||
                ''- Total Rows: '' || $total_rows || ''
'' ||
                ''- Current Page: '' || $current_page || ''
'' ||
                ''- Total Pages: '' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''table'' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM ' || tabular_name || '
            LIMIT $limit
            OFFSET $offset;

            SELECT ''text'' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
                ''(Page '' || $current_page || '' of '' || $total_pages || '') '' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
                AS contents_md;'
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.sql',
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like 'ur%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'ur/index.sql', 'ur/index.sql', 'Uniform Resource', NULL, NULL, 'Explore ingested resources', NULL),
    ('prime', 'ur/index.sql', 99, 'ur/info-schema.sql', 'ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-files.sql', 'ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-imap-account.sql', 'ur/uniform-resource-imap-account.sql', 'Uniform Resources (IMAP)', NULL, NULL, 'Easily access and view your emails with our Uniform Resource (IMAP) system. Ingested from various mail sources, this feature organizes and displays your messages directly in the Web UI, ensuring all your communications are available in one convenient place.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
DROP VIEW IF EXISTS uniform_resource_file;
CREATE VIEW uniform_resource_file AS
  SELECT ur.uniform_resource_id,
         ur.nature,
         p.root_path AS source_path,
         pe.file_path_rel,
         ur.size_bytes
  FROM uniform_resource ur
  LEFT JOIN uniform_resource_edge ure ON ur.uniform_resource_id = ure.uniform_resource_id AND ure.nature = 'ingest_fs_path'
  LEFT JOIN ur_ingest_session_fs_path p ON ure.node_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id;

  DROP VIEW IF EXISTS uniform_resource_imap;
  CREATE VIEW uniform_resource_imap AS
  SELECT
      ur.uniform_resource_id,
      graph.name,
      iac.ur_ingest_session_imap_account_id,
      iac.email,
      iac.host,
      iacm.subject,
      iacm."from",
      iacm.message,
      iacm.date,
      iaf.ur_ingest_session_imap_acct_folder_id,
      iaf.ingest_account_id,
      iaf.folder_name,
      ur.size_bytes,
      ur.nature,
      ur.content
  FROM uniform_resource ur
  INNER JOIN uniform_resource_edge edge ON edge.uniform_resource_id=ur.uniform_resource_id
  INNER JOIN uniform_resource_graph graph ON graph.name=edge.graph_name
  INNER JOIN ur_ingest_session_imap_acct_folder_message iacm ON iacm.ur_ingest_session_imap_acct_folder_message_id = edge.node_id
  INNER JOIN ur_ingest_session_imap_acct_folder iaf ON iacm.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
  LEFT JOIN ur_ingest_session_imap_account iac ON iac.ur_ingest_session_imap_account_id = iaf.ingest_account_id
  WHERE ur.nature = 'text' AND graph.name='imap' AND ur.ingest_session_imap_acct_folder_message IS NOT NULL;

  DROP VIEW IF EXISTS uniform_resource_imap_content;
  CREATE  VIEW uniform_resource_imap_content AS
  SELECT
      uri.uniform_resource_id,
      base_ur.uniform_resource_id baseID,
      ext_ur.uniform_resource_id extID,
      base_ur.uri as base_uri,
      ext_ur.uri as ext_uri,
      base_ur.nature as base_nature,
      ext_ur.nature as ext_nature,
      json_extract(part.value, '$.body.Html') AS html_content
  FROM
      uniform_resource_imap uri
  INNER JOIN uniform_resource base_ur ON base_ur.uniform_resource_id=uri.uniform_resource_id
  INNER JOIN uniform_resource ext_ur ON ext_ur.uri = base_ur.uri ||'/json' AND ext_ur.nature = 'json',
  json_each(ext_ur.content, '$.parts') AS part
  WHERE ext_ur.nature = 'json' AND html_content NOT NULL;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats" AS
    WITH Summary AS (
        SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_fs_path_entry.file_extn, '') AS file_extension,
            ur_ingest_session_fs_path.ur_ingest_session_fs_path_id as ingest_session_fs_path_id,
            ur_ingest_session_fs_path.root_path AS ingest_session_root_fs_path,
            COUNT(ur_ingest_session_fs_path_entry.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_fs_path ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_fs_path.ingest_session_id
        LEFT JOIN
            ur_ingest_session_fs_path_entry ON ur_ingest_session_fs_path.ur_ingest_session_fs_path_id = ur_ingest_session_fs_path_entry.ingest_fs_path_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_fs_path_entry.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_fs_path_entry.file_extn,
            ur_ingest_session_fs_path.root_path
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        file_extension,
        ingest_session_fs_path_id,
        ingest_session_root_fs_path,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        file_extension;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_files_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats" AS
      WITH Summary AS (
          SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_task.ur_status, 'Ok') AS ur_status,
            COALESCE(uniform_resource.nature, 'UNKNOWN') AS nature,
            COUNT(ur_ingest_session_task.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_task ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_task.ingest_session_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_task.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_task.captured_executable
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        ur_status,
        nature,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        ur_status;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_tasks_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_file_issue";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_file_issue" AS
      SELECT us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics
        FROM ur_ingest_session_fs_path_entry ufs
        JOIN ur_ingest_session_fs_path usp ON ufs.ingest_fs_path_id = usp.ur_ingest_session_fs_path_id
        JOIN ur_ingest_session us ON usp.ingest_session_id = us.ur_ingest_session_id
       WHERE ufs.ur_status IS NOT NULL
    GROUP BY us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics;
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'orchestration/index.sql', 'orchestration/index.sql', 'Orchestration', NULL, NULL, 'Explore details about all orchestration', NULL),
    ('prime', 'orchestration/index.sql', 99, 'orchestration/info-schema.sql', 'orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
 DROP VIEW IF EXISTS orchestration_session_by_device;
 CREATE VIEW orchestration_session_by_device AS
 SELECT
     d.device_id,
     d.name AS device_name,
     COUNT(*) AS session_count
 FROM orchestration_session os
 JOIN device d ON os.device_id = d.device_id
 GROUP BY d.device_id, d.name;

 DROP VIEW IF EXISTS orchestration_session_duration;
 CREATE VIEW orchestration_session_duration AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     os.orch_started_at,
     os.orch_finished_at,
     (JULIANDAY(os.orch_finished_at) - JULIANDAY(os.orch_started_at)) * 24 * 60 * 60 AS duration_seconds
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 WHERE os.orch_finished_at IS NOT NULL;

 DROP VIEW IF EXISTS orchestration_success_rate;
 CREATE VIEW orchestration_success_rate AS
 SELECT
     onature.nature AS orchestration_nature,
     COUNT(*) AS total_sessions,
     SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS successful_sessions,
     (CAST(SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_state oss ON os.orchestration_session_id = oss.session_id
 WHERE oss.to_state IN ('surveilr_orch_completed', 'surveilr_orch_failed') -- Consider other terminal states if applicable
 GROUP BY onature.nature;

 DROP VIEW IF EXISTS orchestration_session_script;
 CREATE VIEW orchestration_session_script AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     COUNT(*) AS script_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_entry ose ON os.orchestration_session_id = ose.session_id
 GROUP BY os.orchestration_session_id, onature.nature;

 DROP VIEW IF EXISTS orchestration_executions_by_type;
 CREATE VIEW orchestration_executions_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS execution_count
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_execution_success_rate_by_type;
 CREATE VIEW orchestration_execution_success_rate_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS total_executions,
     SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS successful_executions,
     (CAST(SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_session_summary;
 CREATE VIEW orchestration_session_summary AS
 SELECT
     issue_type,
     COUNT(*) AS issue_count
 FROM orchestration_session_issue
 GROUP BY issue_type;

 DROP VIEW IF EXISTS orchestration_issue_remediation;
 CREATE VIEW orchestration_issue_remediation AS
 SELECT
     orchestration_session_issue_id,
     issue_type,
     issue_message,
     remediation
 FROM orchestration_session_issue
 WHERE remediation IS NOT NULL;

DROP VIEW IF EXISTS orchestration_logs_by_session;
 CREATE VIEW orchestration_logs_by_session AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     osl.category,
     COUNT(*) AS log_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_exec ose ON os.orchestration_session_id = ose.session_id
 JOIN orchestration_session_log osl ON ose.orchestration_session_exec_id = osl.parent_exec_id
 GROUP BY os.orchestration_session_id, onature.nature, osl.category;
-- delete all /cak-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE parent_path='cak'||'/index.sql';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'cak/index.sql', 'cak/index.sql', 'Content Assembler', NULL, NULL, 'The Content Assembler
    harnesses pre-curated content from influencers, curators,
     and authoritative sources, collecting, de-duplicating, and
     scoring valuable links shared across platforms like email,
      Twitter, and LinkedIn for reuse in B2B and community channels in Surveilr.', NULL),
    ('prime', 'cak/index.sql', 1, 'cak/periodicals.sql', 'cak/periodicals.sql', 'Periodicals', NULL, NULL, 'The Source List page provides a streamlined view of all collected content sources. This page displays only the origins of the content, such as sender information for email sources, making it easy to see where each piece of content came from. Use this list to quickly review and identify the various sources contributing to the curated content collection.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Content Assembler",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/content-assembler-favicon.ico",
  "image": "https://www.surveilr.com/assets/brand/content-assembler-icon.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "index.sql",
  "menu_item": [
    {
      "link": "index.sql",
      "title": "Home"
    }
  ],
  "javascript": [
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT ''shell'' AS component,
       ''Content Assembler'' AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/content-assembler-favicon.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/content-assembler-icon.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''/docs/index.sql'',
              ''title'', ''Docs'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/docs/index.sql/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''ur/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''console/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''orchestration/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), 2) || '')'' as footer;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''list'' AS component;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''console''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''console''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Tables'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || table_name || ''](table.sql?name='' || table_name || '')'' AS "Table",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_table
GROUP BY table_name;

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || view_name || ''](view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_view
GROUP BY view_name;

SELECT ''title'' AS component, ''Migrations'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT from_state, to_state, transition_reason, transitioned_at
FROM code_notebook_state
ORDER BY transitioned_at;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/table.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' Table'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type",
    is_primary_key AS "PK",
    is_not_null AS "Required",
    default_value AS "Default"
FROM console_information_schema_table
WHERE table_name = $name;

SELECT ''title'' AS component, ''Foreign Keys'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    foreign_key AS "Foreign Key"
FROM console_information_schema_table_col_fkey
WHERE table_name = $name;

SELECT ''title'' AS component, ''Indexes'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    index_name AS "Index Name"
FROM console_information_schema_table_col_index
WHERE table_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/view.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type"
FROM console_information_schema_view
WHERE view_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;     
   SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
   LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/sqlpage-file.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
      SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $path || '' Path'' AS title, ''#'' AS link;

      SELECT ''title'' AS component, $path AS contents;
      SELECT ''text'' AS component,
             ''```sql
'' || (select contents FROM sqlpage_files where path = $path) || ''
```'' as contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/content.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql'' || '')
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;  
      SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '')[📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%''
      AND NOT(path like ''console/content/%.auto.sql'')
      AND NOT(path like ''console/content/action%'')
ORDER BY path;

SELECT ''title'' AS component, ''Auto-generated "default" content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
    SELECT
      ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
  
  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%.auto.sql''
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/content/action/regenerate-auto.sql',
      '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || $redirect as link WHERE $redirect is NOT NULL;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-nav/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-nav/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage navigation in sqlpage_aide_navigation table'' AS contents;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT path, caption, description FROM sqlpage_aide_navigation ORDER BY namespace, parent_path, path, sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
    ''['' || c.cell_name || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' || 
    replace(c.notebook_name, '' '', ''%20'') || 
    ''&cell='' || 
    replace(c.cell_name, '' '', ''%20'') || 
    '')'' AS "Cell",      
     c.description,
       k.kernel_name as kernel
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT 
    ''foldable'' as component;
SELECT 
    ''RSSD Lifecycle(Migration) Documentation'' as title,
    ''
This document provides an organized and comprehensive overview of ``surveilr``''''s RSSD migration process starting from ``v 1.0.0``, breaking down each component and the steps followed to ensure smooth and efficient migrations. It covers the creation of key tables and views, the handling of migration cells, and the sequence for executing migration scripts.

---

## Session and State Initialization

To manage temporary session data and track user state, we use the ``session_state_ephemeral`` table, which stores essential session information like the current user. This table is temporary, meaning it only persists data for the duration of the session, and it''''s especially useful for identifying the user responsible for specific actions during the migration.

Each time the migration process runs, we initialize session data in this table, ensuring all necessary information is available without affecting the core database tables. This initialization prepares the system for more advanced operations that rely on knowing the user executing each action.

---

## Assurance Schema Table

The ``assurance_schema`` table is designed to store various schema-related details, including the type of schema assurance, associated codes, and related governance data. This table is central to defining the structure of assurance records, which are useful for validating data, tracking governance requirements, and recording creation timestamps. All updates to the schema are logged to track when they were last modified and by whom.

---

## Code Notebook Kernel, Cell, and State Tables

``surveilr`` uses a structured system of code notebooks to store and execute SQL commands. These commands, or “cells,” are grouped into notebooks, and each notebook is associated with a kernel, which provides metadata about the notebook''''s language and structure. The main tables involved here are:

- **``code_notebook_kernel``**: Stores information about different kernels, each representing a unique execution environment or language.
- **``code_notebook_cell``**: Holds individual code cells within each notebook, along with their associated metadata and execution history.
- **``code_notebook_state``**: Tracks each cell''''s state changes, such as when it was last executed and any errors encountered.

By organizing migration scripts into cells and notebooks, ``surveilr`` can maintain detailed control over execution order and track the state of each cell individually. This tracking is essential for handling updates, as it allows us to execute migrations only when necessary.

---

## Views for Managing Cell Versions and Migrations

Several views are defined to simplify and organize the migration process by managing different versions of code cells and identifying migration candidates. These views help filter, sort, and retrieve the cells that need execution.

### Key Views

- **``code_notebook_cell_versions``**: Lists all available versions of each cell, allowing the migration tool to retrieve older versions if needed for rollback or auditing.
- **``code_notebook_cell_latest``**: Shows only the latest version of each cell, simplifying the migration by focusing on the most recent updates.
- **``code_notebook_sql_cell_migratable``**: Filters cells to include only those that are eligible for migration, ensuring that non-executable cells are ignored.

---

## Migration-Oriented Views and Dynamic Migration Scripts

To streamline the migration process, several migration-oriented views organize the data by listing cells that require execution or are ready for re-execution. By grouping these cells in specific views, ``surveilr`` dynamically generates a script that executes only the necessary cells.

### Key Views

- **``code_notebook_sql_cell_migratable_not_executed``**: Lists migratable cells that haven’t yet been executed.
- **``code_notebook_sql_cell_migratable_state``**: Shows the latest migratable cells, along with their current state transitions.

---

## How Migrations Are Executed

When it''''s time to apply changes to the database, this section explains the process in detail, focusing on how ``surveilr`` prepares the environment, identifies which cells to migrate, executes the appropriate SQL code, and ensures data integrity throughout.

---

### 1. Initialization

The first step in the migration process involves setting up the essential database tables and seeding initial values. This lays the foundation for the migration process, making sure that all tables, views, and temporary values needed are in place.

- **Check for Core Tables**: ``surveilr`` first verifies whether the required tables, such as ``code_notebook_cell``, ``code_notebook_state``, and others starting with ``code_notebook%``, are already set up in the database. 
- **Setup**: If these tables do not yet exist, ``surveilr`` automatically initiates the setup by running the initial SQL script, known as ``bootstrap.sql``. This script contains SQL commands that create all the essential tables and views discussed in previous sections. 
- **Seeding**: During the execution of ``bootstrap.sql``, essential data, such as temporary values in the ``session_state_ephemeral`` table (e.g., information about the current user), is also added to ensure that the migration session has the data it needs to proceed smoothly.

---

### 2. Migration Preparation and Identification of Cells to Execute

Once the environment is ready, ``surveilr`` examines which specific cells (code blocks in the migration notebook) need to be executed to bring the database up to the latest version.

- **Listing Eligible Cells**: ``surveilr`` begins by consulting views such as ``code_notebook_sql_cell_migratable_not_executed``. This view is a pre-filtered list of cells that are eligible for migration but haven’t yet been executed.
- **Idempotent vs. Non-Idempotent Cells**: ``surveilr`` then checks whether each cell is marked as “idempotent” or “non-idempotent.” 
   - **Idempotent Cells** can be executed multiple times without adverse effects. If they have been run before, they can safely be run again without impacting data integrity.
   - **Non-Idempotent Cells**, identified by names containing ``_once_``, should only be executed once. If these cells have been executed previously, they are skipped in the migration process to prevent unintentional re-runs.

---

### 3. Dynamic Script Generation and Execution

``surveilr`` then assembles a custom SQL script that includes only the cells identified as eligible for execution. This script is crafted carefully to ensure each cell''''s SQL code is executed in the correct order and with the right contextual information.

- **Script Creation**: We start by generating a dynamic script in a single transaction block. Transactions are a way of grouping a series of commands so that they are either all applied or none are, which protects data integrity.
- **Inclusion of Cells Based on Eligibility**:
   - For each cell, ``surveilr`` checks its eligibility status. If it''''s non-idempotent and already executed, it''''s marked with a comment noting that it''''s excluded from the script due to previous execution.
   - If the cell is idempotent or eligible for re-execution, its SQL code is added to the script, along with additional details such as comments about the cell''''s last execution date.
- **State Transition Records**: After each cell''''s SQL code, additional commands are added to record the cell''''s transition state. This step inserts information into ``code_notebook_state``, logging details such as the cell ID, transition state (from “Pending” to “Executed”), and the reason for the transition (“Migration” or “Reapplication”). These logs are invaluable for auditing purposes.

---

### 4. Execution in a Transactional Block

With the script prepared, ``surveilr`` then executes the entire batch of SQL commands within a transactional block.

- **BEGIN TRANSACTION**: The script begins with a transaction, ensuring that all changes are applied as a single, atomic unit.
- **Running Cell Code**: Within this transaction, each cell''''s SQL code is executed in the order it appears in the script.
- **Error Handling**: If any step in the transaction fails, all changes are rolled back. This prevents partial updates from occurring, ensuring that the database remains in a consistent state.
- **COMMIT**: If the script executes successfully without errors, the transaction is committed, finalizing the changes. The ``COMMIT`` command signifies the end of the migration session, making all updates permanent.

---

### 5. Finalizing Migration and Recording Results

After a successful migration session, ``surveilr`` concludes by recording details about the migration process.

- **Final Updates to ``code_notebook_state``**: Any cells marked as “Executed” are updated in ``code_notebook_state`` with the latest timestamp, indicating their successful migration.
- **Logging Completion**: Activity logs are updated with relevant details, ensuring a clear record of the migration.
- **Cleanup of Temporary Data**: Finally, temporary data is cleared, such as entries in ``session_state_ephemeral``, since these values were only needed during the migration process.
    '' as description_md;


SELECT ''title'' AS component, ''Pending Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_not_executed lists all cells eligible for migration but not yet executed. 
    If migrations have been completed successfully, this list will be empty, 
    indicating that all migratable cells have been processed and marked as executed.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT 
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp
FROM 
    code_notebook_sql_cell_migratable_not_executed AS c
ORDER BY 
    c.cell_name;
    
-- State of Executed Migrations
SELECT ''title'' AS component, ''State of Executed Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_state displays all cells that have been successfully executed as part of the migration process, 
    showing the latest version of each migratable cell. 
    For each cell, it provides details on its transition states, 
    the reason and result of the migration, and the timestamp of when the migration occurred.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT 
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp,
    c.from_state,
    c.to_state,
    c.transition_reason,
    c.transition_result,
    c.transitioned_at
FROM 
    code_notebook_sql_cell_migratable_state AS c
ORDER BY 
    c.cell_name;


-- Executable Migrations
SELECT ''title'' AS component, ''Executable Migrations'' AS contents;
SELECT ''text'' AS component, ''All cells that are candidates for migration (including duplicates)'' as contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT 
        c.code_notebook_cell_id,
        c.notebook_name,
        c.cell_name,
        ''['' || c.cell_name || ''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
        c.interpretable_code_hash,
        c.is_idempotent,
        c.version_timestamp
    FROM 
        code_notebook_sql_cell_migratable_version AS c
    ORDER BY 
        c.cell_name;

-- All Migrations
SELECT ''button'' as component;
SELECT 
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks'' as link,
    ''See all notebook entries'' as title;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''ur''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''ur''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
  SELECT ''table'' AS component,
  ''Name'' AS markdown,
    ''Column Count'' as align_right,
    TRUE as sort,
    TRUE as search;

SELECT
''Table'' as "Type",
  ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_table
  WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
  GROUP BY table_name

  UNION ALL

SELECT
''View'' as "Type",
  ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_view
  WHERE view_name like ''ur_%''
  GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-files.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-files.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-files.sql/index.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small;
SELECT * FROM uniform_resource_file ORDER BY uniform_resource_id
   LIMIT $limit
  OFFSET $offset;

  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-account.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-imap-account.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-imap-account.sql/index.sql'') as contents;
    ;

select
  ''title''   as component,
  ''Mailbox'' as contents;
-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''email'' AS markdown;
SELECT    
''['' || email || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id || '')'' AS "email"
      FROM uniform_resource_imap
      GROUP BY ur_ingest_session_imap_account_id
      ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-folder.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

                SELECT ''breadcrumb'' as component;
SELECT
   ''Home'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT
  ''Uniform Resource'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' as link;
SELECT
  ''Folder'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || $imap_account_id:: TEXT as link;
SELECT
  ''title'' as component,
  (SELECT email FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT) as contents;

--Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''folder'' AS markdown;
  SELECT ''['' || folder_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id || '')'' AS "folder"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_account_id = $imap_account_id:: TEXT
    GROUP BY ur_ingest_session_imap_acct_folder_id
    ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''
SELECT
  ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
  ''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id=''|| ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  ''title''   as component,
  (SELECT email || '' ('' || folder_name || '')''  FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT) as contents;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_imap );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''subject'' AS markdown;;
SELECT
''['' || subject || ''](uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id || '')'' AS "subject"
  , "from",
  CASE
      WHEN ROUND(julianday(''now'') - julianday(date)) = 0 THEN ''Today''
      WHEN ROUND(julianday(''now'') - julianday(date)) = 1 THEN ''1 day ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 30 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 365 THEN CAST(ROUND((julianday(''now'') - julianday(date)) / 30) AS INT) || '' months ago''
      ELSE CAST(ROUND((julianday(''now'') - julianday(date)) / 365) AS INT) || '' years ago''
  END AS "Relative Time",
  strftime(''%Y-%m-%d'', substr(date, 1, 19)) as date
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
  ORDER BY uniform_resource_id
  LIMIT $limit
  OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&folder_id='' || $folder_id ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&folder_id='' || $folder_id ||  '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
SELECT
 ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' AS link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id=$resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   subject AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Breadcrumb ends-- -

  --- back button-- -
    select ''button'' as component;
select
"<< Back" as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id as link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Display uniform_resource table with pagination
  SELECT
''datagrid'' as component;
SELECT
''From'' as title,
  "from" as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''To'' as title,
  email as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''Subject'' as title,
  subject as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;

  SELECT ''html'' AS component;
  SELECT html_content AS html FROM uniform_resource_imap_content WHERE uniform_resource_id=$resource_id::TEXT ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''orchestration''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''orchestration''||''/index.sql''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
     ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
     ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'cak/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''cak/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              select
    ''text''              as component,
    ''The Content Assembler provides access to a centralized repository of content across various platforms, such as email and Twitter. The "Periodicals" link navigates to a section where all content subjects, including periodical updates, can be viewed and managed.'' as contents;
  WITH navigation_cte AS (
      SELECT COALESCE(title, caption) as title, description
        FROM sqlpage_aide_navigation
       WHERE namespace = ''prime'' AND path = ''cak''||''/index.sql''
  )
  SELECT ''list'' AS component, title, description
    FROM navigation_cte;
  SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND parent_path = ''cak''||''/index.sql''
   ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'cak/periodicals.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''cak/periodicals.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''cak/periodicals.sql/index.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
SET total_rows = (SELECT COUNT(*) FROM periodicals_from );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

 select
  ''text''              as component,
  ''The Source List page provides a streamlined view of all collected content sources. This page displays only the origins of the content, such as sender information for email sources, making it easy to see where each piece of content came from. Use this list to quickly review and identify the various sources contributing to the curated content collection.'' as contents;

-- Dashboard count
select
    ''card'' as component,
    4      as columns;
select
    ''Total Mail Inbox''  as title,
    ''## ''||dashboard_from_count||'' ##'' as description_md,
    TRUE                  as active,
    ''mail-pin''       as icon
FROM periodicals_from_count;
select
    ''Filtered periodicals''  as title,
    ''## ''||dashboard_periodical_filtered_count||'' ##'' as description_md,
    TRUE                  as active,
    ''filter''       as icon,
    ''green''           as color
FROM periodical_filtered_count;
select
    ''Removed Anchors''  as title,
    ''## ''||dashboard_anchor_removed_count||'' ##'' as description_md,
    TRUE                  as active,
    ''trash-x''       as icon,
    ''danger''           as color
FROM anchor_removed_count;
select
    ''Total Anchors''  as title,
    ''## ''||dashboard_anchor_total_count||'' ##'' as description_md,
    TRUE                  as active,
    ''link''       as icon,
    ''warning''           as color
FROM anchor_total_count;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
      ''subject'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search,
      ''from'' AS markdown;

 SELECT
    ''['' || message_from || ''](''|| sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals_subject.sql?message_from='' || message_from || '')'' AS "from",
    subject_count as "subject count",
    periodical_count as "periodical count"
    FROM periodicals_from
    LIMIT $limit
  OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'cak/periodicals_subject.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              --- Display breadcrumb
 SELECT
    ''breadcrumb'' AS component;
  SELECT
    ''Home'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
  SELECT
    ''Content Assembler'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/index.sql'' AS link;
  SELECT
    ''Periodicals'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals.sql'' AS link;
  SELECT $message_from AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals_subject.sql?message_from=''|| $message_from  AS link;

  --- Dsply Page Title
  SELECT
      ''title''   as component,
      ''Periodicals From '' || $message_from as contents;

  --- Dsply Page Description
   SELECT
''text'' AS component,
''The Source Details page offers an in-depth view of content collected from a specific sender. Here, you''''ll find a list of messages from this source, including each message''''s subject, sender, recipient, and send date. This organized layout helps you explore all communications from this source in one place, making it easy to review and track relevant content by date and topic.'' AS contents;

   -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM periodicals_subject WHERE message_from=$message_from);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

  -- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search,
      ''subject'' AS markdown,
      ''removed links'' AS markdown;

  SELECT
    ''['' || message_subject || ''](''|| sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodical_anchor.sql?periodical_uniform_resource_id=''  || periodical_uniform_resource_id || '')'' AS "subject",
    ''[ View](''|| sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodical_removed_anchor.sql?periodical_uniform_resource_id='' || periodical_uniform_resource_id || '') ('' ||
      (SELECT
        count(anchor)
      FROM
        removed_anchor_list
      WHERE
        uniform_resource_id = periodical_uniform_resource_id) || '')''
      as "removed links",
    message_from as "from",
    message_to as "to",
     CASE
      WHEN ROUND(julianday(''now'') - julianday(message_date)) = 0 THEN ''Today''
      WHEN ROUND(julianday(''now'') - julianday(message_date)) = 1 THEN ''1 day ago''
      WHEN ROUND(julianday(''now'') - julianday(message_date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday(''now'') - julianday(message_date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(message_date)) < 30 THEN CAST(ROUND(julianday(''now'') - julianday(message_date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(message_date)) < 365 THEN CAST(ROUND((julianday(''now'') - julianday(message_date)) / 30) AS INT) || '' months ago''
      ELSE CAST(ROUND((julianday(''now'') - julianday(message_date)) / 365) AS INT) || '' years ago''
  END AS "Relative Time"
  FROM periodicals_subject
  WHERE message_from=$message_from::TEXT
  LIMIT $limit
  OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&message_from='' || $message_from ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&message_from='' || $message_from ||  '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'cak/periodical_anchor.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
--- Display breadcrumb
 SELECT
    ''breadcrumb'' AS component;
  SELECT
    ''Home'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
  SELECT
    ''Content Assembler'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/index.sql'' AS link;
  SELECT
    ''Periodicals'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals.sql'' AS link;
  SELECT message_from AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals_subject.sql?message_from=''|| message_from  AS link FROM periodicals_subject WHERE periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

  SELECT
    message_subject as title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodical_anchor.sql?periodical_uniform_resource_id=''|| periodical_uniform_resource_id AS link
  FROM
    periodicals_subject
  WHERE
    periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

--- Dsply Page Title
  SELECT
    ''title'' as component,
    message_subject as contents
  FROM
    periodicals_subject
  WHERE
    periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;


select
''text''              as component,
''The Newsletter Link Details page provides a comprehensive list of URLs shared within a specific newsletter. For each entry, you’ll find the original URL as it appeared in the newsletter, the link text, and the canonical URL (standardized for consistent reference). This page also includes key metadata for each link, such as title, description, and any additional structured data, allowing for an in-depth look at the content and context of each link. This organized view makes it easy to analyze and manage all linked resources from the newsletter.'' as contents;

 SELECT ''table'' AS component,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search,
      ''canonical link'' AS markdown,
      ''meta data'' AS markdown,
      ''original link url'' AS markdown;
  SELECT
    ''['' || url_text || ''](''|| orginal_url ||'')''   AS "original link url",
    canonical_link as ''canonical link'',
    ''[ Meta Data ](''|| sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals_meta.sql?url='' || orginal_url || '')'' AS "meta data"
  FROM
    periodical_anchor
  WHERE
    uniform_resource_id = $periodical_uniform_resource_id::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'cak/periodicals_meta.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
--- Display breadcrumb
 SELECT
    ''breadcrumb'' AS component;
  SELECT
    ''Home'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
  SELECT
    ''Content Assembler'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/index.sql'' AS link;
  SELECT
    ''Periodicals'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals.sql'' AS link;
  SELECT
        ps.message_from AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals_subject.sql?message_from=''|| ps.message_from AS link
        FROM
          periodicals_subject ps
        INNER JOIN periodical_anchor pa ON pa.uniform_resource_id = ps.periodical_uniform_resource_id
        WHERE
          pa.orginal_url = $url::TEXT;

  SELECT
    ps.message_subject as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodical_anchor.sql?periodical_uniform_resource_id='' || ps.periodical_uniform_resource_id AS link
  FROM
    periodicals_subject ps
  INNER JOIN periodical_anchor pa ON pa.uniform_resource_id = ps.periodical_uniform_resource_id
  WHERE
    pa.orginal_url = $url::TEXT;

  SELECT
    ''Meta Data'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals_meta.sql?url=''|| $url AS link;

--- Dsply Page Title
  SELECT
      ''title''   as component,
      ''Meta Data (''|| ps.message_subject || '')''  as contents
      FROM periodicals_subject ps
      INNER JOIN periodical_anchor pa ON pa.uniform_resource_id = ps.periodical_uniform_resource_id
      WHERE pa.orginal_url = $url::TEXT;

select
''text''              as component,
''The Link Metadata Viewer page offers a detailed look at the metadata and Open Graph properties of each newsletter link. For every link, this page displays essential metadata fields like title, description, and keywords, as well as Open Graph data such as images, type, and URL, providing a rich context for the content. This structured view allows you to easily understand the attributes and presentation of each link, making it an invaluable tool for analyzing and curating high-quality, shareable content from newsletters.'' as contents;

 SELECT ''table'' AS component,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
  SELECT
    property_name as property,
    content
  FROM
    ur_transform_html_email_anchor_meta_cached
  WHERE
    anchor = $url::TEXT AND property_name IS NOT NULL;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'cak/periodical_removed_anchor.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
--- Display breadcrumb
 SELECT
    ''breadcrumb'' AS component;
  SELECT
    ''Home'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''   AS link;
  SELECT
    ''Content Assembler'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/index.sql'' AS link;
  SELECT
    ''Periodicals'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals.sql'' AS link;
  SELECT message_from AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodicals_subject.sql?message_from=''|| message_from  AS link FROM periodicals_subject WHERE periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

  SELECT
    message_subject as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/cak/periodical_removed_anchor.sql?periodical_uniform_resource_id=''|| periodical_uniform_resource_id AS link
  FROM
    periodicals_subject
  WHERE
    periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

--- Dsply Page Title
  SELECT
    ''title'' as component,
    message_subject as contents
  FROM
    periodicals_subject
  WHERE
    periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;


select
''text''              as component,
''This feature removes links from newsletters that are related to subscription management. It checks for links containing keywords such as unsubscribe, opt-out, preferences, remove, manage, subscription, subscribe, email-settings, list-unsubscribe, mailto, or #main. These links allow recipients to modify or manage their email preferences and subscriptions.'' as contents;

 SELECT ''table'' AS component,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
  SELECT
    anchor  AS "original link url",
    url_text as ''url text''
  FROM
    removed_anchor_list
  WHERE
    uniform_resource_id = $periodical_uniform_resource_id::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
