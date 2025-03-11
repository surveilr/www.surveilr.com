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

DROP VIEW IF EXISTS system_available_disk;
CREATE VIEW system_available_disk AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.gigs_disk_space_available') AS gigs_disk_space_available,
    json_extract(content, '$.columns.gigs_total_disk_space') AS gigs_total_disk_space,
    json_extract(content, '$.columns.percent_disk_space_available') AS percent_disk_space_available,
    updated_at
FROM uniform_resource 
WHERE name = 'Available Disk Space (Linux and Macos)';