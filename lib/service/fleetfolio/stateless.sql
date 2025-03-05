DROP VIEW IF EXISTS boundary_list;
CREATE VIEW boundary_list AS
SELECT 
    boundary_id,
    name 
FROM boundary;

DROP VIEW IF EXISTS active_asset_list;
CREATE VIEW active_asset_list AS
SELECT 
    asset_id,
    boundary_id,
    name 
FROM asset WHERE asset_tag = 'ACTIVE';

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
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.cgroup_path') AS cgroup_path,
    json_extract(content, '$.columns.cmdline') AS cmdline,
    json_extract(content, '$.columns.cwd') AS cwd,
    json_extract(content, '$.columns.disk_bytes_read') AS disk_bytes_read,
    json_extract(content, '$.columns.disk_bytes_written') AS disk_bytes_written,
    json_extract(content, '$.columns.egid') AS egid,
    json_extract(content, '$.columns.euid') AS euid,
    json_extract(content, '$.columns.gid') AS gid,
    json_extract(content, '$.columns.name') AS system_name,
    json_extract(content, '$.columns.nice') AS nice,
    json_extract(content, '$.columns.on_disk') AS on_disk,
    json_extract(content, '$.columns.parent') AS parent,
    json_extract(content, '$.columns.path') AS path,
    json_extract(content, '$.columns.pgroup') AS pgroup,
    json_extract(content, '$.columns.pid') AS pid,
    json_extract(content, '$.columns.resident_size') AS resident_size,
    json_extract(content, '$.columns.root') AS root,
    json_extract(content, '$.columns.sgid') AS sgid,
    json_extract(content, '$.columns.start_time') AS start_time,
    json_extract(content, '$.columns.state') AS state,
    json_extract(content, '$.columns.suid') AS suid,
    json_extract(content, '$.columns.system_time') AS system_time,
    json_extract(content, '$.columns.threads') AS threads,
    json_extract(content, '$.columns.total_size') AS total_size,
    json_extract(content, '$.columns.uid') AS uid,
    json_extract(content, '$.columns.user_time') AS user_time,
    json_extract(content, '$.columns.wired_size') AS wired_size,
    updated_at
FROM uniform_resource 
WHERE name = 'All Processes';