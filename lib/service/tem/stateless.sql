-- This query extracts unique asset names from the `uniform_resource` table for URIs under `/var/`.
-- It breaks down each URI into its path segments and applies the following rules:
--   1. Identifies the base asset folder (e.g., ".session", "dnsx", "tls").
--   2. Handles timestamp-like directories (e.g., "2025-09-06-01-53-35") by skipping them and using the next segment.
--   3. Returns only distinct assets by grouping on the extracted asset name.
--   4. Selects one representative URI (the lexicographically smallest via MIN(uri)) for each unique asset.
--
-- The result provides a deduplicated list of assets with a sample URI for each.
DROP VIEW IF EXISTS list_eaa_asset;
CREATE VIEW list_eaa_asset AS 
WITH parts AS (
  SELECT
    uri,
    -- remove query/fragments, trim slashes, then split into a JSON array of segments
    '["' || REPLACE(
      TRIM(
        substr(uri, 1,
          CASE
            WHEN instr(uri, '?') > 0 THEN instr(uri, '?') - 1
            WHEN instr(uri, '#') > 0 THEN instr(uri, '#') - 1
            ELSE length(uri)
          END
        ), '/'
      ),
    '/', '","') || '"]' AS j
  FROM uniform_resource
  WHERE uri LIKE '%eaa%'
),
assets AS (
  SELECT
    uri,
    j,
    json_array_length(j) AS len,
    json_extract(j, '$[' || (json_array_length(j) - 1) || ']') AS last_seg,
    json_extract(j, '$[' || (json_array_length(j) - 2) || ']') AS penult_seg
  FROM parts
)
SELECT
  CASE
    -- if the last segment looks like a file (has a dot), take the previous segment (the folder)
    WHEN len >= 2 AND last_seg GLOB '*.*' THEN penult_seg
    ELSE last_seg
  END AS asset,
  MIN(uri) AS uri
FROM assets
WHERE asset IS NOT NULL
GROUP BY asset
ORDER BY asset;


-- This query extracts individual JSON-like segments enclosed in square brackets (e.g., [ ... ])
-- from the `content` field of the `uniform_resource` table. It:
-- 1. Cleans carriage returns and newlines from the content.
-- 2. Recursively splits the content based on the '][' delimiter.
-- 3. Returns each segment as a separate row along with its associated
--    `ingest_session_id` and `uri`.
-- The query filters rows where:
--   - `nature` is "json"
--   - `uri` matches the pattern "%whatweb/https___qa-sec-adminapp.pocn.com_443.json%"
DROP VIEW IF EXISTS list_what_web_data_json;
CREATE VIEW list_what_web_data_json AS
WITH cleaned AS (
  SELECT
    uniform_resource_id,
    uri,
    TRIM(REPLACE(REPLACE(content, char(13), ''), char(10), '')) AS c
  FROM uniform_resource
  WHERE nature = 'json'
    AND uri LIKE '%whatweb/%'
    AND content LIKE '[%' -- ensure it starts with [
)
SELECT
  c.uniform_resource_id,
  c.uri,
  json_each.value AS object
FROM cleaned c,
json_each(c.c)
WHERE json_valid(c.c) = 1;

-- Description:
-- This view extracts key web metadata from JSON objects stored in 
-- `list_what_web_data_json`.
DROP VIEW IF EXISTS list_what_web_data;
CREATE VIEW list_what_web_data AS
SELECT
    uniform_resource_id,
    json_extract(object, '$.target') AS target_url,
    json_extract(object, '$.http_status') AS http_status,
    json_extract(object, '$.plugins.IP.string[0]') AS ip_address,
    json_extract(object, '$.plugins.HTTPServer.string[0]') AS http_server,
    json_extract(object, '$.plugins.Title.string[0]') AS page_title,
    json_extract(object, '$.plugins.UncommonHeaders.string[0]') AS uncommon_headers,
    json_extract(object, '$.plugins.Country.string[0]') AS country,
    json_extract(object, '$.plugins.Country.module[0]') AS module,
    json_extract(object, '$.plugins.Strict-Transport-Security.string[0]') AS strict_transport_security,
    json_extract(object, '$.plugins.X-Frame-Options.string[0]') AS x_frame_options
FROM list_what_web_data_json;

-- View: list_dnsx_data
-- This view extracts DNS resolution details from the `uniform_resource` table for records
-- collected via DNSx scans. It filters JSONL data (`nature = 'jsonl'`) where the URI path
-- includes '/dnsx/'. Extracted fields include hostnames, TTL values, resolvers, IP addresses,
-- status codes, and timestamps.
DROP VIEW IF EXISTS list_dnsx_data;
CREATE VIEW list_dnsx_data AS
SELECT
    uniform_resource_id,
    json_extract(content, '$.host') AS host,
    json_extract(content, '$.ttl') AS ttl,
    json_extract(content, '$.resolver[0]') AS resolver,
    json_extract(content, '$.a[0]') AS ip_address,
    json_extract(content, '$.status_code') AS status_code,
    json_extract(content, '$.timestamp') AS timestamp
FROM uniform_resource
WHERE nature = 'jsonl'
  AND uri LIKE '%/dnsx/%';

-- View: list_nuclei_data
-- Purpose: Extracts essential fields from Nuclei scan JSONL data stored in the uniform_resource table.
-- Includes host, URL, template details, description, severity, IP, matched path, and timestamp.
-- Filters only JSONL records under URIs containing "/nuclei/".
DROP VIEW IF EXISTS list_nuclei_data;
CREATE VIEW list_nuclei_data AS
SELECT
  json_extract(content, '$.host') AS host,
  json_extract(content, '$.url') AS url,
  json_extract(content, '$.template-id') AS template_id,
  json_extract(content, '$.info.name') AS name,
  json_extract(content, '$.info.description') AS description,
  json_extract(content, '$.info.severity') AS severity,
  json_extract(content, '$.ip') AS ip,
  json_extract(content, '$.meta.paths') AS matched_path,
  json_extract(content, '$.timestamp') AS timestamp
FROM uniform_resource
WHERE nature = 'jsonl' AND uri LIKE '%/nuclei/%';