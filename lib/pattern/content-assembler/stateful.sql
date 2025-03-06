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
    ABS(RANDOM()) AS anchor_id,
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
    anchor_id,
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
    anchor_id,
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


-- TO DO: http_method currently done is temporary

DROP TABLE IF EXISTS ur_transform_html_email_anchor_http_cached;
CREATE TABLE ur_transform_html_email_anchor_http_cached AS
SELECT
        uniform_resource_transform_id,
        uniform_resource_id,
        anchor,
        http_timeout_set(7200000),
        http_get_body(anchor) as html_body
    FROM ur_transform_html_email_anchor_cached LIMIT 50;

-- DROP TABLE IF EXISTS ur_transform_html_email_anchor_http_cached;
-- CREATE TABLE ur_transform_html_email_anchor_http_cached AS
-- SELECT
--         uniform_resource_transform_id,
--         uniform_resource_id,
--         anchor,
--         "<html><body>Check</body></html>" as html_body
--     FROM ur_transform_html_email_anchor_cached;

-- DROP TABLE IF EXISTS ur_transform_http_url_status_cached;
CREATE TABLE IF NOT EXISTS ur_transform_http_url_status_cached (
        uniform_resource_transform_id TEXT,
        uniform_resource_id TEXT,
        url TEXT,
        html_body BLOB,
        response_status_code INTEGER,
        response_status TEXT,
        message TEXT,
        status TEXT
    );
    

-- DROP TABLE IF EXISTS ur_transform_html_email_anchor_http_cached;
-- CREATE TABLE ur_transform_html_email_anchor_http_cached AS
-- SELECT
--         uniform_resource_transform_id,
--         uniform_resource_id,
--         url as anchor,
--         html_body
--     FROM ur_transform_http_url_status_cached WHERE status='Success';

-- DROP TABLE IF EXISTS ur_transform_html_email_anchor_http_cached;
-- CREATE TABLE ur_transform_html_email_anchor_http_cached AS
-- SELECT
--         uniform_resource_transform_id,
--         uniform_resource_id,
--         anchor,
--         html_body
--     FROM ur_transform_html_email_anchor_cached;

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
    anchor_id,
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
    parent.anchor_id,
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
                AND json_type(anchor_text) = 'object' AND parent.anchor_id = anchor_id)
        ELSE
            (SELECT
                anchor_text
            FROM
                ur_transform_html_email_anchor_cached
            WHERE
                parent.anchor_id = anchor_id)
        END
        AS url_text
FROM ur_transform_html_email_anchor_cached as parent;


DROP TABLE IF EXISTS test_text;
CREATE TABLE test_text AS
SELECT
    parent.anchor_id,
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
                AND json_type(anchor_text) = 'object' AND parent.anchor_id = anchor_id)
        ELSE
            (SELECT
                anchor_text
            FROM
                ur_transform_html_email_anchor_cached
            WHERE
                parent.anchor_id = anchor_id)
        END
        AS url_text
FROM ur_transform_html_email_anchor_cached as parent;

DROP TABLE IF EXISTS ur_removed_anchor_text_cached;
CREATE TABLE ur_removed_anchor_text_cached AS
SELECT
    parent.anchor_id,
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
                AND json_type(anchor_text) = 'object' AND parent.anchor = anchor AND parent.anchor_id=anchor_id)
        ELSE
            (SELECT
                anchor_text
            FROM
                ur_transform_html_email_anchor_subscription_filter_chached
            WHERE
                parent.anchor = anchor AND parent.anchor_id=anchor_id)
        END
        AS url_text
FROM ur_transform_html_email_anchor_subscription_filter_chached as parent WHERE parent.anchor_type NOT NULL;