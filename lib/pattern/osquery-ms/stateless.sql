-- --------------------------------------------------------------------------------
-- Script to prepare convenience views to access uniform_resource.content column
-- as osqueryms content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------

DROP VIEW IF EXISTS surveilr_osquery_ms_node_system_info;
CREATE VIEW surveilr_osquery_ms_node_system_info AS
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

DROP VIEW IF EXISTS surveilr_osquery_ms_node_os_version;
CREATE VIEW surveilr_osquery_ms_node_os_version AS
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


DROP VIEW IF EXISTS surveilr_osquery_ms_node_interface_address;
CREATE VIEW surveilr_osquery_ms_node_interface_address AS
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


DROP VIEW IF EXISTS surveilr_osquery_ms_node_uptime;
CREATE VIEW surveilr_osquery_ms_node_uptime AS
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


DROP VIEW IF EXISTS surveilr_osquery_ms_node_available_space;
CREATE VIEW surveilr_osquery_ms_node_available_space AS
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


DROP VIEW IF EXISTS surveilr_osquery_ms_node_boundary;
CREATE VIEW surveilr_osquery_ms_node_boundary AS
SELECT
    json_extract(l.content, '$.surveilrOsQueryMsNodeKey') AS node_key,
    l.updated_at,
    json_extract(l.content, '$.hostIdentifier') AS host_identifier,
    json_extract(l.content, '$.columns.value') AS boundary
FROM uniform_resource AS l
WHERE l.uri = 'osquery-ms:query-result'
    AND (
        json_extract(l.content, '$.name') = 'osquery-ms Boundary (Linux and Macos)' OR
        json_extract(l.content, '$.name') = 'osquery-ms Boundary (Windows)'
    );

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


DROP VIEW IF EXISTS surveilr_osquery_ms_node_installed_software;
CREATE VIEW surveilr_osquery_ms_node_installed_software AS
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


DROP VIEW IF EXISTS surveilr_osquery_ms_node_executed_policy;
CREATE VIEW surveilr_osquery_ms_node_executed_policy AS
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