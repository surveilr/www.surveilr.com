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

CREATE TABLE IF NOT EXISTS "asset_boundary" (
    "asset_boundary_id" TEXT PRIMARY KEY NOT NULL,
    "asset_id" TEXT NOT NULL,
    "boundary_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("boundary_id") REFERENCES "boundary"("boundary_id")
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

CREATE TABLE IF NOT EXISTS "asset_service" (
    "asset_service_id" TEXT PRIMARY KEY NOT NULL,
    "asset_id" TEXT NOT NULL,
    "asset_service_type_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "asset_service_status_id" TEXT NOT NULL,
    "port" TEXT NOT NULL,
    "experimental_version" TEXT NOT NULL,
    "production_version" TEXT NOT NULL,
    "latest_vendor_version" TEXT NOT NULL,
    "resource_utilization" TEXT NOT NULL,
    "log_file" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "vendor_link" TEXT NOT NULL,
    "installation_date" DATE,
    "criticality" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("asset_service_type_id") REFERENCES "asset_service_type"("asset_service_type_id"),
    FOREIGN KEY("asset_service_status_id") REFERENCES "asset_service_status"("asset_service_status_id")
);

CREATE TABLE IF NOT EXISTS "asset_service_type" (
    "asset_service_type_id" TEXT PRIMARY KEY NOT NULL,
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

CREATE TABLE IF NOT EXISTS "asset_status" (
    "asset_status_id" TEXT PRIMARY KEY NOT NULL,
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
    json_extract(u.content, '$.columns.uid') AS uid,
    uri as query_uri
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
    json_extract(content, '$.columns.created') as created,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="List Containers" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_image;
CREATE TABLE ur_transform_list_container_image AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as image_id, 
    json_extract(content, '$.columns.size_bytes') as size_bytes,
    json_extract(content, '$.columns.tags') as tags,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="List Container Images" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_information;
CREATE TABLE ur_transform_list_network_information AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.ip_address') as ip_address,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="Container Network Information" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_network_volume;
CREATE TABLE ur_transform_list_network_volume AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS hostIdentifier,
    json_extract(content, '$.columns.id') as id, 
    json_extract(content, '$.columns.mount_point') as mount_point, 
    json_extract(content, '$.columns.name') as volume_name,
    uri as query_uri
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
    json_extract(content, '$.columns.type') as type,
    uri as query_uri
FROM uniform_resource WHERE json_valid(content) = 1 AND name="Docker Container Ports" AND uri="osquery-ms:query-result";

DROP TABLE IF EXISTS ur_transform_list_container_process;
CREATE TABLE ur_transform_list_container_process AS
SELECT 
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host,
    json_extract(content, '$.columns.name') as process_name,
    json_extract(content, '$.columns.pid') as pid,
    json_extract(content, '$.columns.uid') as uid,
    json_extract(content, '$.columns.start_time') as start_time,
    json_extract(content, '$.columns.state') as state,
    uri as query_uri
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
    json_extract(ur.content, '$.columns.name') as process_name,
    uri as query_uri
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
  json_extract(ni.value, '$.Status') AS status,
  uri as query_uri
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
  json_extract(value, '$.creation_date') AS creation_date,
  uri as query_uri
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
  json_extract(value, '$.partition') AS partition,
  uri as query_uri
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
  json_extract(value, '$.path') AS path,
  uri as query_uri
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
  json_extract(value, '$.region') AS region,
  uri as query_uri
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
  json_extract(value, '$.vpc_id') AS vpc_id,
  uri as query_uri
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
  json_extract(value, '$.unblended_cost_amount') AS unblended_cost_amount,
  uri as query_uri
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
  json_extract(value, '$.unblended_cost_amount') AS unblended_cost_amount,
  uri as query_uri
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
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount,
  uri as query_uri
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
  json_extract(value, '$.usage_quantity_amount') AS usage_quantity_amount,
  uri as query_uri
FROM uniform_resource,
     json_each(content,'$.rows')
WHERE uri = 'SteampipeAwsCostByServiceMonthly';

-- -- ur_transform_list_ports_443
-- You can check if your server is listening on port 443 (default for HTTPS) to ensure SSL/TLS is enabled for web services.
DROP TABLE IF EXISTS ur_transform_list_ports_443;
CREATE TABLE ur_transform_list_ports_443 AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.address') AS address,  
    CASE json_extract(content, '$.columns.family')
        WHEN '2' THEN 'IPv4'
        WHEN '10' THEN 'IPv6'
        ELSE 'Unknown'
    END AS family,
    json_extract(content, '$.columns.fd') AS fd,
    json_extract(content, '$.columns.net_namespace') AS net_namespace, 
    json_extract(content, '$.columns.path') AS path, 
    json_extract(content, '$.columns.port') AS port,
    CASE json_extract(content, '$.columns.protocol')
        WHEN '6' THEN 'TCP'
        WHEN '17' THEN 'UDP'
        ELSE json_extract(content, '$.columns.protocol')
    END AS protocol,
    json_extract(content, '$.columns.socket') AS socket,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery Listening Ports 443" 
    AND uri = "osquery-ms:query-result"
    AND json_extract(content, '$.columns.port') = '443';


-- -- ur_transform_list_ssl_cert_files
DROP TABLE IF EXISTS ur_transform_list_ssl_cert_files;
CREATE TABLE ur_transform_list_ssl_cert_files AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.block_size') AS block_size,  
    json_extract(content, '$.columns.device') AS device,
    json_extract(content, '$.columns.directory') AS directory, 
    json_extract(content, '$.columns.filename') AS filename, 
    json_extract(content, '$.columns.gid') AS gid,
    json_extract(content, '$.columns.hard_links') AS hard_links,
    json_extract(content, '$.columns.inode') AS inode,
    json_extract(content, '$.columns.mode') AS mode,
    json_extract(content, '$.columns.path') AS path,
    json_extract(content, '$.columns.size') AS size,
    json_extract(content, '$.columns.type') AS type,
    json_extract(content, '$.columns.uid') AS uid,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery SSL Cert Files" 
    AND uri = "osquery-ms:query-result";

-- -- Monitor SSL cert and key file modification times
--  ur_transform_list_ssl_cert_file_mtime
DROP TABLE IF EXISTS ur_transform_list_ssl_cert_file_mtime;
CREATE TABLE ur_transform_list_ssl_cert_file_mtime AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.mtime') AS mtime,  
    json_extract(content, '$.columns.path') AS path,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery SSL Cert File MTIME" 
    AND uri = "osquery-ms:query-result";

-- -- Check if common VPN service ports (443, 1194, 500, 4500) are listening
-- ur_transform_list_osquery_vpn_listening_ports
DROP TABLE IF EXISTS ur_transform_list_osquery_vpn_listening_ports;
CREATE TABLE ur_transform_list_osquery_vpn_listening_ports AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.address') AS address,  
    json_extract(content, '$.columns.family') AS family,
    CASE json_extract(content, '$.columns.family')
        WHEN '2' THEN 'IPv4'
        ELSE json_extract(content, '$.columns.family')
    END AS family,
    json_extract(content, '$.columns.fd') AS fd,
    json_extract(content, '$.columns.net_namespace') AS net_namespace,
    json_extract(content, '$.columns.path') AS path,
    json_extract(content, '$.columns.port') AS port,
    CASE json_extract(content, '$.columns.protocol')
        WHEN '6' THEN 'TCP'
        WHEN '17' THEN 'UDP'
        ELSE json_extract(content, '$.columns.protocol')
    END AS protocol,
    json_extract(content, '$.columns.socket') AS socket,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery VPN Listening Ports" 
    AND uri = "osquery-ms:query-result";

-- Check for cron jobs related to backup tasks
-- ur_transform_list_osquery_vpn_listening_ports
DROP TABLE IF EXISTS ur_transform_list_osquery_vpn_listening_ports;
CREATE TABLE ur_transform_list_osquery_vpn_listening_ports AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.address') AS address,  
    json_extract(content, '$.columns.family') AS family,
    CASE json_extract(content, '$.columns.family')
        WHEN '2' THEN 'IPv4'
        ELSE json_extract(content, '$.columns.family')
    END AS family,
    json_extract(content, '$.columns.fd') AS fd,
    json_extract(content, '$.columns.net_namespace') AS net_namespace,
    json_extract(content, '$.columns.path') AS path,
    json_extract(content, '$.columns.port') AS port,
    CASE json_extract(content, '$.columns.protocol')
        WHEN '6' THEN 'TCP'
        WHEN '17' THEN 'UDP'
        ELSE json_extract(content, '$.columns.protocol')
    END AS protocol,
    json_extract(content, '$.columns.socket') AS socket,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery VPN Listening Ports" 
    AND uri = "osquery-ms:query-result";


-- Check for cron jobs related to backup tasks
-- ur_transform_list_cron_backup_jobs
DROP TABLE IF EXISTS ur_transform_list_cron_backup_jobs;
CREATE TABLE ur_transform_list_cron_backup_jobs AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.command') AS command,  
    json_extract(content, '$.columns.day_of_month') AS day_of_month,
    json_extract(content, '$.columns.day_of_week') AS day_of_week, 
    json_extract(content, '$.columns.event') AS event, 
    json_extract(content, '$.columns.hour') AS hour,  
    json_extract(content, '$.columns.minute') AS minute,
    json_extract(content, '$.columns.month') AS month,
    json_extract(content, '$.columns.path') AS path,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery Cron Backup Jobs" 
    AND uri = "osquery-ms:query-result";

    -- Check for cron jobs related to backup tasks
-- ur_transform_list_cron_backup_jobs
DROP TABLE IF EXISTS ur_transform_list_cron_backup_jobs;
CREATE TABLE ur_transform_list_cron_backup_jobs AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.command') AS command,  
    json_extract(content, '$.columns.day_of_month') AS day_of_month,
    json_extract(content, '$.columns.day_of_week') AS day_of_week, 
    json_extract(content, '$.columns.event') AS event, 
    json_extract(content, '$.columns.hour') AS hour,  
    json_extract(content, '$.columns.minute') AS minute,
    json_extract(content, '$.columns.month') AS month,
    json_extract(content, '$.columns.path') AS path,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery Cron Backup Jobs" 
    AND uri = "osquery-ms:query-result";

-- Inventory: List MySQL database processes
-- ur_transform_list_mysql_process_inventory
DROP TABLE IF EXISTS ur_transform_list_mysql_process_inventory;
CREATE TABLE ur_transform_list_mysql_process_inventory AS
SELECT 
    uniform_resource_id,
    json_extract(content, '$.name') AS name,
    json_extract(content, '$.hostIdentifier') AS host_identifier,
    json_extract(content, '$.columns.name') AS process_name,
    json_extract(content, '$.columns.path') AS process_path,
    uri AS query_uri
FROM uniform_resource 
WHERE 
    json_valid(content) = 1 
    AND name = "Osquery MySQL Process Inventory" 
    AND uri = "osquery-ms:query-result";