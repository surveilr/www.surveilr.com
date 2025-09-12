-- The `tem_tenant` view represents tenants within TEM.
-- Each record is derived from the `organization` table.
-- - `organization_id` keeps the unique identifier of the organization.
-- - `party_id` is exposed as `tenant_id`.
-- - `name` is exposed as `tanent_name` (tenant’s display name).
DROP VIEW IF EXISTS tem_tenant;
CREATE VIEW tem_tenant AS
SELECT
  organization_id,
  party_id AS tenant_id,
  name AS tanent_name
FROM organization;

-- This query extracts unique asset names from the `uniform_resource` table for URIs under `/var/`.
-- It breaks down each URI into its path segments and applies the following rules:
--   1. Identifies the base asset folder (e.g., ".session", "dnsx", "tls").
--   2. Handles timestamp-like directories (e.g., "2025-09-06-01-53-35") by skipping them and using the next segment.
--   3. Returns only distinct assets by grouping on the extracted asset name.
--   4. Selects one representative URI (the lexicographically smallest via MIN(uri)) for each unique asset.
--
-- The result provides a deduplicated list of assets with a sample URI for each.
DROP VIEW IF EXISTS tem_eaa_asset_uri;
CREATE VIEW tem_eaa_asset_uri AS 
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
DROP VIEW IF EXISTS tem_what_web_result_original_json;
CREATE VIEW tem_what_web_result_original_json AS
WITH cleaned AS (
  SELECT
    ur.uniform_resource_id,
    ur.uri,
    dpr.party_id,
    TRIM(REPLACE(REPLACE(content, char(13), ''), char(10), '')) AS c
  FROM uniform_resource ur
  INNER JOIN device_party_relationship dpr ON dpr.device_id=ur.device_id
  WHERE nature = 'json'
    AND uri LIKE '%whatweb/%'
    AND content LIKE '[%' -- ensure it starts with [
)
SELECT
  c.uniform_resource_id,
  c.party_id AS tenant_id,
  c.uri,
  json_each.value AS object
FROM cleaned c,
json_each(c.c)
WHERE json_valid(c.c) = 1;

-- Description:
-- This view extracts key web metadata from JSON objects stored in 
-- `tem_what_web_result`.
DROP VIEW IF EXISTS tem_what_web_result;
CREATE VIEW tem_what_web_result AS
SELECT
    uniform_resource_id,
    tenant_id,
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
FROM tem_what_web_result_original_json;

-- View: tem_dnsx_result
-- This view extracts DNS resolution details from the `uniform_resource` table for records
-- collected via DNSx scans. It filters JSONL data (`nature = 'jsonl'`) where the URI path
-- includes '/tem_dnsx_result/'. Extracted fields include hostnames, TTL values, resolvers, IP addresses,
-- status codes, and timestamps.
DROP VIEW IF EXISTS tem_dnsx_result;
CREATE VIEW tem_dnsx_result AS
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

-- View: tem_nuclei_result
-- Purpose: Extracts essential fields from Nuclei scan JSONL data stored in the uniform_resource table.
-- Includes host, URL, template details, description, severity, IP, matched path, and timestamp.
-- Filters only JSONL records under URIs containing "/nuclei/".
DROP VIEW IF EXISTS tem_nuclei_result;
CREATE VIEW tem_nuclei_result AS
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

-- View: tem_naabu_result
-- Purpose:
--   This view extracts and normalizes Naabu scan results stored as JSONL
--   in the 'uniform_resource' table. It helps visualize open ports and
--   related network information discovered during port scanning.
DROP VIEW IF EXISTS tem_naabu_result;
CREATE VIEW tem_naabu_result AS
SELECT
  json_extract(content, '$.host') AS host,
  json_extract(content, '$.ip') AS ip,
  json_extract(content, '$.timestamp') AS timestamp,
  json_extract(content, '$.port') AS port,
  json_extract(content, '$.protocol') AS protocol,
  json_extract(content, '$.tls') AS tls
FROM uniform_resource
WHERE nature = 'jsonl' AND uri LIKE '%/naabu/%';

-- View: tem_subfinder
-- Purpose: Normalize subfinder JSON results stored in uniform_resource.content 
-- into structured columns. Extracts domain (input), discovered host (raw_records), 
-- and source, along with metadata such as ingest timestamp and tool name. 
-- Filters rows where uri indicates ingestion from subfinder.
DROP VIEW IF EXISTS tem_subfinder;
CREATE VIEW tem_subfinder AS
SELECT
    ur.uniform_resource_id,
    ur.device_id,
    ur.ingest_session_id,
    ur.uri,
    json_extract(ur.content, '$.input')   AS domain,
    json_extract(ur.content, '$.host')    AS raw_records,
    json_extract(ur.content, '$.source')  AS source,
    ur.created_at                         AS ingest_timestamp,
    'subfinder'                           AS tool_name
FROM uniform_resource ur
WHERE ur.uri LIKE '%subfinder%';

-- View: tem_httpx_result
-- Purpose:
--   Normalize httpx-toolkit JSON results stored in uniform_resource.content
--   into structured columns. Provides details on domains, IPs, URLs,
--   HTTP metadata, response status, and timing. Filters only rows
--   where the uri indicates ingestion from httpx-toolkit.
DROP VIEW IF EXISTS tem_httpx_result;
CREATE VIEW tem_httpx_result AS
SELECT
    ur.uniform_resource_id,
    ur.device_id,
    ur.ingest_session_id,
    ur.uri,
    json_extract(ur.content, '$.input')          AS domain,
    json_extract(ur.content, '$.url')            AS url,
    json_extract(ur.content, '$.scheme')         AS scheme,
    json_extract(ur.content, '$.port')           AS port,
    json_extract(ur.content, '$.a')              AS ip_addresses,
    json_extract(ur.content, '$.status-code')    AS status_code,
    json_extract(ur.content, '$.content-type')   AS content_type,
    json_extract(ur.content, '$.response-time')  AS response_time,
    json_extract(ur.content, '$.method')         AS http_method,
    json_extract(ur.content, '$.host')           AS resolved_host,
    json_extract(ur.content, '$.body-sha256')    AS body_sha256,
    json_extract(ur.content, '$.header-sha256')  AS header_sha256,
    json_extract(ur.content, '$.failed')         AS request_failed,
    ur.created_at                                AS ingest_timestamp,
    'httpx-toolkit'                              AS tool_name
FROM uniform_resource ur
WHERE ur.uri LIKE '%httpx-toolkit%';