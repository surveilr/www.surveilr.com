-- The `tem_tenant` view represents tenants within TEM.
-- Each record is derived from the `organization` table.
-- - `organization_id` keeps the unique identifier of the organization.
-- - `party_id` is exposed as `tenant_id`.
-- - `name` is exposed as `tanent_name` (tenant’s display name).
DROP VIEW IF EXISTS tem_tenant;
CREATE VIEW tem_tenant AS
SELECT
  org.organization_id,
  org.party_id AS tenant_id,
  dpr.device_id,
  org.name AS tanent_name
FROM organization org INNER JOIN device_party_relationship dpr ON dpr.party_id=org.party_id;

-- View: tem_ur_ingest_session
-- ------------------------------------------------------------
-- This view provides a simplified listing of ingest sessions.
-- It selects the essential session metadata:
--   - ur_ingest_session_id : unique session identifier
--   - device_id            : device on which ingestion ran
--   - session_date         : start time of the ingest session
--   - ingest_finished_at   : end time of the ingest session
--   - session_agent        : JSON describing the ingest agent
--   - behavior_json        : JSON configuration/behavior details
-- Only active (non-deleted) sessions are included.
-- ------------------------------------------------------------
DROP VIEW IF EXISTS tem_session;
CREATE VIEW tem_session AS
SELECT
    ur_ingest_session_id,
    device_id,
    strftime('%m-%d-%Y %H:%M:%S', ingest_started_at) AS session_name,
    strftime('%m-%d-%Y %H:%M:%S', ingest_started_at) AS ingest_started_at,
    strftime('%m-%d-%Y %H:%M:%S', ingest_finished_at) AS ingest_finished_at,
    json_extract(session_agent, '$.agent') AS agent,
    json_extract(session_agent, '$.version') AS version,
    10 AS tools_count
FROM ur_ingest_session
WHERE deleted_at IS NULL;

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
),
clean_assets AS (
  SELECT
    uri,
    CASE
      WHEN len >= 2 AND last_seg GLOB '*.*' THEN penult_seg
      ELSE last_seg
    END AS asset
  FROM assets
)
SELECT
  asset AS asset,
  MIN(uri) AS uri
FROM clean_assets
WHERE asset IS NOT NULL
  -- ignore segments that look like a full timestamp: YYYY-MM-DD-HH-MM-SS
  AND asset NOT GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
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
    uw.uniform_resource_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
    json_extract(uw.object, '$.target') AS target_url,
    json_extract(uw.object, '$.http_status') AS http_status,
    json_extract(uw.object, '$.plugins.IP.string[0]') AS ip_address,
    json_extract(uw.object, '$.plugins.HTTPServer.string[0]') AS http_server,
    json_extract(uw.object, '$.plugins.Title.string[0]') AS page_title,
    json_extract(uw.object, '$.plugins.UncommonHeaders.string[0]') AS uncommon_headers,
    json_extract(uw.object, '$.plugins.Country.string[0]') AS country,
    json_extract(uw.object, '$.plugins.Country.module[0]') AS module,
    json_extract(uw.object, '$.plugins.Strict-Transport-Security.string[0]') AS strict_transport_security,
    json_extract(uw.object, '$.plugins.X-Frame-Options.string[0]') AS x_frame_options
FROM tem_what_web_result_original_json uw
INNER JOIN uniform_resource ur ON ur.uniform_resource_id = uw.uniform_resource_id
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id;

-- View: tem_dnsx_result
-- This view extracts DNS resolution details from the `uniform_resource` table for records
-- collected via DNSx scans. It filters JSONL data (`nature = 'jsonl'`) where the URI path
-- includes '/dnsx/'. Extracted fields include hostnames, TTL values, resolvers, IP addresses,
-- status codes, timestamps, along with tenant information (tenant_id, tanent_name).
DROP VIEW IF EXISTS tem_dnsx_result;
CREATE VIEW tem_dnsx_result AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
    json_extract(ur.content, '$.host') AS host,
    json_extract(ur.content, '$.ttl') AS ttl,
    json_extract(ur.content, '$.resolver[0]') AS resolver,
    json_extract(ur.content, '$.a[0]') AS ip_address,
    json_extract(ur.content, '$.status_code') AS status_code,
    json_extract(ur.content, '$.timestamp') AS timestamp
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
WHERE ur.nature = 'jsonl'
AND ur.uri LIKE '%/dnsx/%';

-- View: tem_nuclei_result
-- Purpose: Extracts essential fields from Nuclei scan JSONL data stored in the uniform_resource table.
-- Includes host, URL, template details, description, severity, IP, matched path, and timestamp.
-- Filters only JSONL records under URIs containing "/nuclei/".
-- Enriched with tenant information (tenant_id, tanent_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_nuclei_result;
CREATE VIEW tem_nuclei_result AS
SELECT
  ur.uniform_resource_id,
  t.tenant_id,
  t.tanent_name,
  ts.ur_ingest_session_id,
  json_extract(ur.content, '$.host') AS host,
  json_extract(ur.content, '$.url') AS url,
  json_extract(ur.content, '$.template-id') AS template_id,
  json_extract(ur.content, '$.info.name') AS name,
  json_extract(ur.content, '$.info.description') AS description,
  json_extract(ur.content, '$.info.severity') AS severity,
  json_extract(ur.content, '$.ip') AS ip,
  json_extract(ur.content, '$.meta.paths') AS matched_path,
  json_extract(ur.content, '$.timestamp') AS timestamp
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
WHERE ur.nature = 'jsonl'
  AND ur.uri LIKE '%/nuclei/%';

-- View: tem_naabu_result
-- Purpose:
--   This view extracts and normalizes Naabu scan results stored as JSONL
--   in the 'uniform_resource' table. It helps visualize open ports and
--   related network information discovered during port scanning.
--   Enriched with tenant information (tenant_id, tanent_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_naabu_result;
CREATE VIEW tem_naabu_result AS
SELECT
  ur.uniform_resource_id,
  t.tenant_id,
  t.tanent_name,
  ts.ur_ingest_session_id,
  json_extract(ur.content, '$.host') AS host,
  json_extract(ur.content, '$.ip') AS ip,
  json_extract(ur.content, '$.timestamp') AS timestamp,
  json_extract(ur.content, '$.port') AS port,
  json_extract(ur.content, '$.protocol') AS protocol,
  json_extract(ur.content, '$.tls') AS tls
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
WHERE ur.nature = 'jsonl'
  AND ur.uri LIKE '%/naabu/%';

-- View: tem_subfinder
-- Purpose: Normalize subfinder JSON results stored in uniform_resource.content 
-- into structured columns. Extracts domain (input), discovered host (raw_records), 
-- and source, along with metadata such as ingest timestamp and tool name. 
-- Filters rows where uri indicates ingestion from subfinder.
-- Enriched with tenant information (tenant_id, tanent_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_subfinder;
CREATE VIEW tem_subfinder AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
    json_extract(ur.content, '$.input')   AS domain,
    json_extract(ur.content, '$.host')    AS raw_records,
    json_extract(ur.content, '$.source')  AS source,
    ur.created_at                         AS ingest_timestamp,
    'subfinder'                           AS tool_name,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
WHERE ur.uri LIKE '%subfinder%';

-- View: tem_httpx_result
-- Purpose:
--   Normalize httpx-toolkit JSON results stored in uniform_resource.content
--   into structured columns. Provides details on domains, IPs, URLs,
--   HTTP metadata, response status, and timing. Filters only rows
--   where the uri indicates ingestion from httpx-toolkit.
--   Enriched with tenant information (tenant_id, tanent_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_httpx_result;
CREATE VIEW tem_httpx_result AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
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
    'httpx-toolkit'                              AS tool_name,
     ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
WHERE ur.uri LIKE '%httpx-toolkit%';


-- View: tem_nmap
-- --------------------------------------------------------------------
-- This view extracts structured Nmap scan data
-- from the JSON stored in uniform_resource_transform.content.
-- It uses SQLite JSON functions (json_extract) to pull out attributes:
--   - host_ip, protocol, port, state
--   - service_name, service_product, service_version, service_extrainfo
-- The tool name ("nmap") is added for identification.
-- NOTE: The JSON structure allows capturing multiple <port> entries.
--       For this view, only the first element of arrays is selected
--       (json_extract with [0]). For full expansion, consider json_each.
-- Enriched with tenant information (tenant_id, tanent_name)
-- via join with tem_tenant.
DROP VIEW IF EXISTS tem_nmap;
CREATE VIEW tem_nmap AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
    json_extract(urt.content, '$.nmaprun.host[0].address.@addr') AS host_ip,
    json_extract(urt.content, '$.nmaprun.host[0].ports.port[0].@protocol') AS protocol,
    json_extract(urt.content, '$.nmaprun.host[0].ports.port[0].@portid') AS port,
    json_extract(urt.content, '$.nmaprun.host[0].ports.port[0].state.@state') AS state,
    json_extract(urt.content, '$.nmaprun.host[0].ports.port[0].service.@name') AS service_name,
    json_extract(urt.content, '$.nmaprun.host[0].ports.port[0].service.@product') AS service_product,
    json_extract(urt.content, '$.nmaprun.host[0].ports.port[0].service.@version') AS service_version,
    json_extract(urt.content, '$.nmaprun.host[0].ports.port[0].service.@extrainfo') AS service_extrainfo,
    'nmap' AS tool_name,
    ur.uri
FROM uniform_resource ur
INNER JOIN uniform_resource_transform urt
       ON ur.uniform_resource_id = urt.uniform_resource_id
INNER JOIN tem_tenant t
       ON t.device_id = ur.device_id
INNER JOIN tem_session ts
       ON ur.device_id = ts.device_id
WHERE ur.uri LIKE '%nmap%'
  AND ur.uri NOT LIKE '%nmap_targets%';

-- View: tem_katana
-- ------------------------------------------------------------
-- This view extracts structured Katana scan results from
-- the raw JSONL stored in uniform_resource.content.
-- Each JSON object is expanded into a row using json_each().
-- 
-- Columns:
--   uniform_resource_id : Reference to the ingested record
--   uri                 : Path of the source JSONL file
--   target              : Extracted URL scanned
--   status              : HTTP status code of the response
--   type                : Content type of the response
--   observed_at         : Timestamp when the scan was observed
--   device_id           : Device on which the scan was ingested
--   ingest_session_id   : Session under which ingestion occurred
--
-- Filter:
--   Includes only rows where uri contains "katana", so it
--   only returns Katana tool results.
DROP VIEW IF EXISTS tem_katana;
CREATE VIEW tem_katana AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
    json_extract(ur.content, '$.timestamp') AS timestamp,
    json_extract(ur.content, '$.request.method') AS method,
    json_extract(ur.content, '$.request.endpoint') AS endpoint,
    json_extract(ur.content, '$.response.status_code') AS status_code
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
WHERE ur.nature = 'jsonl'
AND ur.uri LIKE '%/katana/%';


-- View: tem_tlsx_certificate
-- --------------------------------------------------------------------
-- This view extracts structured TLS certificate metadata
-- from JSONL data ingested by the "tlsx" tool into the
-- uniform_resource table.
--
-- Key Points:
--   - The `content` field stores JSON lines with TLS scan results.
--   - Extracted fields include host, IP, port, TLS version,
--     cipher suite, validity period, subject/issuer details,
--     and certificate fingerprints.
--   - The `uri` field is retained for traceability, so you can
--     locate the exact ingestion path (e.g.,
--     /opt/sessions/2025-09-17-05-38-21/tlsx/tlsx.jsonl#L1).
--   - Only rows with `nature='jsonl'` and `uri LIKE '%tlsx%'`
--     are included in this view.
--
-- Suggested usage:
--   SELECT * FROM tem_tlsx_certificate WHERE ip_address = 'x.x.x.x';
--
-- This view provides a normalized structure for analyzing TLS
-- exposure and certificate metadata discovered during scans.
-- --------------------------------------------------------------------
DROP VIEW IF EXISTS tem_tlsx_certificate;
CREATE VIEW tem_tlsx_certificate AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
    ur.uri,
    json_extract(ur.content, '$.timestamp')                 AS observed_at,
    json_extract(ur.content, '$.host')                      AS host,
    json_extract(ur.content, '$.ip')                        AS ip_address,
    json_extract(ur.content, '$.port')                      AS port,
    json_extract(ur.content, '$.probe_status')              AS probe_status,
    json_extract(ur.content, '$.tls_version')               AS tls_version,
    json_extract(ur.content, '$.cipher')                    AS cipher_suite,
    json_extract(ur.content, '$.self_signed')               AS is_self_signed,
    json_extract(ur.content, '$.mismatched')                AS is_mismatched,
    json_extract(ur.content, '$.not_before')                AS valid_from,
    json_extract(ur.content, '$.not_after')                 AS valid_until,
    json_extract(ur.content, '$.subject_dn')                AS subject_dn,
    json_extract(ur.content, '$.subject_cn')                AS subject_cn,
    json_extract(ur.content, '$.subject_an')                AS subject_alt_names,
    json_extract(ur.content, '$.serial')                    AS serial_number,
    json_extract(ur.content, '$.issuer_dn')                 AS issuer_dn,
    json_extract(ur.content, '$.issuer_cn')                 AS issuer_cn,
    json_extract(ur.content, '$.fingerprint_hash.md5')      AS fingerprint_md5,
    json_extract(ur.content, '$.fingerprint_hash.sha1')     AS fingerprint_sha1,
    json_extract(ur.content, '$.fingerprint_hash.sha256')   AS fingerprint_sha256,
    json_extract(ur.content, '$.tls_connection')            AS tls_connection,
    json_extract(ur.content, '$.sni')                       AS sni
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
WHERE ur.uri LIKE '%tlsx%'
  AND ur.nature = 'jsonl';


-- View: tem_dirsearch
-- -------------------------------------------------------------
-- This view extracts structured results from dirsearch JSON data
-- ingested into the `uniform_resource` table. The raw JSON stored
-- in `uniform_resource.content` is parsed into normalized columns.
--
-- Each row represents one URL result returned by the dirsearch tool.
-- Fields captured include:
--   - status (HTTP status code)
--   - content_type (MIME type of the response)
--   - content_length (size of the response body)
--   - redirect (if any redirection occurred)
--   - url (discovered endpoint)
--
-- The `uri` field contains the ingestion file path
-- (e.g. /opt/sessions/.../dirsearch/dirsearch.json),
-- which also encodes the tool name (`dirsearch`).
--
-- This view filters only JSON-based dirsearch results by applying:
--   WHERE uri LIKE '%dirsearch%' AND nature = 'json'
--
-- Usage:
--   SELECT * FROM tem_dirsearch WHERE ingest_session_id = ?;
-- -------------------------------------------------------------

DROP VIEW IF EXISTS tem_dirsearch;
CREATE VIEW tem_dirsearch AS
SELECT
    ur.uniform_resource_id,
    ur.device_id,
    t.tenant_id,
    t.tanent_name,
    ts.ur_ingest_session_id,
    ur.uri,
    json_extract(ur.content,   '$.info.time')      AS observed_at,
    json_extract(result.value, '$.status')         AS status_code,
    json_extract(result.value, '$.content-type')   AS content_type,
    json_extract(result.value, '$.content-length') AS content_length,
    json_extract(result.value, '$.redirect')       AS redirect_url,
    json_extract(result.value, '$.url')            AS discovered_url
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
     -- Expand `results` array into individual rows
     JOIN json_each(json_extract(ur.content, '$.results')) AS result
WHERE ur.uri LIKE '%dirsearch%'
  AND ur.nature = 'json';
