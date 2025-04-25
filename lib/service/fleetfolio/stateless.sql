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

DROP VIEW IF EXISTS boundary_list;
CREATE VIEW boundary_list AS
SELECT 
    boundary as boundary_key,
    boundary 
FROM surveilr_osquery_ms_node_boundary GROUP BY boundary;

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
FROM surveilr_osquery_ms_node_boundary boundary
LEFT JOIN surveilr_osquery_ms_node_detail nodeDet ON nodeDet.host_identifier=boundary.host_identifier
LEFT JOIN surveilr_osquery_ms_node_system_info sysinfo ON sysinfo.host_identifier=boundary.host_identifier;

-- policy list of host 
DROP VIEW IF EXISTS asset_policy_list;
CREATE VIEW asset_policy_list AS
SELECT 
    host.host_identifier,
    host.host_identifier as host,
    pol.host_identifier,
    pol.policy_name,
    pol.policy_result,
    pol.resolution
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
INNER JOIN ur_transform_aws_account_info account ON vpc.account_id = account.account_id;

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