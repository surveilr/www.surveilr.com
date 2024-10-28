DROP TABLE IF EXISTS ur_transform_html_email_anchor;
CREATE TABLE ur_transform_html_email_anchor AS
SELECT
    uniform_resource_transform_id,
    uniform_resource_id,
    json_extract(json_each.value, '$.attributes.href') AS anchor,
    json_extract(json_each.value, '$.children[0]') AS text
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
        WHEN regexp_like(anchor, '(?i)optout') THEN 'optout'
        WHEN regexp_like(anchor, '(?i)unsubscribe') THEN 'unsubscribe'
    END AS type,
    text
FROM
    ur_transform_html_email_anchor;