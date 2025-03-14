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

-- server up time os query for all host 
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