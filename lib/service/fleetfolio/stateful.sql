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

DROP TABLE IF EXISTS ur_transform_list_user;
CREATE TABLE ur_transform_list_user AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.columns.username') AS user_name,
    json_extract(u.content, '$.columns.directory') AS directory,
    json_extract(u.content, '$.columns.uid') AS uid
FROM uniform_resource u
WHERE name = 'Users';


-- Container TABLE
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
    json_extract(content, '$.columns.created') as created
FROM uniform_resource WHERE name="List Containers" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_image;
CREATE TABLE ur_transform_list_container_image AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as image_id, 
    json_extract(content, '$.columns.size_bytes') as size_bytes,
    json_extract(content, '$.columns.tags') as tags
FROM uniform_resource WHERE name="List Container Images" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_information;
CREATE TABLE ur_transform_list_network_information AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.ip_address') as ip_address
FROM uniform_resource WHERE name="Container Network Information" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_volume;
CREATE TABLE ur_transform_list_network_volume AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.mount_point') as mount_point, 
    json_extract(content, '$.columns.name') as volume_name
FROM uniform_resource WHERE name="list Container Volumes" AND uri="osquery-ms:query-result";

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
    json_extract(content, '$.columns.type') as type
FROM uniform_resource WHERE name="Docker Container Ports" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_process;
CREATE TABLE ur_transform_list_container_process AS
SELECT 
    asset.asset_id,
    json_extract(ur.content, '$.name') AS name,
    json_extract(ur.content, '$.hostIdentifier') AS host,
    json_extract(ur.content, '$.columns.name') as process_name,
    json_extract(ur.content, '$.columns.pid') as pid,
    json_extract(ur.content, '$.columns.uid') as uid
FROM uniform_resource as ur
INNER JOIN asset_active_list AS asset ON asset.host=host_identifier
WHERE name="Osquery All Container Processes" AND uri="osquery-ms:query-result" GROUP BY  
    json_extract(ur.content, '$.columns.pid'),
    json_extract(ur.content, '$.columns.uid');


-- All Process
DROP TABLE IF EXISTS ur_transform_list_all_process;
CREATE TABLE ur_transform_list_all_process AS
SELECT 
    asset.asset_id,
    json_extract(ur.content, '$.name') AS name,
    json_extract(ur.content, '$.hostIdentifier') AS host,
    json_extract(ur.content, '$.columns.name') as process_name
FROM uniform_resource as ur
INNER JOIN asset_active_list AS asset ON asset.host=host_identifier
WHERE name="Osquery All Processes" AND uri="osquery-ms:query-result";



---------------------AWS Tables-----------------------
DROP TABLE IF EXISTS ur_transform_ec2_instance;
CREATE TABLE ur_transform_ec2_instance AS
SELECT 
  json_extract(instance.value, '$.instance_id') AS instance_id,
  json_extract(instance.value, '$.account_id') AS account_id,
  json_extract(instance.value, '$.title') AS title,
  json_extract(instance.value, '$.architecture') AS architecture,
  json_extract(instance.value, '$.platform_details') AS platform_details,
  json_extract(instance.value, '$.root_device_name') AS root_device_name,
  json_extract(instance.value, '$.instance_state') AS state,
  json_extract(instance.value, '$.instance_type') AS instance_type,
  json_extract(instance.value, '$.cpu_options_core_count') AS cpu_options_core_count, 
  json_extract(instance.value, '$.az') AS az,
  json_extract(instance.value, '$.launch_time') AS launch_time,
  
  json_extract(ni.value, '$.NetworkInterfaceId') AS network_interface_id,
  json_extract(ni.value, '$.PrivateIpAddress') AS private_ip_address,
  json_extract(ni.value, '$.Association.PublicIp') AS public_ip_address,
  json_extract(ni.value, '$.SubnetId') AS subnet_id,
  json_extract(ni.value, '$.VpcId') AS vpc_id,
  json_extract(ni.value, '$.MacAddress') AS mac_address,
  json_extract(ni.value, '$.Status') AS status
FROM uniform_resource,
     json_each(content) AS instance,
     json_each(json_extract(instance.value, '$.network_interfaces')) AS ni
WHERE uri = 'steampipeawsEC2Instances';

DROP TABLE IF EXISTS ur_transform_vpc;
CREATE TABLE ur_transform_vpc AS
SELECT 
  json_extract(value, '$.owner_id') AS owner_id,
  json_extract(value, '$.state') AS state,
  json_extract(value, '$.title') AS title,
  json_extract(value, '$.vpc_id') AS vpc_id
FROM uniform_resource,
     json_each(content)
WHERE uri = 'steampipeawsVPC';

DROP TABLE IF EXISTS ur_transform_aws_buckets;
CREATE TABLE ur_transform_aws_buckets AS
SELECT 
  json_extract(value, '$.name') AS name,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.creation_date') AS creation_date
FROM uniform_resource,
     json_each(content)
WHERE uri = 'steampipeListAllAwsBuckets';