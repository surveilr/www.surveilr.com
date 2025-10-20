-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- --------------------------------------------------------------------------------
-- Script to create a table from uniform_resource.content column
-- as osqueryms content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_system_info;
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_os_version;
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_interface_address;
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_uptime;
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_available_space;
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_boundary;
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_installed_software;
-- DROP VIEW IF EXISTS surveilr_osquery_ms_node_executed_policy; 

DROP TABLE IF EXISTS surveilr_osquery_ms_node_system_info;
CREATE TABLE surveilr_osquery_ms_node_system_info AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.board_model') AS board_model,
    json_extract(l.content, '$.columns.board_serial') AS board_serial,
    json_extract(l.content, '$.columns.board_vendor') AS board_vendor,
    json_extract(l.content, '$.columns.board_version') AS board_version,
    json_extract(l.content, '$.columns.computer_name') AS computer_name,
    json_extract(l.content, '$.columns.cpu_brand') AS cpu_brand,
    json_extract(l.content, '$.columns.cpu_logical_cores') AS cpu_logical_cores,
    json_extract(l.content, '$.columns.cpu_microcode') AS cpu_microcode,
    json_extract(l.content, '$.columns.cpu_physical_cores') AS cpu_physical_cores,
    json_extract(l.content, '$.columns.cpu_sockets') AS cpu_sockets,
    json_extract(l.content, '$.columns.cpu_subtype') AS cpu_subtype,
    json_extract(l.content, '$.columns.cpu_type') AS cpu_type,
    json_extract(l.content, '$.columns.hardware_model') AS hardware_model,
    json_extract(l.content, '$.columns.hardware_serial') AS hardware_serial,
    json_extract(l.content, '$.columns.hardware_vendor') AS hardware_vendor,
    json_extract(l.content, '$.columns.hardware_version') AS hardware_version,
    json_extract(l.content, '$.columns.hostname') AS hostname,
    json_extract(l.content, '$.columns.local_hostname') AS local_hostname,
    json_extract(l.content, '$.columns.physical_memory') AS physical_memory,
    json_extract(l.content, '$.columns.uuid') AS uuid
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
AND json_extract(l.content, '$.name') = 'System Information';

DROP TABLE IF EXISTS surveilr_osquery_ms_node_os_version;
CREATE TABLE surveilr_osquery_ms_node_os_version AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.arch') AS arch,
    json_extract(l.content, '$.columns.build') AS build,
    json_extract(l.content, '$.columns.extra') AS extra,
    json_extract(l.content, '$.columns.kernel_version') AS kernel_version,
    json_extract(l.content, '$.columns.major') AS major,
    json_extract(l.content, '$.columns.minor') AS minor,
    json_extract(l.content, '$.columns.name') AS name,
    json_extract(l.content, '$.columns.patch') AS patch,
    json_extract(l.content, '$.columns.platform') AS platform,
    json_extract(l.content, '$.columns.version') AS version
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
AND (json_extract(l.content, '$.name') = 'OS Version (Linux and Macos)'
    OR json_extract(l.content, '$.name') = 'OS Version (Windows)');

DROP TABLE IF EXISTS surveilr_osquery_ms_node_interface_address;
CREATE TABLE surveilr_osquery_ms_node_interface_address AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.address') AS address,
    json_extract(l.content, '$.columns.mac') AS mac
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
AND (
    json_extract(l.content, '$.name') = 'Network Interfaces (Linux and Macos)'
    OR json_extract(l.content, '$.name') = 'Network Interfaces (Windows)'
);

DROP TABLE IF EXISTS surveilr_osquery_ms_node_uptime;
CREATE TABLE surveilr_osquery_ms_node_uptime AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.days') AS days,
    json_extract(l.content, '$.columns.hours') AS hours,
    json_extract(l.content, '$.columns.minutes') AS minutes,
    json_extract(l.content, '$.columns.seconds') AS seconds,
    json_extract(l.content, '$.columns.total_seconds') AS total_seconds
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
AND json_extract(l.content, '$.name') = 'Server Uptime'
ORDER BY l.created_at DESC;

DROP TABLE IF EXISTS surveilr_osquery_ms_node_available_space;
CREATE TABLE surveilr_osquery_ms_node_available_space AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.gigs_disk_space_available') AS available_space,
    json_extract(l.content, '$.columns.gigs_total_disk_space') AS gigs_total_disk_space,
    json_extract(l.content, '$.columns.percent_disk_space_available') AS percent_disk_space_available
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
AND (
    json_extract(l.content, '$.name') = 'Available Disk Space (Linux and Macos)'
    OR json_extract(l.content, '$.name') = 'Available Disk Space (Windows)'
)
ORDER BY l.created_at DESC;

DROP TABLE IF EXISTS surveilr_osquery_ms_node_boundary;
CREATE TABLE surveilr_osquery_ms_node_boundary AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.value') AS boundary,
    l.uri as query_uri
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
    AND (
        json_extract(l.content, '$.name') = 'osquery-ms Boundary (Linux and Macos)' OR
        json_extract(l.content, '$.name') = 'osquery-ms Boundary (Windows)'
    );


DROP TABLE IF EXISTS surveilr_osquery_ms_node_installed_software;
CREATE TABLE surveilr_osquery_ms_node_installed_software AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.name') AS name,
    json_extract(l.content, '$.columns.source') AS source,
    json_extract(l.content, '$.columns.type') AS type,
    json_extract(l.content, '$.columns.version') AS version,
    CASE
        WHEN json_extract(l.content, '$.name') = 'Installed Linux software' THEN 'linux'
        WHEN json_extract(l.content, '$.name') = 'Installed Macos software' THEN 'macos'
        WHEN json_extract(l.content, '$.name') = 'Installed Windows software' THEN 'windows'
        ELSE 'unknown'
    END AS platform
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
    AND (
        json_extract(l.content, '$.name') = 'Installed Linux software' OR
        json_extract(l.content, '$.name') = 'Installed Macos software' OR
        json_extract(l.content, '$.name') = 'Installed Windows software'
    );

DROP TABLE IF EXISTS surveilr_osquery_ms_node_executed_policy;
CREATE TABLE surveilr_osquery_ms_node_executed_policy AS
WITH ranked_policies AS (
    SELECT
        json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
        l.updated_at,
        json_extract(l.content, '$.hostIdentifier') AS host_identifier,
        json_extract(l.content, '$.name') AS policy_name,
        json_extract(l.content, '$.columns.policy_result') AS policy_result,
        ROW_NUMBER() OVER (PARTITION BY json_extract(l.content, '$.name') ORDER BY l.created_at DESC) AS row_num
    FROM uniform_resource AS l
    WHERE l.uri = 'osquery-ms:query-result'
        AND json_extract(l.content, '$.name') IN (
            'SSH keys encrypted', 
            'Full disk encryption enabled (Linux)', 
            'Full disk encryption enabled (Windows)', 
            'Full disk encryption enabled (Macos)'
        )
)
SELECT
    ranked_policies.node_key,
    ranked_policies.updated_at,
    ranked_policies.host_identifier,
    ranked_policies.policy_name,
    CASE 
        WHEN ranked_policies.policy_result = 'true' THEN 'Pass'
        ELSE 'Fail'
    END AS policy_result,
    CASE 
        WHEN ranked_policies.policy_result = 'true' THEN '-'
        ELSE json_extract(c.cell_governance, '$.policy.resolution')
    END AS resolution
FROM ranked_policies
JOIN code_notebook_cell c
    ON ranked_policies.policy_name = c.cell_name
WHERE ranked_policies.row_num = 1;
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


-- delete all /tem-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE parent_path like 'tem'||'/index.sql';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'tem/index.sql', 'tem/index.sql', 'Threat Exposure Management', NULL, NULL, 'Opsfolio Threat Exposure Management (TEM) and Opsfolio EAA are part of the Opsfolio Suite, which underpins Opsfolio Compliance-as-a-Service (CaaS) offerings.', NULL),
    ('prime', 'tem/index.sql', 1, 'tem/attack_surface_mapping_tenant.sql', 'tem/attack_surface_mapping_tenant.sql', 'Attack Surface Mapping By Tenant', NULL, NULL, 'This page provides a comprehensive view of the attack surface mapped for each tenant. It aggregates results from multiple reconnaissance and scanning tools, including HTTP/HTTPS endpoints, subdomains, open ports, and TLS/SSL information. Users can explore discovered hosts, services, protocols, and vulnerabilities, helping teams assess network exposure and prioritize security remediation for each tenant environment.', NULL),
    ('prime', 'tem/index.sql', 1, 'tem/attack_surface_mapping_session.sql', 'tem/attack_surface_mapping_session.sql', 'Attack Surface Mapping By Session', NULL, NULL, 'This data represents the information footprint of an application, domain, or infrastructure, typically gathered during reconnaissance, vulnerability assessment, or penetration testing.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
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

DROP VIEW IF EXISTS rssd_statistics_overview;
CREATE VIEW rssd_statistics_overview AS
SELECT 
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024), 2) FROM pragma_page_count(), pragma_page_size()) AS db_size_mb,
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024 * 1024), 4) FROM pragma_page_count(), pragma_page_size()) AS db_size_gb,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'table') AS total_tables,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'index') AS total_indexes,
    (SELECT SUM(tbl_rows) FROM (
        SELECT name, 
              (SELECT COUNT(*) FROM sqlite_master sm WHERE sm.type='table' AND sm.name=t.name) AS tbl_rows
        FROM sqlite_master t WHERE type='table'
    )) AS total_rows,
    (SELECT page_size FROM pragma_page_size()) AS page_size,
    (SELECT page_count FROM pragma_page_count()) AS total_pages;

CREATE TABLE IF NOT EXISTS surveilr_table_size (
    table_name TEXT PRIMARY KEY,
    table_size_mb REAL
);
DROP VIEW IF EXISTS rssd_table_statistic;
CREATE VIEW rssd_table_statistic AS
SELECT 
    m.name AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info(m.name)) AS total_columns,
    (SELECT COUNT(*) FROM pragma_index_list(m.name)) AS total_indexes,
    (SELECT COUNT(*) FROM pragma_foreign_key_list(m.name)) AS foreign_keys,
    (SELECT COUNT(*) FROM pragma_table_info(m.name) WHERE pk != 0) AS primary_keys,
    (SELECT table_size_mb FROM surveilr_table_size WHERE table_name = m.name) AS table_size_mb
FROM sqlite_master m
WHERE m.type = 'table';

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
    ('prime', 'console/index.sql', 2, 'console/migrations/index.sql', 'console/migrations/index.sql', 'RSSD Lifecycle (migrations)', 'Migrations', NULL, 'Explore RSSD Migrations to determine what was executed and not', NULL),
    ('prime', 'console/index.sql', 2, 'console/about.sql', 'console/about.sql', 'Resource Surveillance Details', 'About', NULL, 'Detailed information about the underlying surveilr binary', NULL),
    ('prime', 'console/index.sql', 1, 'console/statistics/index.sql', 'console/statistics/index.sql', 'RSSD Statistics', 'Statistics', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 5, 'console/behavior/index.sql', 'console/behavior/index.sql', 'Behavior Configuration', 'Behavior', NULL, 'Explore behavior configurations and presets used to drive application operations at runtime', NULL)
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
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'docs/index.sql', 'docs/index.sql', 'Docs', NULL, NULL, 'Explore surveilr functions and release notes', NULL),
    ('prime', 'docs/index.sql', 99, 'docs/release-notes.sql', 'docs/release-notes.sql', 'Release Notes', NULL, NULL, 'surveilr releases details', NULL),
    ('prime', 'docs/index.sql', 2, 'docs/functions.sql', 'docs/functions.sql', 'SQL Functions', NULL, NULL, 'surveilr specific SQLite functions for extensibilty', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
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
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''tem/index.sql''
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
              

              -- Intro text
SELECT
    ''text'' AS component,
    ''Opsfolio Threat Exposure Management (TEM) transforms static penetration test reports into real-time, actionable dashboards and workflows. Powered by Opsfolio EAA, it streamlines vulnerability reporting, automates remediation tracking, and delivers compliance-ready evidence to keep your organization secure and audit-ready.'' AS contents;

-- Navigation list
WITH navigation_cte AS (
    SELECT COALESCE(title, caption) AS title, description
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''tem''||''/index.sql''
)
SELECT ''list'' AS component, title, description
FROM navigation_cte;

SELECT caption AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) AS link, description
FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path = ''tem''||''/index.sql''
ORDER BY sibling_order;

--- Page Title for Tasks Section
SELECT ''title'' AS component, ''Tasks Overview'' AS contents;

--- Small description above the table
SELECT ''text'' AS component,
''This table lists all tasks detected in the system, including their status and title. Click on a Task ID to view detailed content.'' AS contents;

--- Tasks Table
SELECT ''table'' AS component, TRUE AS sort, TRUE AS search, ''Title'' AS markdown;

SET total_rows = (SELECT COUNT(*) FROM tem_task_summary WHERE uri LIKE ''%task%'');
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
''['' || title || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/task_detail.sql?task_id='' || uniform_resource_id || '')'' AS "Title",
task_id AS "Task ID",
status AS "Status",
priority,
strftime(''%m-%d-%Y'', created_date) AS "created date",
strftime(''%m-%d-%Y'', updated_date) AS "updated date"
FROM tem_task_summary;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/task_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/task_detail.sql/index.sql'') as contents;
    ;

--- Breadcrumbs
SELECT ''breadcrumb'' AS component;
SELECT ''Home'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
SELECT ''Tem'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;
SELECT 
(SELECT title FROM tem_task_summary WHERE uniform_resource_id = $task_id) AS title,
''#'' AS link;

--- Card Header with Task Title
SELECT ''card'' AS component,
    (SELECT title
        FROM tem_task_summary
        WHERE uniform_resource_id = $task_id) AS title,
    1 AS columns;

--- Task Content Section (rendered nicely in Markdown)
WITH RECURSIVE strip_comments(txt) AS (
-- initial content (after frontmatter)
SELECT ltrim(
        substr(
        content,
        instr(substr(content, instr(content, ''---'') + 3), ''---'') + instr(content, ''---'') + 5
        )
    )
FROM tem_task_summary
WHERE uniform_resource_id = $task_id

UNION ALL

-- remove first <!-- ... --> occurrence
SELECT 
    substr(txt, 1, instr(txt, ''<!--'') - 1) || substr(txt, instr(txt, ''-->'') + 3)
FROM strip_comments
WHERE txt LIKE ''%<!--%-->%''
)
SELECT txt AS description_md
FROM strip_comments
WHERE txt NOT LIKE ''%<!--%-->%''
LIMIT 1;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/attack_surface_mapping_tenant.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''tem/attack_surface_mapping_tenant.sql''
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
   WHERE namespace = ''prime'' AND path = ''tem/attack_surface_mapping_tenant.sql/index.sql'') as contents;
    ;

--- Dsply Page Title
SELECT
    ''title''   as component,
    ''Attack Surface Mapping By Tenant'' contents;

SELECT
    ''text''              as component,
    "Attack Surface Mapping is the process of identifying, collecting, and analyzing all potential points of entry an attacker could exploit within an organization''s digital infrastructure. It involves using tools such as WhatWeb, Nmap, TLS/TLSX, Nuclei, DNSx, Dirsearch, Naabu, Subfinder, Katana, and HTTPX-Toolkit to enumerate exposed services, technologies, subdomains, directories, ports, TLS configurations, and vulnerabilities. This helps organizations gain a comprehensive view of their external and internal exposure, prioritize remediation efforts, and strengthen their security posture." as contents;

SELECT
    ''card'' as component,
    4      as columns;
SELECT tenant_name as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || tenant_id as link
 FROM tem_tenant;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/attack_surface_mapping_session.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''tem/attack_surface_mapping_session.sql''
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
   WHERE namespace = ''prime'' AND path = ''tem/attack_surface_mapping_session.sql/index.sql'') as contents;
    ;


--- Dsply Page Title
SELECT
    ''title''   as component,
    ''Attack Surface Mapping By Session'' contents;

SELECT
    ''text''              as component,
    "This page presents the attack surface data collected during a specific session. It consolidates results from scanning and reconnaissance tools, showing discovered hosts, services, protocols, and exposed endpoints. This allows users to analyze session-specific findings, track changes over time, and prioritize security actions based on session-based activities." as contents;

SELECT ''table'' AS component,
TRUE AS sort,
TRUE AS search,
''Session'' as markdown;

SELECT 
    ''['' || session_name || ''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || ur_ingest_session_id || '')'' AS "Session",
    (SELECT COUNT(tool_name) FROM tem_session_finding_link WHERE ts.ur_ingest_session_id=ur_ingest_session_id) AS "Analysis Tools",
    IFNULL(ingest_started_at, ''-'') AS "Session Start Date",
    IFNULL(ingest_finished_at, ''-'') AS "Session End Date",
    IFNULL(agent, ''-'') AS "Agent",
    IFNULL(version, ''-'') AS "Version"
FROM tem_session ts;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/attack_surface_mapping_inner.sql',
      '             SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
             -- not including breadcrumbs from sqlpage_aide_navigation
             -- not including page title from sqlpage_aide_navigation
             

             SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
   FROM sqlpage_aide_navigation
  WHERE namespace = ''prime'' AND path = ''tem/tenant/attack_surface_mapping_inner.sql/index.sql'') as contents;
   ;
 --- Display breadcrumb
 SELECT
     ''breadcrumb'' AS component;
 SELECT
     ''Home'' AS title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
     ''Threat Exposure Management'' AS title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
 SELECT ''Attack Surface Mapping By Tenant'' AS title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;

 SELECT tenant_name AS title,
     ''#'' AS link FROM tem_tenant WHERE tenant_id=$tenant_id;

 --- Dsply Page Title
 SELECT
   ''title''   as component,
   ''Assets'' as contents;

 SELECT
   ''text''              as component,
   ''Collection of reconnaissance and security assessment tools used for subdomain discovery, port scanning, DNS probing, web technology fingerprinting, TLS analysis, and vulnerability detection.'' as contents;
 

SELECT
     ''card'' as component,
     4      as columns;
 SELECT
     "Assets"  as title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant_asset.sql?tenant_id='' || $tenant_id as link;

 SELECT "Findings" as title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id as link;
           ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant_asset.sql',
      '             SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
             -- not including breadcrumbs from sqlpage_aide_navigation
             -- not including page title from sqlpage_aide_navigation
             

             SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
   FROM sqlpage_aide_navigation
  WHERE namespace = ''prime'' AND path = ''tem/tenant_asset.sql/index.sql'') as contents;
   ;
 --- Display breadcrumb
 SELECT
     ''breadcrumb'' AS component;
 SELECT
     ''Home'' AS title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
     ''Threat Exposure Management'' AS title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
 SELECT ''Attack Surface Mapping By Tenant'' AS title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
     ''tenant/attack_surface_mapping_inner.sql?tenant_id=''|| $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
 SELECT ''Assets'' AS title,
     ''#'' AS link;

 --- Dsply Page Title
 SELECT
   ''title''   as component,
   ''Assets'' as contents;

 SELECT
   ''text''              as component,
   ''Collection of reconnaissance and security assessment tools used for subdomain discovery, port scanning, DNS probing, web technology fingerprinting, TLS analysis, and vulnerability detection.'' as contents;
 

 SELECT ''table'' AS component,
TRUE AS sort,
TRUE AS search;

 SELECT
     asset 
 FROM tem_eaa_asset_uri;
           ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/finding.sql',
      '            SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
            -- not including breadcrumbs from sqlpage_aide_navigation
            -- not including page title from sqlpage_aide_navigation
            

            SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND path = ''tem/session/finding.sql/index.sql'') as contents;
  ;
--- Display breadcrumb
SELECT
    ''breadcrumb'' AS component;
SELECT
    ''Home'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
SELECT
    ''Threat Exposure Management'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
SELECT ''Attack Surface Mapping By Session'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
SELECT tenant_name AS title,
    ''tenant/attack_surface_mapping_inner.sql?tenant_id=''|| $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
SELECT ''Findings'' AS title,
    ''#'' AS link;

--- Dsply Page Title
SELECT
  ''title''   as component,
  ''Findings'' as contents;

SELECT
  ''text''              as component,
  ''Detailed insights from each security tool, including scan results, fingerprints, DNS records, TLS details, subdomain enumeration, and vulnerability assessments, mapped per asset for better threat exposure analysis.'' as contents;


SELECT ''table'' AS component,
TRUE AS sort,
TRUE AS search,
''Asset'' as markdown;

SELECT
    ''['' || tool_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''' || redirect_url || '')'' AS ''Asset'',
    session_name AS "Session Name", -- or tenant_name for tenant page
    count
FROM tem_session_finding_link
WHERE ur_ingest_session_id = $session_id;
          ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/finding.sql',
      '            SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
            -- not including breadcrumbs from sqlpage_aide_navigation
            -- not including page title from sqlpage_aide_navigation
            

            SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND path = ''tem/tenant/finding.sql/index.sql'') as contents;
  ;
--- Display breadcrumb
SELECT
    ''breadcrumb'' AS component;
SELECT
    ''Home'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
SELECT
    ''Threat Exposure Management'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
SELECT ''Attack Surface Mapping By Tenant'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
 SELECT tenant_name AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
SELECT ''Findings'' AS title,
    ''#'' AS link;

--- Dsply Page Title
SELECT
  ''title''   as component,
  ''Findings'' as contents;

SELECT
  ''text''              as component,
  ''Detailed insights from each security tool, including scan results, fingerprints, DNS records, TLS details, subdomain enumeration, and vulnerability assessments, mapped per asset for better threat exposure analysis.'' as contents;


SELECT ''table'' AS component,
TRUE AS sort,
TRUE AS search,
''Asset'' as markdown;

SELECT
    ''['' || tool_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''' || redirect_url || '')'' AS Asset,
    tenant_name AS "Tenant Name",
    count
FROM tem_tenant_finding_link
WHERE tenant_id = $tenant_id;
          ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/what_web.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/what_web.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''Web Technology Fingerprinting'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''Web Technology Fingerprinting'' as contents;

  SELECT
    ''text''              as component,
    ''This page displays the results of automated web technology fingerprinting using WhatWeb. It includes details about detected servers, technologies, HTTP responses, geolocation, and key headers for each scanned endpoint.'' as contents;
  

  SELECT ''table'' AS component,
 TRUE AS sort,
 ''http_status'' AS markdown,
 TRUE AS search;
 
  SET total_rows = (SELECT COUNT(*) FROM tem_what_web_result WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
      SELECT
          CASE
              WHEN length(q.target_url) > 60 THEN substr(q.target_url, 1, 60) || ''...''
              ELSE q.target_url
          END AS "Target URL",
          CASE
              WHEN q.http_status BETWEEN 200 AND 299 THEN ''🟢 '' || q.http_status
              WHEN q.http_status BETWEEN 300 AND 399 THEN ''🟠 '' || q.http_status
              WHEN q.http_status BETWEEN 400 AND 599 THEN ''🔴 '' || q.http_status
              ELSE CAST(q.http_status AS TEXT)
          END AS "HTTP Status",
          q.ip_address AS "IP Address",
          q.country AS "Country",
          q.http_server AS "Web Server",
          q.page_title AS "Detected Technologies",
          q.uncommon_headers AS "Key HTTP Headers"
      FROM (
          SELECT *
          FROM tem_what_web_result
          WHERE tenant_id = $tenant_id
      ) q
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/what_web.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/what_web.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Session'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
  SELECT ''Findings'' AS title,
         sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id=''|| $session_id AS link;
  SELECT ''Web Technology Fingerprinting'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''Web Technology Fingerprinting'' as contents;

  SELECT
    ''text''              as component,
    ''This page displays the results of automated web technology fingerprinting using WhatWeb. It includes details about detected servers, technologies, HTTP responses, geolocation, and key headers for each scanned endpoint.'' as contents;
  

  SELECT ''table'' AS component,
 TRUE AS sort,
 ''http_status'' AS markdown,
 TRUE AS search;
 
  SET total_rows = (SELECT COUNT(*) FROM tem_what_web_result WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
      SELECT
          CASE
              WHEN length(q.target_url) > 60 THEN substr(q.target_url, 1, 60) || ''...''
              ELSE q.target_url
          END AS "Target URL",
          q.tenant_name AS "Tenant",
          CASE
              WHEN q.http_status BETWEEN 200 AND 299 THEN ''🟢 '' || q.http_status
              WHEN q.http_status BETWEEN 300 AND 399 THEN ''🟠 '' || q.http_status
              WHEN q.http_status BETWEEN 400 AND 599 THEN ''🔴 '' || q.http_status
              ELSE CAST(q.http_status AS TEXT)
          END AS "HTTP Status",
          q.ip_address AS "IP Address",
          q.country AS "Country",
          q.http_server AS "Web Server",
          q.page_title AS "Detected Technologies",
          q.uncommon_headers AS "Key HTTP Headers"
      FROM (
          SELECT *
          FROM tem_what_web_result
          WHERE ur_ingest_session_id = $session_id
      ) q
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/dnsx.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/dnsx.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''DNS Enumeration Results'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''DNS Enumeration Results'' as contents;

  SELECT
    ''text''              as component,
    ''This page lists the discovered DNS records using dnsx. It provides information about resolved subdomains, their IP addresses, DNS servers queried, response status, and timestamps for when the enumeration was performed.'' as contents;
  

  SELECT ''table'' AS component,
 TRUE AS sort,
 TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_dnsx_result WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      host,
      ttl,
      resolver,
      ip_address as "ip address",
      status_code AS "status code",
      datetime(substr(timestamp, 1, 19), ''-4 hours'') AS time
  FROM tem_dnsx_result WHERE tenant_id = $tenant_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/dnsx.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/dnsx.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Session'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
  SELECT ''Findings'' AS title,
         sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id=''|| $session_id AS link;
  SELECT ''DNS Enumeration Results'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''DNS Enumeration Results'' as contents;

  SELECT
    ''text''              as component,
    ''This page lists the discovered DNS records using dnsx. It provides information about resolved subdomains, their IP addresses, DNS servers queried, response status, and timestamps for when the enumeration was performed.'' as contents;
  

  SELECT ''table'' AS component,
 TRUE AS sort,
 TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_dnsx_result WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      tenant_name AS "Tenant",
      host,
      ttl,
      resolver,
      ip_address as "ip address",
      status_code AS "status code",
      datetime(substr(timestamp, 1, 19), ''-4 hours'') AS time
  FROM tem_dnsx_result WHERE ur_ingest_session_id = $session_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/nuclei.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/nuclei.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''Nuclei Scan Findings'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''Nuclei Scan Findings'' as contents;

  SELECT
    ''text''              as component,
    ''Comprehensive overview of detected vulnerabilities and exposures from Nuclei scans. Displays host, URL, template details, severity levels, matched paths, and timestamps for quick analysis and remediation planning.'' as contents;
  

  SELECT ''table'' AS component,
 TRUE AS sort,
 TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_nuclei_result WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      host,
      url,
      template_id AS "Template ID",
      name AS "Description",
      severity AS "Severity",
      ip AS "IP Address",
      matched_path  AS "Matched Path",
      datetime(substr(timestamp, 1, 19), ''-4 hours'') AS "Scan Time"
  FROM tem_nuclei_result WHERE tenant_id = $tenant_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/nuclei.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/nuclei.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
 SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Session'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
  SELECT ''Findings'' AS title,
         sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id=''|| $session_id AS link;
  SELECT ''Nuclei Scan Findings'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''Nuclei Scan Findings'' as contents;

  SELECT
    ''text''              as component,
    ''Comprehensive overview of detected vulnerabilities and exposures from Nuclei scans. Displays host, URL, template details, severity levels, matched paths, and timestamps for quick analysis and remediation planning.'' as contents;
  

  SELECT ''table'' AS component,
 TRUE AS sort,
 TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_nuclei_result WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      tenant_name AS "Tenant",
      host,
      url,
      template_id AS "Template ID",
      name AS "Description",
      severity AS "Severity",
      ip AS "IP Address",
      matched_path  AS "Matched Path",
      datetime(substr(timestamp, 1, 19), ''-4 hours'') AS "Scan Time"
  FROM tem_nuclei_result WHERE ur_ingest_session_id = $session_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/naabu.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/naabu.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''Naabu Port Scan Results'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''Naabu Port Scan Results'' as contents;

  SELECT
    ''text''              as component,
    ''This page displays the results from Naabu port scanning, showing open ports, associated hosts, and key network details. It helps in identifying exposed services and potential network entry points by providing real-time visibility into IPs, protocols, and TLS status discovered during the scan.'' as contents;
  

  SELECT ''table'' AS component,
  TRUE AS sort,
  TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_naabu_result WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      host,
      port,
      ip AS "IP Address",
      protocol,
      tls,
      datetime(substr(timestamp, 1, 19), ''-4 hours'') AS "Scan Time"
  FROM tem_naabu_result WHERE tenant_id = $tenant_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/naabu.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/naabu.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Session'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
  SELECT ''Findings'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
  SELECT ''Naabu Port Scan Results'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''Naabu Port Scan Results'' as contents;

  SELECT
    ''text''              as component,
    ''This page displays the results from Naabu port scanning, showing open ports, associated hosts, and key network details. It helps in identifying exposed services and potential network entry points by providing real-time visibility into IPs, protocols, and TLS status discovered during the scan.'' as contents;
  

  SELECT ''table'' AS component,
  TRUE AS sort,
  TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_naabu_result WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      tenant_name AS "Tenant",
      host,
      port,
      ip AS "IP Address",
      protocol,
      tls,
      datetime(substr(timestamp, 1, 19), ''-4 hours'') AS "Scan Time"
  FROM tem_naabu_result WHERE ur_ingest_session_id = $session_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/subfinder.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/subfinder.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''Subfinder Results'' AS title,
      ''#'' AS link;

  --- Display Page Title
  SELECT
    ''title''   as component,
    ''Subfinder Results'' as contents;

  SELECT
    ''text'' as component,
    ''This page displays results from the Subfinder tool. It shows discovered subdomains, their source, and ingestion metadata. This helps in expanding the attack surface by enumerating subdomains associated with target domains and providing visibility into where they were found.'' as contents;

  SELECT ''table'' AS component,
  TRUE AS sort,
  TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_subfinder WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      domain                AS "Domain",
      raw_records           AS "Discovered Host",
      source                AS "Source",
      tool_name             AS "Tool"
  FROM tem_subfinder WHERE tenant_id = $tenant_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/subfinder.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/subfinder.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
   SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Session'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
  SELECT ''Findings'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
  SELECT ''Subfinder Results'' AS title,
      ''#'' AS link;

  --- Display Page Title
  SELECT
    ''title''   as component,
    ''Subfinder Results'' as contents;

  SELECT
    ''text'' as component,
    ''This page displays results from the Subfinder tool. It shows discovered subdomains, their source, and ingestion metadata. This helps in expanding the attack surface by enumerating subdomains associated with target domains and providing visibility into where they were found.'' as contents;

  SELECT ''table'' AS component,
  TRUE AS sort,
  TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_subfinder WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      tenant_name           AS  "Tenant",
      domain                AS "Domain",
      raw_records           AS "Discovered Host",
      source                AS "Source",
      tool_name             AS "Tool"
  FROM tem_subfinder WHERE ur_ingest_session_id = $session_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/httpx-toolkit.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/httpx-toolkit.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''HTTPX Toolkit Results'' AS title,
      ''#'' AS link;

  --- Display Page Title
  SELECT
    ''title''   as component,
    ''HTTPX Toolkit Results'' as contents;

  SELECT
    ''text'' as component,
    ''This page displays results from the httpx-toolkit. It provides insights into HTTP/HTTPS endpoints, including status codes, response times, content type, IP resolution, and digests. This helps identify live services, exposed endpoints, and potential security issues.'' as contents;

  SELECT ''table'' AS component,
  TRUE AS sort,
  TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_httpx_result WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      domain             AS "Domain",
      url                AS "URL",
      scheme             AS "Scheme",
      port               AS "Port",
      (
          SELECT group_concat(value, '', '')
          FROM json_each(ip_addresses)
      )                 AS "IP Addresses",
      status_code        AS "Status Code",
      content_type       AS "Content Type",
      response_time      AS "Response Time",
      http_method        AS "HTTP Method",
      resolved_host      AS "Resolved Host",
      ingest_timestamp   AS "Ingested At"
  FROM tem_httpx_result WHERE tenant_id = $tenant_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/httpx-toolkit.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/httpx-toolkit.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Session'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
  SELECT ''Findings'' AS title,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
  SELECT ''HTTPX Toolkit Results'' AS title,
      ''#'' AS link;

  --- Display Page Title
  SELECT
    ''title''   as component,
    ''HTTPX Toolkit Results'' as contents;

  SELECT
    ''text'' as component,
    ''This page displays results from the httpx-toolkit. It provides insights into HTTP/HTTPS endpoints, including status codes, response times, content type, IP resolution, and digests. This helps identify live services, exposed endpoints, and potential security issues.'' as contents;

  SELECT ''table'' AS component,
  TRUE AS sort,
  TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_httpx_result WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT
      tenant_name        AS  "Tenant",
      domain             AS "Domain",
      url                AS "URL",
      scheme             AS "Scheme",
      port               AS "Port",
      (
          SELECT group_concat(value, '', '')
          FROM json_each(ip_addresses)
      )                 AS "IP Addresses",
      status_code        AS "Status Code",
      content_type       AS "Content Type",
      response_time      AS "Response Time",
      http_method        AS "HTTP Method",
      resolved_host      AS "Resolved Host",
      ingest_timestamp   AS "Ingested At"
  FROM tem_httpx_result WHERE ur_ingest_session_id = $session_id;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/nmap.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/nmap.sql/index.sql'') as contents;
    ;
--- Display breadcrumb
SELECT
        ''breadcrumb'' AS component;
    SELECT
        ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
    SELECT
        ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
    SELECT ''Attack Surface Mapping By Tenant'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
    SELECT tenant_name AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
    SELECT ''Findings'' AS title,
            sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
    SELECT ''Nmap Scan Results'' AS title,
   ''#'' AS link;

--- Display Page Title
SELECT ''title'' AS component,
    ''Nmap Scan Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays parsed Nmap scan results extracted from XML stored in uniform_resource.content. 
        It includes host IP, port, protocol, state, and detected service details to help assess open services and network exposure.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_nmap WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    host_ip           AS "Host IP",
    protocol          AS "Protocol",
    port              AS "Port",
    state             AS "State",
    service_name      AS "Service",
    service_product   AS "Product",
    service_version   AS "Version",
    service_extrainfo AS "Extra Info",
    tool_name         AS "Tool"
FROM tem_nmap WHERE tenant_id = $tenant_id;;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/nmap.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/nmap.sql/index.sql'') as contents;
    ;
--- Display breadcrumb
SELECT ''breadcrumb'' AS component;
    SELECT
    ''breadcrumb'' AS component;
    SELECT
        ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
    SELECT
        ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
    SELECT ''Attack Surface Mapping By Session'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
    SELECT ''Findings'' AS title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
    SELECT ''Nmap Scan Results'' AS title,
   ''#'' AS link;

--- Display Page Title
SELECT ''title'' AS component,
    ''Nmap Scan Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays parsed Nmap scan results extracted from XML stored in uniform_resource.content. 
        It includes host IP, port, protocol, state, and detected service details to help assess open services and network exposure.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_nmap WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    tenant_name       AS  "Tenant",
    host_ip           AS "Host IP",
    protocol          AS "Protocol",
    port              AS "Port",
    state             AS "State",
    service_name      AS "Service",
    service_product   AS "Product",
    service_version   AS "Version",
    service_extrainfo AS "Extra Info",
    tool_name         AS "Tool"
FROM tem_nmap WHERE ur_ingest_session_id = $session_id;;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/katana.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/katana.sql/index.sql'') as contents;
    ;

--- Display breadcrumb
SELECT ''breadcrumb'' AS component;
    SELECT
        ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT
        ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;
    SELECT
        ''Attack Surface Mapping By Tenant'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
    SELECT tenant_name AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id
        AS link
    FROM tem_tenant WHERE tenant_id = $tenant_id;
    SELECT ''Findings'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
    SELECT ''Katana Scan Results'' AS title,
        ''#'' AS link;

--- Page title
SELECT ''title'' AS component,
    ''Katana Scan Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays parsed Katana scan results extracted from JSONL stored in uniform_resource.content. 
    Each record includes the request method, endpoint, status code, and timestamp, 
    helping to analyze web exposure discovered during reconnaissance.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_katana WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
   strftime(''%m-%d-%Y'', timestamp) AS "Observed At",
    method        AS "Method",
    endpoint      AS "Endpoint",
    COALESCE(
        printf(''%s'', status_code),
        ''N/A''
    )                               AS "Status Code"
FROM tem_katana
WHERE tenant_id = $tenant_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/katana.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/katana.sql/index.sql'') as contents;
    ;

--- Breadcrumb
SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
    SELECT ''Attack Surface Mapping By Session'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
    SELECT ''Findings'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
    SELECT ''Katana Scan Results'' AS title,
        ''#'' AS link;

--- Page Title
SELECT ''title'' AS component,
    ''Katana Scan Results'' AS contents;

--- Page Description
SELECT ''text'' AS component,
    ''This page displays parsed Katana scan results extracted from JSONL stored in uniform_resource.content. 
     It includes request and response details such as method, endpoint, status code, and observed timestamps 
     to assist in analyzing web application surface mapping.'' AS contents;

--- Table Config
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_katana WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    tenant_name  AS "Tenant",
    strftime(''%m-%d-%Y %H:%M:%S'', timestamp) AS "Observed At",
    method       AS "Method",
    endpoint     AS "Endpoint",
    COALESCE(status_code, ''N/A'') AS "Status Code"
FROM tem_katana
WHERE ur_ingest_session_id = $session_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/tlsx_certificate.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/tlsx_certificate.sql/index.sql'') as contents;
    ;

--- Breadcrumb setup
SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;
    SELECT ''Attack Surface Mapping By Tenant'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
    SELECT tenant_name AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link
    FROM tem_tenant WHERE tenant_id = $tenant_id;
    SELECT ''Findings'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
    SELECT ''TLS Certificate Results'' AS title,
        ''#'' AS link;

--- Page title
SELECT ''title'' AS component,
    ''TLS Certificate Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays parsed TLS certificate scan results from tlsx JSONL data stored in uniform_resource.content.
    Each record includes host, IP, port, TLS version, cipher suite, subject/issuer details, fingerprints, and validity period.
    This helps assess TLS configuration, certificate trust, and potential misconfigurations.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_tlsx_certificate WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    strftime(''%m-%d-%Y'', observed_at) AS "Observed At",
    host                              AS "Host",
    ip_address                        AS "IP Address",
    port                              AS "Port",
    probe_status                      AS "Probe Status",
    tls_version                       AS "TLS Version",
    is_self_signed                    AS "Self-Signed",
    is_mismatched                     AS "Mismatched",
    strftime(''%m-%d-%Y'', valid_from)  AS "Valid From",
    strftime(''%m-%d-%Y'', valid_until) AS "Valid Until",
    serial_number                     AS "Serial",
    issuer_dn                         AS "Issuer DN",
    issuer_cn                         AS "Issuer CN",
    tls_connection                    AS "TLS Connection",
    sni                               AS "SNI"
FROM tem_tlsx_certificate
WHERE tenant_id = $tenant_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/tlsx_certificate.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/tlsx_certificate.sql/index.sql'') as contents;
    ;

 --- Breadcrumb setup
SELECT ''breadcrumb'' AS component;
     SELECT ''Home'' AS title,
         sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
     SELECT ''Threat Exposure Management'' AS title,
         sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
     SELECT ''Attack Surface Mapping By Session'' AS title,
         sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
     SELECT ''Findings'' AS title,
         sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
     SELECT ''TLS Certificate Results'' AS title,
         ''#'' AS link;

 --- Page title
 SELECT ''title'' AS component,
     ''TLS Certificate Results'' AS contents;

 --- Page description
 SELECT ''text'' AS component,
     ''This page displays parsed TLS certificate scan results from tlsx JSONL data stored in uniform_resource.content.
     Each record includes host, IP, port, TLS version, cipher suite, subject/issuer details, fingerprints, and validity period.
     This helps assess TLS configuration, certificate trust, and potential misconfigurations.'' AS contents;

 --- Table setup
 SELECT ''table'' AS component,
     TRUE AS sort,
     TRUE AS search;

 SET total_rows = (SELECT COUNT(*) FROM tem_tlsx_certificate WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
 SELECT
     tenant_name  AS "Tenant",
     strftime(''%m-%d-%Y'', observed_at) AS "Observed At",
     host                              AS "Host",
     ip_address                        AS "IP Address",
     port                              AS "Port",
     probe_status                      AS "Probe Status",
     tls_version                       AS "TLS Version",
     is_self_signed                    AS "Self-Signed",
     is_mismatched                     AS "Mismatched",
     strftime(''%m-%d-%Y'', valid_from)  AS "Valid From",
     strftime(''%m-%d-%Y'', valid_until) AS "Valid Until",
     serial_number                     AS "Serial",
     issuer_dn                         AS "Issuer DN",
     issuer_cn                         AS "Issuer CN",
     tls_connection                    AS "TLS Connection",
     sni                               AS "SNI"
 FROM tem_tlsx_certificate
 WHERE ur_ingest_session_id = $session_id;

 SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/dirsearch.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/dirsearch.sql/index.sql'') as contents;
    ;

--- Breadcrumb setup
SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;
    SELECT ''Attack Surface Mapping By Tenant'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
    SELECT tenant_name AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link
    FROM tem_tenant WHERE tenant_id = $tenant_id;
    SELECT ''Findings'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
    SELECT ''Dirsearch Web Path Enumeration Results'' AS title,
        ''#'' AS link;

--- Page title
SELECT ''title'' AS component,
    ''Dirsearch Web Path Enumeration Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays parsed results from the Dirsearch tool, which scans web applications to enumerate hidden files and directories. 
    Each entry shows the discovered URL, HTTP status code, content type, response length, and any redirect information.
    These insights help identify sensitive endpoints, misconfigurations, or exposed resources within a tenant’s web application footprint.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_dirsearch WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    observed_at AS "Observed At",
    discovered_url   AS "Discovered URL",
    status_code      AS "Status Code",
    content_type     AS "Content Type",
    content_length   AS "Content Length",
    redirect_url     AS "Redirect"
FROM tem_dirsearch
WHERE tenant_id = $tenant_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/dirsearch.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/dirsearch.sql/index.sql'') as contents;
    ;

--- Breadcrumb setup
  SELECT ''breadcrumb'' AS component;
      SELECT ''Home'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
      SELECT ''Threat Exposure Management'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
      SELECT ''Attack Surface Mapping By Session'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
      SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
    SELECT ''Dirsearch Web Path Enumeration Results'' AS title,
        ''#'' AS link;

--- Page title
SELECT ''title'' AS component,
    ''Dirsearch Web Path Enumeration Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays parsed results from the Dirsearch tool, which scans web applications to enumerate hidden files and directories. 
    Each entry shows the discovered URL, HTTP status code, content type, response length, and any redirect information.
    These insights help identify sensitive endpoints, misconfigurations, or exposed resources within a session’s web application footprint.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_dirsearch WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    tenant_name  AS "Tenant",
    observed_at AS "Observed At",
    discovered_url   AS "Discovered URL",
    status_code AS "Status Code",
    content_type     AS "Content Type",
    content_length   AS "Content Length",
    COALESCE(redirect_url, ''-'') AS "Redirect"
FROM tem_dirsearch
WHERE ur_ingest_session_id = $session_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/tssl_certificate.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/tssl_certificate.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''TestSSL Report'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''TestSSL Report'' as contents;

  SELECT
    ''text''              as component,
    ''The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.'' as contents;
  
   SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search,
    ''Host'' as markdown;

SET total_rows = (SELECT COUNT(*) FROM tem_testssl_general WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
     ''['' || host || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/tssl_certificate_inner.sql?component=tab&tab=pretests&uniform_resource_id='' || uniform_resource_id ||''&tenant_id=''||$tenant_id||'')'' as Host,
    datetime(start_time, ''unixepoch'') AS "start time",
    ip,
    port,
    rdns
FROM tem_testssl_general
WHERE tenant_id = $tenant_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/tssl_certificate_inner.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/tssl_certificate_inner.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Tenant'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
  SELECT tenant_name AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
  SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
  SELECT ''TestSSL Report'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/tssl_certificate.sql?tenant_id='' || $tenant_id AS link;
  SELECT host AS title,
      ''#'' AS link
  FROM tem_testssl_general
  WHERE tenant_id = $tenant_id;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''TestSSL Report'' as contents;

  SELECT
    ''text''              as component,
    ''The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.'' as contents;
  


  select 
  ''table'' as component,
  TRUE    as freeze_columns,
  TRUE    as freeze_headers,
  TRUE    as border;  
     
      select 
          ''Invocation'' as ''General Info'',
          invocation as ''Value''
          FROM tem_testssl_general WHERE tenant_id=$tenant_id
      union all
      select 
          ''Open SSL'' as ''General Info'',
          openssl as ''Value''
          FROM tem_testssl_general WHERE tenant_id=$tenant_id
      union all
      select 
          ''Version'' as ''General Info'',
          version as ''Value''
          FROM tem_testssl_general WHERE tenant_id=$tenant_id
      union all
      select 
          ''Host'' as ''General Info'',
          host as ''Value''
          FROM tem_testssl_general WHERE tenant_id=$tenant_id
      union all
      select 
          ''ip'' as ''General Info'',
          ip as ''Value''
          FROM tem_testssl_general WHERE tenant_id=$tenant_id
      union all
      select 
          ''port'' as ''General Info'',
          port as ''Value''
          FROM tem_testssl_general WHERE tenant_id=$tenant_id
      union all
      select 
          ''service'' as ''General Info'',
          service as ''Value''
          FROM tem_testssl_general WHERE tenant_id=$tenant_id

 select 
      ''tab'' as component;
  -- Pretests tab (active only if tab=pretests) 
  select 
      ''Pretests'' as title,
      (coalesce($tab, ''pretests'') = ''pretests'') as active,
      ''?component=tab&tab=pretests&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- Protocols tab (active only if tab=protocols) 
  select 
      ''Protocols'' as title,
      ($tab = ''protocols'') as active,
      ''?component=tab&tab=protocols&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

   -- Ciphers tab (active only if tab=ciphers)
  select 
      ''Ciphers'' as title,
      ($tab = ''ciphers'') as active,
      ''?component=tab&tab=ciphers&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- Server Preferences tab (active only if tab=server-preferences)
  select 
      ''Server Preferences'' as title,
      ($tab = ''server-preferences'') as active,
      ''?component=tab&tab=server-preferences&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- Forward Secrecy (active only if tab=forward-secrecy)
  select 
      ''Forward Secrecy'' as title,
      ($tab = ''forward-secrecy'') as active,
      ''?component=tab&tab=forward-secrecy&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- Server Defaults / Certificates (active only if tab=protocols)
  select 
      ''Server Defaults / Certificates'' as title,
      ($tab = ''server-defaults'') as active,
      ''?component=tab&tab=server-defaults&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- HTTP Response Headers (active only if tab=http-response-header)
  select 
      ''HTTP Response Headers'' as title,
      ($tab = ''http-response-header'') as active,
      ''?component=tab&tab=http-response-header&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- Vulnerabilities (active only if tab=http-response-header)
  select 
      ''Vulnerabilities'' as title,
      ($tab = ''vulnerabilitie'') as active,
      ''?component=tab&tab=vulnerabilitie&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- Browser Simulations (active only if tab=browser-simulations)
  select 
      ''Browser Simulations'' as title,
      ($tab = ''browser-simulations'') as active,
      ''?component=tab&tab=browser-simulations&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

  -- Rating (active only if tab=rating)
  select 
      ''Rating'' as title,
      ($tab = ''rating'') as active,
      ''?component=tab&tab=rating&uniform_resource_id=''||$uniform_resource_id||''&tenant_id=''||$tenant_id as link;

      -- Pretests tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_pretest WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Pretests'' as contents WHERE $tab = ''pretests'';
      SELECT
      ''text''              as component,
      ''Quick preliminary checks performed before the detailed scan. These verify basic connectivity, service availability, and whether the host can be tested reliably.'' as contents
      WHERE $tab = ''pretests'';
  
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''pretests'';
      select id,severity,finding from tem_testssl_pretest where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''pretests'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''pretests'';
        ;;

      -- Protocols tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_protocols WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Protocols'' as contents WHERE $tab = ''protocols'';
      SELECT
      ''text''              as component,
      ''Lists the supported SSL/TLS protocol versions (e.g., TLS 1.0, 1.2, 1.3). Helps identify if older, insecure protocols are enabled or only modern secure ones are accepted.'' as contents
      WHERE $tab = ''protocols'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''protocols'';
      select id,severity,finding from tem_testssl_protocols where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''protocols'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''protocols'';
        ;;

      -- Ciphers tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_ciphers WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Ciphers'' as contents WHERE $tab = ''ciphers'';
      SELECT
      ''text''              as component,
      ''Shows the encryption algorithms (ciphers) supported by the server. Weak or outdated ciphers (like CBC-based ones) are flagged, while strong ciphers are marked safe.'' as contents
      WHERE $tab = ''ciphers'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''ciphers'';
      select id,severity,finding from tem_testssl_ciphers where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''ciphers'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''ciphers'';
        ;;

      -- Server Preferences tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_server_references WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Server Preferences'' as contents WHERE $tab = ''server-preferences'';
      SELECT
      ''text''              as component,
      ''Describes how the server prioritizes protocols and ciphers. For example, whether the server enforces its own cipher order or allows clients to choose.'' as contents
      WHERE $tab = ''server-preferences'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''server-preferences'';
      select id,severity,finding from tem_testssl_server_references where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''server-preferences'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''server-preferences'';
        ;;

      -- Forward Secrecy (FS) tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_fs WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Forward Secrecy (FS)'' as contents WHERE $tab = ''forward-secrecy'';
      SELECT
      ''text''              as component,
      ''Checks whether the server supports forward secrecy using key exchange methods (e.g., ECDHE). FS ensures that past communications remain secure even if the server’s private key is compromised later.'' as contents
      WHERE $tab = ''forward-secrecy'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''forward-secrecy'';
      select id,severity,finding from tem_testssl_fs where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''forward-secrecy'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''forward-secrecy'';
        ;;

      -- Server Defaults / Certificates tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_server_default WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Server Defaults / Certificates'' as contents WHERE $tab = ''server-defaults'';
      SELECT
      ''text''              as component,
      ''Displays SSL/TLS certificate information such as common name, issuer, validity, and other defaults. This helps verify domain ownership, certificate authority, and expiration.'' as contents
      WHERE $tab = ''server-defaults'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''server-defaults'';
      select id,severity,finding from tem_testssl_server_default where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''server-defaults'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''server-defaults'';
        ;;

      -- HTTP Response Headers tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_header_response WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''HTTP Response Headers'' as contents WHERE $tab = ''http-response-header'';
      SELECT
      ''text''              as component,
      ''Lists security-related HTTP headers (e.g., HSTS, X-Frame-Options, CSP). These help protect against attacks like clickjacking, XSS, or protocol downgrade.'' as contents
      WHERE $tab = ''http-response-header'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''http-response-header'';
      select header_response_id as "header response id",severity,finding from tem_testssl_header_response where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''http-response-header'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''http-response-header'';
        ;;

      -- Vulnerabilities tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_vulnerabilitie WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Vulnerabilities'' as contents WHERE $tab = ''vulnerabilitie'';
      SELECT
      ''text''              as component,
      ''Tests the server against known SSL/TLS vulnerabilities (e.g., Heartbleed, POODLE, LUCKY13). Any positive finding here indicates a serious risk.'' as contents
      WHERE $tab = ''vulnerabilitie'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''vulnerabilitie'';
      select vulnerability_id as "vulnerability id",severity,finding from tem_testssl_vulnerabilitie where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''vulnerabilitie'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''vulnerabilitie'';
        ;;

      -- Browser Simulations tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_browser_simulation WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Browser Simulations'' as contents WHERE $tab = ''browser-simulations'';
      SELECT
      ''text''              as component,
      ''Simulates how different browsers and versions connect to the server. This helps verify compatibility and whether old browsers are blocked from insecure connections.'' as contents
      WHERE $tab = ''browser-simulations'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''browser-simulations'';
      select simulation_id as "simulation id",severity,finding from tem_testssl_browser_simulation where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''browser-simulations'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''browser-simulations'';
        ;;

     -- Rating Simulations tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_rating WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
       SELECT
      ''title''   as component,
      ''Rating'' as contents WHERE $tab = ''rating'';
      SELECT
      ''text''              as component,
      ''Provides an overall grade (A, B, etc.) summarizing the server’s SSL/TLS configuration strength. This is often based on industry benchmarks like SSL Labs grading.'' as contents
      WHERE $tab = ''rating'';
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''rating'';
      select rating_id as "rating id",severity,finding from tem_testssl_rating where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = ''rating'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''rating'';
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/tssl_certificate.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/tssl_certificate.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
   SELECT ''breadcrumb'' AS component;
      SELECT ''Home'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
      SELECT ''Threat Exposure Management'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
      SELECT ''Attack Surface Mapping By Session'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
      SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
  SELECT ''TestSSL Report'' AS title,
      ''#'' AS link;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''TestSSL Report'' as contents;

  SELECT
    ''text''              as component,
    ''The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.'' as contents;
  
   SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search,
    ''Host'' as markdown;

SET total_rows = (SELECT COUNT(*) FROM tem_testssl_general WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
     ''['' || host || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/tssl_certificate_inner.sql?component=tab&tab=pretests&uniform_resource_id='' || uniform_resource_id ||''&session_id=''||$session_id||'')'' as Host,
    datetime(start_time, ''unixepoch'') AS "start time",
    ip,
    port,
    rdns,
    tenant_name  AS "Tenant"
FROM tem_testssl_general
WHERE ur_ingest_session_id = $session_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/tssl_certificate_inner.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/tssl_certificate_inner.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT ''breadcrumb'' AS component;
  SELECT ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
  SELECT ''Threat Exposure Management'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
  SELECT ''Attack Surface Mapping By Session'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
  SELECT ''Findings'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
  SELECT ''TestSSL Report'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/tssl_certificate.sql?session_id='' || $session_id AS link;
  SELECT host AS title,
      ''#'' AS link
  FROM tem_testssl_general
  WHERE ur_ingest_session_id = $session_id;

  --- Dsply Page Title
  SELECT
    ''title''   as component,
    ''TestSSL Report'' as contents;

  SELECT
    ''text''              as component,
    ''The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.'' as contents;
  


  select 
  ''table'' as component,
  TRUE    as freeze_columns,
  TRUE    as freeze_headers,
  TRUE    as border;  
     select 
          ''Tenant'' as ''General Info'',
          tenant_name as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
      union all
      select 
          ''Invocation'' as ''General Info'',
          invocation as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
      union all
      select 
          ''Open SSL'' as ''General Info'',
          openssl as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
      union all
      select 
          ''Version'' as ''General Info'',
          version as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
      union all
      select 
          ''Host'' as ''General Info'',
          host as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
      union all
      select 
          ''ip'' as ''General Info'',
          ip as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
      union all
      select 
          ''port'' as ''General Info'',
          port as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
      union all
      select 
          ''service'' as ''General Info'',
          service as ''Value''
          FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id

 select 
      ''tab'' as component;
  -- Pretests tab (active only if tab=pretests) 
  select 
      ''Pretests'' as title,
      (coalesce($tab, ''pretests'') = ''pretests'') as active,
      ''?component=tab&tab=pretests&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- Protocols tab (active only if tab=protocols) 
  select 
      ''Protocols'' as title,
      ($tab = ''protocols'') as active,
      ''?component=tab&tab=protocols&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

   -- Ciphers tab (active only if tab=ciphers)
  select 
      ''Ciphers'' as title,
      ($tab = ''ciphers'') as active,
      ''?component=tab&tab=ciphers&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- Server Preferences tab (active only if tab=server-preferences)
  select 
      ''Server Preferences'' as title,
      ($tab = ''server-preferences'') as active,
      ''?component=tab&tab=server-preferences&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- Forward Secrecy (active only if tab=forward-secrecy)
  select 
      ''Forward Secrecy'' as title,
      ($tab = ''forward-secrecy'') as active,
      ''?component=tab&tab=forward-secrecy&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- Server Defaults / Certificates (active only if tab=protocols)
  select 
      ''Server Defaults / Certificates'' as title,
      ($tab = ''server-defaults'') as active,
      ''?component=tab&tab=server-defaults&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- HTTP Response Headers (active only if tab=http-response-header)
  select 
      ''HTTP Response Headers'' as title,
      ($tab = ''http-response-header'') as active,
      ''?component=tab&tab=http-response-header&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- Vulnerabilities (active only if tab=http-response-header)
  select 
      ''Vulnerabilities'' as title,
      ($tab = ''vulnerabilitie'') as active,
      ''?component=tab&tab=vulnerabilitie&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- Browser Simulations (active only if tab=browser-simulations)
  select 
      ''Browser Simulations'' as title,
      ($tab = ''browser-simulations'') as active,
      ''?component=tab&tab=browser-simulations&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

  -- Rating (active only if tab=rating)
  select 
      ''Rating'' as title,
      ($tab = ''rating'') as active,
      ''?component=tab&tab=rating&uniform_resource_id=''||$uniform_resource_id||''&session_id=''||$session_id as link;

      -- Pretests tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_pretest WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
      ''title''   as component,
      ''Pretests'' as contents
      WHERE $tab = ''pretests'';
      SELECT
      ''text''              as component,
      ''Quick preliminary checks performed before the detailed scan. These verify basic connectivity, service availability, and whether the host can be tested reliably.'' as contents
      WHERE $tab = ''pretests'';
  
      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''pretests'';
      select id,severity,finding from tem_testssl_pretest where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''pretests'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''pretests'';
        ;;

      -- Protocols tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_protocols WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
          ''title''   as component,
          ''Protocols'' as contents WHERE $tab = ''protocols'';
      SELECT
          ''text''              as component,
          ''Lists the supported SSL/TLS protocol versions (e.g., TLS 1.0, 1.2, 1.3). Helps identify if older, insecure protocols are enabled or only modern secure ones are accepted.'' as contents
      WHERE $tab = ''protocols'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''protocols'';
      select id,severity,finding from tem_testssl_protocols where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''protocols'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''protocols'';
        ;;

      -- Ciphers tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_ciphers WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
          ''title''   as component,
          ''Ciphers'' as contents WHERE $tab = ''ciphers'';
      SELECT
          ''text''              as component,
          ''Shows the encryption algorithms (ciphers) supported by the server. Weak or outdated ciphers (like CBC-based ones) are flagged, while strong ciphers are marked safe.'' as contents
      WHERE $tab = ''ciphers'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''ciphers'';
      select id,severity,finding from tem_testssl_ciphers where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''ciphers'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''ciphers'';
        ;;

      -- Server Preferences tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_server_references WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
          ''title''   as component,
          ''Server Preferences'' as contents WHERE $tab = ''server-preferences'';
      SELECT
          ''text''              as component,
          ''Describes how the server prioritizes protocols and ciphers. For example, whether the server enforces its own cipher order or allows clients to choose.'' as contents
      WHERE $tab = ''server-preferences'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''server-preferences'';
      select id,severity,finding from tem_testssl_server_references where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''server-preferences'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''server-preferences'';
        ;;

      -- Forward Secrecy (FS) tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_fs WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
          ''title''   as component,
          ''Forward Secrecy (FS)'' as contents WHERE $tab = ''forward-secrecy'';
      SELECT
          ''text''              as component,
          ''Checks whether the server supports forward secrecy using key exchange methods (e.g., ECDHE). FS ensures that past communications remain secure even if the server’s private key is compromised later.'' as contents
      WHERE $tab = ''forward-secrecy'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''forward-secrecy'';
      select id,severity,finding from tem_testssl_fs where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''forward-secrecy'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''forward-secrecy'';
        ;;

      -- Server Defaults / Certificates tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_server_default WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
          ''title''   as component,
          ''Server Defaults / Certificates'' as contents WHERE $tab = ''server-defaults'';
      SELECT
          ''text''              as component,
          ''Displays SSL/TLS certificate information such as common name, issuer, validity, and other defaults. This helps verify domain ownership, certificate authority, and expiration.'' as contents
      WHERE $tab = ''server-defaults'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''server-defaults'';
      select id,severity,finding from tem_testssl_server_default where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''server-defaults'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''server-defaults'';
        ;;

      -- HTTP Response Headers tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_header_response WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
          ''title''   as component,
          ''HTTP Response Headers'' as contents WHERE $tab = ''http-response-header'';
      SELECT
          ''text''              as component,
          ''Lists security-related HTTP headers (e.g., HSTS, X-Frame-Options, CSP). These help protect against attacks like clickjacking, XSS, or protocol downgrade.'' as contents
      WHERE $tab = ''http-response-header'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''http-response-header'';
      select header_response_id as "header response id",severity,finding from tem_testssl_header_response where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''http-response-header'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''http-response-header'';
        ;;

      -- Vulnerabilities tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_vulnerabilitie WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
      SELECT
          ''title''   as component,
          ''Vulnerabilities'' as contents WHERE $tab = ''vulnerabilitie'';
      SELECT
          ''text''              as component,
          ''Tests the server against known SSL/TLS vulnerabilities (e.g., Heartbleed, POODLE, LUCKY13). Any positive finding here indicates a serious risk.'' as contents
      WHERE $tab = ''vulnerabilitie'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''vulnerabilitie'';
      select vulnerability_id as "vulnerability id",severity,finding from tem_testssl_vulnerabilitie where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''vulnerabilitie'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''vulnerabilitie'';
        ;;

      -- Browser Simulations tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_browser_simulation WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
       SELECT
          ''title''   as component,
          ''Browser Simulations'' as contents WHERE $tab = ''browser-simulations'';
      SELECT
          ''text''              as component,
          ''Simulates how different browsers and versions connect to the server. This helps verify compatibility and whether old browsers are blocked from insecure connections.'' as contents
      WHERE $tab = ''browser-simulations'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''browser-simulations'';
      select simulation_id as "simulation id",severity,finding from tem_testssl_browser_simulation where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''browser-simulations'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''browser-simulations'';
        ;;

     -- Rating Simulations tab
      SET total_rows = (SELECT COUNT(*) FROM tem_testssl_rating WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
       SELECT
          ''title''   as component,
          ''Rating'' as contents WHERE $tab = ''rating'';
      SELECT
          ''text''              as component,
          ''Provides an overall grade (A, B, etc.) summarizing the server’s SSL/TLS configuration strength. This is often based on industry benchmarks like SSL Labs grading.'' as contents
      WHERE $tab = ''rating'';

      SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search,
          ''Host'' as markdown where $tab = ''rating'';
      select rating_id as "rating id",severity,finding from tem_testssl_rating where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = ''rating'';
      SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&component='' || replace($component, '' '', ''%20''), '''') || COALESCE(''&tab='' || replace($tab, '' '', ''%20''), '''') || COALESCE(''&uniform_resource_id='' || replace($uniform_resource_id, '' '', ''%20''), '''') || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
 WHERE $tab=''rating'';
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/openssl.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/openssl.sql/index.sql'') as contents;
    ;

  --- Breadcrumb setup
  SELECT ''breadcrumb'' AS component;
      SELECT ''Home'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
      SELECT ''Threat Exposure Management'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;
      SELECT ''Attack Surface Mapping By Tenant'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
      SELECT tenant_name AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link
      FROM tem_tenant WHERE tenant_id = $tenant_id;
      SELECT ''Findings'' AS title,
          sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
      SELECT ''SSL/TLS Certificate Metadata'' AS title,
          ''#'' AS link;

  --- Page title
  SELECT ''title'' AS component,
      ''SSL/TLS Certificate Metadata'' AS contents;

  --- Page description
  SELECT ''text'' AS component,
      ''This page displays structured SSL/TLS certificate details extracted from OpenSSL output. 
      Each row represents a certificate discovered within the tenant’s infrastructure, showing subject details, issuer information, and validity periods. 
      These insights help assess certificate ownership, identify expired or weakly issued certificates, and strengthen the tenant’s security posture.'' AS contents;

  --- Table setup
  SELECT ''table'' AS component,
      TRUE AS sort,
      TRUE AS search;

  SET total_rows = (SELECT COUNT(*) FROM tem_openssl WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
 SELECT
    CASE WHEN common_name IS NULL OR trim(common_name) = '''' THEN ''-'' ELSE common_name END AS "Common Name",
    CASE WHEN subject_organization IS NULL OR trim(subject_organization) = '''' THEN ''-'' ELSE subject_organization END AS "Subject Organization",
    CASE WHEN issuer_common_name IS NULL OR trim(issuer_common_name) = '''' THEN ''-'' ELSE issuer_common_name END AS "Issuer CN",
    CASE WHEN issuer_organization IS NULL OR trim(issuer_organization) = '''' THEN ''-'' ELSE issuer_organization END AS "Issuer Organization",
    CASE WHEN issuer_country IS NULL OR trim(issuer_country) = '''' THEN ''-'' ELSE issuer_country END AS "Issuer Country",

    -- Issued Date
    CASE
        WHEN issued_date IS NULL OR trim(issued_date) = '''' THEN ''-''
        ELSE printf(
                ''%s %s %s'',
                trim(substr(replace(replace(issued_date, ''  '', '' ''), ''  '', '' ''), 1, 3)),
                trim(substr(replace(replace(issued_date, ''  '', '' ''), ''  '', '' ''), 5, 2)),
                trim(substr(replace(replace(issued_date, ''  '', '' ''), ''  '', '' ''), -9, 4))
            )
    END AS "Issued Date",

    -- Expires Date
    CASE
        WHEN expires_date IS NULL OR trim(expires_date) = '''' THEN ''-''
        ELSE printf(
                ''%s %s %s'',
                trim(substr(replace(replace(expires_date, ''  '', '' ''), ''  '', '' ''), 1, 3)),
                trim(substr(replace(replace(expires_date, ''  '', '' ''), ''  '', '' ''), 5, 2)),
                trim(substr(replace(replace(expires_date, ''  '', '' ''), ''  '', '' ''), -9, 4))
            )
    END AS "Expires Date"

FROM tem_openssl
WHERE tenant_id = $tenant_id;

  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/openssl.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/openssl.sql/index.sql'') as contents;
    ;

--- Breadcrumb setup
    SELECT ''breadcrumb'' AS component;
        SELECT ''Home'' AS title,
            sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
        SELECT ''Threat Exposure Management'' AS title,
            sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;  
        SELECT ''Attack Surface Mapping By Session'' AS title,
            sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
        SELECT ''Findings'' AS title,
            sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
        SELECT ''SSL/TLS Certificate Metadata'' AS title,
            ''#'' AS link;

--- Page title
SELECT ''title'' AS component,
    ''SSL/TLS Certificate Metadata'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays structured SSL/TLS certificate details extracted from OpenSSL output for a given session. 
    Each row represents a certificate discovered within the session’s infrastructure, showing subject details, issuer information, and validity periods. 
    These insights help assess certificate ownership, identify expired or weakly issued certificates, and strengthen the session’s security posture.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_openssl WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    CASE WHEN tenant_name IS NULL OR trim(tenant_name) = '''' THEN ''-'' ELSE tenant_name END AS "Tenant",
    CASE WHEN common_name IS NULL OR trim(common_name) = '''' THEN ''-'' ELSE common_name END AS "Common Name",
    CASE WHEN subject_organization IS NULL OR trim(subject_organization) = '''' THEN ''-'' ELSE subject_organization END AS "Subject Organization",
    CASE WHEN issuer_common_name IS NULL OR trim(issuer_common_name) = '''' THEN ''-'' ELSE issuer_common_name END AS "Issuer CN",
    CASE WHEN issuer_organization IS NULL OR trim(issuer_organization) = '''' THEN ''-'' ELSE issuer_organization END AS "Issuer Organization",
    CASE WHEN issuer_country IS NULL OR trim(issuer_country) = '''' THEN ''-'' ELSE issuer_country END AS "Issuer Country",

    -- Issued Date
    CASE
        WHEN issued_date IS NULL OR trim(issued_date) = '''' THEN ''-''
        ELSE printf(
                ''%s %s %s'',
                trim(substr(replace(replace(issued_date, ''  '', '' ''), ''  '', '' ''), 1, 3)),
                trim(substr(replace(replace(issued_date, ''  '', '' ''), ''  '', '' ''), 5, 2)),
                trim(substr(replace(replace(issued_date, ''  '', '' ''), ''  '', '' ''), -9, 4))
            )
    END AS "Issued Date",

    -- Expires Date
    CASE
        WHEN expires_date IS NULL OR trim(expires_date) = '''' THEN ''-''
        ELSE printf(
                ''%s %s %s'',
                trim(substr(replace(replace(expires_date, ''  '', '' ''), ''  '', '' ''), 1, 3)),
                trim(substr(replace(replace(expires_date, ''  '', '' ''), ''  '', '' ''), 5, 2)),
                trim(substr(replace(replace(expires_date, ''  '', '' ''), ''  '', '' ''), -9, 4))
            )
    END AS "Expires Date"

FROM tem_openssl
WHERE ur_ingest_session_id = $session_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/tenant/wafw00f.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/tenant/wafw00f.sql/index.sql'') as contents;
    ;

--- Breadcrumb setup
SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;
    SELECT ''Attack Surface Mapping By Tenant'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_tenant.sql'' AS link;
    SELECT tenant_name AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/attack_surface_mapping_inner.sql?tenant_id='' || $tenant_id AS link
    FROM tem_tenant
    WHERE tenant_id = $tenant_id;
    SELECT ''Pentest Findings'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/tenant/finding.sql?tenant_id='' || $tenant_id AS link;
    SELECT ''WAF Detection Results'' AS title,
        ''#'' AS link;

--- Page title
SELECT ''title'' AS component,
    ''WAF Detection Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays the WAFW00F penetration testing results for the tenant. Each row corresponds to a scanned host/domain within the tenant’s infrastructure. 
    The host column shows the scanned domain, and the Scan Output column contains the full WAFW00F scan block for reference.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_wafw00f WHERE tenant_id = $tenant_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    host AS "Host/Domain",
    block_content AS "Scan Output"
FROM tem_wafw00f
WHERE tenant_id = $tenant_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&tenant_id='' || replace($tenant_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'tem/session/wafw00f.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''tem/session/wafw00f.sql/index.sql'') as contents;
    ;

--- Breadcrumb setup
SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Threat Exposure Management'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/index.sql'' AS link;
    SELECT ''Attack Surface Mapping By Session'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/attack_surface_mapping_session.sql'' AS link;
    SELECT ''Findings'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/tem/session/finding.sql?session_id='' || $session_id AS link;
    SELECT ''WAF Detection Results'' AS title,
        ''#'' AS link;

--- Page title
SELECT ''title'' AS component,
    ''WAF Detection Results'' AS contents;

--- Page description
SELECT ''text'' AS component,
    ''This page displays the WAFW00F penetration testing results for the given session. Each row corresponds to a scanned host/domain within the session’s infrastructure. 
    The Host/Domain column shows the scanned domain, and the Scan Output column contains the full WAFW00F scan block for reference.'' AS contents;

--- Table setup
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;

SET total_rows = (SELECT COUNT(*) FROM tem_wafw00f WHERE ur_ingest_session_id = $session_id);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
SELECT
    host AS "Host/Domain",
    block_content AS "Scan Output"
FROM tem_wafw00f
WHERE ur_ingest_session_id = $session_id;

SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&session_id='' || replace($session_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'sqlpage/templates/shell-custom.handlebars',
      '          
          
          
          

          <!DOCTYPE html>
      <html lang="{{language}}" style="font-size: {{default font_size 18}}px" {{#if class}} class="{{class}}" {{/if}}>
        <head>
        <meta charset="utf-8" />

          <!--Base CSS-->
            <link rel="stylesheet" href="{{static_path ''sqlpage.css''}}">
              {{#each (to_array css)}}
              {{#if this}}
<link rel="stylesheet" href="{{this}}">
  {{/if}}
{{/each}}

<!--Font Setup-->
  {{#if font}}
{{#if (starts_with font "/")}}
<style>
  @font-face {
  font-family: ''LocalFont'';
  src: url(''{{font}}'') format(''woff2'');
  font-weight: normal;
  font-style: normal;
}
                      :root {
  --tblr-font-sans-serif: ''LocalFont'', Arial, sans-serif;
}
</style>
{{else}}
<link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family={{font}}&display=fallback">
      <style>
                      :root {
  --tblr-font-sans-serif: ''{{font}}'', Arial, sans-serif;
}
</style>
{{/if}}
{{/if}}

<!--JavaScript-->
  <script src="{{static_path ''sqlpage.js''}}" defer nonce="{{@csp_nonce}}"></script>
{{#each (to_array javascript)}}
{{#if this}}
<script src="{{this}}" defer nonce="{{@../csp_nonce}}"></script>
{{/if}}
{{/each}}
{{#each (to_array javascript_module)}}
{{#if this}}
<script src="{{this}}" type="module" defer nonce="{{@../csp_nonce}}"></script>
{{/if}}
{{/each}}
</head>

  <body class="layout-{{#if sidebar}}fluid{{else}}{{default layout ''boxed''}}{{/if}}" {{#if theme}} data-bs-theme="{{theme}}" {{/if}}>
    <div class="page">
      <!--Header-->


        <!--Page Wrapper-->
          <div class="page-wrapper">
            <main class="page-body w-full flex-grow-1 px-0" id="sqlpage_main_wrapper">
              {{~#each_row~}}{{~/each_row~}}
</main>
  </div>
  </div>
  </body>
  </html>;
        ',
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

SELECT ''title'' AS component,
$name AS contents;
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
      'console/about.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/about.sql''
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
              

                 -- Title Component
    SELECT
    ''text'' AS component,
    (''Resource Surveillance v'' || replace(sqlpage.exec(''surveilr'', ''--version''), ''surveilr '', '''')) AS title;

    -- Description Component
      SELECT
          ''text'' AS component,
          ''A detailed description of what is incorporated into surveilr. It informs of critical dependencies like rusqlite, sqlpage, pgwire, e.t.c, ensuring they are present and meet version requirements. Additionally, it scans for and executes capturable executables in the PATH and evaluates surveilr_doctor_* database views for more insights.''
          AS contents_md;

      -- Section: Dependencies
      SELECT
          ''title'' AS component,
          ''Internal Dependencies'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          "Dependency",
          "Version"
      FROM (
          SELECT
              ''SQLPage'' AS "Dependency",
              json_extract(json_data, ''$.versions.sqlpage'') AS "Version"
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Pgwire'',
              json_extract(json_data, ''$.versions.pgwire'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Rusqlite'',
              json_extract(json_data, ''$.versions.rusqlite'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
      );

      -- Section: Static Extensions
      SELECT
          ''title'' AS component,
          ''Statically Linked Extensions'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          json_extract(value, ''$.name'') AS "Extension Name",
          json_extract(value, ''$.url'') AS "URL",
          json_extract(value, ''$.version'') AS "Version"
      FROM json_each(
          json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.static_extensions'')
      );

    -- Section: Dynamic Extensions
    SELECT
        ''title'' AS component,
        ''Dynamically Linked Extensions'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Extension Name",
        json_extract(value, ''$.path'') AS "Path"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.dynamic_extensions'')
    );

    -- Section: Environment Variables
    SELECT
        ''title'' AS component,
        ''Environment Variables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Variable",
        json_extract(value, ''$.value'') AS "Value"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.env_vars'')
    );

    -- Section: Capturable Executables
    SELECT
        ''title'' AS component,
        ''Capturable Executables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Executable Name",
        json_extract(value, ''$.output'') AS "Output"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.capturable_executables'')
    );

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;

SELECT
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md, ''$SITE_PREFIX_URL'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') AS "Content"
FROM console_information_schema_view
WHERE view_name LIKE ''surveilr_doctor%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/statistics/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/statistics/index.sql''
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
              

              SELECT ''datagrid'' as component;
SELECT ''Size'' as title, "db_size_mb" || '' MB'' as description FROM rssd_statistics_overview;
SELECT ''Tables'' as title, "total_tables" as description FROM rssd_statistics_overview;
SELECT ''Indexes'' as title, "total_indexes" as description FROM rssd_statistics_overview;
SELECT ''Rows'' as title, "total_rows" as description FROM rssd_statistics_overview;
SELECT ''Page Size'' as title, "page_size" as description FROM rssd_statistics_overview;
SELECT ''Total Pages'' as title, "total_pages" as description FROM rssd_statistics_overview;

select ''text'' as component, ''Tables'' as title;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT * FROM rssd_table_statistic ORDER BY table_size_mb DESC;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/behavior/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/behavior/index.sql''
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
              

              SELECT ''title'' AS component, ''Behavior Configuration'' AS contents;

SELECT ''text'' AS component,
  ''Behaviors are configuration presets that drive application operations at runtime, including ingest behaviors, file scanning configurations, and device-specific settings.'' AS contents;

-- Summary cards
SELECT ''card'' AS component, 3 AS columns;
SELECT
    ''Total Behaviors'' AS title,
    COUNT(*) AS description,
    ''blue'' AS color
FROM behavior
WHERE deleted_at IS NULL;

SELECT
    ''Active Devices'' AS title,
    COUNT(DISTINCT device_id) AS description,
    ''green'' AS color
FROM behavior
WHERE deleted_at IS NULL;

SELECT
    ''Unique Behavior Types'' AS title,
    COUNT(DISTINCT behavior_name) AS description,
    ''orange'' AS color
FROM behavior
WHERE deleted_at IS NULL;

-- Initialize pagination
SET total_rows = (SELECT COUNT(*) FROM behavior );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Behavior table with pagination
SELECT ''title'' AS component, ''Behavior Configurations'' AS contents, 2 AS level;
SELECT ''table'' AS component,
       ''Behavior Name'' as markdown,
       ''Device'' as markdown,
       TRUE as sort,
       TRUE as search;
SELECT
    ''['' || b.behavior_name || ''](behavior-detail.sql?behavior_id='' || b.behavior_id || '')'' AS "Behavior Name",
    ''['' || d.name || ''](/console/info-schema/table.sql?name=device)'' AS "Device",
    CASE
        WHEN LENGTH(b.behavior_conf_json) > 100
        THEN SUBSTR(b.behavior_conf_json, 1, 100) || ''...''
        ELSE b.behavior_conf_json
    END AS "Configuration Preview",
    b.created_at AS "Created",
    CASE
        WHEN b.updated_at IS NOT NULL THEN b.updated_at
        ELSE b.created_at
    END AS "Last Modified"
FROM behavior b
LEFT JOIN device d ON b.device_id = d.device_id
WHERE b.deleted_at IS NULL
ORDER BY b.created_at DESC
LIMIT $limit
OFFSET $offset;

-- Pagination controls
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/behavior/behavior-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              -- Breadcrumbs
SELECT ''breadcrumb'' as component;
SELECT ''Home'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT ''Console'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/index.sql'' as link;
SELECT ''Behavior'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/behavior/index.sql'' as link;
SELECT behavior_name as title FROM behavior WHERE behavior_id = $behavior_id;

SELECT ''title'' AS component,
       (SELECT behavior_name FROM behavior WHERE behavior_id = $behavior_id) AS contents;

SELECT ''text'' AS component,
  ''Detailed view of behavior configuration including JSON configuration, governance settings, and associated device information.'' AS contents;

-- Behavior details card
SELECT ''card'' AS component, 2 AS columns;
SELECT
    ''Behavior ID'' AS title,
    behavior_id AS description,
    ''blue'' AS color
FROM behavior
WHERE behavior_id = $behavior_id;

SELECT
    ''Device'' AS title,
    (SELECT name FROM device WHERE device_id = b.device_id) AS description,
    ''green'' AS color
FROM behavior b
WHERE behavior_id = $behavior_id;

-- Configuration details
SELECT ''title'' AS component, ''Configuration Details'' AS contents, 2 AS level;
SELECT ''table'' AS component;
SELECT
    ''Behavior Name'' AS "Property",
    behavior_name AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Device ID'' AS "Property",
    device_id AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Created At'' AS "Property",
    created_at AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Created By'' AS "Property",
    created_by AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Updated At'' AS "Property",
    COALESCE(updated_at, ''Never'') AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Updated By'' AS "Property",
    COALESCE(updated_by, ''N/A'') AS "Value"
FROM behavior WHERE behavior_id = $behavior_id;

-- JSON Configuration
SELECT ''title'' AS component, ''JSON Configuration'' AS contents, 2 AS level;
SELECT ''code'' AS component;
SELECT
    ''json'' as language,
    behavior_conf_json as contents
FROM behavior
WHERE behavior_id = $behavior_id;

-- Governance (if available)
SELECT ''title'' AS component, ''Governance'' AS contents, 2 AS level
WHERE EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);

SELECT ''code'' AS component
WHERE EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);

SELECT
    ''json'' as language,
    governance as contents
FROM behavior
WHERE behavior_id = $behavior_id AND governance IS NOT NULL;

-- Show message if no governance
SELECT ''text'' AS component,
       ''No governance configuration available for this behavior.'' AS contents
WHERE NOT EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/index.sql''
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
WHERE namespace = ''prime'' AND path = ''docs''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''docs''||''/index.sql''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/release-notes.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/release-notes.sql''
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
              

              SELECT ''title'' AS component, ''Release Notes for surveilr Versions'' as contents;

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.11'' as title, ''# `surveilr ` v1.8.11 Release Notes


##  🎉 New Feature: Automatic Document Processing & Metadata Extraction

## 🚀 What''''s New

Surveilr now automatically extracts metadata and converts documents to markdown during ingestion - no configuration
required!

Supported File Types

- PDF files: Full metadata extraction + markdown conversion
- DOCX files: Full metadata extraction + markdown conversion
- Images (PNG, JPEG, GIF, etc.): Metadata extraction (dimensions, format, file size)'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.9'' as title, ''# `surveilr ` v1.8.9 Release Notes

## 🚀 What''''s New

### **1. Surveilr ingestion Improvements**
- Image Ingestion Support - Fixed issues with image format ingestion during file processing
- GitHub API Rate Limiting - Enhanced rate limiting handling for GitHub PLM integration

### **2. Dependencies Update**
- OIDC/SSO Support - Added OpenID Connect and Single Sign-On support for surveilr web UI
- SQLPage Upgrade - Updated to latest SQLPage version'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.8'' as title, ''# `surveilr ` v1.8.8 Release Notes

## 🚀 What''''s New

### **1. Bug-fixes**
## Ingestion & PLM Issues (#320)
  - Fixed TLS crypto provider initialization issues
  - Fixed ingestion PLM issues with github
## CSV Transform Issues (#194)
  - Fixed CSV transform duplicate detection issues
## File Carving (#299)
  - Fixed file carving functionality'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.5'' as title, ''# `surveilr ` v1.8.5 Release Notes

## 🚀 What''''s New
### **1. Surveilr ingestion Improvements**
Prevent Duplication of Records in surveilr ingest files --csv-transform-auto Command

### **2. Changes to Osquery-ms**
- Platform Consistency: Darwin is the actual kernel name that macOS runs on, making it more technically
  accurate
- OSQuery Compatibility: Aligns with osquery''''s internal platform detection which uses "darwin"'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.4'' as title, ''# `surveilr ` v1.8.4 Release Notes

## 🚀 What''''s New
### **1. Surveilr ingestion Improvements**
Automatically detects and adds missing columns during surveilr ingestion.

### **2. Installation Config**
-The mac archive no longer contains a nested folder — you can now upgrade surveilr by running surveilr upgrade
-This fixes installation issues with scripts like install.ps1 and allows surveilr.exe to run immediately after extraction.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.3'' as title, ''# `surveilr ` v1.8.3 Release Notes

## 🚀 What''''s New
### **1. Admin Merge Improvements**
Automatically detects and adds missing columns during database schema merging.

### **2. Markdown Transformation Enhancements**
Introduced transform-md for parsing Markdown files and converting them into structured JSON.
Added support for Markdown querying using --md-select with the mdq library.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.2'' as title, ''# `surveilr ` v1.8.2 Release Notes

---

## 🚀 What''''s New

### **1. surveilr osquery-ms` Server**
- Significant enhancements and a complete overhaul of the file carving architecture in osQuery MS server'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.1'' as title, ''# `surveilr` v1.8.1 Release Notes

---

## 🚀 What''''s New

### **1. `sureilr osquery-ms` Server**
- Added distributed queries and file carving to the server.

'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.0'' as title, ''# `surveilr` v1.8.0 Release Notes

---

## 🚀 What''''s New

### **1. SQLPage**
- Updated SQLPage to the latest version, `v0.34.0`, ensuring compatibility and access to the newest features and bug fixes.

### 2. Introduced `surveilr_notebook_cell_exec`
`surveilr_notebook_cell_exec` is a function designed to execute queries stored in `code_notebook_cell`s against the RSSD. This is the SQLite function equivalent of the `surveilr notebook cat` command which only outputs the content of the `code_notebook_cell`, this function on other hand, executes it. It takes two arguments, the `notebook_name` and the `cell_name` and it returns either `true` or `false` to denote if the execution was succesful.

## Bug Fixes
1. Fixed the SQL query issue when `--persist-raw-logs` is passed to the `surveilr osquery-ms` server.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.25'' as title, ''# `surveilr` v1.7.13 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.16'' as title, ''# `surveilr` v1.7.16 Release Notes

## Bug Fixes
1. Enhanced the CSV transform functionality to correctly include partyID for each ingested CSV table when provided.

2. Resolved an issue where ingesting multiple CSV files with the same name from different folders resulted in data loss. Now, all files are consolidated into a single table while preserving distinct data sources with the partyID field.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.13'' as title, ''# `surveilr` v1.7.13 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.12'' as title, ''# `surveilr` v1.7.12 Release Notes

## 🚀 What''''s New

### 1. `surveilr osquery-ms` Server
The server has been fully setup, configured with boundaries and the corresponding WebUI, fully configurable with `code_notebooks`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.11'' as title, ''# `surveilr` v1.7.11 Release Notes

## 🚀 What''''s New

### 1. Upgraded SQLPage
SQLPage has been updated to version 0.33.1, aligning with the latest releases.

## Bug Fixes
### 1. `surveilr admin merge`
- Added recent and new tables to the merge structure ensuring all tables in each RSSD are present in the final merged RSSD.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.10'' as title, ''# `surveilr` v1.7.10 Release Notes

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Added support for boundaries to enable grouping of nodes for better viewing
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.9'' as title, ''# `surveilr` v1.7.9 Release Notes

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Introduced a new flag `--keep-status-logs` to indicate whether the server should store status logs received from osQuery in the RSSD.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.8'' as title, ''# `surveilr` v1.7.8 Release Notes

This release focuses on enhancing the `surveilr osquery-ms` UI by adding new tables and optimizing data management. No bugs were fixed or new features introduced. Please review the Web UI for updates.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.7'' as title, ''# `surveilr` v1.7.7 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.6'' as title, ''# `surveilr` v1.7.6 Release Notes

---

## 🚀 Bug Fixes

### 1. `surveilr` Bootstrap SQL
This release fixes the "no such table: device" error introduced in the previous version by propagating any erroors during the SQL initialization of the RSSD with `surveilr`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.5'' as title, ''# `surveilr` v1.7.5 Release Notes

---


### 🆕 **New Features**
- **osQuery Management Server Integration**:  
  - `surveilr` now acts as a management layer for osQuery, enabling secure and efficient monitoring of infrastructure.
  - Supports remote configuration, logging, and query execution for osQuery nodes.

- **Behavior & Notebooks Support**:  
  - Introduced **Notebooks**, which store predefined queries in the `code_notebook_cell` table.
  - **Behaviors** allow defining and managing query execution for different node groups.

- **Secure Node Enrollment**:  
  - Nodes authenticate using an **enrollment secret key** (`SURVEILR_OSQUERY_MS_ENROLL_SECRET`).
  - Secure communication via **TLS certificates** (`cert.pem`, `key.pem`).

- **Automated Query Execution**:  
  - Default queries from **"osQuery Management Server (Prime)"** execute automatically.
  - Custom notebooks and queries can be added dynamically via SQL.

- **Centralized Logging & Config Fetching**:  
  - Osquery logs and configurations are fetched via TLS endpoints (`/logger`, `/config`).
  - All communication is secured using **server-side TLS certificates**.

- **Web UI for Query Results Visualization**:  
  - `surveilr web-ui` provides an intuitive dashboard to inspect query results across enrolled nodes.
  - Simply start with `surveilr web-ui -p 3050 --host <server-ip>`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.1'' as title, ''# `surveilr` v1.7.1 Release Notes

---

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Introduced a new flag--behavior` or `-b` to specify behavior name to queries to run automatically enrolled nodes.
- a new SQLite function called `surveilr_osquery_ms_create_behaviour` to facilitate the creation of behaviors, making process smooth and easy.

### Example
When starting the `surveilr osquery-ms` server without passing a behavior, a default behavior with the following query configuration is created:
```json
{
  "surveilr-cli": {
    ...
    "osquery_ms": {
      "tls_proc": {
 "query": "select * from processes",
        "interval": 60
      }
    }
  }
}
```
To use a behavior with the `surveilr` osQuery management server first create a behavior using the new function: 
```bash
surveilr shell --cmd "select surveil_osquery_ms_create_behaviour(''''-behaviour'''', ''''{\"tls_proc\": {\"query\": \"select * from processes\", \"interval\": 60}, \"routes\": {\"query\": \"SELECT * FROM routes WHERE destination = ''''''''::1''''''''\", \"interval\": 60}}'''');"
```
Then, pass that behavior to the server by:

```bash
surveilr osquery-ms --cert ./cert.pem --key ./key.pem --enroll-secret "<secret>" -b "initial-behaviour"
```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.0'' as title, ''# `surveilr` v1.7.0 Release Notes

---

## 🚀 What''''s New

### **1. `surveilr` OSQuery Management Server**
Introducing Osquery Management Server using `surveilr`, enabling secure and centralized monitoring of your infrastructure. The setup ensures secure node enrollment through TLS authentication and secret keys, allowing only authorized devices to connect. Users can easily configure and manage node behaviors dynamically via `surveilr`’s behavior tables.

### **2. OpenDAL Dropbox Integration**
The `surveilr_udi_dal_dropbox` SQLite function, is a powerful new virtual table module that enables seamless interaction with Dropbox files directly within your SQL queries. This module allows users to access and query comprehensive file metadata, including name, path, size, last modified timestamp, content, and more, within specified directories.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.6.0'' as title, ''# `surveilr` v1.6.0 Release Notes

---

## 🚀 What''''s New

### **1. SQLPage**
- Updated SQLPage to the latest version, ensuring compatibility and access to the newest features and bug fixes.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.11'' as title, ''# `surveilr` v1.5.11 Release Notes

---

### Overview
This release includes updates to dependencies, bug fixes, and performance improvements to enhance stability and functionality.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.10'' as title, ''# `surveilr` v1.5.9 Release Notes

---

## 🚀 Bug Fixes

### **1. WebUI Page for About**
- A dedicated About page has been added in the WebUI to visualize the response of `surveilr doctor`:
  - **Dependencies Table**:
    - The display of versions and their generation process has been fixed.
  - **Diagnostic Views**:
    - A new section has been added to display the contents and details of all views prefixed with `surveilr_doctor*`, facilitating the of details and logs for diagnostics.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.8'' as title, ''# `surveilr` v1.5.8 Release Notes 🎉

---

### **1. WebUI Page for About**
- Added a dedicated About page in the WebUI visiualizing the response of `surveilr doctor`:
  - **Dependencies Table**:
    - Displays the versions of `sqlpage`, `rusqlite`, and `pgwire` in a table.
  - **Extensions List**:
    - Lists all synamic and static extensions .
  - **Capturable executables**:
    - Lists all capturable executables that were found in the `PATH`.
  - **Env variables**
    - Captures all environment variables starting with `SURVEILR_` and `SQLPAGE_`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.6'' as title, ''# `surveilr` v1.5.6 Release Notes 🎉

---

## 🚀 What''''s New
### **1. Enhanced Diagnostics Command**
- **`surveilr doctor` Command Improvements**:
  - **Dependencies Check**:
    - Verifies versions of critical dependencies: `Deno`, `Rustc`, and `SQLite`.
    - Ensures dependencies meet minimum version requirements for seamless functionality.
  - **Capturable Executables Detection**:
    - Searches for executables in the `PATH` matching `surveilr-doctor*.*`.
    - Executes these executables, assuming their output is in JSON format, and integrates their results into the diagnostics report.
  - **Database Views Analysis**:
    - Queries all views starting with the prefix `surveilr_doctor_` in the specified RSSD.
    - Displays their contents in tabular format for comprehensive insights.

---

### **2. JSON Mode**
- Added a `--json` flag to the `surveilr doctor` command.
  - Outputs the entire diagnostics report, including versions, extensions, and database views, in structured JSON format.

---

### **3. WebUI Page for Diagnostics**
- Added a dedicated page in the WebUI for the `surveilr doctor` diagnostics:
  - **Versions Table**:
    - Displays the versions of `Deno`, `Rustc`, and `SQLite` in a table.
  - **Extensions List**:
    - Lists all detected extensions.
  - **Database Views Content**:
    - Automatically identifies and displays the contents of views starting with `surveilr_doctor_` in individual tables.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.5'' as title, ''# `surveilr` v1.5.5 Release Notes 🎉

---

## 🚀 What''''s New

### Virtual Table: `surveilr_function_docs`

**Description**  
The `surveilr_function_docs` virtual table offers a structured method to query metadata about `surveilr` SQLite functions registered in the system.

**Columns**  
- `name` (`TEXT`): The function''''s name.
- `description` (`TEXT`): A concise description of the function''''s purpose.
- `parameters` (`JSON`): A JSON object detailing the function''''s parameters, including:
  - `name`: The name of the parameter.
  - `data_type`: The parameter''''s expected data type.
  - `description`: An explanation of the parameter''''s role.
- `return_type` (`TEXT`): The function''''s return type.
- `introduced_in_version` (`TEXT`): The version in which the function was first introduced.

**Use Cases**  
- Utilized in the Web UI for generating documentation on the functions.

---

### Virtual Table: `surveilr_udi_dal_fs`

**Description**  
The `surveilr_udi_dal_fs` virtual table acts as an abstraction layer for interacting with the file system. It enables users to list and examine file metadata in a structured, SQL-friendly manner. This table can list files and their metadata recursively from a specified path.

**Columns**  
- `name` (`TEXT`): The file''''s name.
- `path` (`TEXT`): The complete file path.
- `last_modified` (`TEXT`): The file''''s last modified timestamp, when available.
- `content` (`BLOB`): The content of the file (optional).
- `size` (`INTEGER`): The size of the file in bytes.
- `content_type` (`TEXT`): The MIME type of the file or an inferred content type (e.g., based on the extension).
- `digest` (`TEXT`): The MD5 digest of the file, if available.
- `arg_path` (`TEXT`, hidden): The base path for querying files, specified in the `filter` method.

**Key Features**  
- Lists files recursively from a specified directory.
- Facilitates metadata extraction, such as file size, last modified timestamp, and MDhash).

---

### Virtual Table: `surveilr_udi_dal_s3`

**Description**  
The `surveilr_udi_dal_s3` virtual table is an abstraction layer that interacts with the S3 bucket in a given region. It allows listing and inspecting file metadata in a structured, SQL-accessible way.

**Columns**  
- `name` (`TEXT`): The name of the file.
- `path` (`TEXT`): The full path to the file.
- `last_modified` (`TEXT`): The last modified timestamp of the file, if available.
- `content` (`BLOB`): The file''''s content (optional).
- `size` (`INTEGER`): The file size in bytes.
- `content_type` (`TEXT`): The file''''s MIME type or inferred content type (e.g., based on the extension).
- `digest` (`TEXT`): The file''''s MD5 digest, if available.
- `arg_path` (`TEXT`, hidden): The base path to query files from, specified in the `filter` method.

**Key Features**  
- Supports metadata extraction (e.g., file size, last modified timestamp, MD5 hash).

---

## Example Queries

### Querying Function Documentation
```sql
SELECT * FROM surveilr_function_docs WHERE introduced_in_version = ''''1.0.0'''';
```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.3'' as title, ''# `surveilr` v1.5.3 Release Notes 🎉

---

## 🚀 What''''s New

### 1. **Open Project Data Extension**
`surveilr` now includes additional data from Open Project PLM ingestion. Details such as a work package''''s versions and relations are now encapsulated in JSON format in a new `elaboration` column within the `ur_ingest_session_plm_acct_project_issue` table. The JSON structure is as follows, with the possibility for extension:
```json
elaboration: {"issue_id": 78829, "relations": [...], "version": {...}}
```

### 2. **Functions for Extension Verification**
Two new functions have been introduced to verify and ensure the presence of certain intended functions and extensions before their use:
- The `select surveilr_ensure_function(''''func'''', ''''if not found msg'''', ''''func2'''', ''''if func2 not found msg'''')` function can be used to declaratively specify the required function(s), and will produce an error with guidance on how to obtain the function if it is not found.

- The `select surveilr_ensure_extension(''''extn.so'''', ''''../bin/extn2.so'''')` function allows for the declarative indication of necessary extensions, and will dynamically load them if they are not already available.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.2'' as title, ''# `surveilr` v1.5.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. **`surveilr` SQLite Extensions**
`surveilr` extensions are now statically linked, resolving all extensions and function usage issues. The following extensions are included by default in `surveilr`, with additional ones planned for future releases:
- [`sqlean`](https://github.com/nalgeon/sqlean)
- [`sqlite-url`](https://github.com/asg017/sqlite-url)
- [`sqlite-hashes`](https://github.com/nyurik/sqlite-hashes)
- [`sqlite-lines`](https://github.com/asg017/sqlite-lines)'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.3'' as title, ''# `surveilr` v1.4.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. Utilizing Custom Extensions with `surveilr`
In the previous release, we introduced the feature of automatically loading extensions from the default `sqlpkg` location. However, this posed a security risk, and we have since disabled that feature. To use extensions installed by `sqlpkg`, simply pass `--sqlpkg`, and the default location will be utilized. If you wish to change the directory from which extensions are loaded, use `--sqlpkg /path/to/extensions`, or specify the directory with the new `SURVEILR_SQLPKG` environment variable.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.2'' as title, ''# `surveilr` v1.4.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. Utilizing Custom Extensions with **`surveilr`**
Loading extensions is now straightforward with the `--sqlite-dyn-extn` flag. As long as your extensions are installed via [`sqlpkg`](https://sqlpkg.org/), `surveilr` will automatically detect the default location of `sqlpkg` and all installed extensions. Simply install the extension using `sqlpkg`. To specify a custom path for `sqlpkg`, use the `--sql-pkg-home` argument with a directory containing the extensions, regardless of depth, and `surveilr` will locate them. Additionally, the `SURVEILR_SQLITE_DYN_EXTNS` environment variable has been introduced to designate an extension path instead of using `--sqlite-dyn-extn`.
**Note**: Using `--sqlite-dyn-extn` won''''t prevent `surveilr` from loading extensions from `sqlpkg`''''s default directory. To disable loading from `sqlpkg`, use the `--no-sqlpkg` flag.

Here''''s a detailed example of using `surveilr shell` and `surveilr orchestrate` with dynamic extensions.
**Using `sqlpkg` defaults**
- Download the [`sqlpkg` CLI](https://github.com/nalgeon/sqlpkg-cli?tab=readme-ov-file#download-and-install-preferred-method).
- Download the [text extension](https://sqlpkg.org/?q=text), which offers various text manipulation functions: `sqlpkg install nalgeon/sqlean`
- Run the following command:
  ```bash
  surveilr shell --cmd "select text_substring(''''hello world'''', 7, 5) AS result" # surveilr loads all extensions from the .sqlpkg default directory
  ```

**Including an additional extension with `sqlpkg`**
Combine `--sqlite-dyn-extn` with `surveilr`''''s ability to load extensions from `sqlpkg`
- Add the `path` extension to `sqlpkg`''''s installed extensions: `sqlpkg install asg017/path`
- Execute:
  ```bash
  surveilr shell --cmd "SELECT
        text_substring(''''hello world'''', 7, 5) AS substring_result,
        math_sqrt(9) AS sqrt_result,
        path_parts.type,
        path_parts.part 
    FROM 
        (SELECT * FROM path_parts(''''/usr/bin/sqlite3'''')) AS path_parts;
    " --sqlite-dyn-extn .extensions/math.so
  ```

**Specify a Custom Directory to Load Extensions From**
A `--sqlpkg-home` flag has been introduced to specify a custom path for extensions. They do not need to be installed by `sqlpkg` to be used. `surveilr` will navigate the specified folder and load all compatible extensions for the operating system—`.so` for Linux, `.dll` for Windows, and `.dylib` for macOS. (If you installed with `sqlpkg`, you don''''t need to know the file type).
```bash
surveilr shell --cmd "SELECT text_substring(''''hello world'''', 7, 5) AS substring_result, math_sqrt(9) AS sqrt_result" --sqlpkg-home ./src/resource_serde/src/functions/extensions/
```

### 2. Upgraded SQLPage
SQLPage has been updated to version 0.31.0, aligning with the latest releases.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.1'' as title, ''# `surveilr` v1.4.1 Release Notes 🎉

---

## 🚀 Bug Fixes

### 1. **`surveilr` SQLite Extensions**
To temporarily mitigate the issue with `surveilr` intermittently working due to the dynamic loading of extensions, `surveilr` no longer supports dynamic loading by default. It is now supported only upon request by using the `--sqlite-dyn-extn` flag. This flag is a multiple option that specifies the path to an extension to be loaded into `surveilr`. To obtain the dynamic versions (`.dll`, `.so`, or `.dylib`), you can use [`sqlpkg`](https://sqlpkg.org/) to install the necessary extension.

For instance, to utilize the `text` functions:
- Install the extension with [`sqlpkg`](https://sqlpkg.org/?q=text): `sqlpkg install nalgeon/text`
- Then execute it:
  ```bash
  surveilr shell --cmd "select text_substring(''''hello world'''', 7, 5);" --sqlite-dyn-extn ./text.so
  ```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.3.1'' as title, ''# `surveilr` v1.3.1 Release Notes 🎉

---

## 🚀 Bug Fixes

### 1. **`surveilr` SQLite Extensions**
This release fixes the `glibc` compatibility error that occured with `surveilr` while registering function extensions.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.3.0'' as title, ''# `surveilr` Release Announcement: Now Fully Compatible Across All Distros 🎉

We are thrilled to announce that `surveilr` is now fully compatible with all major Linux distributions, resolving the longstanding issue related to OpenSSL compatibility! 🚀

## What''''s New?
- **Universal Compatibility**: `surveilr` now works seamlessly on **Ubuntu**, **Debian**, **Kali Linux**, and other Linux distributions, across various versions and architectures. Whether you''''re using Ubuntu 18.04, Debian 10, or the latest Kali Linux, `surveilr` is ready to perform without any hiccups.
- **Resolved OpenSSL Bug**: We’ve fixed the recurring OpenSSL-related issue that caused headaches for users on older and varied systems. With this update, you no longer need to worry about OpenSSL version mismatches or missing libraries.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v2.2.0'' as title, ''# `surveilr ` v2.2.0 Release Notes

## 🚀 What''''s New

1. JSONL File Ingestion Support

- New Format Support: Added comprehensive JSONL (JSON Lines) file format ingestion capabilities
- Streaming Data Processing: Efficiently handles large streaming JSON datasets line-by-line
- Automatic Schema Detection: Intelligently detects and processes JSONL file structures

## How JSONL Ingestion Works

Unlike regular JSON files that contain a single JSON object or array, JSONL files contain one valid JSON object per
line:

{"id": 1, "name": "Alice", "timestamp": "2025-09-01T10:00:00Z"}
{"id": 2, "name": "Bob", "timestamp": "2025-09-01T10:01:00Z"}
{"id": 3, "name": "Charlie", "timestamp": "2025-09-01T10:02:00Z"}

Ingestion Process:
1. Line-by-Line Reading: File is read sequentially, one line at a time
2. JSON Validation: Each line is validated as proper JSON
3. Individual Processing: Each JSON object is processed as a separate resource
4. Schema Evolution: Supports varying schemas across lines in the same file
6. Line-Specific URIs: Each line gets a unique URI with line number reference for precise tracking

### URI Structure for JSONL:
Each JSON line creates a unique uniform_resource entry with line-specific URI:
/path/to/events.jsonl#L1    # First JSON object
/path/to/events.jsonl#L2    # Second JSON object
/path/to/events.jsonl#L3    # Third JSON object

### Example:
File: /data/user-events.jsonl
Line 1: {"user": "alice", "action": "login", "timestamp": "2025-09-01T10:00:00Z"}
Line 2: {"user": "bob", "action": "logout", "timestamp": "2025-09-01T10:05:00Z"}

### Results in uniform_resource entries with URIs:
/data/user-events.jsonl#L1
/data/user-events.jsonl#L2

This unique URI scheme allows precise tracking of which specific line in the JSONL file each resource originated
from, enabling accurate data lineage and debugging capabilities.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.2.0'' as title, ''# `surveilr` v1.2.0 Release Notes 🎉

## What''''s New?
This update introduces two major additions that streamline file system integration and ingestion session management.

---

### New Features

#### 1. `surveilr_ingest_session_id` Scalar Function
The `surveilr_ingest_session_id` function is now available, offering robust management of ingestion sessions. This function ensures efficient session handling by:
- Reusing existing session IDs for devices with active sessions.
- Creating new ingestion sessions when none exist.
- Associating sessions with metadata for improved traceability.


#### 2. `surveilr_udi_dal_fs` Virtual Table Function
The `surveilr_udi_dal_fs` virtual table function provides seamless access to file system resources directly within your SQL queries. With this feature, you can:
- Query file metadata, such as names, paths, sizes, and timestamps.
- Retrieve file content and calculate digests for integrity checks.
- Traverse directories recursively to handle large and nested file systems effortlessly.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.1.0'' as title, ''# `surveilr` v1.1.0 Release Notes 🎉

## 🚀 New Features

### 1. **Integrated Documentation in Web UI**

This release introduces a comprehensive update to the RSSD Web UI, allowing users to access and view all `surveilr`-related SQLite functions, release notes, and internal documentation directly within the interface. This feature enhances user experience by providing integrated, easily navigable documentation without the need to leave the web environment, ensuring that all necessary information is readily available for efficient reference and usage.

### 2. **`uniform_resource` Graph Infrastructure**

The foundational framework for tracking `uniform_resource` content using graph representations has been laid out in this release. This infrastructure allows users to visualize `uniform_resource` data as connected graphs in addition to the traditional relational database structure. To facilitate this, three dedicated views—`imap_graph`, `plm_graph`, and `filesystem_graph`—have been created. These views provide a structured way to observe and interact with data from different ingestion sources:

- **`imap_graph`**: Represents the graphical relationships for content ingested through IMAP processes, allowing for a visual mapping of email and folder structures.
- **`plm_graph`**: Visualizes content from PLM (Product Lifecycle Management) ingestion, showcasing project and issue-based connections.
- **`filesystem_graph`**: Illustrates file ingestion paths and hierarchies, enabling users to track and manage file-based data more intuitively.

This release marks an important step towards enhancing data tracking capabilities, providing a dual approach of relational and graphical views for better data insights and management.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v2.1.0'' as title, ''# `surveilr ` v2.1.0 Release Notes

## 🚀 What''''s New

### **1. AI-Powered Natural Language to SQL (ask-ai)**
- New Command: surveilr ask-ai sql converts natural language queries into SQL and executes them against your RSSD
- Smart Context Integration: Automatically retrieves relevant AI context from Surveilr notebook cells for
domain-specific knowledge
- Multiple Output Formats: Support for table, JSON, CSV, and markdown output formats
- Flexible LLM Support: Works with OpenAI-compatible endpoints including local models (Ollama, etc.)

### Basic natural language queries
`surveilr` ask-ai sql "show me all files ingested in the last week"
`surveilr` ask-ai sql "what devices have been scanned?"
`surveilr` ask-ai sql "find all JSON files larger than 1MB"

### Different output formats
`surveilr` ask-ai sql "show device information" --output json
`surveilr` ask-ai sql "list recent sessions" --output csv
`surveilr` ask-ai sql "security audit summary" --output markdown

### Development and debugging
`surveilr` ask-ai sql "show database tables" --show-query
`surveilr` ask-ai sql "count all records" --sql-only

🔧 Configuration

## 🤖 AI Engine Compatibility

The new `ask-ai` feature supports a wide range of AI engines through OpenAI-compatible APIs:

### Supported AI Engines
- **OpenAI**: GPT-4, GPT-3.5-turbo, GPT-4-turbo
- **Local AI Servers**: Ollama, LM Studio, text-generation-webui
- **Cloud Providers**: Azure OpenAI, Anthropic Claude (via compatible proxies)
- **Open Source Models**: Any model served via vLLM, LocalAI, or other OpenAI-compatible servers

### Technical Implementation
Surveilr uses the [ureq HTTP client](https://crates.io/crates/ureq) to communicate with any OpenAI-compatible API
endpoint. For a comprehensive list of supported providers and configuration examples, see the [OpenAI-compatible 
providers documentation](https://docs.litellm.ai/docs/providers/openai_compatible).

### Quick Configuration Examples
```bash
# OpenAI (default)
export SURVEILR_LLM_API_KEY="sk-your-key"

# Ollama (local)
export SURVEILR_LLM_ENDPOINT="http://localhost:11434/v1/chat/completions"

# LM Studio (local)
export SURVEILR_LLM_ENDPOINT="http://localhost:1234/v1/chat/completions"

# Azure OpenAI
export SURVEILR_LLM_ENDPOINT="https://your-resource.openai.azure.com/openai/deployments/your-deployment/chat/completi
ons?api-version=2023-05-15"'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.0.0'' as title, ''# `surveilr` v1.0.0 Release Notes 🎉

We’re thrilled to announce the release of `surveilr` v1.0, a significant milestone in our journey to deliver powerful tools for continuous security, quality and compliance evidence workflows. This release introduces a streamlined migration system and a seamless, user-friendly experience for accessing the `surveilr` Web UI.

---

## 🚀 New Features

### 1. **Database Migration System**

This release introduces a comprehensive database migration feature that allows smooth and controlled updates to the RSSD structure. Our migration system includes:

- **Structured Notebooks and Cells**: A structured system organizes SQL migration scripts into modular code notebooks, making migration scripts easy to track, audit, and execute as needed.
- **Idempotent vs. Non-Idempotent Handling**: Ensures each migration runs in an optimal and secure manner by tracking cell execution history, allowing for re-execution where safe.
- **Automated State Tracking**: All state changes are logged for complete auditing, showing timestamps, transition details, and the results of each migration step.
- **Transactional Execution**: All migrations run within a single transaction block for seamless rollbacks and data consistency.
- **Dynamic Migration Scripts**: Cells marked for migration are dynamically added to the migration script, reducing manual effort and risk of errors.

This system ensures safe, controlled migration of database changes, enhancing reliability and traceability for every update.

### 2. **Enhanced Default Command and Web UI Launch**

The surveilr executable now starts the Web UI as the default command when no specific CLI commands are passed. This feature aims to enhance accessibility and ease of use for new users and teams. Here’s what happens by default:

- **Automatic Web UI Startup**: By default, running surveilr without additional commands launches the surveilr Web UI.
- **Auto-Browser Launch**: Opens the default browser on the workstation, pointing to the Web UI’s URL and port, providing a user-friendly experience right from the first run.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v2.0.0'' as title, ''# `surveilr ` v2.0.0 Release Notes

## 🚀 What''''s New

### **1. Enhanced Markdown Transformation Workflow**
- Improved mdq Integration: Fixed mdq selector syntax and added comprehensive selector support
- Content Preservation: Markdown transforms no longer null out original content by default 
- Better URI Tracking: Transform results now preserve source file paths (e.g., document.pdf/md-select:headers)

### **2. Dependencies Update**
- Upgraded to SQLPage 0.36.1.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v3.0.0'' as title, ''# Surveilr v3.0.0 - Drizzle ORM Foundation

## Summary

Migrated internal schema generation from SQLa to [Drizzle ORM](https://orm.drizzle.team/) - a lightweight, type-safe TypeScript ORM. This establishes the foundation for optional type-safe database queries while maintaining our **SQL-first philosophy**.

## What Changed

### Schema Generation (Internal)
- **Replaced**: SQLa-based `lifecycle.sql.ts` → Drizzle-generated bootstrap SQL
- **New**: Type-safe schema definitions in `lib/std/drizzle/models.ts` and `views.ts`
- **Result**: Same RSSD structure with enhanced TypeScript support

### Developer Experience
- **Added**: Optional type-safe query helpers for complex scenarios
- **Maintained**: SQL views remain the preferred approach for business logic

## File Organization
```
lib/std/drizzle/
├── models.ts              # RSSD table schemas
├── views.ts              # SQL view definitions
├── bootstrap.sql.ts       # Schema generator
└── drizzle-lifecycle.ts   # Migration cells
```

## Migration Impact

- **End Users**: No changes to `surveilr` CLI commands
- **Developers**: Optional access to type-safe queries when needed
- **Databases**: Same RSSD structure, generated via Drizzle instead of SQLa

## Technical Validation

- ✅ Identical 65+ table structure generated
- ✅ All foreign key constraints preserved
- ✅ File ingestion, transforms, multitenancy functional
- ✅ Web UI and code notebook systems working
- ✅ Complete test suite passing

---'' as description_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/functions.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/functions.sql''
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
              

              -- To display title
SELECT
  ''text'' AS component,
  ''Surveilr SQLite Functions'' AS title;

SELECT
  ''text'' AS component,
  ''Below is a comprehensive list and description of all Surveilr SQLite functions. Each function includes details about its parameters, return type, and version introduced.''
  AS contents_md;

SELECT
''list'' AS component,
''Surveilr Functions'' AS title;

  SELECT  name AS title,
        NULL AS icon,  -- Add an icon field if applicable
        ''functions-inner.sql?function='' || name || ''#function'' AS link,
        $function = name AS active
  FROM surveilr_function_doc
  ORDER BY name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/functions-inner.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
select
  ''breadcrumb'' as component;
select
  ''Home'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
select
  ''Docs'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/index.sql'' as link;
select
  ''SQL Functions'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/functions.sql'' as link;
select
  $function as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/functions-inner.sql?function=''  || $function AS link;


  SELECT
    ''text'' AS component,
    '''' || name || ''()'' AS title, ''function'' AS id
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''text'' AS component,
    description AS contents_md
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''text'' AS component,
    ''Introduced in version '' || version || ''.'' AS contents
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''title'' AS component,
    3 AS level,
    ''Parameters'' AS contents
  WHERE $function IS NOT NULL;

  SELECT
    ''card'' AS component,
    3 AS columns
    WHERE $function IS NOT NULL;
  SELECT
      json_each.value ->> ''$.name'' AS title,
      json_each.value ->> ''$.description'' AS description,
      json_each.value ->> ''$.data_type'' AS footer,
      ''azure'' AS color
  FROM surveilr_function_doc, json_each(surveilr_function_doc.parameters)
  WHERE name = $function;

  -- Navigation Buttons
  SELECT ''button'' AS component, ''sm'' AS size, ''pill'' AS shape;
  SELECT name AS title,
        NULL AS icon,  -- Add an icon field if needed
        sqlpage.link(''functions-inner.sql'', json_object(''function'', name)) AS link
  FROM surveilr_function_doc
  ORDER BY name;
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
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
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
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&folder_id='' || replace($folder_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&folder_id='' || replace($folder_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
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
      'shell/shell.json',
      '{
  "component": "case when sqlpage.environment_variable(''EOH_INSTANCE'')=1 then ''shell-custom'' else ''shell'' END",
  "title": "",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/tem.ico",
  "image": "https://www.surveilr.com/assets/brand/tem.png",
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
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js",
    "data:text/javascript,document.addEventListener(''DOMContentLoaded'',function(){document.title=''Tem'';});"
  ],
  "footer": "Resource Surveillance Web UI",
  "css": "\n        /* Hide all text content in navbar-brand except images */\n        .navbar-brand {\n          font-size: 0 !important;\n        }\n        .navbar-brand img {\n          font-size: initial !important;\n          display: inline-block !important;\n        }\n        /* Alternative approach - hide text nodes */\n        .navbar-brand > *:not(img) {\n          display: none !important;\n        }\n        /* Hide any span or text elements in navbar */\n        .navbar-brand span,\n        .navbar-brand .navbar-text {\n          display: none !important;\n        }\n      "
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT case when sqlpage.environment_variable(''EOH_INSTANCE'')=1 then ''shell-custom'' else ''shell'' END AS component,
       NULL AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/tem.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/tem.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       ''data:text/javascript,document.addEventListener(''''DOMContentLoaded'''',function(){document.title=''''Tem'''';});'' AS javascript,
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
       ''Surveilr ''|| (SELECT json_extract(session_agent, ''$.version'') AS version FROM ur_ingest_session LIMIT 1) || '' Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), LENGTH(sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'')) + 2 ) || '')'' as footer,
       ''
        /* Hide all text content in navbar-brand except images */
        .navbar-brand {
          font-size: 0 !important;
        }
        .navbar-brand img {
          font-size: initial !important;
          display: inline-block !important;
        }
        /* Alternative approach - hide text nodes */
        .navbar-brand > *:not(img) {
          display: none !important;
        }
        /* Hide any span or text elements in navbar */
        .navbar-brand span,
        .navbar-brand .navbar-text {
          display: none !important;
        }
      '' AS css;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
