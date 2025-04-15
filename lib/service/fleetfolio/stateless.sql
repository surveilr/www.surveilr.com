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

-- User list of host 
DROP VIEW IF EXISTS asset_user_list;
CREATE VIEW asset_user_list AS
SELECT 
    ast.asset_id,
    ast.name as host,
    ss.host_identifier,
    ss.user_name,
    ss.directory,
    ss.uid
FROM asset ast
INNER JOIN ur_transform_list_user ss ON ss.host_identifier=ast.name;


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


DROP VIEW IF EXISTS list_docker_container;
CREATE VIEW list_docker_container AS
SELECT 
asset.asset_id,
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
INNER JOIN asset_active_list AS asset ON asset.host=c.hostIdentifier
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
LEFT JOIN ur_transform_vpc vpc ON ec2.vpc_id=vpc.vpc_id;

DROP VIEW IF EXISTS list_aws_s3_bucket;
CREATE VIEW list_aws_s3_bucket AS
SELECT
name,
region,
creation_date
FROM
  ur_transform_aws_buckets;