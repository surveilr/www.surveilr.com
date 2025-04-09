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

DROP TABLE IF EXISTS list_user;
CREATE TABLE list_user AS
SELECT 
    u.uniform_resource_id,
    json_extract(u.content, '$.name') AS name,
    json_extract(u.content, '$.hostIdentifier') AS host_identifier, 
    json_extract(u.content, '$.columns.username') AS user_name,
    json_extract(u.content, '$.columns.directory') AS directory,
    json_extract(u.content, '$.columns.uid') AS uid
FROM uniform_resource u
WHERE name = 'Users';

-- User list of host 
DROP TABLE IF EXISTS asset_user_list;
CREATE TABLE asset_user_list AS
SELECT 
    ast.asset_id,
    ast.name as host,
    ss.host_identifier,
    ss.user_name,
    ss.directory,
    ss.uid
FROM asset ast
INNER JOIN list_user ss ON ss.host_identifier=ast.name;

-- Container TABLE
DROP TABLE IF EXISTS list_container;
CREATE TABLE list_container AS
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

DROP TABLE IF EXISTS list_container_image;
CREATE TABLE list_container_image AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as image_id, 
    json_extract(content, '$.columns.size_bytes') as size_bytes,
    json_extract(content, '$.columns.tags') as tags
FROM uniform_resource WHERE name="List Container Images" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS list_network_information;
CREATE TABLE list_network_information AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.ip_address') as ip_address
FROM uniform_resource WHERE name="Container Network Information" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS list_network_volume;
CREATE TABLE list_network_volume AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.mount_point') as mount_point, 
    json_extract(content, '$.columns.name') as volume_name
FROM uniform_resource WHERE name="list Container Volumes" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS list_container_ports;
CREATE TABLE list_container_ports AS
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

DROP TABLE IF EXISTS list_container_process;
CREATE TABLE list_container_process AS
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
DROP TABLE IF EXISTS list_all_process;
CREATE TABLE list_all_process AS
SELECT 
    asset.asset_id,
    json_extract(ur.content, '$.name') AS name,
    json_extract(ur.content, '$.hostIdentifier') AS host,
    json_extract(ur.content, '$.columns.name') as process_name
FROM uniform_resource as ur
INNER JOIN asset_active_list AS asset ON asset.host=host_identifier
WHERE name="Osquery All Processes" AND uri="osquery-ms:query-result";