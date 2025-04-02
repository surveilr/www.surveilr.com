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

DROP VIEW IF EXISTS asset_active_list;
CREATE VIEW asset_active_list AS
SELECT 
    bnd.boundary_id,
    bnd.parent_boundary_id,
    parent.name as parent_boundary,
    ast.asset_id,
    bnd.name as boundry,
    ast.name as host,
    ast.description,
    nodeDet.surveilr_osquery_ms_node_id,
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
    nodeDet. issues,
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
    sysinfo.uuid
FROM asset ast
INNER JOIN boundary bnd ON bnd.boundary_id = ast.boundary_id
INNER JOIN boundary parent ON parent.boundary_id = bnd.parent_boundary_id
LEFT JOIN surveilr_osquery_ms_node_detail nodeDet ON nodeDet.host_identifier=ast.name
LEFT JOIN surveilr_osquery_ms_node_system_info sysinfo ON sysinfo.host_identifier=ast.name
WHERE ast.asset_tag="ACTIVE" AND ast.asset_retired_date IS NULL;

-- policy list of host 
DROP VIEW IF EXISTS asset_policy_list;
CREATE VIEW asset_policy_list AS
SELECT 
    ast.asset_id,
    ast.name as host,
    pol.host_identifier,
    pol.policy_name,
    pol.policy_result,
    pol.resolution
FROM asset ast
INNER JOIN surveilr_osquery_ms_node_executed_policy pol ON pol.host_identifier=ast.name;

-- Installed software of host 
DROP VIEW IF EXISTS asset_software_list;
CREATE VIEW asset_software_list AS
SELECT 
    ast.asset_id,
    ast.name as host,
    sw.host_identifier,
    sw.name,
    sw.source,
    sw.type,
    sw.version,
    sw.platform
FROM asset ast
INNER JOIN surveilr_osquery_ms_node_installed_software sw ON sw.host_identifier=ast.name;

-- DROP VIEW IF EXISTS system_user;
-- CREATE VIEW system_user AS
-- SELECT 
--     u.uniform_resource_id,
--     json_extract(u.content, '$.name') AS name,
--     json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
--     json_extract(u.content, '$.numerics') AS numerics,
--     json_extract(u.content, '$.columns.username') AS user_name,
--     json_extract(u.content, '$.columns.directory') AS directory,
--     json_extract(u.content, '$.columns.description') AS description,
--     json_extract(u.content, '$.columns.gid') AS gid,
--     json_extract(u.content, '$.columns.gid_signed') AS gid_signed,
--     json_extract(u.content, '$.columns.shell') AS shell,
--     json_extract(u.content, '$.columns.uid') AS uid,
--     json_extract(u.content, '$.columns.uid_signed') AS uid_signed,
--     json_extract(u.content, '$.columns.uuid') AS uuid,
--     u.updated_at
-- FROM uniform_resource u
-- INNER JOIN uniform_resource_edge ue ON ue.uniform_resource_id=u.uniform_resource_id
-- WHERE name = 'Users' AND ue.graph_name='osquery-ms';

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
WHERE name = 'Users';

-- User list of host 
DROP VIEW IF EXISTS asset_user_list;
CREATE VIEW asset_user_list AS
SELECT 
    ast.asset_id,
    ast.name as host,
    ss.host_identifier,
    ss.user_name,
    ss.directory
FROM asset ast
INNER JOIN system_user ss ON ss.host_identifier=ast.name;

-- Container views
DROP VIEW IF EXISTS list_container;
CREATE VIEW list_container AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.name') as container_name,
    json_extract(content, '$.columns.image') as image, 
    json_extract(content, '$.columns.status') as status
FROM uniform_resource WHERE name="list Containers" AND uri="osquery-ms:query-result";

DROP VIEW IF EXISTS list_container_image;
CREATE VIEW list_container_image AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as image_id, 
    json_extract(content, '$.columns.size_bytes') as size_bytes,
    json_extract(content, '$.columns.tags') as tags
FROM uniform_resource WHERE name="list Container Images" AND uri="osquery-ms:query-result";

DROP VIEW IF EXISTS list_container_image;
CREATE VIEW list_container_image AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.size_bytes') as size_bytes,
    json_extract(content, '$.columns.tags') as tags
FROM uniform_resource WHERE name="list Container Images" AND uri="osquery-ms:query-result";

DROP VIEW IF EXISTS list_network_information;
CREATE VIEW list_network_information AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.ip_address') as ip_address
FROM uniform_resource WHERE name="container Network Information" AND uri="osquery-ms:query-result";

DROP VIEW IF EXISTS list_network_volume;
CREATE VIEW list_network_volume AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.mount_point') as mount_point, 
    json_extract(content, '$.columns.name') as volume_name
FROM uniform_resource WHERE name="list Container Volumes" AND uri="osquery-ms:query-result";

DROP VIEW IF EXISTS list_docker_container;
CREATE VIEW list_docker_container AS
SELECT 
asset.asset_id,
c.container_name,
c.image,
c.status,
ni.ip_address
FROM list_container AS c
INNER JOIN list_network_information AS ni ON ni.id=c.id AND ni.hostIdentifier=c.hostIdentifier
INNER JOIN asset_active_list AS asset ON asset.host=c.hostIdentifier;