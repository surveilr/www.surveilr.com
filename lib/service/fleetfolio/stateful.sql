-- --------------------------------------------------------------------------------
-- The following tables are created to ensure compatibility between the RSSD and Aggregate Assurance databases.
-- Some client environments may not have the Aggregate Assurance schema pre-defined, so these CREATE TABLE IF NOT EXISTS
-- statements are used to safely initialize the required structures without causing errors.
-- This approach ensures seamless integration and consistent data references across both systems.
-- --------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "boundary" (
    "boundary_id" TEXT PRIMARY KEY NOT NULL,
    "parent_boundary_id" TEXT,
    "graph_id" TEXT NOT NULL,
    "boundary_nature_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("parent_boundary_id") REFERENCES "boundary"("boundary_id"),
    FOREIGN KEY("graph_id") REFERENCES "graph"("graph_id"),
    FOREIGN KEY("boundary_nature_id") REFERENCES "boundary_nature"("boundary_nature_id")
);

CREATE TABLE IF NOT EXISTS "asset" (
    "asset_id" TEXT PRIMARY KEY NOT NULL,
    "organization_id" TEXT NOT NULL,
    "boundary_id" TEXT,
    "asset_retired_date" DATE,
    "asset_status_id" TEXT NOT NULL,
    "asset_tag" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "asset_type_id" TEXT NOT NULL,
    "asset_workload_category" TEXT NOT NULL,
    "assignment_id" TEXT NOT NULL,
    "barcode_or_rfid_tag" TEXT NOT NULL,
    "installed_date" DATE,
    "planned_retirement_date" DATE,
    "purchase_delivery_date" DATE,
    "purchase_order_date" DATE,
    "purchase_request_date" DATE,
    "serial_number" TEXT NOT NULL,
    "tco_amount" TEXT NOT NULL,
    "tco_currency" TEXT NOT NULL,
    "criticality" TEXT,
    "asymmetric_keys_encryption_enabled" TEXT,
    "cryptographic_key_encryption_enabled" TEXT,
    "symmetric_keys_encryption_enabled" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("organization_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("boundary_id") REFERENCES "boundary"("boundary_id"),
    FOREIGN KEY("asset_status_id") REFERENCES "asset_status"("asset_status_id"),
    FOREIGN KEY("asset_type_id") REFERENCES "asset_type"("asset_type_id"),
    FOREIGN KEY("assignment_id") REFERENCES "assignment"("assignment_id")
);

CREATE TABLE IF NOT EXISTS "asset_type" (
    "asset_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);

CREATE TABLE IF NOT EXISTS "assignment" (
    "assignment_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);

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
WHERE u.uri="osquery-ms:query-result" AND name = 'Users';


-- -- Container TABLE
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
FROM uniform_resource WHERE json_valid(content) = 1 AND name="List Containers" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_image;
CREATE TABLE ur_transform_list_container_image AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as image_id, 
    json_extract(content, '$.columns.size_bytes') as size_bytes,
    json_extract(content, '$.columns.tags') as tags
FROM uniform_resource WHERE json_valid(content) = 1 AND name="List Container Images" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_information;
CREATE TABLE ur_transform_list_network_information AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.ip_address') as ip_address
FROM uniform_resource WHERE json_valid(content) = 1 AND name="Container Network Information" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_volume;
CREATE TABLE ur_transform_list_network_volume AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.mount_point') as mount_point, 
    json_extract(content, '$.columns.name') as volume_name
FROM uniform_resource WHERE json_valid(content) = 1 AND name="list Container Volumes" AND uri="osquery-ms:query-result";

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
FROM uniform_resource WHERE json_valid(content) = 1 AND name="Docker Container Ports" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_process;
CREATE TABLE ur_transform_list_container_process AS
SELECT 
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host,
    json_extract(content, '$.columns.name') as process_name,
    json_extract(content, '$.columns.pid') as pid,
    json_extract(content, '$.columns.uid') as uid
FROM uniform_resource 
WHERE json_valid(content) = 1 AND name="Osquery All Container Processes" AND uri="osquery-ms:query-result" GROUP BY  
    json_extract(content, '$.columns.pid'),
    json_extract(content, '$.columns.uid');


-- -- All Process
DROP TABLE IF EXISTS ur_transform_list_all_process;
CREATE TABLE ur_transform_list_all_process AS
SELECT 
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(ur.content, '$.name') AS name,
    json_extract(ur.content, '$.hostIdentifier') AS host,
    json_extract(ur.content, '$.columns.name') as process_name
FROM uniform_resource as ur
WHERE json_valid(content) = 1 AND name="Osquery All Processes" AND uri="osquery-ms:query-result";

-- -- Authentication Data
-- DROP TABLE IF EXISTS ur_transform_carve_data;
-- CREATE TABLE ur_transform_carve_data AS
-- SELECT 
--     ssmn.host_identifier,
--     CAST(ur.content AS TEXT) as carve_data,
--     SUBSTR(
--         ur.uri,
--         INSTR(ur.uri, 'osquery_carve_') + LENGTH('osquery_carve_'),
--         36
--     ) AS carve_uuid
-- FROM uniform_resource as ur
-- INNER JOIN surveilr_osquery_ms_carve ssmc ON carve_uuid=ssmc.carve_guid
-- INNER JOIN surveilr_osquery_ms_node ssmn ON ssmc.node_key=ssmn.node_key
-- WHERE ur.uri LIKE "%/var/log/auth.log%";

-- DROP TABLE IF EXISTS ur_transform_carved_ssh_data;
-- CREATE TABLE ur_transform_carved_ssh_data AS
-- WITH RECURSIVE
-- split_lines(host_identifier, carve_uuid, line, rest) AS (
--   SELECT
--     ssmn.host_identifier,
--     SUBSTR(
--         ur.uri,
--         INSTR(ur.uri, 'osquery_carve_') + LENGTH('osquery_carve_'),
--         36
--     ) AS carve_uuid,
--     -- Extract first line
--     SUBSTR(CAST(ur.content AS TEXT), 1, INSTR(CAST(ur.content AS TEXT) || CHAR(10), CHAR(10)) - 1),
--     -- Extract the rest of the content
--     SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT) || CHAR(10), CHAR(10)) + 1)
--   FROM uniform_resource AS ur
--   INNER JOIN surveilr_osquery_ms_carve ssmc 
--     ON SUBSTR(ur.uri, INSTR(ur.uri, 'osquery_carve_') + LENGTH('osquery_carve_'), 36) = ssmc.carve_guid
--   INNER JOIN surveilr_osquery_ms_node ssmn 
--     ON ssmc.node_key = ssmn.node_key
--   WHERE ur.uri LIKE "%/var/log/auth.log%"

--   UNION ALL

--   SELECT
--     host_identifier,
--     carve_uuid,
--     SUBSTR(rest, 1, INSTR(rest || CHAR(10), CHAR(10)) - 1),
--     SUBSTR(rest, INSTR(rest || CHAR(10), CHAR(10)) + 1)
--   FROM split_lines
--   WHERE LENGTH(rest) > 0
-- )

-- SELECT host_identifier, carve_uuid, line AS sshd_log_line
-- FROM split_lines
-- WHERE line LIKE '%sshd%';



-- -------------------AWS Tables-----------------------

-- steampipeawsEC2Instances
DROP TABLE IF EXISTS ur_transform_ec2_instance;
CREATE TABLE ur_transform_ec2_instance AS
SELECT 
  json_extract(rowsValue.value, '$.instance_id') AS instance_id,
  json_extract(rowsValue.value, '$.account_id') AS account_id,
  json_extract(rowsValue.value, '$.title') AS title,
  json_extract(rowsValue.value, '$.architecture') AS architecture,
  json_extract(rowsValue.value, '$.platform_details') AS platform_details,
  json_extract(rowsValue.value, '$.root_device_name') AS root_device_name,
  json_extract(rowsValue.value, '$.instance_state') AS state,
  json_extract(rowsValue.value, '$.instance_type') AS instance_type,
  json_extract(rowsValue.value, '$.cpu_options_core_count') AS cpu_options_core_count,
  json_extract(rowsValue.value, '$.az') AS az,
  json_extract(rowsValue.value, '$.launch_time') AS launch_time,

  json_extract(ni.value, '$.NetworkInterfaceId') AS network_interface_id,
  json_extract(ni.value, '$.PrivateIpAddress') AS private_ip_address,
  json_extract(ni.value, '$.Association.PublicIp') AS public_ip_address,
  json_extract(ni.value, '$.SubnetId') AS subnet_id,
  json_extract(ni.value, '$.VpcId') AS vpc_id,
  json_extract(ni.value, '$.MacAddress') AS mac_address,
  json_extract(ni.value, '$.Status') AS status
FROM 
  uniform_resource,
  json_each(json_extract(content, '$.rows')) as rowsValue,
  json_each(json_extract(rowsValue.value, '$.network_interfaces')) AS ni
WHERE 
  uri = 'SteampipeawsEC2Instances';

-- steampipeListAllAwsBuckets
DROP TABLE IF EXISTS ur_transform_aws_buckets;
CREATE TABLE ur_transform_aws_buckets AS
SELECT 
  json_extract(value, '$.name') AS name,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.creation_date') AS creation_date
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeListAllawsS3Buckets';

-- steampipeListAllAwsVPCs
DROP TABLE IF EXISTS ur_transform_aws_vpc;
CREATE TABLE ur_transform_aws_vpc AS
SELECT 
  json_extract(value, '$.vpc_id') AS vpc_id,
  json_extract(value, '$.title') AS title,
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.owner_id') AS owner_id,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.state') AS state,
  json_extract(value, '$.cidr_block') AS cidr_block,
  json_extract(value, '$.dhcp_options_id') AS dhcp_options_id,
  json_extract(value, '$.is_default') AS is_default,
  json_extract(value, '$.partition') AS partition
FROM uniform_resource,
     json_each(content ,'$.rows')
WHERE uri = 'SteampipeListAllAwsVPCs';

-- steampipeawsIAMUserInfo
DROP TABLE IF EXISTS ur_transform_aws_user_info;
CREATE TABLE ur_transform_aws_user_info AS
SELECT 
  json_extract(value, '$.user_id') AS user_id,
  json_extract(value, '$.name') AS name,
  json_extract(value, '$.create_date') AS create_date,
  json_extract(value, '$.password_last_used') AS password_last_used,
  json_extract(value, '$.path') AS path
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsIAMUserInfo';

-- SteampipeawsAccountInfo
DROP TABLE IF EXISTS ur_transform_aws_account_info;
CREATE TABLE ur_transform_aws_account_info AS
SELECT 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.title') AS title,
  json_extract(value, '$.alias') AS alias,
  json_extract(value, '$.arn') AS arn,
  json_extract(value, '$.organization_id') AS organization_id,
  json_extract(value, '$.organization_master_account_email') AS organization_master_account_email,
  json_extract(value, '$.organization_master_account_id') AS organization_master_account_id,
  json_extract(value, '$.partition') AS partition,
  json_extract(value, '$.region') AS region
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsAccountInfo';

-- SteampipeawsEC2ApplicationLoadBalancers
DROP TABLE IF EXISTS ur_transform_aws_ec2_application_load_balancer;
CREATE TABLE ur_transform_aws_ec2_application_load_balancer AS
SELECT 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.name') AS name,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.canonical_hosted_zone_id') AS canonical_hosted_zone_id,
  json_extract(value, '$.created_time') AS created_time,
  json_extract(value, '$.dns_name') AS dns_name,
  json_extract(value, '$.ip_address_type') AS ip_address_type,
  json_extract(value, '$.load_balancer_attributes') AS load_balancer_attributes,
  json_extract(value, '$.scheme') AS scheme,
  json_extract(value, '$.security_groups') AS security_groups,
  json_extract(value, '$.type') AS type,
  json_extract(value, '$.vpc_id') AS vpc_id
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsEC2ApplicationLoadBalancers';

-- SteampipeListAwsCostDetails
DROP TABLE IF EXISTS ur_transform_list_aws_cost_detail;
CREATE TABLE ur_transform_list_aws_cost_detail AS
SELECT 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount, 
  json_extract(value, '$.amortized_cost_unit') AS amortized_cost_unit,
  json_extract(value, '$.blended_cost_amount') AS blended_cost_amount, 
  json_extract(value, '$.estimated') AS estimated,
  json_extract(value, '$.unblended_cost_unit') AS unblended_cost_unit, 
  json_extract(value, '$.net_unblended_cost_unit') AS net_unblended_cost_unit,
  json_extract(value, '$.linked_account_id') AS linked_account_id,
  json_extract(value, '$.canonical_hosted_zone_id') AS canonical_hosted_zone_id,
  json_extract(value, '$.net_amortized_cost_amount') AS net_amortized_cost_amount,
  json_extract(value, '$.net_unblended_cost_amount') AS net_unblended_cost_amount,
  json_extract(value, '$.period_start') AS period_start,
  json_extract(value, '$.period_end') AS period_end,
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount,
  json_extract(value, '$.usage_quantity_unit') AS usage_quantity_unit,
  json_extract(value, '$.unblended_cost_amount') AS unblended_cost_amount 
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeListAwsCostDetails';

-- SteampipeawsMonthlyCostByAccount
DROP TABLE IF EXISTS ur_transform_list_aws_monthly_cost_detail;
CREATE TABLE ur_transform_list_aws_monthly_cost_detail AS
SELECT 
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount, 
  json_extract(value, '$.blended_cost_amount') AS blended_cost_amount, 
  json_extract(value, '$.linked_account_id') AS linked_account_id,
  json_extract(value, '$.net_amortized_cost_amount') AS net_amortized_cost_amount, 
  json_extract(value, '$.net_unblended_cost_amount') AS net_unblended_cost_amount,
  json_extract(value, '$.period_start') AS period_start,
  json_extract(value, '$.period_end') AS period_end,
  json_extract(value, '$.unblended_cost_amount') AS unblended_cost_amount
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeawsMonthlyCostByAccount';

-- SteampipeawsDailyCostByService
DROP TABLE IF EXISTS ur_transform_list_aws_daily_cost_by_service;
CREATE TABLE ur_transform_list_aws_daily_cost_by_service AS
SELECT 
  json_extract(value, '$.period_start') AS period_start, 
  json_extract(value, '$.period_end') AS period_end, 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.service') AS service, 
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount,
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeAwsCostByServiceDaily';

-- SteampipeAwsCostByServiceMonthly
DROP TABLE IF EXISTS ur_transform_list_aws_monthly_cost_by_service;
CREATE TABLE ur_transform_list_aws_monthly_cost_by_service AS
SELECT 
  json_extract(value, '$.period_start') AS period_start, 
  json_extract(value, '$.period_end') AS period_end, 
  json_extract(value, '$.account_id') AS account_id,
  json_extract(value, '$.service') AS service, 
  json_extract(value, '$.region') AS region,
  json_extract(value, '$.amortized_cost_amount') AS amortized_cost_amount,
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeAwsCostByServiceMonthly';