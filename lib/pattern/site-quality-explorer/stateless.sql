
DROP VIEW IF EXISTS site_quality_control;
CREATE VIEW site_quality_control AS
SELECT
  uniform_resource_id,
  uri,
  json_extract(frontmatter, '$.site-quality-control-id') AS site_quality_control_id,
  json_extract(frontmatter, '$.name') AS name,
  json_extract(frontmatter, '$.fii') AS fii,
  TRIM(
    SUBSTR(
      json_extract(content_fm_body_attrs, '$.body'),
      INSTR(json_extract(content_fm_body_attrs, '$.body'), '\n') + 1
    )
  ) AS description
FROM
  uniform_resource
WHERE
  uri LIKE '%control.md';

DROP VIEW IF EXISTS site_quality_policy;
CREATE VIEW site_quality_policy AS
SELECT
  uniform_resource_id,
  uri,
  json_extract(frontmatter, '$.site-quality-control-id') AS site_quality_control_id,
  json_extract(frontmatter, '$.name') AS name,
  json_extract(frontmatter, '$.description') AS description,
  json_extract(frontmatter, '$.property-name') AS property_name,
  json_extract(frontmatter, '$.impact') AS impact,
  json_extract(frontmatter, '$.suggested-solution') AS suggested_solution,
  TRIM(
    SUBSTR(
      json_extract(content_fm_body_attrs, '$.body'),
      INSTR(json_extract(content_fm_body_attrs, '$.body'), '\n') + 1
    )
  ) AS requirement
FROM
  uniform_resource
WHERE
  uri NOT LIKE '%control.md' AND uri LIKE '%site-quality-explorer/content/site-quality-controls%';

DROP VIEW IF EXISTS uniform_resource_website;
CREATE VIEW uniform_resource_website AS
SELECT DISTINCT
    SUBSTR(
        ur.uri,
        INSTR(ur.uri, 'site-quality-explorer/content/website-resources/') + LENGTH('site-quality-explorer/content/website-resources/'),
        INSTR(SUBSTR(ur.uri, INSTR(ur.uri, 'site-quality-explorer/content/website-resources/') + LENGTH('site-quality-explorer/content/website-resources/')), '/') - 1
    ) AS hostname,
    MAX(CASE WHEN urogc.property_name = 'og:title' THEN urogc.content END) AS title,
    MAX(CASE WHEN urogc.property_name = 'og:description' THEN urogc.content END) AS description
FROM
    uniform_resource ur
LEFT JOIN
    uniform_resource_open_graph_cached urogc ON ur.uri = urogc.uri
WHERE
    ur.uri LIKE '%site-quality-explorer/content/website-resources/%' AND ur.uri NOT LIKE '%.md%'
GROUP BY
    hostname;

DROP VIEW IF EXISTS uniform_resource_image;
CREATE VIEW IF NOT EXISTS uniform_resource_image AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'img', 'src') AS src,  -- Directly gets src attribute
  html_attr_get(h.html, 'img', 'alt') AS alt,  -- Directly gets alt attribute
  h.html                                       -- Full HTML of the img element
FROM
  uniform_resource AS u,
  html_each(u.content, 'img') AS h;

DROP VIEW IF EXISTS uniform_resource_link;
CREATE VIEW IF NOT EXISTS uniform_resource_link AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'a', 'href') AS href,
  h.text,
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'a') AS h;

DROP VIEW IF EXISTS uniform_resource_text_element;
CREATE VIEW IF NOT EXISTS uniform_resource_text_element AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  substr(h.html, 2, instr(h.html, '>') - 2) AS tag,  -- Extracts the tag name
  h.text,                                            -- Text content of the element
  h.html                                             -- Full HTML of the element
FROM
  uniform_resource AS u,
  html_each(u.content, '*') AS h
WHERE
  substr(h.html, 2, instr(h.html, '>') - 2) IN ('p', 'li', 'span', 'h1', 'h2', 'h3');

DROP VIEW IF EXISTS uniform_resource_open_graph;
CREATE VIEW IF NOT EXISTS uniform_resource_open_graph AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'meta', 'property') AS property_name,   -- Extracts the Open Graph property name
  html_attr_get(h.html, 'meta', 'content') AS content,          -- Extracts the content of the property
  h.html AS html                                                -- Full HTML of the meta tag
FROM
  uniform_resource AS u,
  html_each(u.content, 'meta') AS h
WHERE
  html_attr_get(h.html, 'meta', 'property') LIKE 'og:%'          -- Filters for Open Graph properties
  AND html_attr_get(h.html, 'meta', 'content') IS NOT NULL AND u.uri LIKE '%.html%';

DROP VIEW IF EXISTS uniform_resource_html_meta_data;
CREATE VIEW uniform_resource_html_meta_data AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  'title' AS property_name,  -- Explicitly set property_name to 'title'
  html_text(u.content, 'title') AS content,  -- Extract content of the <title> tag
  html_extract(u.content,'title') AS html
FROM
  uniform_resource AS u WHERE u.uri LIKE '%.html%'
UNION ALL
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'meta', 'name') AS property_name,
  html_attr_get(h.html, 'meta', 'content') AS content,
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'meta') AS h
WHERE
  -- Exclude Open Graph, Twitter Cards, etc.
  html_attr_get(h.html, 'meta', 'name') NOT LIKE 'og:%'
  AND html_attr_get(h.html, 'meta', 'name') NOT LIKE 'twitter:%'
  AND html_attr_get(h.html, 'meta', 'name') NOT LIKE 'fb:%'
  AND html_attr_get(h.html, 'meta', 'name') NOT LIKE 'DC.%'
  AND html_attr_get(h.html, 'meta', 'name') NOT LIKE 'apple-%'
  AND html_attr_get(h.html, 'meta', 'name') NOT LIKE 'schema.org'
  AND html_attr_get(h.html, 'meta', 'name') NOT LIKE 'pinterest%'
  AND html_attr_get(h.html, 'meta', 'name') NOT LIKE 'linkedin%'
  AND u.uri LIKE '%.html%';

DROP VIEW IF EXISTS uniform_resource_twitter_card;
CREATE VIEW uniform_resource_twitter_card AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'meta', 'name') AS property_name,
  html_attr_get(h.html, 'meta', 'content') AS content,
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'meta[name^="twitter:"]') AS h
  WHERE u.uri LIKE '%.html%';

DROP VIEW IF EXISTS uniform_resource_facebook_app;
CREATE VIEW uniform_resource_facebook_app AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'meta', 'property') AS property_name,
  html_attr_get(h.html, 'meta', 'content') AS content,
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'meta[property^="fb:"]') AS h
  WHERE u.uri LIKE '%.html%';

DROP VIEW IF EXISTS uniform_resource_dublin_core;
CREATE VIEW uniform_resource_dublin_core AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'meta', 'name') AS property_name,
  html_attr_get(h.html, 'meta', 'content') AS content,
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'meta[name^="DC."]') AS h
  WHERE u.uri LIKE '%.html%';

DROP VIEW IF EXISTS uniform_resource_schema_org;
CREATE VIEW uniform_resource_schema_org AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  'schema.org' AS property_name,
  h.html AS content,  -- Full JSON-LD content
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'script[type="application/ld+json"]') AS h;

DROP VIEW IF EXISTS uniform_resource_apple;
CREATE VIEW uniform_resource_apple AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'meta', 'name') AS property_name,
  html_attr_get(h.html, 'meta', 'content') AS content,
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'meta[name^="apple-"]') AS h
  WHERE u.uri LIKE '%.html%';

DROP VIEW IF EXISTS uniform_resource_social_media;
CREATE VIEW uniform_resource_social_media AS
SELECT
  u.uniform_resource_id AS uniform_resource_id,
  u.uri,
  html_attr_get(h.html, 'meta', 'name') AS property_name,
  html_attr_get(h.html, 'meta', 'content') AS content,
  h.html
FROM
  uniform_resource AS u,
  html_each(u.content, 'meta[name^="pinterest"], meta[name^="linkedin"]') AS h
  WHERE u.uri LIKE '%.html%';

DROP VIEW IF EXISTS uniform_resource_uri_missing_open_graph;
CREATE VIEW uniform_resource_uri_missing_open_graph AS
WITH required_properties AS (
  SELECT 'og:title' AS property_name
  UNION ALL SELECT 'og:description'
  UNION ALL SELECT 'og:image'
  UNION ALL SELECT 'og:url'
  -- You can add more properties as needed
)
SELECT DISTINCT
  SUBSTR(u.uri, INSTR(u.uri, 'site-quality-explorer/content/website-resources/') + LENGTH('site-quality-explorer/content/website-resources/')) AS uri,
  rp.property_name
FROM
  uniform_resource AS u
  CROSS JOIN required_properties AS rp
LEFT JOIN
  (SELECT uniform_resource_id, property_name,content FROM uniform_resource_open_graph_cached) AS og
  ON u.uniform_resource_id = og.uniform_resource_id
  AND rp.property_name = og.property_name
WHERE
  u.uri LIKE '%.html%' AND (og.property_name IS NULL OR og.content IS NULL);

DROP VIEW IF EXISTS uniform_resource_uri_missing_html_meta_data;
CREATE VIEW uniform_resource_uri_missing_html_meta_data AS
WITH required_properties AS (
  SELECT 'description' AS property_name
  UNION ALL SELECT 'keywords'
  UNION ALL SELECT 'author'
  UNION ALL SELECT 'robots'
  UNION ALL SELECT 'viewport'
  UNION ALL SELECT 'title'
  -- You can add more required meta properties as needed
)
SELECT DISTINCT
 SUBSTR(u.uri, INSTR(u.uri, 'site-quality-explorer/content/website-resources/') + LENGTH('site-quality-explorer/content/website-resources/')) AS uri,
 rp.property_name
FROM
  uniform_resource AS u
  CROSS JOIN required_properties AS rp
LEFT JOIN
  (SELECT uniform_resource_id, property_name,content FROM uniform_resource_html_meta_data_cached) AS hmd
  ON u.uniform_resource_id = hmd.uniform_resource_id
  AND rp.property_name = hmd.property_name
WHERE
  u.uri LIKE '%.html%' AND (hmd.property_name IS NULL OR hmd.content IS NULL);

DROP VIEW IF EXISTS uniform_resource_uri_missing_twitter_card;
CREATE VIEW uniform_resource_uri_missing_twitter_card AS
WITH required_properties AS (
  SELECT 'twitter:card' AS property_name
  UNION ALL SELECT 'twitter:title'
  UNION ALL SELECT 'twitter:description'
  UNION ALL SELECT 'twitter:image'
  -- You can add more properties as needed
)
SELECT DISTINCT
  SUBSTR(u.uri, INSTR(u.uri, 'site-quality-explorer/content/website-resources/') + LENGTH('site-quality-explorer/content/website-resources/')) AS uri,
  rp.property_name
FROM
  uniform_resource AS u
  CROSS JOIN required_properties AS rp
LEFT JOIN
  (SELECT uniform_resource_id, property_name,content FROM uniform_resource_twitter_card_cached) AS tc
  ON u.uniform_resource_id = tc.uniform_resource_id
  AND rp.property_name = tc.property_name
WHERE
  u.uri LIKE '%.html%' AND (tc.property_name IS NULL OR tc.content IS NULL);

DROP VIEW IF EXISTS uniform_resource_uri_missing_meta_info;
CREATE VIEW uniform_resource_uri_missing_meta_info AS
SELECT * FROM uniform_resource_uri_missing_open_graph
UNION ALL
SELECT * FROM uniform_resource_uri_missing_html_meta_data
UNION ALL
SELECT * FROM uniform_resource_uri_missing_twitter_card;

