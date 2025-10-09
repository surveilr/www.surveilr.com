-- The `tem_tenant` view represents tenants within TEM.
-- Each record is derived from the `organization` table.
-- - `organization_id` keeps the unique identifier of the organization.
-- - `party_id` is exposed as `tenant_id`.
-- - `name` is exposed as `tenant_name` (tenant’s display name).
DROP VIEW IF EXISTS tem_tenant;
CREATE VIEW tem_tenant AS
SELECT
  org.organization_id,
  org.party_id AS tenant_id,
  dpr.device_id,
  org.name AS tenant_name
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
    json_extract(session_agent, '$.version') AS version
FROM ur_ingest_session
WHERE deleted_at IS NULL;

-- ===============================================================
-- View: tem_session_finding_link
--
-- Purpose:
--   Consolidates all session-based scan/tool results in TEM
--   for display on the Findings page.
--   Includes tool name, redirect URL, session ID, session name,
--   and count of findings per tool.
-- ===============================================================

DROP VIEW IF EXISTS tem_session_finding_link;
CREATE VIEW tem_session_finding_link AS
SELECT
    'What web data' AS tool_name,
    '/tem/session/what_web.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_what_web_result WHERE ur_ingest_session_id = s.ur_ingest_session_id) AS count
FROM tem_session s

UNION ALL
SELECT
    'DNSX Scan Results',
    '/tem/session/dnsx.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_dnsx_result WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'Nuclei Scan Findings',
    '/tem/session/nuclei.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_nuclei_result WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'Naabu Port Scan Results',
    '/tem/session/naabu.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_naabu_result WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'Subfinder Results',
    '/tem/session/subfinder.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_subfinder WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'HTTPX Toolkit Results',
    '/tem/session/httpx-toolkit.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_httpx_result WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'Nmap Scan Results',
    '/tem/session/nmap.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_nmap WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'Katana Scan Results',
    '/tem/session/katana.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_katana WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'TLS Certificate Results',
    '/tem/session/tlsx_certificate.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_tlsx_certificate WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'Dirsearch Web Path Enumeration Results',
    '/tem/session/dirsearch.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_dirsearch WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'TestSSL Report',
    '/tem/session/tssl_certificate.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_testssl_general WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'SSL/TLS Certificate Metadata',
    '/tem/session/openssl.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_openssl WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s

UNION ALL
SELECT
    'WAF Detection Results',
    '/tem/session/wafw00f.sql?session_id=' || ur_ingest_session_id AS redirect_url,
    ur_ingest_session_id,
    session_name,
    (SELECT COUNT(*) FROM tem_wafw00f WHERE ur_ingest_session_id = s.ur_ingest_session_id)
FROM tem_session s;


-- ===============================================================
-- View: tem_tenant_finding_link
--
-- Purpose:
--   Consolidates all tenant-based scan/tool results in TEM
--   for display on the Findings page.
--   Includes tool name, redirect URL, tenant ID, tenant name,
--   and count of findings per tool.
--
-- Notes:
--   - The 'redirect_url' column is used to generate clickable links
--     in the UI.
--   - Additional tools can be added by appending new SELECT blocks
--     with UNION ALL.
-- ===============================================================

DROP VIEW IF EXISTS tem_tenant_finding_link;
CREATE VIEW tem_tenant_finding_link AS
SELECT
    'What web data' AS tool_name,
    '/tem/tenant/what_web.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_what_web_result WHERE tenant_id = t.tenant_id) AS count
FROM tem_tenant t

UNION ALL
SELECT
    'DNSX Scan Results',
    '/tem/tenant/dnsx.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_dnsx_result WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'Nuclei Scan Findings',
    '/tem/tenant/nuclei.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_nuclei_result WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'Naabu Port Scan Results',
    '/tem/tenant/naabu.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_naabu_result WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'Subfinder Results',
    '/tem/tenant/subfinder.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_subfinder WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'HTTPX Toolkit Results',
    '/tem/tenant/httpx-toolkit.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_httpx_result WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'Nmap Scan Results',
    '/tem/tenant/nmap.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_nmap WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'Katana Scan Results',
    '/tem/tenant/katana.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_katana WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'TLS Certificate Results',
    '/tem/tenant/tlsx_certificate.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_tlsx_certificate WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'Dirsearch Web Path Enumeration Results',
    '/tem/tenant/dirsearch.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_dirsearch WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'TestSSL Report',
    '/tem/tenant/tssl_certificate.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_testssl_general WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'SSL/TLS Certificate Metadata',
    '/tem/tenant/openssl.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_openssl WHERE tenant_id = t.tenant_id)
FROM tem_tenant t

UNION ALL
SELECT
    'WAF Detection Results',
    '/tem/tenant/wafw00f.sql?tenant_id=' || tenant_id AS redirect_url,
    tenant_id,
    tenant_name,
    (SELECT COUNT(*) FROM tem_wafw00f WHERE tenant_id = t.tenant_id)
FROM tem_tenant t;


-- View: tem_task_summary
-- Purpose: Extracts all task-related records from the uniform_resource table.
-- Includes the full Markdown content along with frontmatter fields: task ID, title, and status.
-- Filters only records where the URI contains "/task/".
-- Designed to provide a single source for listing tasks and rendering task details in the TEM module.

DROP VIEW IF EXISTS tem_task_summary;
CREATE VIEW tem_task_summary AS
SELECT
    uniform_resource_id,
    uri,
    content,  -- full Markdown content
    json_extract(frontmatter, '$.id') AS task_id,
    json_extract(frontmatter, '$.title') AS title,
    json_extract(frontmatter, '$.status') AS status,
    json_extract(frontmatter, '$.created_date') AS created_date,
    json_extract(frontmatter, '$.updated_date') AS updated_date,
    json_extract(frontmatter, '$.priority') AS priority
FROM uniform_resource
WHERE uri LIKE '%task%';


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
    t.tenant_name,
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
-- status codes, timestamps, along with tenant information (tenant_id, tenant_name).
DROP VIEW IF EXISTS tem_dnsx_result;
CREATE VIEW tem_dnsx_result AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
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
-- Enriched with tenant information (tenant_id, tenant_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_nuclei_result;
CREATE VIEW tem_nuclei_result AS
SELECT
  ur.uniform_resource_id,
  t.tenant_id,
  t.tenant_name,
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
--   Enriched with tenant information (tenant_id, tenant_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_naabu_result;
CREATE VIEW tem_naabu_result AS
SELECT
  ur.uniform_resource_id,
  t.tenant_id,
  t.tenant_name,
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
-- Enriched with tenant information (tenant_id, tenant_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_subfinder;
CREATE VIEW tem_subfinder AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
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
--   Enriched with tenant information (tenant_id, tenant_name) via join with tem_tenant.
DROP VIEW IF EXISTS tem_httpx_result;
CREATE VIEW tem_httpx_result AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
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
-- Enriched with tenant information (tenant_id, tenant_name)
-- via join with tem_tenant.
DROP VIEW IF EXISTS tem_nmap;
CREATE VIEW tem_nmap AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
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
    t.tenant_name,
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
    t.tenant_name,
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
    t.tenant_name,
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

-- =======================================================
-- View: tem_testssl_general
-- -------------------------------------------------------
-- Purpose:
--   Extract general host-level details from testssl.json
--   files stored in uniform_resource.
--   Each row corresponds to one scanned host (targetHost).
-- Includes:
--   - Tenant info (tenant_id, tenant_name)
--   - Scan start time
--   - Host details (host, ip, port, rdns, service)
--   - Source URI reference
-- =======================================================
DROP VIEW IF EXISTS tem_testssl_general;
CREATE VIEW tem_testssl_general AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(ur.content, '$.Invocation') AS invocation,
    json_extract(ur.content, '$.version') AS version,
    json_extract(ur.content, '$.openssl') AS openssl,
    json_extract(ur.content, '$.startTime') AS start_time,
    json_extract(s.value, '$.targetHost') AS host,
    json_extract(s.value, '$.ip')         AS ip,
    json_extract(s.value, '$.port')       AS port,
    json_extract(s.value, '$.rDNS')       AS rdns,
    json_extract(s.value, '$.service')    AS service,
    ur.uri
  FROM uniform_resource ur
  INNER JOIN tem_tenant t ON t.device_id = ur.device_id
  INNER JOIN tem_session ts ON ur.device_id = ts.device_id
  JOIN json_each(ur.content, '$.scanResult') s
  WHERE ur.uri LIKE '%testssl%' AND ur.nature = 'json' AND json_extract(s.value, '$.targetHost') NOT NULL;

-- =======================================================
-- View: tem_testssl_pretest
-- -------------------------------------------------------
-- Purpose:
--   Extract all "pretest" findings from testssl.json
--   for each scanned host.
--   Each row corresponds to one pretest check result.
-- Includes:
--   - Host
--   - Pretest id, severity, finding
--   - Source URI reference
-- =======================================================
DROP VIEW IF EXISTS tem_testssl_pretest;
CREATE VIEW tem_testssl_pretest AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(p.value, '$.id')           AS id,
    json_extract(p.value, '$.severity')     AS severity,
    json_extract(p.value, '$.finding')      AS finding,
    ur.uri
FROM uniform_resource ur
  INNER JOIN tem_tenant t ON t.device_id = ur.device_id
  INNER JOIN tem_session ts ON ur.device_id = ts.device_id
  JOIN json_each(ur.content, '$.scanResult') s
  JOIN json_each(s.value, '$.pretest') p

WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json' AND json_extract(s.value, '$.targetHost') NOT NULL;

-- =======================================================
-- Query: Extract protocol details from testssl.json
-- -------------------------------------------------------
-- Purpose:
--   This query pulls out the protocol findings from
--   testssl scan results stored in uniform_resource.
--   Each row corresponds to one protocol check for
--   a specific scanned host.
-- =======================================================
DROP VIEW IF EXISTS tem_testssl_protocols;
CREATE VIEW tem_testssl_protocols AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(p.value, '$.id')           AS id,
    json_extract(p.value, '$.severity')     AS severity,
    json_extract(p.value, '$.finding')      AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.protocols') p
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json' AND json_extract(s.value, '$.targetHost') NOT NULL;

-- =======================================================
-- View: tem_testssl_ciphers
-- -------------------------------------------------------
-- Purpose:
--   Extract all "cipher" test results from testssl.json
--   stored in the uniform_resource table.
--
-- Behavior:
--   - Iterates through each scanResult element.
--   - Expands the ciphers array inside each scanResult.
--   - Produces one row per cipher finding for each host.
-- =======================================================
DROP VIEW IF EXISTS tem_testssl_ciphers;
CREATE VIEW tem_testssl_ciphers AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(c.value, '$.id')           AS id,
    json_extract(c.value, '$.severity')     AS severity,
    json_extract(c.value, '$.finding')      AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.ciphers') c
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json' AND json_extract(s.value, '$.targetHost') NOT NULL;

-- =======================================================
-- View: tem_testssl_server_references
-- -------------------------------------------------------
-- Purpose:
--   Extract all "serverPreferences" test results from
--   testssl.json files stored in the uniform_resource table.
--
-- Behavior:
--   - Iterates through each element of the scanResult array.
--   - Expands the serverPreferences array for each host.
--   - Produces one row per server preference finding.
-- =======================================================
DROP VIEW IF EXISTS tem_testssl_server_references;
CREATE VIEW tem_testssl_server_references AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(sp.value, '$.id')           AS id,
    json_extract(sp.value, '$.severity')     AS severity,
    json_extract(sp.value, '$.finding')      AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.serverPreferences') sp
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json' AND json_extract(s.value, '$.targetHost') NOT NULL;

-- =======================================================
-- View: tem_testssl_fs
-- -------------------------------------------------------
-- Purpose:
--   Extract all "Forward Secrecy (FS)" test results from
--   testssl.json files stored in the uniform_resource table.
--
-- Behavior:
--   - Iterates through each element of the scanResult array.
--   - Expands the fs (Forward Secrecy) array for each host.
--   - Produces one row per FS finding.
--
-- Forward Secrecy (FS):
--   Forward Secrecy ensures that even if the server's long-term
--   private key is compromised, past communications remain secure.
--   Testssl.sh reports FS support status for the cipher suites.
-- =======================================================
DROP VIEW IF EXISTS tem_testssl_fs;
CREATE VIEW tem_testssl_fs AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(fs.value, '$.id')           AS id,
    json_extract(fs.value, '$.severity')     AS severity,
    json_extract(fs.value, '$.finding')      AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.fs') fs
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json' AND json_extract(s.value, '$.targetHost') NOT NULL;

-- View: tem_testssl_server_defaults
-- --------------------------------------------
-- This view extracts the "serverDefault" section from TestSSL JSON scan results.
-- For each host in a testssl scan, it retrieves:
--   - pretest_id:    The identifier of the server default check
--   - pretest_severity: Severity level of the finding
--   - pretest_finding: Description of the finding
-- The view links the scan data to the uniform_resource table via uniform_resource_id
-- and filters only JSON entries with a valid targetHost. Useful for reporting
-- server configuration issues and compliance checks.
DROP VIEW IF EXISTS tem_testssl_server_default;
DROP VIEW IF EXISTS tem_testssl_server_default;
CREATE VIEW tem_testssl_server_default AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(sd.value, '$.targetHost')   AS host,
    json_extract(sd.value, '$.id')           AS id,
    json_extract(sd.value, '$.severity')     AS severity,
    json_extract(sd.value, '$.finding')      AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.serverDefaults') sd
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json' AND json_extract(s.value, '$.targetHost') NOT NULL;


-- View: tem_testssl_header_response
-- --------------------------------------------
-- This view extracts the "headerResponse" section from TestSSL JSON scan results.
-- For each host in a TestSSL scan, it retrieves:
--   - header_response_id: The identifier of the header response check
--   - severity: Severity level of the finding
--   - finding: Description of the finding
-- The view links the scan data to the uniform_resource table via uniform_resource_id
-- and filters only JSON entries with a valid targetHost.
DROP VIEW IF EXISTS tem_testssl_header_response;
CREATE VIEW tem_testssl_header_response AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(fs.value, '$.id')          AS header_response_id,
    json_extract(fs.value, '$.severity')    AS severity,
    json_extract(fs.value, '$.finding')     AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.headerResponse') fs
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json'
  AND json_extract(s.value, '$.targetHost') NOT NULL;


-- View: tem_testssl_vulnerabilitie
-- --------------------------------------------
-- This view extracts the "vulnerabilities" section from TestSSL JSON scan results.
-- For each host in a TestSSL scan, it retrieves:
--   - vulnerability_id: The identifier of the vulnerability check
--   - severity: Severity level of the finding
--   - finding: Description of the finding
-- The view links the scan data to the uniform_resource table via uniform_resource_id
-- and filters only JSON entries with a valid targetHost.
DROP VIEW IF EXISTS tem_testssl_vulnerabilitie;
CREATE VIEW tem_testssl_vulnerabilitie AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(fs.value, '$.id')          AS vulnerability_id,
    json_extract(fs.value, '$.severity')    AS severity,
    json_extract(fs.value, '$.finding')     AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.vulnerabilities') fs
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json'
  AND json_extract(s.value, '$.targetHost') NOT NULL;

-- View: tem_testssl_browser_simulation
-- --------------------------------------------
-- This view extracts the "browserSimulations" section from TestSSL JSON scan results.
-- For each host in a TestSSL scan, it retrieves:
--   - simulation_id: The identifier of the browser simulation check
--   - severity: Severity level of the finding
--   - finding: Description of the finding
-- The view links the scan data to the uniform_resource table via uniform_resource_id
-- and filters only JSON entries with a valid targetHost.
DROP VIEW IF EXISTS tem_testssl_browser_simulation;
CREATE VIEW tem_testssl_browser_simulation AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(fs.value, '$.id')          AS simulation_id,
    json_extract(fs.value, '$.severity')    AS severity,
    json_extract(fs.value, '$.finding')     AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.browserSimulations') fs
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json'
  AND json_extract(s.value, '$.targetHost') NOT NULL;

-- View: tem_testssl_rating
-- --------------------------------------------
-- This view extracts the "rating" section from TestSSL JSON scan results.
-- For each host in a TestSSL scan, it retrieves:
--   - rating_id: The identifier of the rating check
--   - severity: Severity level of the finding
--   - finding: Description of the finding or rating result
-- The view links the scan data to the uniform_resource table via uniform_resource_id
-- and filters only JSON entries with a valid targetHost.
DROP VIEW IF EXISTS tem_testssl_rating;
CREATE VIEW tem_testssl_rating AS
SELECT
    ur.uniform_resource_id,
    t.tenant_id,
    t.tenant_name,
    ts.ur_ingest_session_id,
    json_extract(s.value, '$.targetHost')   AS host,
    json_extract(fs.value, '$.id')          AS rating_id,
    json_extract(fs.value, '$.severity')    AS severity,
    json_extract(fs.value, '$.finding')     AS finding,
    ur.uri
FROM uniform_resource ur
INNER JOIN tem_tenant t ON t.device_id = ur.device_id
INNER JOIN tem_session ts ON ur.device_id = ts.device_id
JOIN json_each(ur.content, '$.scanResult') s
JOIN json_each(s.value, '$.rating') fs
WHERE ur.uri LIKE '%testssl%'
  AND ur.nature = 'json'
  AND json_extract(s.value, '$.targetHost') NOT NULL;

  -- ===============================================================
-- View: tem_openssl_original_txt
--
-- Purpose:
--   This view extracts individual SSL/TLS certificate blocks and
--   their associated metadata from the raw content stored in the
--   `uniform_resource` table. Certificates are split into multiple
--   rows for easier parsing and analysis.
--
-- Method:
--   * Uses a recursive CTE (`cert_blocks`) to search the content for
--     "-----BEGIN CERTIFICATE-----" and "-----END CERTIFICATE-----"
--     markers.
--   * Each recursion step:
--       - `metadata`   : Text before the certificate block
--       - `certificate`: The full PEM-encoded certificate including
--                        BEGIN/END markers
--       - `remaining_text`: Remaining content after the current
--                           certificate (used for recursion)
--   * The process continues until no more certificate blocks are
--     found.
--
-- Output Columns:
--   - uniform_resource_id : Identifier linking back to the source entry
--   - tenant_id           : Tenant identifier
--   - tenant_name         : Tenant name
--   - ur_ingest_session_id: Session identifier
--   - cert_index          : Sequential index of the certificate
--   - metadata            : Preceding OpenSSL diagnostic text
--   - certificate         : Extracted PEM certificate block
--
-- Notes:
--   * Certificates are returned in the order they appear.
--   * Rows without a certificate (NULL) are excluded.
--   * This view normalizes OpenSSL output into a relational form for
--     downstream parsing (e.g., extracting CN, issuer, validity period).
--
-- ===============================================================
DROP VIEW IF EXISTS tem_openssl_original_txt;
CREATE VIEW tem_openssl_original_txt AS
WITH RECURSIVE cert_blocks AS (
    -- Anchor: start from the beginning of content with tenant info
    SELECT
        ur.uniform_resource_id,
        t.tenant_id,
        t.tenant_name,
        ts.ur_ingest_session_id,
        ur.content AS remaining_text,
        NULL AS metadata,
        NULL AS certificate,
        1 AS cert_index
    FROM uniform_resource ur
    INNER JOIN tem_tenant t ON t.device_id = ur.device_id
    INNER JOIN tem_session ts ON ur.device_id = ts.device_id
    WHERE ur.uri LIKE '%openssl%'  -- filter by uri
    
    UNION ALL

    -- Recursive step: extract the next certificate block
    SELECT
        uniform_resource_id,
        tenant_id,
        tenant_name,
        ur_ingest_session_id,
        substr(remaining_text, instr(remaining_text, '-----END CERTIFICATE-----') + length('-----END CERTIFICATE-----')) AS remaining_text,
        trim(substr(remaining_text, 1, instr(remaining_text, '-----BEGIN CERTIFICATE-----') - 1)) AS metadata,
        substr(
            remaining_text,
            instr(remaining_text, '-----BEGIN CERTIFICATE-----'),
            instr(remaining_text, '-----END CERTIFICATE-----') - instr(remaining_text, '-----BEGIN CERTIFICATE-----') + length('-----END CERTIFICATE-----')
        ) AS certificate,
        cert_index + 1
    FROM cert_blocks
    WHERE remaining_text LIKE '%-----BEGIN CERTIFICATE-----%'
)
SELECT
    uniform_resource_id,
    tenant_id,
    tenant_name,
    ur_ingest_session_id,
    cert_index,
    metadata,
    certificate
FROM cert_blocks
WHERE certificate IS NOT NULL
ORDER BY uniform_resource_id, cert_index;


-- ===============================================================
-- View: tem_openssl
-- Purpose:
--   This view parses raw SSL certificate metadata stored in the
--   `tem_openssl_original_txt` view and extracts key fields into
--   structured columns. The goal is to make certificate details
--   easier to query, filter, and join with other data.
--
-- Source:
--   Table: tem_openssl_original_txt
--   Column: metadata (raw certificate text as produced by OpenSSL)
--
-- Extracted Fields:
--   - common_name          : Subject CN from "s:" line
--   - subject_organization : Subject O from "s:" line
--   - issuer_country       : Issuer C from "i:" line
--   - issuer_common_name   : Issuer CN from "i:" line
--   - issuer_organization  : Issuer O from "i:" line
--   - issued_date          : Certificate "NotBefore" validity date
--   - expires_date         : Certificate "NotAfter" validity date
--
-- Notes:
--   * The view trims values and falls back to an empty string ("")
--     if a field is not present in the metadata.
--   * Only rows where a Common Name (CN) exists in the subject
--     line are included (filter applied in final WHERE clause).
--   * Parsing is implemented using SQLite string functions
--     (instr, substr, length) to avoid dependency on regexp.
--
-- Usage Example:
--   SELECT common_name, issuer_common_name, issued_date, expires_date
--   FROM tem_openssl
--   WHERE expires_date < date('now');
--
-- ===============================================================
DROP VIEW IF EXISTS tem_openssl;
CREATE VIEW tem_openssl AS
WITH parsed AS (
  SELECT
    uniform_resource_id,
    tenant_id,
    tenant_name,
    ur_ingest_session_id,
    cert_index,
    metadata,

    -- full subject line starting at the first "s:" up to the newline
    CASE
      WHEN instr(metadata, 's:') = 0 THEN ''
      ELSE trim(
        substr(
          metadata,
          instr(metadata, 's:'),
          CASE
            WHEN instr(substr(metadata, instr(metadata, 's:')), char(10)) > 0
              THEN instr(substr(metadata, instr(metadata, 's:')), char(10)) - 1
            ELSE length(metadata) - instr(metadata, 's:') + 1
          END
        )
      )
    END AS subject_line,

    -- full issuer line starting at the first "i:" up to the newline
    CASE
      WHEN instr(metadata, 'i:') = 0 THEN ''
      ELSE trim(
        substr(
          metadata,
          instr(metadata, 'i:'),
          CASE
            WHEN instr(substr(metadata, instr(metadata, 'i:')), char(10)) > 0
              THEN instr(substr(metadata, instr(metadata, 'i:')), char(10)) - 1
            ELSE length(metadata) - instr(metadata, 'i:') + 1
          END
        )
      )
    END AS issuer_line

  FROM tem_openssl_original_txt
)

SELECT
  uniform_resource_id,
  tenant_id,
  tenant_name,
  ur_ingest_session_id,
  cert_index,

  /* common_name (from subject_line -> CN=...) */
  CASE
    WHEN instr(subject_line, 'CN=') = 0 THEN ''
    ELSE trim(
      substr(
        subject_line,
        instr(subject_line, 'CN=') + 3,
        CASE
          WHEN instr(substr(subject_line, instr(subject_line, 'CN=') + 3), ',') > 0
            THEN instr(substr(subject_line, instr(subject_line, 'CN=') + 3), ',') - 1
          ELSE length(subject_line) - (instr(subject_line, 'CN=') + 3) + 1
        END
      )
    )
  END AS common_name,

  /* subject_organization (from subject_line -> O=...) */
  CASE
    WHEN instr(subject_line, 'O=') = 0 THEN ''
    ELSE trim(
      substr(
        subject_line,
        instr(subject_line, 'O=') + 2,
        CASE
          WHEN instr(substr(subject_line, instr(subject_line, 'O=') + 2), ',') > 0
            THEN instr(substr(subject_line, instr(subject_line, 'O=') + 2), ',') - 1
          ELSE length(subject_line) - (instr(subject_line, 'O=') + 2) + 1
        END
      )
    )
  END AS subject_organization,

  /* issuer_country (from issuer_line -> C=...) */
  CASE
    WHEN instr(issuer_line, 'C=') = 0 THEN ''
    ELSE trim(
      substr(
        issuer_line,
        instr(issuer_line, 'C=') + 2,
        CASE
          WHEN instr(substr(issuer_line, instr(issuer_line, 'C=') + 2), ',') > 0
            THEN instr(substr(issuer_line, instr(issuer_line, 'C=') + 2), ',') - 1
          ELSE length(issuer_line) - (instr(issuer_line, 'C=') + 2) + 1
        END
      )
    )
  END AS issuer_country,

  /* issuer_common_name (from issuer_line -> CN=...) */
  CASE
    WHEN instr(issuer_line, 'CN=') = 0 THEN ''
    ELSE trim(
      substr(
        issuer_line,
        instr(issuer_line, 'CN=') + 3,
        CASE
          WHEN instr(substr(issuer_line, instr(issuer_line, 'CN=') + 3), ',') > 0
            THEN instr(substr(issuer_line, instr(issuer_line, 'CN=') + 3), ',') - 1
          ELSE length(issuer_line) - (instr(issuer_line, 'CN=') + 3) + 1
        END
      )
    )
  END AS issuer_common_name,

  /* issuer_organization (from issuer_line -> O=...) */
  CASE
    WHEN instr(issuer_line, 'O=') = 0 THEN ''
    ELSE trim(
      substr(
        issuer_line,
        instr(issuer_line, 'O=') + 2,
        CASE
          WHEN instr(substr(issuer_line, instr(issuer_line, 'O=') + 2), ',') > 0
            THEN instr(substr(issuer_line, instr(issuer_line, 'O=') + 2), ',') - 1
          ELSE length(issuer_line) - (instr(issuer_line, 'O=') + 2) + 1
        END
      )
    )
  END AS issuer_organization,

  /* issued_date (NotBefore:) */
  CASE
    WHEN instr(metadata, 'NotBefore:') = 0 THEN ''
    ELSE trim(
      substr(
        metadata,
        instr(metadata, 'NotBefore:') + length('NotBefore:'),
        CASE
          WHEN instr(substr(metadata, instr(metadata, 'NotBefore:') + length('NotBefore:')), ';') > 0
            THEN instr(substr(metadata, instr(metadata, 'NotBefore:') + length('NotBefore:')), ';') - 1
          WHEN instr(substr(metadata, instr(metadata, 'NotBefore:') + length('NotBefore:')), char(10)) > 0
            THEN instr(substr(metadata, instr(metadata, 'NotBefore:') + length('NotBefore:')), char(10)) - 1
          ELSE length(metadata) - (instr(metadata, 'NotBefore:') + length('NotBefore:')) + 1
        END
      )
    )
  END AS issued_date,

  /* expires_date (NotAfter:) */
  CASE
    WHEN instr(metadata, 'NotAfter:') = 0 THEN ''
    ELSE trim(
      substr(
        metadata,
        instr(metadata, 'NotAfter:') + length('NotAfter:'),
        CASE
          WHEN instr(substr(metadata, instr(metadata, 'NotAfter:') + length('NotAfter:')), char(10)) > 0
            THEN instr(substr(metadata, instr(metadata, 'NotAfter:') + length('NotAfter:')), char(10)) - 1
          WHEN instr(substr(metadata, instr(metadata, 'NotAfter:') + length('NotAfter:')), ';') > 0
            THEN instr(substr(metadata, instr(metadata, 'NotAfter:') + length('NotAfter:')), ';') - 1
          ELSE length(metadata) - (instr(metadata, 'NotAfter:') + length('NotAfter:')) + 1
        END
      )
    )
  END AS expires_date

FROM parsed
WHERE instr(subject_line, 'CN=') > 0;


-- ===============================================================
-- View: tem_wafw00f_original_txt
-- Purpose:
--   Parses wafw00f output stored in uniform_resource.content (rows where
--   uri LIKE '%wafw00f%'). Splits the raw text into lines, identifies
--   blocks that start with '[*] Checking ...' and aggregates only the
--   marker lines that start with one of: [*], [+], [-], [~].
--   Non-marker lines (e.g. ASCII art/banner or other noise) are excluded.
-- ===============================================================
DROP VIEW IF EXISTS tem_wafw00f_original_txt;
CREATE VIEW tem_wafw00f_original_txt AS
WITH RECURSIVE
-- Recursively split content into trimmed lines with a sequential line number
split_lines(uniform_resource_id, uri, line, rest, ln) AS (
    SELECT
        uniform_resource_id,
        uri,
        trim(
          CASE
            WHEN instr(content, char(10)) > 0 THEN substr(content, 1, instr(content, char(10)) - 1)
            ELSE content
          END
        ) AS line,
        CASE
          WHEN instr(content, char(10)) > 0 THEN substr(content, instr(content, char(10)) + 1)
          ELSE ''
        END AS rest,
        1 AS ln
    FROM uniform_resource
    WHERE uri LIKE '%wafw00f%'

    UNION ALL

    SELECT
        uniform_resource_id,
        uri,
        trim(
          CASE
            WHEN instr(rest, char(10)) > 0 THEN substr(rest, 1, instr(rest, char(10)) - 1)
            ELSE rest
          END
        ) AS line,
        CASE
          WHEN instr(rest, char(10)) > 0 THEN substr(rest, instr(rest, char(10)) + 1)
          ELSE ''
        END AS rest,
        ln + 1
    FROM split_lines
    WHERE rest <> ''
),
-- Find the start line number for each block (lines that begin with "[*] Checking ")
block_start AS (
    SELECT uniform_resource_id, uri, ln AS start_ln
    FROM split_lines
    WHERE line LIKE '[*] Checking %'
),
-- Assign each marker line to the most recent block_start before it.
-- Also filter to include only marker lines that start with one of the allowed prefixes.
block_lines AS (
    SELECT s.uniform_resource_id,
           s.uri,
           b.start_ln AS block_ln,
           s.line
    FROM split_lines s
    JOIN block_start b
      ON s.uniform_resource_id = b.uniform_resource_id
     AND s.ln >= b.start_ln
     AND NOT EXISTS (
           SELECT 1 FROM block_start b2
           WHERE b2.uniform_resource_id = s.uniform_resource_id
             AND b2.start_ln > b.start_ln
             AND b2.start_ln <= s.ln
         )
    WHERE
      -- keep only marker lines:
      s.line LIKE '[*]%' OR
      s.line LIKE '[+]%' OR
      s.line LIKE '[-]%' OR
      s.line LIKE '[~]%'
)
-- Aggregate lines into one block per row; order by the block start line
SELECT
    uniform_resource_id,
    uri,
    group_concat(line, char(10)) AS block_content
FROM block_lines
GROUP BY uniform_resource_id, uri, block_ln
ORDER BY uniform_resource_id, block_ln;

-- ===============================================================
-- View: tem_waf_hosts
-- 
-- Purpose:
--   Extracts the host/domain from each WAFW00F block in the
--   tem_wafw00f_original_txt table. Each row corresponds to
--   a single WAFW00F scan block. Only the host is extracted
--   from lines starting with "[*] Checking ...", along with
--   the full block_content for reference.
-- 
-- Columns:
--   uniform_resource_id : ID of the original uniform_resource row
--   host                : Extracted host/domain from the scan
--   block_content       : Full text block of the WAFW00F scan
-- ===============================================================
DROP VIEW IF EXISTS tem_wafw00f;
CREATE VIEW tem_wafw00f AS
WITH RECURSIVE split_lines AS (
    SELECT
        wafWoof.uniform_resource_id,
        t.tenant_id,
        t.tenant_name,
        ts.ur_ingest_session_id,
        CASE
            WHEN instr(block_content, char(10)) > 0 THEN substr(block_content, 1, instr(block_content, char(10)) - 1)
            ELSE block_content
        END AS line,
        CASE
            WHEN instr(block_content, char(10)) > 0 THEN substr(block_content, instr(block_content, char(10)) + 1)
            ELSE ''
        END AS rest,
        block_content
    FROM tem_wafw00f_original_txt wafWoof
    INNER JOIN uniform_resource ur ON wafWoof.uniform_resource_id = ur.uniform_resource_id
    INNER JOIN tem_tenant t ON t.device_id = ur.device_id
    INNER JOIN tem_session ts ON ur.device_id = ts.device_id

    UNION ALL

    SELECT
        uniform_resource_id,
        tenant_id,
        tenant_name,
        ur_ingest_session_id,
        CASE
            WHEN instr(rest, char(10)) > 0 THEN substr(rest, 1, instr(rest, char(10)) - 1)
            ELSE rest
        END AS line,
        CASE
            WHEN instr(rest, char(10)) > 0 THEN substr(rest, instr(rest, char(10)) + 1)
            ELSE ''
        END AS rest,
        block_content
    FROM split_lines
    WHERE rest <> ''
)
SELECT DISTINCT
    uniform_resource_id,
    tenant_id,
    tenant_name,
    ur_ingest_session_id,
    -- Extract host from "https://..."
    substr(
        line,
        instr(line, 'https://') + 8,
        CASE
            WHEN instr(substr(line, instr(line, 'https://') + 8), '/') > 0
            THEN instr(substr(line, instr(line, 'https://') + 8), '/') - 1
            ELSE length(substr(line, instr(line, 'https://') + 8))
        END
    ) AS host,
    block_content
FROM split_lines
WHERE line LIKE '[*] Checking %'
ORDER BY host;

