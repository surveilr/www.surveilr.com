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
-- --------------------------------------------------------------------------------
-- Script to prepare convenience views to access uniform_resource.content column
-- as osqueryms content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------

DROP VIEW IF EXISTS surveilr_osquery_ms_node_detail;
CREATE VIEW surveilr_osquery_ms_node_detail AS
SELECT
    n.surveilr_osquery_ms_node_id,
    n.node_key,
    n.host_identifier,
    n.osquery_version,
    n.last_seen,
    n.created_at,
    i.updated_at,
    i.address AS ip_address,
    i.mac,
    b.boundary,
    CASE 
        WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 60 THEN 
            (strftime('%s', 'now') - strftime('%s', n.created_at)) || ' seconds ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 3600 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 60) || ' minutes ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 86400 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 3600) || ' hours ago'
        ELSE 
            ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 86400) || ' days ago'
    END AS added_to_surveilr_osquery_ms,
    o.name AS operating_system,
    round(a.available_space, 2) || ' GB' AS available_space,
    CASE 
        WHEN (strftime('%s', 'now') - strftime('%s', last_seen)) < 60 THEN 'Online'
        ELSE 'Offline'
    END AS node_status,
    CASE 
        WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 60 THEN 
            (strftime('%s', 'now') - strftime('%s', n.last_seen)) || ' seconds ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 3600 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 60) || ' minutes ago'
        WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 86400 THEN 
            ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 3600) || ' hours ago'
        ELSE 
            ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 86400) || ' days ago'
    END AS last_fetched,
    CASE
        WHEN CAST(u.days AS INTEGER) > 0 THEN 
            'about ' || u.days || ' day' || (CASE WHEN CAST(u.days AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
        WHEN CAST(u.hours AS INTEGER) > 0 THEN 
            'about ' || u.hours || ' hour' || (CASE WHEN CAST(u.hours AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
        WHEN CAST(u.minutes AS INTEGER) > 0 THEN 
            'about ' || u.minutes || ' minute' || (CASE WHEN CAST(u.minutes AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
        ELSE 
            'about ' || u.seconds || ' second' || (CASE WHEN CAST(u.seconds AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
    END AS last_restarted,
    COALESCE(failed_policies.failed_count, 0) AS issues
FROM surveilr_osquery_ms_node n
LEFT JOIN surveilr_osquery_ms_node_available_space a ON n.node_key = a.node_key
LEFT JOIN surveilr_osquery_ms_node_os_version o ON n.node_key = o.node_key
LEFT JOIN surveilr_osquery_ms_node_uptime u ON n.node_key = u.node_key
LEFT JOIN surveilr_osquery_ms_node_interface_address i ON n.node_key = i.node_key
LEFT JOIN surveilr_osquery_ms_node_boundary b ON n.node_key = b.node_key
LEFT JOIN (
    SELECT node_key, COUNT(*) AS failed_count
    FROM surveilr_osquery_ms_node_executed_policy
    WHERE policy_result = 'Fail'
    GROUP BY node_key
) AS failed_policies ON n.node_key = failed_policies.node_key;


-- --------------------------------------------------------------------------------
-- The following tables are created to ensure compatibility between the RSSD and Aggregate Assurance databases.
-- Some client environments may not have the Aggregate Assurance schema pre-defined, so these CREATE TABLE IF NOT EXISTS
-- statements are used to safely initialize the required structures without causing errors.
-- This approach ensures seamless integration and consistent data references across both systems.
-- --------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "boundary" (
    "boundary_id" TEXT PRIMARY KEY NOT NULL,
    "parent_boundary_id" TEXT,
    "graph_id" TEXT NOT NULL,
    "boundary_nature_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("parent_boundary_id") REFERENCES "boundary"("boundary_id"),
    FOREIGN KEY("graph_id") REFERENCES "graph"("graph_id"),
    FOREIGN KEY("boundary_nature_id") REFERENCES "boundary_nature"("boundary_nature_id")
);

CREATE TABLE IF NOT EXISTS "asset" (
    "asset_id" TEXT PRIMARY KEY NOT NULL,
    "organization_id" TEXT NOT NULL,
    "boundary_id" TEXT,
    "asset_retired_date" DATE,
    "asset_status_id" TEXT NOT NULL,
    "asset_tag" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "asset_type_id" TEXT NOT NULL,
    "asset_workload_category" TEXT NOT NULL,
    "assignment_id" TEXT NOT NULL,
    "barcode_or_rfid_tag" TEXT NOT NULL,
    "installed_date" DATE,
    "planned_retirement_date" DATE,
    "purchase_delivery_date" DATE,
    "purchase_order_date" DATE,
    "purchase_request_date" DATE,
    "serial_number" TEXT NOT NULL,
    "tco_amount" TEXT NOT NULL,
    "tco_currency" TEXT NOT NULL,
    "criticality" TEXT,
    "asymmetric_keys_encryption_enabled" TEXT,
    "cryptographic_key_encryption_enabled" TEXT,
    "symmetric_keys_encryption_enabled" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("organization_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("boundary_id") REFERENCES "boundary"("boundary_id"),
    FOREIGN KEY("asset_status_id") REFERENCES "asset_status"("asset_status_id"),
    FOREIGN KEY("asset_type_id") REFERENCES "asset_type"("asset_type_id"),
    FOREIGN KEY("assignment_id") REFERENCES "assignment"("assignment_id")
);

CREATE TABLE IF NOT EXISTS "asset_boundary" (
    "asset_boundary_id" TEXT PRIMARY KEY NOT NULL,
    "asset_id" TEXT NOT NULL,
    "boundary_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("boundary_id") REFERENCES "boundary"("boundary_id")
);

CREATE TABLE IF NOT EXISTS "asset_type" (
    "asset_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);

CREATE TABLE IF NOT EXISTS "assignment" (
    "assignment_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);

CREATE TABLE IF NOT EXISTS "asset_service" (
    "asset_service_id" TEXT PRIMARY KEY NOT NULL,
    "asset_id" TEXT NOT NULL,
    "asset_service_type_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "asset_service_status_id" TEXT NOT NULL,
    "port" TEXT NOT NULL,
    "experimental_version" TEXT NOT NULL,
    "production_version" TEXT NOT NULL,
    "latest_vendor_version" TEXT NOT NULL,
    "resource_utilization" TEXT NOT NULL,
    "log_file" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "vendor_link" TEXT NOT NULL,
    "installation_date" DATE,
    "criticality" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("asset_service_type_id") REFERENCES "asset_service_type"("asset_service_type_id"),
    FOREIGN KEY("asset_service_status_id") REFERENCES "asset_service_status"("asset_service_status_id")
);

CREATE TABLE IF NOT EXISTS "asset_service_type" (
    "asset_service_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);

CREATE TABLE IF NOT EXISTS "asset_status" (
    "asset_status_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);

-- --------------------------------------------------------------------------------
-- Script to create a table from uniform_resource.content column
-- as osqueryms content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------

-- DROP VIEW IF EXISTS list_user;
-- DROP VIEW IF EXISTS asset_user_list;
-- DROP VIEW IF EXISTS list_container;
-- DROP VIEW IF EXISTS list_container_image;
-- DROP VIEW IF EXISTS list_network_information;
-- DROP VIEW IF EXISTS list_network_volume;
-- DROP VIEW IF EXISTS list_container_ports;
-- DROP VIEW IF EXISTS list_container_process;
-- DROP VIEW IF EXISTS list_container_authentication_log;
-- DROP VIEW IF EXISTS list_all_process;

DROP TABLE IF EXISTS ur_transform_list_user;
CREATE TABLE ur_transform_list_user AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.columns.username') AS user_name,
    json_extract(u.content, '$.columns.directory') AS directory,
    json_extract(u.content, '$.columns.uid') AS uid,
    uri as query_uri
FROM uniform_resource u
WHERE u.uri="osquery-ms:query-result" AND name = 'Users';


-- -- Container TABLE
DROP TABLE IF EXISTS ur_transform_list_container;
CREATE TABLE ur_transform_list_container AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id,  
    json_extract(content, '$.columns.pid') as pid,
    json_extract(content, '$.columns.name') as container_name,
    json_extract(content, '$.columns.image') as image, 
    json_extract(content, '$.columns.image_id') as image_id, 
    json_extract(content, '$.columns.status') as status,
    json_extract(content, '$.columns.state') as state,
    json_extract(content, '$.columns.created') as created,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="List Containers" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_image;
CREATE TABLE ur_transform_list_container_image AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as image_id, 
    json_extract(content, '$.columns.size_bytes') as size_bytes,
    json_extract(content, '$.columns.tags') as tags,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="List Container Images" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_information;
CREATE TABLE ur_transform_list_network_information AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.ip_address') as ip_address,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="Container Network Information" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_volume;
CREATE TABLE ur_transform_list_network_volume AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.mount_point') as mount_point, 
    json_extract(content, '$.columns.name') as volume_name,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="list Container Volumes" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_ports;
CREATE TABLE ur_transform_list_container_ports AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.host_ip') as host_ip, 
    json_extract(content, '$.columns.host_port') as host_port,
    json_extract(content, '$.columns.port') as port,
    json_extract(content, '$.columns.type') as type,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="Docker Container Ports" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_process;
CREATE TABLE ur_transform_list_container_process AS
SELECT 
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host,
    json_extract(content, '$.columns.name') as process_name,
    json_extract(content, '$.columns.pid') as pid,
    json_extract(content, '$.columns.uid') as uid,
    json_extract(content, '$.columns.start_time') as start_time,
    json_extract(content, '$.columns.state') as state,
    uri as query_uri
FROM uniform_resource 
WHERE json_valid(content) = 1 AND name="Osquery All Container Processes" AND uri="osquery-ms:query-result" GROUP BY  
    json_extract(content, '$.columns.pid'),
    json_extract(content, '$.columns.uid');


-- -- All Process
DROP TABLE IF EXISTS ur_transform_list_all_process;
CREATE TABLE ur_transform_list_all_process AS
SELECT 
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(ur.content, '$.name') AS name,
    json_extract(ur.content, '$.hostIdentifier') AS host,
    json_extract(ur.content, '$.columns.name') as process_name,
    uri as query_uri
FROM uniform_resource as ur
WHERE json_valid(content) = 1 AND name="Osquery All Processes" AND uri="osquery-ms:query-result";

-- -- Authentication Data
-- DROP TABLE IF EXISTS ur_transform_carve_data;
-- CREATE TABLE ur_transform_carve_data AS
-- SELECT 
--     ssmn.host_identifier,
--     CAST(ur.content AS TEXT) as carve_data,
--     SUBSTR(
--         ur.uri,
--         INSTR(ur.uri, 'osquery_carve_') + LENGTH('osquery_carve_'),
--         36
--     ) AS carve_uuid
-- FROM uniform_resource as ur
-- INNER JOIN surveilr_osquery_ms_carve ssmc ON carve_uuid=ssmc.carve_guid
-- INNER JOIN surveilr_osquery_ms_node ssmn ON ssmc.node_key=ssmn.node_key
-- WHERE ur.uri LIKE "%/var/log/auth.log%";

-- DROP TABLE IF EXISTS ur_transform_carved_ssh_data;
-- CREATE TABLE ur_transform_carved_ssh_data AS
-- WITH RECURSIVE
-- split_lines(host_identifier, carve_uuid, line, rest) AS (
--   SELECT
--     ssmn.host_identifier,
--     SUBSTR(
--         ur.uri,
--         INSTR(ur.uri, 'osquery_carve_') + LENGTH('osquery_carve_'),
--         36
--     ) AS carve_uuid,
--     -- Extract first line
--     SUBSTR(CAST(ur.content AS TEXT), 1, INSTR(CAST(ur.content AS TEXT) || CHAR(10), CHAR(10)) - 1),
--     -- Extract the rest of the content
--     SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT) || CHAR(10), CHAR(10)) + 1)
--   FROM uniform_resource AS ur
--   INNER JOIN surveilr_osquery_ms_carve ssmc 
--     ON SUBSTR(ur.uri, INSTR(ur.uri, 'osquery_carve_') + LENGTH('osquery_carve_'), 36) = ssmc.carve_guid
--   INNER JOIN surveilr_osquery_ms_node ssmn 
--     ON ssmc.node_key = ssmn.node_key
--   WHERE ur.uri LIKE "%/var/log/auth.log%"

--   UNION ALL

--   SELECT
--     host_identifier,
--     carve_uuid,
--     SUBSTR(rest, 1, INSTR(rest || CHAR(10), CHAR(10)) - 1),
--     SUBSTR(rest, INSTR(rest || CHAR(10), CHAR(10)) + 1)
--   FROM split_lines
--   WHERE LENGTH(rest) > 0
-- )

-- SELECT host_identifier, carve_uuid, line AS sshd_log_line
-- FROM split_lines
-- WHERE line LIKE '%sshd%';



-- -------------------AWS Tables-----------------------

-- steampipeawsEC2Instances
DROP TABLE IF EXISTS ur_transform_ec2_instance;
CREATE TABLE ur_transform_ec2_instance AS
SELECT 
  json_extract(rowsValue.value, '$.instance_id') AS instance_id,
  json_extract(rowsValue.value, '$.account_id') AS account_id,
  json_extract(rowsValue.value, '$.title') AS title,
  json_extract(rowsValue.value, '$.architecture') AS architecture,
  json_extract(rowsValue.value, '$.platform_details') AS platform_details,
  json_extract(rowsValue.value, '$.root_device_name') AS root_device_name,
  json_extract(rowsValue.value, '$.instance_state') AS state,
  json_extract(rowsValue.value, '$.instance_type') AS instance_type,
  json_extract(rowsValue.value, '$.cpu_options_core_count') AS cpu_options_core_count,
  json_extract(rowsValue.value, '$.az') AS az,
  json_extract(rowsValue.value, '$.launch_time') AS launch_time,

  json_extract(ni.value, '$.NetworkInterfaceId') AS network_interface_id,
  json_extract(ni.value, '$.PrivateIpAddress') AS private_ip_address,
  json_extract(ni.value, '$.Association.PublicIp') AS public_ip_address,
  json_extract(ni.value, '$.SubnetId') AS subnet_id,
  json_extract(ni.value, '$.VpcId') AS vpc_id,
  json_extract(ni.value, '$.MacAddress') AS mac_address,
  json_extract(ni.value, '$.Status') AS status,
  uri as query_uri
FROM 
  uniform_resource,
  json_each(json_extract(content, '$.rows')) as rowsValue,
  json_each(json_extract(rowsValue.value, '$.network_interfaces')) AS ni
WHERE 
  uri = 'SteampipeawsEC2Instances';

-- steampipeListAllAwsBuckets
DROP TABLE IF EXISTS ur_transform_aws_buckets;
CREATE TABLE ur_transform_aws_buckets AS
SELECT 
  json_extract(value, '$.name') AS name,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.creation_date') AS creation_date,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeListAllawsS3Buckets';

-- steampipeListAllAwsVPCs
DROP TABLE IF EXISTS ur_transform_aws_vpc;
CREATE TABLE ur_transform_aws_vpc AS
SELECT 
  json_extract(value, '$.vpc_id') AS vpc_id,
  json_extract(value, '$.title') AS title,
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.owner_id') AS owner_id,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.state') AS state,
  json_extract(value, '$.cidr_block') AS cidr_block,
  json_extract(value, '$.dhcp_options_id') AS dhcp_options_id,
  json_extract(value, '$.is_default') AS is_default,
  json_extract(value, '$.partition') AS partition,
  uri as query_uri
FROM uniform_resource,
     json_each(content ,'$.rows')
WHERE uri = 'SteampipeListAllAwsVPCs';

-- steampipeawsIAMUserInfo
DROP TABLE IF EXISTS ur_transform_aws_user_info;
CREATE TABLE ur_transform_aws_user_info AS
SELECT 
  json_extract(value, '$.user_id') AS user_id,
  json_extract(value, '$.name') AS name,
  json_extract(value, '$.create_date') AS create_date,
  json_extract(value, '$.password_last_used') AS password_last_used,
  json_extract(value, '$.path') AS path,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsIAMUserInfo';

-- SteampipeawsAccountInfo
DROP TABLE IF EXISTS ur_transform_aws_account_info;
CREATE TABLE ur_transform_aws_account_info AS
SELECT 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.title') AS title,
  json_extract(value, '$.alias') AS alias,
  json_extract(value, '$.arn') AS arn,
  json_extract(value, '$.organization_id') AS organization_id,
  json_extract(value, '$.organization_master_account_email') AS organization_master_account_email,
  json_extract(value, '$.organization_master_account_id') AS organization_master_account_id,
  json_extract(value, '$.partition') AS partition,
  json_extract(value, '$.region') AS region,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsAccountInfo';

-- SteampipeawsEC2ApplicationLoadBalancers
DROP TABLE IF EXISTS ur_transform_aws_ec2_application_load_balancer;
CREATE TABLE ur_transform_aws_ec2_application_load_balancer AS
SELECT 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.name') AS name,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.canonical_hosted_zone_id') AS canonical_hosted_zone_id,
  json_extract(value, '$.created_time') AS created_time,
  json_extract(value, '$.dns_name') AS dns_name,
  json_extract(value, '$.ip_address_type') AS ip_address_type,
  json_extract(value, '$.load_balancer_attributes') AS load_balancer_attributes,
  json_extract(value, '$.scheme') AS scheme,
  json_extract(value, '$.security_groups') AS security_groups,
  json_extract(value, '$.type') AS type,
  json_extract(value, '$.vpc_id') AS vpc_id,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsEC2ApplicationLoadBalancers';

-- SteampipeListAwsCostDetails
DROP TABLE IF EXISTS ur_transform_list_aws_cost_detail;
CREATE TABLE ur_transform_list_aws_cost_detail AS
SELECT 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount, 
  json_extract(value, '$.amortized_cost_unit') AS amortized_cost_unit,
  json_extract(value, '$.blended_cost_amount') AS blended_cost_amount, 
  json_extract(value, '$.estimated') AS estimated,
  json_extract(value, '$.unblended_cost_unit') AS unblended_cost_unit, 
  json_extract(value, '$.net_unblended_cost_unit') AS net_unblended_cost_unit,
  json_extract(value, '$.linked_account_id') AS linked_account_id,
  json_extract(value, '$.canonical_hosted_zone_id') AS canonical_hosted_zone_id,
  json_extract(value, '$.net_amortized_cost_amount') AS net_amortized_cost_amount,
  json_extract(value, '$.net_unblended_cost_amount') AS net_unblended_cost_amount,
  json_extract(value, '$.period_start') AS period_start,
  json_extract(value, '$.period_end') AS period_end,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount,
  json_extract(value, '$.usage_quantity_unit') AS usage_quantity_unit,
  json_extract(value, '$.unblended_cost_amount') AS unblended_cost_amount,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeListAwsCostDetails';

-- SteampipeawsMonthlyCostByAccount
DROP TABLE IF EXISTS ur_transform_list_aws_monthly_cost_detail;
CREATE TABLE ur_transform_list_aws_monthly_cost_detail AS
SELECT 
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount, 
  json_extract(value, '$.blended_cost_amount') AS blended_cost_amount, 
  json_extract(value, '$.linked_account_id') AS linked_account_id,
  json_extract(value, '$.net_amortized_cost_amount') AS net_amortized_cost_amount, 
  json_extract(value, '$.net_unblended_cost_amount') AS net_unblended_cost_amount,
  json_extract(value, '$.period_start') AS period_start,
  json_extract(value, '$.period_end') AS period_end,
  json_extract(value, '$.unblended_cost_amount') AS unblended_cost_amount,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsMonthlyCostByAccount';

-- SteampipeawsDailyCostByService
DROP TABLE IF EXISTS ur_transform_list_aws_daily_cost_by_service;
CREATE TABLE ur_transform_list_aws_daily_cost_by_service AS
SELECT 
  json_extract(value, '$.period_start') AS period_start, 
  json_extract(value, '$.period_end') AS period_end, 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.service') AS service, 
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount,
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeAwsCostByServiceDaily';

-- SteampipeAwsCostByServiceMonthly
DROP TABLE IF EXISTS ur_transform_list_aws_monthly_cost_by_service;
CREATE TABLE ur_transform_list_aws_monthly_cost_by_service AS
SELECT 
  json_extract(value, '$.period_start') AS period_start, 
  json_extract(value, '$.period_end') AS period_end, 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.service') AS service, 
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount,
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeAwsCostByServiceMonthly';
-- DROP VIEW IF EXISTS all_boundary;
-- CREATE VIEW all_boundary AS
-- SELECT 
--     boundary_id,
--     parent_boundary_id,
--     name 
-- FROM boundary;

-- DROP VIEW IF EXISTS parent_boundary;
-- CREATE VIEW parent_boundary AS
-- SELECT 
--     boundary_id,
--     name 
-- FROM boundary WHERE parent_boundary_id IS NULL;

DROP VIEW IF EXISTS expected_asset_list;
CREATE VIEW expected_asset_list AS
SELECT 
    ast.asset_id,
    ast.name AS host,
    ast.description,
    ast.asset_tag,
    astyp.value AS asset_type,
    assignment.value AS assignment,
    GROUP_CONCAT(bnd.name, ', ') AS boundaries,
    GROUP_CONCAT(parent.name, ', ') AS parent_boundaries
FROM asset ast
INNER JOIN asset_boundary ab ON ab.asset_id = ast.asset_id
INNER JOIN boundary bnd ON bnd.boundary_id = ab.boundary_id
LEFT JOIN boundary parent ON parent.boundary_id = bnd.parent_boundary_id
INNER JOIN asset_type astyp ON astyp.asset_type_id = ast.asset_type_id
INNER JOIN assignment ON assignment.assignment_id = ast.assignment_id
WHERE ast.asset_tag = "ACTIVE"
GROUP BY ast.asset_id;

DROP VIEW IF EXISTS boundary_list;
CREATE VIEW boundary_list AS
SELECT 
    boundary as boundary_key,
    boundary 
FROM surveilr_osquery_ms_node_boundary GROUP BY boundary;

DROP VIEW IF EXISTS expected_asset_service_list;
CREATE VIEW expected_asset_service_list AS
SELECT
  asser.name,
  ast.name AS server,
  ast.name AS host_identifier,
  ast.organization_id,
  astyp.value AS asset_type,
  astyp.asset_service_type_id,
  GROUP_CONCAT(bnt.name, ', ') AS boundary,
  asser.description,
  asser.port,
  asser.experimental_version,
  asser.production_version,
  asser.latest_vendor_version,
  asser.resource_utilization,
  asser.log_file,
  asser.url,
  asser.vendor_link,
  asser.installation_date,
  asser.criticality,
  o.name AS owner,
  sta.value AS tag,
  ast.criticality AS asset_criticality,
  ast.asymmetric_keys_encryption_enabled AS asymmetric_keys,
  ast.cryptographic_key_encryption_enabled AS cryptographic_key,
  ast.symmetric_keys_encryption_enabled AS symmetric_keys
FROM asset_service asser
INNER JOIN asset_service_type astyp ON astyp.asset_service_type_id = asser.asset_service_type_id
INNER JOIN asset ast ON ast.asset_id = asser.asset_id
INNER JOIN organization o ON o.organization_id = ast.organization_id
INNER JOIN asset_status sta ON sta.asset_status_id = ast.asset_status_id
INNER JOIN asset_boundary ab ON ab.asset_id = ast.asset_id
INNER JOIN boundary bnt ON bnt.boundary_id = ab.boundary_id
GROUP BY asser.asset_service_id;

DROP VIEW IF EXISTS host_list;
CREATE VIEW host_list AS
SELECT 
    "" as description,
    nodeDet.surveilr_osquery_ms_node_id,
    boundary.boundary as boundary,
    boundary.boundary as boundary_key,
    boundary.host_identifier as host,
    nodeDet.node_key,
    nodeDet.host_identifier,
    nodeDet.osquery_version,
    nodeDet.last_seen,
    nodeDet.created_at,
    nodeDet.updated_at,
    nodeDet.ip_address,
    nodeDet.mac,
    nodeDet.added_to_surveilr_osquery_ms,
    nodeDet.operating_system,
    nodeDet.available_space,
    nodeDet.node_status as status,
    nodeDet.last_fetched,
    nodeDet.last_restarted,
    nodeDet.issues,
    sysinfo.board_model,
    sysinfo.board_serial,
    sysinfo.board_vendor,
    sysinfo.board_version,
    sysinfo.computer_name,
    sysinfo.cpu_brand,
    sysinfo.cpu_logical_cores,
    sysinfo.cpu_microcode,
    sysinfo.cpu_physical_cores,
    sysinfo.cpu_sockets,
    sysinfo.cpu_subtype,
    sysinfo.cpu_type,
    sysinfo.hardware_model,
    sysinfo.hardware_serial,
    sysinfo.hardware_vendor,
    sysinfo.hardware_version,
    sysinfo.local_hostname,
    sysinfo.physical_memory,
    sysinfo.uuid,
    boundary.query_uri,
    eal.boundaries as logical_boundary
FROM surveilr_osquery_ms_node_boundary boundary
LEFT JOIN surveilr_osquery_ms_node_detail nodeDet ON nodeDet.host_identifier=boundary.host_identifier
LEFT JOIN surveilr_osquery_ms_node_system_info sysinfo ON sysinfo.host_identifier=boundary.host_identifier
LEFT JOIN expected_asset_list eal ON nodeDet.host_identifier= eal.host;

DROP VIEW IF EXISTS boundary_asset_count_list;
CREATE VIEW boundary_asset_count_list AS
SELECT 
    boundary.boundary AS boundary_name,
    COUNT(DISTINCT boundary.host_identifier) AS host_count
FROM surveilr_osquery_ms_node_boundary boundary
LEFT JOIN surveilr_osquery_ms_node_detail nodeDet 
    ON nodeDet.host_identifier = boundary.host_identifier
GROUP BY boundary.boundary
ORDER BY host_count DESC;

DROP VIEW IF EXISTS logical_boundary_asset_count_list;
CREATE VIEW logical_boundary_asset_count_list AS
SELECT 
    bnt.name AS boundary_name,
    COUNT(ast_bnt.asset_id) AS host_count
FROM boundary bnt 
INNER JOIN asset_boundary ast_bnt ON ast_bnt.boundary_id = bnt.boundary_id
INNER JOIN asset ON asset.asset_id = ast_bnt.asset_id
INNER JOIN surveilr_osquery_ms_node_detail node ON node.host_identifier=asset.name
WHERE bnt.parent_boundary_id IS NOT NULL
GROUP BY bnt.name
ORDER BY host_count DESC;;

-- policy list of host 
DROP VIEW IF EXISTS asset_policy_list;
CREATE VIEW asset_policy_list AS
SELECT 
    host.host_identifier,
    host.host_identifier as host,
    pol.host_identifier,
    pol.policy_name,
    pol.policy_result,
    pol.resolution,
    host.query_uri
FROM surveilr_osquery_ms_node_boundary host
INNER JOIN surveilr_osquery_ms_node_executed_policy pol ON pol.host_identifier=host.host_identifier;

-- Installed software of host 
DROP VIEW IF EXISTS asset_software_list;
CREATE VIEW asset_software_list AS
SELECT 
    host.host_identifier,
    host.host_identifier as host,
    sw.name,
    sw.source,
    sw.type,
    sw.version,
    sw.platform
FROM surveilr_osquery_ms_node_boundary host
INNER JOIN surveilr_osquery_ms_node_installed_software sw ON sw.host_identifier=host.host_identifier;

-- User list of host 
DROP VIEW IF EXISTS asset_user_list;
CREATE VIEW asset_user_list AS
SELECT 
    host.host_identifier,
    host.host_identifier as host,
    ss.host_identifier,
    ss.user_name,
    ss.directory,
    ss.uid
FROM surveilr_osquery_ms_node_boundary host
INNER JOIN ur_transform_list_user ss ON ss.host_identifier=host.host_identifier;

DROP VIEW IF EXISTS list_docker_container;
CREATE VIEW list_docker_container AS
SELECT 
host.host_identifier,
c.container_name,
c.image,
c.status,
c.state,
port.host_port,
port.port,
ni.ip_address,
process.process_name as process,
user.user_name as owenrship,
datetime(created, 'unixepoch', 'localtime') AS created_date
FROM ur_transform_list_container AS c
INNER JOIN ur_transform_list_container_ports AS port ON port.id=c.id
INNER JOIN ur_transform_list_network_information AS ni ON ni.id=c.id AND ni.hostIdentifier=c.hostIdentifier
INNER JOIN surveilr_osquery_ms_node_boundary AS host ON host.host_identifier=c.hostIdentifier
INNER JOIN ur_transform_list_container_process AS process ON process.pid=c.pid AND process.host=c.hostIdentifier
INNER JOIN asset_user_list AS user ON user.uid=process.uid; 

DROP VIEW IF EXISTS list_docker_container;
CREATE VIEW list_docker_container AS
SELECT 
host.host_identifier,
c.container_name,
c.image,
c.status,
c.state,
port.host_port,
port.port,
ni.ip_address,
process.process_name as process,
user.user_name as owenrship,
datetime(created, 'unixepoch', 'localtime') AS created_date
FROM ur_transform_list_container AS c
INNER JOIN ur_transform_list_container_ports AS port ON port.id=c.id
INNER JOIN ur_transform_list_network_information AS ni ON ni.id=c.id AND ni.hostIdentifier=c.hostIdentifier
INNER JOIN surveilr_osquery_ms_node_boundary AS host ON host.host_identifier=c.hostIdentifier
INNER JOIN ur_transform_list_container_process AS process ON process.pid=c.pid AND process.host=c.hostIdentifier
INNER JOIN asset_user_list AS user ON user.uid=process.uid;

DROP VIEW IF EXISTS list_aws_ec2_instance;
CREATE VIEW list_aws_ec2_instance AS
SELECT
  ec2.instance_id,
  ec2.account_id,
  ec2.title,
  ec2.architecture,
  ec2.platform_details,
  ec2.root_device_name,
  ec2.state,
  ec2.instance_type,
  ec2.cpu_options_core_count,
  ec2.az,
  ec2.launch_time,
  ec2.network_interface_id,
  ec2.private_ip_address,
  ec2.public_ip_address,
  ec2.subnet_id,
  ec2.vpc_id,
  ec2.mac_address,
  ec2.status,
  vpc.title as vpc_name,
  vpc.state as vpc_state
FROM
  ur_transform_ec2_instance AS ec2
LEFT JOIN ur_transform_aws_vpc vpc ON ec2.vpc_id=vpc.vpc_id;

DROP VIEW IF EXISTS list_aws_s3_bucket;
CREATE VIEW list_aws_s3_bucket AS
SELECT
name,
region,
creation_date
FROM
  ur_transform_aws_buckets;

DROP VIEW IF EXISTS list_aws_vpc;
CREATE VIEW list_aws_vpc AS
SELECT
vpc.title as vpc_name,
account.title as account,
account.title as owner,
vpc.region,
vpc.state,
vpc.cidr_block,
vpc.dhcp_options_id,
vpc.is_default,
vpc.partition
FROM
  ur_transform_aws_vpc vpc
LEFT JOIN ur_transform_aws_account_info account ON vpc.account_id = account.account_id;

DROP VIEW IF EXISTS list_aws_ec2_application_load_balancer;
CREATE VIEW list_aws_ec2_application_load_balancer AS
SELECT
lb.name,
account.title as account,
account.title as owner,
vpc.title as vpc,
lb.region,
lb.created_time,
lb.dns_name,
lb.ip_address_type,
lb.load_balancer_attributes,
lb.scheme,
lb.security_groups,
lb.type
FROM
  ur_transform_aws_ec2_application_load_balancer lb
INNER JOIN ur_transform_aws_account_info account ON lb.account_id = account.account_id
INNER JOIN ur_transform_aws_vpc vpc ON lb.vpc_id=vpc.vpc_id;

DROP VIEW IF EXISTS list_aws_cost_detail;
CREATE VIEW list_aws_cost_detail AS
SELECT 
account_id,
amortized_cost_amount,
amortized_cost_unit,
blended_cost_amount,
estimated,
unblended_cost_unit,
net_unblended_cost_unit,
linked_account_id,
canonical_hosted_zone_id,
net_amortized_cost_amount,
net_unblended_cost_amount,
period_start,
period_end,
region,
usage_quantity_amount,
usage_quantity_unit,
unblended_cost_amount
FROM ur_transform_list_aws_cost_detail;

DROP VIEW IF EXISTS list_aws_monthely_cost_detail;
CREATE VIEW list_aws_monthely_cost_detail AS
SELECT 
acd.amortized_cost_amount,
acd.blended_cost_amount,
acd.net_amortized_cost_amount,
acd.net_unblended_cost_amount,
acd.period_start,
acd.period_end,
acd.unblended_cost_amount,
acc.title as account
FROM ur_transform_list_aws_monthly_cost_detail AS acd
INNER JOIN ur_transform_aws_account_info AS acc ON acd.linked_account_id = acc.account_id ORDER BY acd.period_start DESC;


DROP VIEW IF EXISTS list_aws_service_from_daily_cost;
CREATE VIEW list_aws_service_from_daily_cost AS
SELECT 
service
FROM ur_transform_list_aws_daily_cost_by_service GROUP BY service;

DROP VIEW IF EXISTS list_aws_daily_service_cost;
CREATE VIEW list_aws_daily_service_cost AS
SELECT 
acd.period_start,
acd.period_end,
acd.service,
acd.region,
acd.amortized_cost_amount,
acd.usage_quantity_amount,
acd.amortized_cost_amount,
acc.title as account
FROM ur_transform_list_aws_daily_cost_by_service AS acd
INNER JOIN ur_transform_aws_account_info AS acc ON acd.account_id = acc.account_id ORDER BY acd.period_start DESC;

DROP VIEW IF EXISTS list_aws_monthly_service_cost;
CREATE VIEW list_aws_monthly_service_cost AS
SELECT 
acd.period_start,
acd.period_end,
acd.service,
acd.region,
acd.amortized_cost_amount,
acd.usage_quantity_amount,
acd.amortized_cost_amount,
acc.title as account
FROM ur_transform_list_aws_monthly_cost_by_service AS acd
INNER JOIN ur_transform_aws_account_info AS acc ON acd.account_id = acc.account_id ORDER BY acd.period_start DESC;

DROP VIEW IF EXISTS list_container_process;
CREATE VIEW list_container_process AS
SELECT 
host_identifier,
name,
host,
process_name,
pid,
uid,
start_time,
state,
CASE state
  WHEN 'R' THEN 'Running'
  WHEN 'S' THEN 'Sleeping'
  WHEN 'D' THEN 'Uninterruptible Sleep'
  WHEN 'Z' THEN 'Zombie'
  WHEN 'T' THEN 'Stopped'
  WHEN 't' THEN 'Tracing Stop'
  WHEN 'X' THEN 'Dead'
  WHEN 'x' THEN 'Dead'
  WHEN 'K' THEN 'Wakekill'
  WHEN 'W' THEN 'Waking'
  WHEN 'P' THEN 'Parked'
  WHEN 'I' THEN 'Idle'
  ELSE 'Unknown'
END AS state_description
FROM ur_transform_list_container_process;
-- delete all /fleetfolio-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE parent_path like 'fleetfolio'||'/index.sql';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'fleetfolio/index.sql', 'fleetfolio/index.sql', 'Fleetfolio', NULL, NULL, 'Fleetfolio is a powerful infrastructure assurance platform built on surveilr that helps organizations achieve continuous compliance, security, and operational reliability. Unlike traditional asset management tools that simply list discovered assets, Fleetfolio takes a proactive approach by defining expected infrastructure assets and verifying them against actual assets found using osQuery Management Server (MS).', NULL),
    ('prime', 'fleetfolio/index.sql', 1, 'fleetfolio/boundary.sql', 'fleetfolio/boundary.sql', 'Boundaries', NULL, NULL, 'The Server (Host) List ingested via osQuery provides real-time visibility into all discovered infrastructure assets.', NULL),
    ('prime', 'fleetfolio/index.sql', 1, 'fleetfolio/assets.sql', 'fleetfolio/assets.sql', 'Assets', NULL, NULL, 'The Server (Host) List ingested via osQuery provides real-time visibility into all discovered infrastructure assets.', NULL)
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
    ('prime', 'console/index.sql', 1, 'console/statistics/index.sql', 'console/statistics/index.sql', 'RSSD Statistics', 'Statistics', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL)
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
      'fleetfolio/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''fleetfolio/index.sql''
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
              

              select
    ''text''              as component,
    ''Fleetfolio is a powerful infrastructure assurance platform built on surveilr that helps organizations achieve continuous compliance, security, and operational reliability. Unlike traditional asset management tools that simply list discovered assets, Fleetfolio takes a proactive approach by defining expected infrastructure assets and verifying them against actual assets found using osQuery Management Server (MS).'' as contents;
  WITH navigation_cte AS (
      SELECT COALESCE(title, caption) as title, description
        FROM sqlpage_aide_navigation
       WHERE namespace = ''prime'' AND path = ''fleetfolio''||''/index.sql''
  )
  SELECT ''list'' AS component, title, description
    FROM navigation_cte;
  SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND parent_path = ''fleetfolio''||''/index.sql''
   ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/boundary.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''fleetfolio/boundary.sql''
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
   WHERE namespace = ''prime'' AND path = ''fleetfolio/boundary.sql/index.sql'') as contents;
    ;

    -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
      --- Dsply Page Title
  SELECT
      ''title''   as component,
      ''Boundary '' contents;

     select
      ''text''              as component,
      ''A boundary refers to a defined collection of servers and assets that work together to provide a specific function or service. It typically represents a perimeter or a framework within which resources are organized, managed, and controlled. Within this boundary, servers and assets are interconnected, often with defined roles and responsibilities, ensuring that operations are executed smoothly and securely. This concept is widely used in IT infrastructure and network management to segment and protect different environments or resources.'' as contents;

    -- Dashboard count
    select
        ''card'' as component,
        4      as columns;
    select
        boundary  as title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/host_list.sql?boundary_key='' || boundary_key as link
    FROM boundary_list;

-- AWS Trust Boundary
select
    ''card'' as component,
     4      as columns;
select
    "AWS Trust Boundary"  as title,
    ''brand-aws'' as icon,
    ''orange'' as color,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' as link
 ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/assets.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''fleetfolio/assets.sql''
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
   WHERE namespace = ''prime'' AND path = ''fleetfolio/assets.sql/index.sql'') as contents;
    ;

    -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
      --- Dsply Page Title
  SELECT
      ''title''   as component,
      ''Assets '' contents;
    select
      ''text''              as component,
      ''Assets refer to a collection of IT resources such as nodes, servers, virtual machines, and other infrastructure components'' as contents;

  -- Display dasboard count of physical boundaries
  SELECT 
    ''card''                     as component,
    ''Physical boundaries'' as title,
    4                     as columns;
    select 
        boundary_name  as title,
        ''assets.sql?physical_boundary=''||boundary_name as link,
        host_count as description
        FROM boundary_asset_count_list;

  

  -- Display dasboard count of logical boundaries
  SELECT 
    ''card''                     as component,
    ''Logical boundaries'' as title,
    4                     as columns;
    select 
        boundary_name  as title,
        ''assets.sql?logical_boundary=''||boundary_name as link,
        host_count as description
        FROM logical_boundary_asset_count_list;

    -- asset list
SELECT ''table'' AS component,
    ''host'' as markdown,
    TRUE as sort,
    TRUE as search;
SELECT
''['' || host || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/host_detail.sql?host_identifier='' || host_identifier || ''&path=direct)'' as host,
boundary,
logical_boundary as "logical boundary",
CASE 
    WHEN status = ''Online'' THEN ''🟢 Online''
    WHEN status = ''Offline'' THEN ''🔴 Offline''
    ELSE ''⚠️ Unknown''
END AS "Status",
osquery_version as "Os query version",
available_space AS "Disk space available",
operating_system AS "Operating System",
osquery_version AS "osQuery Version",
ip_address AS "IP Address",
last_fetched AS "Last Fetched",
last_restarted AS "Last Restarted"
FROM host_list 
WHERE
  CASE
      WHEN $physical_boundary IS NOT NULL THEN boundary LIKE ''%''||$physical_boundary||''%''
      WHEN $logical_boundary IS NOT NULL THEN logical_boundary LIKE ''%''||$logical_boundary||''%''
      ELSE 1 = 1
  END;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/host_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/host_list.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Fleetfolio'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
  SELECT ''Boundary'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link;
  SELECT boundary AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/host_list.sql?boundary_key='' || boundary_key  AS link
    FROM host_list WHERE boundary_key=$boundary_key LIMIT 1;


--- Dsply Page Title
SELECT
    ''title''   as component,
    boundary as contents FROM host_list WHERE boundary_key=$boundary_key LIMIT 1;

   select
    ''text''              as component,
    ''A boundary refers to a defined collection of servers and assets that work together to provide a specific function or service. It typically represents a perimeter or a framework within which resources are organized, managed, and controlled. Within this boundary, servers and assets are interconnected, often with defined roles and responsibilities, ensuring that operations are executed smoothly and securely. This concept is widely used in IT infrastructure and network management to segment and protect different environments or resources.'' as contents;

 -- asset list
  SELECT ''table'' AS component,
      ''host'' as markdown,
      TRUE as sort,
      TRUE as search;
  SELECT 
  ''['' || host || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/host_detail.sql?host_identifier='' || host_identifier || ''&path=boundary)'' as host,
  boundary,
  CASE 
      WHEN status = ''Online'' THEN ''🟢 Online''
      WHEN status = ''Offline'' THEN ''🔴 Offline''
      ELSE ''⚠️ Unknown''
  END AS "Status",
  osquery_version as "Os query version",
  available_space AS "Disk space available",
  operating_system AS "Operating System",
  osquery_version AS "osQuery Version",
  ip_address AS "IP Address",
  last_fetched AS "Last Fetched",
  last_restarted AS "Last Restarted"
  FROM host_list WHERE boundary_key=$boundary_key;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/host_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/host_detail.sql/index.sql'') as contents;
    ;
  --- Display breadcrumb
  SELECT
      ''breadcrumb'' AS component;
  SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
  SELECT
      ''Fleetfolio'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
  SELECT
      ''Boundary'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link WHERE $path=''boundary''; 
  SELECT boundary AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/host_list.sql?boundary_key='' || boundary_key  AS link
      FROM host_list WHERE host_identifier=$host_identifier AND $path=''boundary'' LIMIT 1;
  SELECT host AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/host_detail.sql?host_identifier='' || host_identifier  AS link
      FROM host_list WHERE host_identifier=$host_identifier LIMIT 1;


  --- Dsply Page Title
  SELECT
      ''title''   as component,
      host as contents FROM host_list WHERE host_identifier=$host_identifier;

  SELECT
      ''text''              as component,
      description as contents FROM host_list WHERE host_identifier=$host_identifier;

    -- Display sourse lable of data
    SELECT
      ''html'' AS component,
      contents,
      ''<div style="width: 100%; padding-top: 20px; text-align: right; font-size: 14px; color: #666;">
      Source: <strong>'' || contents || ''</strong>
      </div>'' AS html
    FROM (
      SELECT
        query_uri,
        CASE
          WHEN query_uri LIKE ''%osquery%'' THEN ''osquery''
          WHEN query_uri LIKE ''%Steampipe%'' THEN ''Steampipe''
          ELSE ''Other''
        END AS contents
      FROM host_list
      LIMIT 1
    );


  --- Display Asset (Host) Details first row
  SELECT ''datagrid'' as component;
      -- SELECT ''Parent Boundary'' as title, parent_boundary as description FROM host_list WHERE asset_id=$host_identifier;
      SELECT ''Boundary'' as title, boundary as description FROM host_list WHERE host_identifier=$host_identifier;
      SELECT ''Logical Boundary'' as title, logical_boundary as description FROM host_list WHERE host_identifier=$host_identifier;
      SELECT ''Status'' as title,
      CASE 
          WHEN status = ''Online'' THEN ''🟢 Online''
          WHEN status = ''Offline'' THEN ''🔴 Offline''
          ELSE ''⚠️ Unknown''
      END AS  description FROM host_list WHERE host_identifier=$host_identifier;
      SELECT ''Issues'' as title, issues as description FROM host_list WHERE host_identifier=$host_identifier;
      SELECT ''Osquery version'' as title, osquery_version as description FROM host_list WHERE host_identifier=$host_identifier;
      SELECT ''Operating system'' as title, operating_system as description FROM host_list WHERE host_identifier=$host_identifier;


     -- Display sourse lable of data
     SELECT
      ''html'' AS component,
      contents,
      ''<div style="width: 100%; padding-top: 20px; text-align: right; font-size: 14px; color: #666;">
      Source: <strong>'' || contents || ''</strong>
      </div>'' AS html
    FROM (
      SELECT
        query_uri,
        CASE
          WHEN query_uri LIKE ''%osquery%'' THEN ''osquery''
          WHEN query_uri LIKE ''%Steampipe%'' THEN ''Steampipe''
          ELSE ''Other''
        END AS contents
      FROM host_list
      LIMIT 1
    );
      select 
          ''html'' as component,
          ''<div style="display: flex; gap: 20px; width: 100%;">
              <!-- First Column -->
              <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc;  border-radius: 4px; width: 33%; background-color: #ffffff;">
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">Disk space</div>
                      <div>'' || available_space || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">Memory</div>
                      <div>'' || ROUND(physical_memory / (1024 * 1024 * 1024), 2) || '' GB'' || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">Processor Type</div>
                      <div>'' || cpu_type || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px;">
                      <div class="datagrid-title">Added to surveilr</div>
                      <div>'' || added_to_surveilr_osquery_ms || ''</div>
                  </div>
              </div> 

              <!-- Second Column -->
              <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">Hardware Model</div>
                      <div>'' || hardware_model || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">Board Model</div>
                      <div>'' || board_model || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">Serial Number</div>
                      <div>'' || hardware_serial || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px;">
                      <div class="datagrid-title">Last restarted</div>
                      <div>'' || last_restarted || ''</div>
                  </div>
              </div> 

              <!-- Third Column -->
              <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">IP Address</div>
                      <div>'' || ip_address || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                      <div class="datagrid-title">Mac Address</div>
                      <div>'' || mac || ''</div>
                  </div>
                  <div style="display: flex; justify-content: space-between; padding: 4px;">
                      <div class="datagrid-title">Last Fetched</div>
                      <div>'' || last_fetched || ''</div>
                  </div>
              </div>
          </div>
      '' as html FROM host_list WHERE host_identifier=$host_identifier;

  select 
  ''divider'' as component,
  ''System Environment''   as contents;

  SELECT ''tab'' AS component, TRUE AS center;
  SELECT ''Policies'' AS title, ''?tab=policies&host_identifier='' || $host_identifier AS link, ($tab = ''policies'' OR $tab IS NULL) AS active;
  select ''Software'' as title, ''?tab=software&host_identifier='' || $host_identifier AS link, $tab = ''software'' as active;
  select ''Users'' as title, ''?tab=users&host_identifier='' || $host_identifier AS link, $tab = ''users'' as active;
  select ''Containers'' as title, ''?tab=container&host_identifier='' || $host_identifier AS link, $tab = ''container'' as active;
  select ''All Process'' as title, ''?tab=all_process&host_identifier='' || $host_identifier AS link, $tab = ''all_process'' as active;
  select ''Asset Service'' as title, ''?tab=asset_service&host_identifier='' || $host_identifier AS link, $tab = ''asset_service'' as active;



  -- policy table and tab value Start here
  -- policy pagenation

  -- Display sourse lable of data
  SELECT
    ''html'' AS component,
    contents,
    ''<div style="width: 100%; padding-top: 20px; text-align: right; font-size: 14px; color: #666;">
    Source : <strong>'' || contents || ''</strong>
    </div>'' AS html
    FROM (
      SELECT
        query_uri,
        CASE
          WHEN query_uri LIKE ''%osquery%'' THEN ''osquery''
          WHEN query_uri LIKE ''%Steampipe%'' THEN ''Steampipe''
          ELSE ''Other''
        END AS contents
      FROM asset_policy_list WHERE host_identifier = $host_identifier LIMIT 1
    ) WHERE $tab = ''policies'';

  SET total_rows = (SELECT COUNT(*) FROM asset_policy_list WHERE host_identifier=$host_identifier);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT ''table'' AS component, TRUE as sort, TRUE as search WHERE ($tab = ''policies'' OR $tab IS NULL);
  SELECT 
  policy_name AS "Policy", policy_result as "Status", resolution
  FROM asset_policy_list
  WHERE host_identifier = $host_identifier AND ($tab = ''policies'' OR $tab IS NULL) LIMIT $limit
  OFFSET $offset;
  -- checking
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''policies'';;

  -- Software table and tab value Start here
 
  SET total_rows = (SELECT COUNT(*) FROM asset_software_list WHERE host_identifier=$host_identifier);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT ''table'' AS component, TRUE as sort, TRUE as search WHERE $tab = ''software'';
  SELECT name, version, type, platform, ''-'' AS "Vulnerabilities"
  FROM asset_software_list
  WHERE host_identifier = $host_identifier AND $tab = ''software''
  LIMIT $limit OFFSET $offset;

  -- Software pagenation
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''software'';;

  -- User table and tab value Start here
  SET total_rows = (SELECT COUNT(*) FROM asset_user_list WHERE host_identifier=$host_identifier);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT ''table'' AS component, TRUE as sort, TRUE as search WHERE $tab = ''users'';
  SELECT user_name as "User Name", directory as "Directory"
  FROM asset_user_list
  WHERE host_identifier = $host_identifier AND $tab = ''users''
  LIMIT $limit OFFSET $offset;

  -- User pagenation
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''users'';;

-- Container table and tab value Start here
-- Container pagenation
SET total_rows = (SELECT COUNT(*) FROM list_docker_container WHERE host_identifier=$host_identifier);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT ''table'' AS component, TRUE as sort, TRUE as search,TRUE    as hover
   WHERE $tab = ''container'';
  SELECT LTRIM(container_name, ''/'') AS name, image,host_port AS "host Port",
  port, ip_address as "IP Address", owenrship, process, state, status,created_date as created
  FROM list_docker_container
  WHERE host_identifier = $host_identifier AND $tab = ''container''
  LIMIT $limit OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''container'';;


  -- all_process table and tab value Start here
  -- all_process pagenation
  SET total_rows = (SELECT COUNT(*) FROM list_container_process WHERE host_identifier=$host_identifier);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT ''table'' AS component, TRUE as sort, TRUE as search WHERE $tab = ''all_process'';
  SELECT process_name AS "process name",start_time as "start time", state, state_description as "state description"
  FROM list_container_process
  WHERE host_identifier = $host_identifier AND $tab = ''all_process''
  LIMIT $limit OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''all_process'';;

-- asset_service table and tab value Start here
  -- asset_service pagenation
  SET total_rows = (SELECT COUNT(*) FROM expected_asset_service_list WHERE host_identifier=$host_identifier);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
  SELECT ''table'' AS component, TRUE as sort, TRUE as search WHERE $tab = ''asset_service'';
  SELECT name AS "service",
  server,asset_type as "asset type",boundary, description, port,
  installation_date as "installation date"
  FROM expected_asset_service_list
  WHERE host_identifier = $host_identifier AND $tab = ''asset_service''
  LIMIT $limit OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&host_identifier='' || replace($host_identifier, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''asset_service'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_trust_boundary_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_trust_boundary_list.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 --- Dsply Page Title 
 SELECT
     ''title''   as component,
     "AWS Trust Boundary" contents; 

  -- Dashboard count
   select
       ''card'' as component,
       4      as columns;
   select
       "AWS EC2 instance "  as title,
       ''square'' as icon,
       ''orange''                    as color,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_ec2_instance_list.sql'' as link;
   select
       "AWS S3 buckets"  as title,
       "bucket" as icon,
       ''blue''                    as color,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_s3_bucket_list.sql'' as link;
   select
       "AWS VPC"  as title,
       "cloud" as icon,
       ''black''                    as color,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_vpc_list.sql'' as link;
   select
       "AWS EC2 Application Load Balancer"  as title,
       "load-balancer" as icon,
       ''orange''                    as color,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_ec2_application_load_balancer.sql'' as link;
   select
       "AWS Cost"  as title,
       "settings-dollar" as icon,
       ''black''                    as color,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_cost_detail_list.sql'' as link;
    select
       "AWS Monthely Cost Detail"  as title,
       "settings-dollar" as icon,
       ''black''                    as color,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_monthely_cost_detail_list.sql'' as link;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_ec2_instance_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_ec2_instance_list.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 SELECT
   ''AWS EC2 instance'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_ec2_instance_list.sql'' AS link; 


 --- Dsply Page Title
 SELECT
     ''title''   as component,
     "AWS EC2 instance" contents;

    select
     ''text''              as component,
     ''An EC2 instance represents a virtual server hosted on Amazon Web Services (AWS), used to run applications, services, or processes in a scalable and flexible cloud environment. Each instance is provisioned with a specific configuration—such as CPU, memory, storage, and networking capabilities—to meet the needs of the workload it supports. EC2 instances are a core component of cloud infrastructure, enabling users to deploy and manage computing resources without the need for physical hardware. They can be started, stopped, resized, or terminated as needed, offering full control over performance, cost, and security.'' as contents;


 SET total_rows = (SELECT COUNT(*) FROM list_aws_ec2_instance );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
SELECT ''table'' AS component,
       ''host'' as markdown,
       TRUE as sort,
       TRUE as search,
       ''title'' as markdown;
   SELECT 
   ''['' || title || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_ec2_instance_detail.sql?instance_id='' || instance_id || '')'' as title,
   architecture,
   platform_details AS platform, 
   root_device_name as "root device name",
   state,
   instance_type as "instance type",
   datetime(substr(launch_time, 1, 19)) as "launch time"
   FROM list_aws_ec2_instance;
    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_ec2_instance_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_ec2_instance_detail.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 
 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 SELECT
   ''AWS EC2 instance'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_ec2_instance_list.sql'' AS link; 
 SELECT
   title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_ec2_instance_detail.sql?instance_id='' || instance_id AS link FROM list_aws_ec2_instance WHERE instance_id=$instance_id; 

 --- Dsply Page Title
   SELECT
     ''title''   as component,
     title as contents FROM list_aws_ec2_instance WHERE instance_id=$instance_id;

   select
     ''text''              as component,
     ''An EC2 instance represents a virtual server hosted on Amazon Web Services (AWS), used to run applications, services, or processes in a scalable and flexible cloud environment. Each instance is provisioned with a specific configuration—such as CPU, memory, storage, and networking capabilities—to meet the needs of the workload it supports. EC2 instances are a core component of cloud infrastructure, enabling users to deploy and manage computing resources without the need for physical hardware. They can be started, stopped, resized, or terminated as needed, offering full control over performance, cost, and security.'' as contents;

    select 
           ''html'' as component,
           ''<div style="display: flex; gap: 20px; width: 100%;">
               <!-- First Column -->
               <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc;  border-radius: 4px; width: 33%; background-color: #ffffff;">
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Architecture</div>
                       <div>''|| architecture ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Platform</div>
                       <div>''|| platform_details ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Root Device Name</div>
                       <div>''|| root_device_name ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px;">
                       <div class="datagrid-title">Type </div>
                       <div>''|| instance_type ||''</div>
                   </div>
               </div> 

               <!-- Second Column -->
               <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">state</div>
                       <div>''|| state ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Cpu options core count</div>
                       <div>''|| cpu_options_core_count ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Availability Zone</div>
                       <div>''|| az ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px;">
                       <div class="datagrid-title">Launch Time</div>
                       <div>''|| datetime(substr(launch_time, 1, 19)) ||''</div>
                   </div>
               </div> 

               <!-- Third Column -->
               <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Private IP Address</div>
                       <div>''|| private_ip_address ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Mac Address</div>
                       <div>''|| mac_address ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">Public IP Address</div>
                       <div>''|| COALESCE(public_ip_address, ''No IP address'') ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px;">
                       <div class="datagrid-title">Status</div>
                       <div>''|| status ||''</div>
                   </div>
               </div>
                <!-- Fourth Column -->
               <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">VPC</div>
                       <div>''|| COALESCE(vpc_name, ''No VPC name available'') ||''</div>
                   </div>
                   <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                       <div class="datagrid-title">VPC State</div>
                       <div>''|| COALESCE(vpc_state, ''No VPC state available'') ||''</div>
                   </div>
           
               </div>
           </div>

       '' as html FROM list_aws_ec2_instance WHERE instance_id=$instance_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_s3_bucket_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_s3_bucket_list.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 SELECT
   ''AWS S3 buckets'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/list_aws_ec2_instance.sql'' AS link; 


 --- Dsply Page Title
 SELECT
     ''title''   as component,
     "AWS S3 buckets" contents;

    select
     ''text''              as component,
     ''AWS S3 Bucket is a scalable storage container in Amazon Simple Storage Service (S3) used to store and organize objects (such as files, images, backups, and data). Each bucket has a globally unique name and supports features like versioning, access control, encryption, and lifecycle policies.'' as contents;


 SET total_rows = (SELECT COUNT(*) FROM list_aws_s3_bucket );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
SELECT ''table'' AS component,
       ''host'' as markdown,
       TRUE as sort,
       TRUE as search,
       ''title'' as markdown;
   SELECT 
   name,
   region,
   datetime(substr(creation_date, 1, 19)) as "Creation date"
   FROM list_aws_s3_bucket;
    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_vpc_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_vpc_list.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 SELECT
   ''AWS VPC'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_vpc_list.sql'' AS link; 


 --- Dsply Page Title
 SELECT
     ''title''   as component,
     "AWS VPC" contents;

    select
     ''text''              as component,
     ''Amazon Virtual Private Cloud (VPC) is a logically isolated section of the AWS Cloud where you can launch and manage AWS resources in a custom-defined network. You control key networking aspects like IP address ranges, subnets, route tables, internet gateways, and security settings.'' as contents;


 SET total_rows = (SELECT COUNT(*) FROM list_aws_vpc );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
SELECT ''table'' AS component,
       ''host'' as markdown,
       TRUE as sort,
       TRUE as search;
   SELECT 
   vpc_name as name,
   account,
   owner,
   region,
   state,
   cidr_block as ''cidr block'',
   dhcp_options_id as ''DHCP Options ID'',
   is_default as "is default",
   partition
   FROM list_aws_vpc;
    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_ec2_application_load_balancer.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_ec2_application_load_balancer.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 SELECT
   ''AWS EC2 Application Load Balancer'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_ec2_application_load_balancer.sql'' AS link; 


 --- Dsply Page Title
 SELECT
     ''title''   as component,
     "AWS EC2 Application Load Balancer" contents;

    select
     ''text''              as component,
     ''The AWS EC2 Application Load Balancer (ALB) is a highly scalable and flexible load balancing service designed to distribute incoming HTTP and HTTPS traffic across multiple targets, such as EC2 instances, containers, and IP addresses, within one or more Availability Zones. It operates at the application layer (Layer 7 of the OSI model), allowing advanced routing based on content such as URL paths, host headers, and HTTP headers. ALB supports features like SSL termination, WebSocket support, and integration with AWS services like Auto Scaling and ECS, making it ideal for modern web applications and microservices architectures.'' as contents;


 SET total_rows = (SELECT COUNT(*) FROM list_aws_ec2_application_load_balancer );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
SELECT ''table'' AS component,
       TRUE as sort,
       TRUE as search;
   SELECT 
   name,
   account,
   owner,
   vpc,
   region,
   dns_name as ''dns name'',
   ip_address_type as ''ip address type'',
   scheme,
   type
   FROM list_aws_ec2_application_load_balancer;
    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_cost_detail_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_cost_detail_list.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 SELECT
   ''AWS Cost Summary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_cost_detail_list.sql'' AS link; 


 --- Dsply Page Title
 SELECT
     ''title''   as component,
     "AWS Cost Summary" contents;

    select
     ''text''              as component,
     ''View a consolidated summary of your AWS spending, broken down by account and month. Monitor trends, compare costs, and gain insights to optimize your cloud expenses.'' as contents;


 SET total_rows = (SELECT COUNT(*) FROM list_aws_service_from_daily_cost );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
   SELECT ''table'' AS component,
         ''Service'' as markdown,
         TRUE as sort,
         TRUE as search;
   SELECT 
     "[" || service || "](aws_cost_report.sql?service="|| replace(service, '' '', ''%20'') || "&tab=daily_cost)" AS "Service" FROM list_aws_service_from_daily_cost;
    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_cost_report.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_cost_report.sql/index.sql'') as contents;
    ;
    --- Display breadcrumb
 SELECT
    ''breadcrumb'' AS component;
  SELECT
    ''Home'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
  SELECT
    ''Fleetfolio'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
  SELECT
    ''Boundary'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

  SELECT
    ''AWS Trust Boundary'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

  SELECT
    ''AWS Cost Summary'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_cost_detail_list.sql'' AS link; 

  SELECT
    $service AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_cost_report.sql?service='' || $service  AS link; 

  --- Dsply Page Title
  SELECT
      ''title''   as component,
      $service contents;

     select
      ''text''              as component,
      ''View a consolidated summary of your AWS spending, broken down by account and month. Monitor trends, compare costs, and gain insights to optimize your cloud expenses.'' as contents;

  SELECT ''tab'' AS component, TRUE AS center;
  SELECT ''Daily Cost'' AS title, ''?tab=daily_cost&service='' || $service AS link, ($tab = ''daily_cost'' OR $tab IS NULL) AS active;
  select ''Monthly Cost'' as title, ''?tab=monthly_coste&service='' || $service AS link, $tab = ''monthly_coste'' as active;


SELECT ''table'' AS component,
        TRUE as sort,
        TRUE as search;
-- AWS daily service cost list
SET total_rows = (SELECT COUNT(*) FROM list_aws_daily_service_cost WHERE service=$service);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
 
    SELECT 
    datetime(substr(period_start, 1, 19)) as "period start",
    datetime(substr(period_end, 1, 19)) AS "period end",
    service,
    region,
    amortized_cost_amount AS "amortized cost amount", 
    usage_quantity_amount AS "usage quantity amount"
    FROM list_aws_daily_service_cost WHERE service=$service AND ($tab = ''daily_cost'' OR $tab IS NULL) ORDER BY period_start DESC;
     SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&service='' || replace($service, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&service='' || replace($service, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''daily_cost'';;

-- AWS monthly service cost list    
SET total_rows = (SELECT COUNT(*) FROM list_aws_monthly_service_cost WHERE service=$service);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
 
    SELECT 
    datetime(substr(period_start, 1, 19)) as "period start",
    datetime(substr(period_end, 1, 19)) AS "period end",
    service,
    region,
    amortized_cost_amount AS "amortized cost amount", 
    usage_quantity_amount AS "usage quantity amount"
    FROM list_aws_monthly_service_cost WHERE service=$service AND $tab = ''monthly_coste'' ORDER BY period_start DESC;
     SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&tab='' || replace($tab, '' '', ''%20'') ||
''&service='' || replace($service, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&tab='' || replace($tab, '' '', ''%20'') ||
''&service='' || replace($service, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
 WHERE $tab=''monthly_coste'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'fleetfolio/aws_monthely_cost_detail_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''fleetfolio/aws_monthely_cost_detail_list.sql/index.sql'') as contents;
    ;
   --- Display breadcrumb
SELECT
   ''breadcrumb'' AS component;
 SELECT
   ''Home'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''    AS link;
 SELECT
   ''Fleetfolio'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/index.sql'' AS link;  
 SELECT
   ''Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/boundary.sql'' AS link; 

 SELECT
   ''AWS Trust Boundary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_trust_boundary_list.sql'' AS link; 

 SELECT
   ''AWS Monthely Cost Summary'' AS title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/fleetfolio/aws_monthely_cost_detail_list.sql'' AS link; 


 --- Dsply Page Title
 SELECT
     ''title''   as component,
     "AWS Monthely Cost Summary" contents;

    select
     ''text''              as component,
     ''View a consolidated summary of your AWS spending, broken down by account and month. Monitor trends, compare costs, and gain insights to optimize your cloud expenses.'' as contents;


 SET total_rows = (SELECT COUNT(*) FROM list_aws_monthely_cost_detail );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1; 
SELECT ''table'' AS component,
       TRUE as sort,
       TRUE as search;
   SELECT 
   account,
   amortized_cost_amount AS "Amortized Cost",
   blended_cost_amount AS "Blended Cost",
   net_amortized_cost_amount AS "Net Amortized AWS Cost",
   net_unblended_cost_amount AS "Net Unblended AWS Cost", 
   unblended_cost_amount AS "Unblended AWS Cost",
   datetime(substr(period_start, 1, 19)) as "Period Start"
   FROM list_aws_monthely_cost_detail;
    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'sqlpage/templates/shell-custom.handlebars',
      '        
        
        
        

        <!DOCTYPE html>
<html lang="{{language}}" style="font-size: {{default font_size 18}}px" {{#if class}}class="{{class}}" {{/if}}>
<head>
    <meta charset="utf-8" />

    <!-- Base CSS -->
    <link rel="stylesheet" href="{{static_path ''sqlpage.css''}}">

    <style>
    .py-4 {
          padding-top: 1rem !important;
          padding-bottom: 1rem !important;
    }
    header .py-4 {
        padding-top: 1rem !important;
        padding-bottom: 1rem !important;
    }
    header .w-6 {
        height: 1.5rem !important;
    }
    header .h-6 {
        height: 1.5rem !important;
    }
    header .space-x-8 {
        display: flex;
        gap: 0rem !important;
    }
    footer .pt-6 {
        padding-top: 1.5rem !important;
    }
    footer .pt-8 {
        padding-top: 2rem !important;
    }
    footer .px-4 {
        padding-left: 1rem !important;
        padding-right: 1rem !important;
    }
    footer .mt-4 {
        padding-top: 1rem !important;
    }
    </style>
    
    {{#each (to_array css)}}
        {{#if this}}
            <link rel="stylesheet" href="{{this}}">
        {{/if}}
    {{/each}}

    <!-- Font Setup -->
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

    <!-- JavaScript -->
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

<body class="layout-{{#if sidebar}}fluid{{else}}{{default layout ''boxed''}}{{/if}}" {{#if theme}}data-bs-theme="{{theme}}" {{/if}}>
    <div class="page">
        <!-- Header -->
        <!-- Page Wrapper -->
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
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
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
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&folder_id='' || replace($folder_id, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&folder_id='' || replace($folder_id, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
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
  "title": "fleetfolio",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/fleetfolio.ico",
  "image": "https://www.surveilr.com/assets/brand/fleetfolio.png",
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
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT case when sqlpage.environment_variable(''EOH_INSTANCE'')=1 then ''shell-custom'' else ''shell'' END AS component,
       ''fleetfolio'' AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/fleetfolio.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/fleetfolio.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
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
       ''Surveilr ''|| (SELECT json_extract(session_agent, ''$.version'') AS version FROM ur_ingest_session LIMIT 1) || '' Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), LENGTH(sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'')) + 2 ) || '')'' as footer;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
