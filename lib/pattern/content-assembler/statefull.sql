DROP TABLE IF EXISTS ur_transform_html_flattened_email_anchor;
CREATE TABLE ur_transform_html_flattened_email_anchor AS
SELECT
    uniform_resource_transform_id,
    uniform_resource_id,
    json_extract(json_each.value, '$.attributes.href') AS anchor,
    json_extract(json_each.value, '$.children[0]') AS anchor_text
FROM
    uniform_resource_transform,
    json_each(content);


DROP TABLE IF EXISTS ur_transform_html_email_anchor_subscription_filter;
CREATE TABLE ur_transform_html_email_anchor_subscription_filter AS
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
    ur_transform_html_flattened_email_anchor;

DROP TABLE IF EXISTS ur_transform_html_email_anchor;
CREATE TABLE ur_transform_html_email_anchor AS
SELECT
    uniform_resource_transform_id,
    uniform_resource_id,
    anchor,
    anchor_text
FROM
    ur_transform_html_flattened_email_anchor
    WHERE NOT regexp_like(anchor, '(?i)unsubscribe|optout|opt-out|preferences|remove|manage|email-settings|subscription|subscribe|list-unsubscribe|mailto:');