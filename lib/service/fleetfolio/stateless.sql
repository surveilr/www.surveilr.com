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

DROP VIEW IF EXISTS expected_asset_list;
CREATE VIEW expected_asset_list AS
SELECT 
    ast.asset_id,
    ast.name AS host,
    ast.description,
    ast.asset_tag,
    astyp.value AS asset_type,
    assignment.value AS assignment,
    GROUP_CONCAT(bnd.name, ', ') AS boundaries,
    GROUP_CONCAT(parent.name, ', ') AS parent_boundaries
FROM asset ast
INNER JOIN asset_boundary ab ON ab.asset_id = ast.asset_id
INNER JOIN boundary bnd ON bnd.boundary_id = ab.boundary_id
LEFT JOIN boundary parent ON parent.boundary_id = bnd.parent_boundary_id
INNER JOIN asset_type astyp ON astyp.asset_type_id = ast.asset_type_id
INNER JOIN assignment ON assignment.assignment_id = ast.assignment_id
WHERE ast.asset_tag = "ACTIVE"
GROUP BY ast.asset_id;

DROP VIEW IF EXISTS boundary_list;
CREATE VIEW boundary_list AS
SELECT 
    boundary as boundary_key,
    boundary 
FROM surveilr_osquery_ms_node_boundary GROUP BY boundary;

DROP VIEW IF EXISTS expected_asset_service_list;
CREATE VIEW expected_asset_service_list AS
SELECT
  asser.name,
  ast.name AS server,
  ast.name AS host_identifier,
  ast.organization_id,
  astyp.value AS asset_type,
  astyp.asset_service_type_id,
  GROUP_CONCAT(bnt.name, ', ') AS boundary,
  asser.description,
  asser.port,
  asser.experimental_version,
  asser.production_version,
  asser.latest_vendor_version,
  asser.resource_utilization,
  asser.log_file,
  asser.url,
  asser.vendor_link,
  asser.installation_date,
  asser.criticality,
  o.name AS owner,
  sta.value AS tag,
  ast.criticality AS asset_criticality,
  ast.asymmetric_keys_encryption_enabled AS asymmetric_keys,
  ast.cryptographic_key_encryption_enabled AS cryptographic_key,
  ast.symmetric_keys_encryption_enabled AS symmetric_keys
FROM asset_service asser
INNER JOIN asset_service_type astyp ON astyp.asset_service_type_id = asser.asset_service_type_id
INNER JOIN asset ast ON ast.asset_id = asser.asset_id
INNER JOIN organization o ON o.organization_id = ast.organization_id
INNER JOIN asset_status sta ON sta.asset_status_id = ast.asset_status_id
INNER JOIN asset_boundary ab ON ab.asset_id = ast.asset_id
INNER JOIN boundary bnt ON bnt.boundary_id = ab.boundary_id
GROUP BY asser.asset_service_id;

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
    nodeDet.issues,
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
    sysinfo.uuid,
    boundary.query_uri,
    eal.boundaries as logical_boundary
FROM surveilr_osquery_ms_node_boundary boundary
LEFT JOIN surveilr_osquery_ms_node_detail nodeDet ON nodeDet.host_identifier=boundary.host_identifier
LEFT JOIN surveilr_osquery_ms_node_system_info sysinfo ON sysinfo.host_identifier=boundary.host_identifier
LEFT JOIN expected_asset_list eal ON nodeDet.host_identifier= eal.host;

DROP VIEW IF EXISTS boundary_asset_count_list;
CREATE VIEW boundary_asset_count_list AS
SELECT 
    boundary.boundary AS boundary_name,
    COUNT(DISTINCT boundary.host_identifier) AS host_count
FROM surveilr_osquery_ms_node_boundary boundary
LEFT JOIN surveilr_osquery_ms_node_detail nodeDet 
    ON nodeDet.host_identifier = boundary.host_identifier
GROUP BY boundary.boundary
ORDER BY host_count DESC;

DROP VIEW IF EXISTS logical_boundary_asset_count_list;
CREATE VIEW logical_boundary_asset_count_list AS
SELECT 
    bnt.name AS boundary_name,
    COUNT(ast_bnt.asset_id) AS host_count
FROM boundary bnt 
INNER JOIN asset_boundary ast_bnt ON ast_bnt.boundary_id = bnt.boundary_id
INNER JOIN asset ON asset.asset_id = ast_bnt.asset_id
INNER JOIN surveilr_osquery_ms_node_detail node ON node.host_identifier=asset.name
WHERE bnt.parent_boundary_id IS NOT NULL
GROUP BY bnt.name
ORDER BY host_count DESC;;

-- policy list of host 
DROP VIEW IF EXISTS asset_policy_list;
CREATE VIEW asset_policy_list AS
SELECT 
    host.host_identifier,
    host.host_identifier as host,
    pol.host_identifier,
    pol.policy_name,
    pol.policy_result,
    pol.resolution,
    host.query_uri
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
    ss.uid,
    ss.query_uri
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
datetime(created, 'unixepoch', 'localtime') AS created_date,
c.query_uri
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
datetime(created, 'unixepoch', 'localtime') AS created_date,
c.query_uri
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
LEFT JOIN ur_transform_aws_account_info account ON vpc.account_id = account.account_id;

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

DROP VIEW IF EXISTS list_aws_cost_detail;
CREATE VIEW list_aws_cost_detail AS
SELECT 
account_id,
amortized_cost_amount,
amortized_cost_unit,
blended_cost_amount,
estimated,
unblended_cost_unit,
net_unblended_cost_unit,
linked_account_id,
canonical_hosted_zone_id,
net_amortized_cost_amount,
net_unblended_cost_amount,
period_start,
period_end,
region,
usage_quantity_amount,
usage_quantity_unit,
unblended_cost_amount
FROM ur_transform_list_aws_cost_detail;

DROP VIEW IF EXISTS list_aws_monthely_cost_detail;
CREATE VIEW list_aws_monthely_cost_detail AS
SELECT 
acd.amortized_cost_amount,
acd.blended_cost_amount,
acd.net_amortized_cost_amount,
acd.net_unblended_cost_amount,
acd.period_start,
acd.period_end,
acd.unblended_cost_amount,
acc.title as account
FROM ur_transform_list_aws_monthly_cost_detail AS acd
INNER JOIN ur_transform_aws_account_info AS acc ON acd.linked_account_id = acc.account_id ORDER BY acd.period_start DESC;


DROP VIEW IF EXISTS list_aws_service_from_daily_cost;
CREATE VIEW list_aws_service_from_daily_cost AS
SELECT 
service
FROM ur_transform_list_aws_daily_cost_by_service GROUP BY service;

DROP VIEW IF EXISTS list_aws_daily_service_cost;
CREATE VIEW list_aws_daily_service_cost AS
SELECT 
acd.period_start,
acd.period_end,
acd.service,
acd.region,
acd.amortized_cost_amount,
acd.usage_quantity_amount,
acd.amortized_cost_amount,
acc.title as account
FROM ur_transform_list_aws_daily_cost_by_service AS acd
INNER JOIN ur_transform_aws_account_info AS acc ON acd.account_id = acc.account_id ORDER BY acd.period_start DESC;

DROP VIEW IF EXISTS list_aws_monthly_service_cost;
CREATE VIEW list_aws_monthly_service_cost AS
SELECT 
acd.period_start,
acd.period_end,
acd.service,
acd.region,
acd.amortized_cost_amount,
acd.usage_quantity_amount,
acd.amortized_cost_amount,
acc.title as account
FROM ur_transform_list_aws_monthly_cost_by_service AS acd
INNER JOIN ur_transform_aws_account_info AS acc ON acd.account_id = acc.account_id ORDER BY acd.period_start DESC;

DROP VIEW IF EXISTS list_container_process;
CREATE VIEW list_container_process AS
SELECT 
host_identifier,
name,
host,
process_name,
pid,
uid,
start_time,
state,
CASE state
  WHEN 'R' THEN 'Running'
  WHEN 'S' THEN 'Sleeping'
  WHEN 'D' THEN 'Uninterruptible Sleep'
  WHEN 'Z' THEN 'Zombie'
  WHEN 'T' THEN 'Stopped'
  WHEN 't' THEN 'Tracing Stop'
  WHEN 'X' THEN 'Dead'
  WHEN 'x' THEN 'Dead'
  WHEN 'K' THEN 'Wakekill'
  WHEN 'W' THEN 'Waking'
  WHEN 'P' THEN 'Parked'
  WHEN 'I' THEN 'Idle'
  ELSE 'Unknown'
END AS state_description,
query_uri
FROM ur_transform_list_container_process;

DROP VIEW IF EXISTS list_ports_443;
CREATE VIEW list_ports_443 AS
SELECT 
  host_identifier,
  name,
  address,
  family,
  fd,
  net_namespace,
  path,
  port,
  protocol,
  socket,query_uri
FROM ur_transform_list_ports_443;

DROP VIEW IF EXISTS list_ssl_cert_files;
CREATE VIEW list_ssl_cert_files AS
SELECT 
  lp4.host_identifier,
  lp4.name,
  lp4.block_size,
  lp4.device,
  lp4.directory,
  lp4.filename,
  lp4.gid,
  lp4.hard_links,
  lp4.inode,
  lp4.mode,
  lp4.path,
  lp4.size,
  lp4.type,
  lp4.uid,
  user.user_name,
  lp4.query_uri
FROM ur_transform_list_ssl_cert_files lp4
LEFT JOIN ur_transform_list_user user ON user.uid = lp4.uid;
