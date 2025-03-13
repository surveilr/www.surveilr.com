DROP VIEW IF EXISTS all_boundary;
CREATE VIEW all_boundary AS
SELECT 
    boundary_id,
    parent_boundary_id,
    name 
FROM boundary;

DROP VIEW IF EXISTS parent_boundary;
CREATE VIEW parent_boundary AS
SELECT 
    boundary_id,
    name 
FROM boundary WHERE parent_boundary_id IS NULL;

DROP VIEW IF EXISTS boundary_list;
CREATE VIEW boundary_list AS
SELECT 
    boundary_id,
    parent_boundary_id,
    name 
FROM boundary WHERE parent_boundary_id IS NOT NULL;

DROP VIEW IF EXISTS active_asset_list;
CREATE VIEW active_asset_list AS
SELECT 
    asset_id,
    boundary_id,
    name 
FROM asset WHERE asset_tag = 'ACTIVE';

DROP VIEW IF EXISTS boundary_asset_list;
CREATE VIEW boundary_asset_list AS
SELECT 
   asset.asset_id,asset.boundary_id,boundary.name as boundary,asset.name as asset
FROM asset INNER JOIN boundary ON boundary.boundary_id=asset.boundary_id;

DROP VIEW IF EXISTS expected_asset_list;
CREATE VIEW expected_asset_list AS
SELECT 
    asset_id,
    boundary_id,
    name,
    asset_retired_date,
    assetSt.value as asset_status,
    asset_tag,
    description,
    assetType.value as asset_type,
    assignment.value as assignment,
    installed_date,
    planned_retirement_date,
    purchase_delivery_date,
    purchase_order_date,
    criticality
FROM asset 
LEFT JOIN asset_status assetSt ON assetSt.asset_status_id = asset.asset_status_id
LEFT JOIN asset_type assetType ON assetType.asset_type_id=asset.asset_type_id
LEFT JOIN assignment ON assignment.assignment_id = asset.assignment_id;

DROP VIEW IF EXISTS system_detail_group;
CREATE VIEW system_detail_group AS
SELECT 
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,  
    COUNT(*) AS count 
FROM uniform_resource 
GROUP BY name, hostIdentifier;

DROP VIEW IF EXISTS system_detail_all_processes;
CREATE VIEW system_detail_all_processes AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier,
    json_extract(u.content, '$.columns.cgroup_path') AS cgroup_path,
    json_extract(u.content, '$.columns.cmdline') AS cmdline,
    json_extract(u.content, '$.columns.cwd') AS cwd,
    json_extract(u.content, '$.columns.disk_bytes_read') AS disk_bytes_read,
    json_extract(u.content, '$.columns.disk_bytes_written') AS disk_bytes_written,
    json_extract(u.content, '$.columns.egid') AS egid,
    json_extract(u.content, '$.columns.euid') AS euid,
    json_extract(u.content, '$.columns.gid') AS gid,
    json_extract(u.content, '$.columns.name') AS system_name,
    json_extract(u.content, '$.columns.nice') AS nice,
    json_extract(u.content, '$.columns.on_disk') AS on_disk,
    json_extract(u.content, '$.columns.parent') AS parent,
    json_extract(u.content, '$.columns.path') AS path,
    json_extract(u.content, '$.columns.pgroup') AS pgroup,
    json_extract(u.content, '$.columns.pid') AS pid,
    json_extract(u.content, '$.columns.resident_size') AS resident_size,
    json_extract(u.content, '$.columns.root') AS root,
    json_extract(u.content, '$.columns.sgid') AS sgid,
    json_extract(u.content, '$.columns.start_time') AS start_time,
    json_extract(u.content, '$.columns.state') AS state,
    json_extract(u.content, '$.columns.suid') AS suid,
    json_extract(u.content, '$.columns.system_time') AS system_time,
    json_extract(u.content, '$.columns.threads') AS threads,
    json_extract(u.content, '$.columns.total_size') AS total_size,
    json_extract(u.content, '$.columns.uid') AS uid,
    json_extract(u.content, '$.columns.user_time') AS user_time,
    json_extract(u.content, '$.columns.wired_size') AS wired_size,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'All Processes' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_available_disk;
CREATE VIEW system_available_disk AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier,
    json_extract(u.content, '$.columns.gigs_disk_space_available') AS gigs_disk_space_available,
    json_extract(u.content, '$.columns.gigs_total_disk_space') AS gigs_total_disk_space,
    json_extract(u.content, '$.columns.percent_disk_space_available') AS percent_disk_space_available,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'Available Disk Space (Linux and Macos)' AND ue.graph_name='osquery-ms'; 

DROP VIEW IF EXISTS system_full_disk_encryption_linux;
CREATE VIEW system_full_disk_encryption_linux AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.policy_result') AS policy_result,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'Full disk encryption enabled (Linux)' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_installed_software_linux;
CREATE VIEW system_installed_software_linux AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.name') AS software_name,
    json_extract(u.content, '$.columns.source') AS software_source,
    json_extract(u.content, '$.columns.type') AS software_type,
    json_extract(u.content, '$.columns.version') AS software_version,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'Installed Linux software' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_listening_ports;
CREATE VIEW system_listening_ports AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.address') AS address,
    json_extract(u.content, '$.columns.family') AS family,
    json_extract(u.content, '$.columns.fd') AS fd,
    json_extract(u.content, '$.columns.net_namespace') AS net_namespace,
    json_extract(u.content, '$.columns.path') AS path,
    json_extract(u.content, '$.columns.pid') AS pid,
    json_extract(u.content, '$.columns.port') AS port,
    json_extract(u.content, '$.columns.protocol') AS protocol,
    json_extract(u.content, '$.columns.socket') AS socket,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'Listening Ports' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_linux_macos_network_interface;
CREATE VIEW system_linux_macos_network_interface AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.address') AS ip_address,
    json_extract(u.content, '$.columns.mac') AS mac,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'Network Interfaces (Linux and Macos)' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_os_version;
CREATE VIEW system_os_version AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.arch') AS arch,
    json_extract(u.content, '$.columns.build') AS build,
    json_extract(u.content, '$.columns.extra') AS extra,
    json_extract(u.content, '$.columns.kernel_version') AS kernel_version,
    json_extract(u.content, '$.columns.major') AS major,
    json_extract(u.content, '$.columns.minor') AS minor,
    json_extract(u.content, '$.columns.name') AS os_name,
    json_extract(u.content, '$.columns.patch') AS patch,
    json_extract(u.content, '$.columns.platform') AS platform,
    json_extract(u.content, '$.columns.version') AS os_version,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'OS Version (Linux and Macos)' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_ssh_keys_encrypted;
CREATE VIEW system_ssh_keys_encrypted AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.policy_result') AS policy_result,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'SSH keys encrypted' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_server_uptime;
CREATE VIEW system_server_uptime AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.days') AS days,
    json_extract(u.content, '$.columns.hours') AS hours,
    json_extract(u.content, '$.columns.minutes') AS minutes,
    json_extract(u.content, '$.columns.seconds') AS seconds,
    json_extract(u.content, '$.columns.total_seconds') AS total_seconds,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'Server Uptime' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_information;
CREATE VIEW system_information AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.board_model') AS board_model,
    json_extract(u.content, '$.columns.board_serial') AS board_serial,
    json_extract(u.content, '$.columns.board_vendor') AS board_vendor,
    json_extract(u.content, '$.columns.board_version') AS board_version,
    json_extract(u.content, '$.columns.computer_name') AS computer_name,
    json_extract(u.content, '$.columns.cpu_brand') AS cpu_brand,
    json_extract(u.content, '$.columns.cpu_logical_cores') AS cpu_logical_cores,
    json_extract(u.content, '$.columns.cpu_microcode') AS cpu_microcode,
    json_extract(u.content, '$.columns.cpu_physical_cores') AS cpu_physical_cores,
    json_extract(u.content, '$.columns.cpu_sockets') AS cpu_sockets,
    json_extract(u.content, '$.columns.cpu_subtype') AS cpu_subtype,
    json_extract(u.content, '$.columns.cpu_type') AS cpu_type,
    json_extract(u.content, '$.columns.hardware_model') AS hardware_model,
    json_extract(u.content, '$.columns.hardware_serial') AS hardware_serial,
    json_extract(u.content, '$.columns.hardware_vendor') AS hardware_vendor,
    json_extract(u.content, '$.columns.hardware_version') AS hardware_version,
    json_extract(u.content, '$.columns.hostname') AS hostname,
    json_extract(u.content, '$.columns.local_hostname') AS local_hostname,
    json_extract(u.content, '$.columns.physical_memory') AS physical_memory,
    json_extract(u.content, '$.columns.uuid') AS uuid,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'System Information' AND ue.graph_name='osquery-ms';

DROP VIEW IF EXISTS system_user;
CREATE VIEW system_user AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.numerics') AS numerics,
    json_extract(u.content, '$.columns.username') AS user_name,
    json_extract(u.content, '$.columns.directory') AS directory,
    json_extract(u.content, '$.columns.description') AS description,
    json_extract(u.content, '$.columns.gid') AS gid,
    json_extract(u.content, '$.columns.gid_signed') AS gid_signed,
    json_extract(u.content, '$.columns.shell') AS shell,
    json_extract(u.content, '$.columns.uid') AS uid,
    json_extract(u.content, '$.columns.uid_signed') AS uid_signed,
    json_extract(u.content, '$.columns.uuid') AS uuid,
    u.updated_at
FROM uniform_resource u
INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
WHERE name = 'Users' AND ue.graph_name='osquery-ms';