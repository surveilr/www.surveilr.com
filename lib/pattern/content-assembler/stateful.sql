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
    END AS anchor_type,
    anchor_text
FROM
    ur_transform_html_flattened_email_anchor_cached;

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

DROP TABLE IF EXISTS ur_periodical_chached;
CREATE TABLE ur_periodical_chached AS
SELECT
    ur_extended.uniform_resource_id AS periodical_uniform_resource_id,
    ur_imap."from" AS message_from,
    ur_imap_account.email AS message_to,
    ur_imap."subject" AS message_subject,
    ur_imap."date" AS message_date,
    ur_base.uniform_resource_id  AS base_uniform_resource_id,
    ur_extended.uri AS extended_uri
FROM
    ur_ingest_session_imap_acct_folder_message ur_imap
LEFT JOIN ur_ingest_session_imap_acct_folder ur_imap_folder ON ur_imap_folder.ur_ingest_session_imap_acct_folder_id = ur_imap.ingest_imap_acct_folder_id
LEFT JOIN ur_ingest_session_imap_account ur_imap_account ON ur_imap_account.ur_ingest_session_imap_account_id = ur_imap_folder.ingest_account_id
JOIN
    uniform_resource ur_base
    -- the `uniform_resource` table is connected to the `ur_ingest_session_imap_acct_folder_message` table through a foreign key
    ON ur_base.ingest_session_imap_acct_folder_message = ur_imap.ur_ingest_session_imap_acct_folder_message_id
JOIN
    uniform_resource ur_extended
    ON ur_extended.uri = ur_base.uri || '/html'
WHERE
    regexp_like(ur_extended.uri,'(?i)/html');


DROP TABLE IF EXISTS ur_transform_html_email_anchor_http_cached;
CREATE TABLE ur_transform_html_email_anchor_http_cached AS
SELECT
        uniform_resource_transform_id,
        uniform_resource_id,
        anchor,
        http_get_body(anchor) as html_body
    FROM ur_transform_html_email_anchor_cached LIMIT 20;

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

DROP TABLE IF EXISTS ur_transform_html_email_anchor_title_cached;
CREATE TABLE ur_transform_html_email_anchor_title_cached AS
SELECT
        eah.uniform_resource_transform_id,
        eah.uniform_resource_id,
        eah.anchor,
        html_text(h.html,'title') as title
    FROM ur_transform_html_email_anchor_http_cached eah,
        html_each(eah.html_body, 'title') AS h;

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


DROP TABLE IF EXISTS ur_periodical_anchor_text_cached;
CREATE TABLE ur_periodical_anchor_text_cached AS
SELECT
    parent.anchor,
    parent.anchor_text,
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