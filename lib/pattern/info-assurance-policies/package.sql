-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- --------------------------------------------------------------------------------
-- Script to prepare convenience views to access uniform_resource.content column
-- as CCDA content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------

-- TODO: will this help performance?
-- CREATE INDEX IF NOT EXISTS idx_resource_type ON uniform_resource ((content ->> '$.resourceType'));
-- CREATE INDEX IF NOT EXISTS idx_bundle_entry ON uniform_resource ((json_type(content -> '$.entry')));

-- CCDA Discovery and Enumeration Views
-- --------------------------------------------------------------------------------

-- Summary of the uniform_resource table
-- Provides a count of total rows, valid JSON rows, invalid JSON rows,
-- and potential CCDA v4 candidates and bundles based on JSON structure.
DROP VIEW IF EXISTS uniform_resource_summary;
CREATE VIEW uniform_resource_summary AS
    SELECT
        COUNT(*) AS total_rows,
        SUM(CASE WHEN json_valid(content) THEN 1 ELSE 0 END) AS valid_json_rows,
        SUM(CASE WHEN json_valid(content) THEN 0 ELSE 1 END) AS invalid_json_rows,
        SUM(CASE WHEN json_valid(content) AND content ->> '$.resourceType' IS NOT NULL THEN 1 ELSE 0 END) AS ccda_v4_candidates,
        SUM(CASE WHEN json_valid(content) AND json_type(content -> '$.entry') = 'array' THEN 1 ELSE 0 END) AS ccda_v4_bundle_candidates
    FROM
        uniform_resource;

DROP VIEW IF EXISTS policy_dashboard;
CREATE VIEW policy_dashboard AS
    WITH RECURSIVE split_uri AS (
        SELECT
            uniform_resource_id,
            uri,
            substr(uri, instr(uri, 'src/') + 4, instr(substr(uri, instr(uri, 'src/') + 4), '/') - 1) AS segment,
            substr(substr(uri, instr(uri, 'src/') + 4), instr(substr(uri, instr(uri, 'src/') + 4), '/') + 1) AS rest,
            1 AS level
        FROM uniform_resource
        WHERE instr(uri, 'src/') > 0 AND  instr(substring(uri,instr(uri, 'src/')),'_')=0 
        UNION ALL
        SELECT
            uniform_resource_id,
            uri,
            substr(rest, 1, instr(rest, '/') - 1) AS segment,
            substr(rest, instr(rest, '/') + 1) AS rest,
            level + 1
        FROM split_uri
        WHERE instr(rest, '/') > 0 AND instr(substring(uri,instr(uri, 'src/')),'_')=0
    ),
    final_segment AS (
        SELECT DISTINCT
            uniform_resource_id,
            segment,
            substr(uri, instr(uri, 'src/')) AS url,
            CASE WHEN instr(rest, '/') = 0 THEN 0 ELSE 1 END AS is_folder
        FROM split_uri
        WHERE level = 4 AND instr(rest, '/') = 0
    )
    SELECT
        uniform_resource_id,
        COALESCE(REPLACE(segment, '-', ' '), '') AS title,
        segment,
        url
    FROM final_segment
    WHERE url LIKE '%.md' OR url LIKE '%.mdx'
    GROUP BY segment
    ORDER BY is_folder ASC, segment ASC;

DROP VIEW IF EXISTS policy_detail;
CREATE VIEW policy_detail AS
    SELECT uniform_resource_id,uri,content_fm_body_attrs, content, nature FROM uniform_resource;

DROP VIEW IF EXISTS policy_list;
CREATE VIEW policy_list AS
    WITH RECURSIVE split_uri AS (
    -- Initial split to get the first segment after 'src/'
    SELECT
        uniform_resource_id,
        frontmatter->>'title' AS title,
        uri,
        last_modified_at,
        null as parentfolder,
        substr(uri, instr(uri, 'src/') + 4, instr(substr(uri, instr(uri, 'src/') + 4), '/') - 1) AS segment1,
        substr(substr(uri, instr(uri, 'src/') + 4), instr(substr(uri, instr(uri, 'src/') + 4), '/') + 1) AS rest,
        1 AS level
    FROM uniform_resource
    WHERE instr(uri, 'src/') > 0 AND instr(substr(uri, instr(uri, 'src/')), '_') = 0 and  content not LIKE  '%Draft: true%'
    UNION ALL
    SELECT
    uniform_resource_id,
    title,
        uri,
        last_modified_at,
         CASE
	        WHEN level = 4 THEN segment1
	        WHEN level = 5 THEN segment1
	        WHEN level = 6 THEN segment1
	        WHEN level = 7 THEN segment1
        END AS parentfolder,
        CASE
	        WHEN level = 1 THEN substr(rest, 1, instr(rest, '/') - 1)
	        WHEN level = 2 THEN substr(rest, 1, instr(rest, '/') - 1)
	        WHEN level = 3 THEN substr(rest, 1, instr(rest, '/') - 1)
	        WHEN level = 4 THEN substr(rest, 1, instr(rest, '/') - 1)
	        WHEN level = 5 THEN substr(rest, 1, instr(rest, '/') - 1)
	        WHEN level = 6 THEN substr(rest, 1, instr(rest, '/') - 1)
	        WHEN level = 7 THEN substr(rest, 1, instr(rest, '/') - 1)
	        WHEN level = 8 THEN substr(rest, 1, instr(rest, '/') - 1)
            ELSE segment1
        END AS segment1,
        CASE 
            WHEN instr(rest, '/') > 0 THEN substr(rest, instr(rest, '/') + 1)
            ELSE ''
        END AS rest,
        level + 1
    FROM split_uri
    WHERE rest != '' AND instr(substr(uri, instr(uri, 'src/')), '_') = 0
),
latest_entries AS (
            SELECT
              uri,
              MAX(last_modified_at) AS latest_last_modified_at
            FROM
              uniform_resource
            GROUP BY
              uri
        )
Select  distinct substr(ss.uri, instr(ss.uri, 'src/')) AS url,ss.title,ss.parentfolder,ss.segment1,ss.rest,ss.last_modified_at,ss.uniform_resource_id
from split_uri ss
JOIN 
 latest_entries le
        ON
          ss.uri = le.uri AND last_modified_at = le.latest_last_modified_at
where level >4 and level <6
and  instr(rest,'/')=0 
order by ss.parentfolder,ss.segment1,url;

DROP VIEW IF EXISTS vigetallviews ;
CREATE VIEW vigetallviews as
Select 'Up time' title,'viup_time' as viewname,'opsfolio/info/policy/viup_time.sql' as path,0 as used_path 
UNION ALL
Select 'Log' title,'viLog'as viewname,'opsfolio/info/policy/viLog.sql' as path,0 as used_path
UNION ALL
Select 'Encrypted passwords' title,'viencrypted_passwords'as viewname,'opsfolio/info/policy/viencrypted_passwords.sql' as path,0 as used_path
UNION ALL
Select 'Network Log' title,'vinetwork_log'as viewname,'opsfolio/info/policy/vinetwork_log.sql' as path,0 as used_path
UNION ALL
Select 'SSL Certificate' title,'vissl_certificate'as viewname,'opsfolio/info/policy/vissl_certificate.sql' as path,0 as used_path
UNION ALL
Select 'Available Storage' title,'vistorage_available'as viewname,'opsfolio/info/policy/vistorage_available.sql' as path,0 as used_path
UNION ALL
Select 'Ram Utilization' title,'viram_utilization'as viewname,'opsfolio/info/policy/viram_utilization.sql' as path,0 as used_path
UNION ALL
Select 'Cpu Information' title,'vicpu_infomation'as viewname,'opsfolio/info/policy/vicpu_infomation.sql' as path,0 as used_path
UNION ALL
Select 'Removed Accounts' title,'viaccounts_removed'as viewname,'opsfolio/info/policy/viaccounts_removed.sql' as path,0 as used_path
UNION ALL
Select 'SSH Settings' title,'vissh_settings'as viewname,'opsfolio/info/policy/vissh_settings.sql' as path,0 as used_path
UNION ALL
Select 'Unsuccessful Attempts' title,'viunsuccessful_attempts_log'as viewname,'opsfolio/info/policy/viunsuccessful_attempts_log.sql' as path,0 as used_path
UNION ALL
Select 'Authentication' title,'viauthentication'as viewname,'opsfolio/info/policy/viauthentication.sql' as path,0 as used_path
UNION ALL
Select 'Awareness training' title,'viawareness_training'as viewname,'opsfolio/info/policy/viawareness_training.sql' as path,0 as used_path
UNION ALL
Select 'Server details' title,'viserver_details'as viewname,'opsfolio/info/policy/viserver_details.sql' as path,0 as used_path
UNION ALL
Select 'Asset details' title,'viasset_details'as viewname,'opsfolio/info/policy/viasset_details.sql' as path,0 as used_path
UNION ALL
Select 'Identify Critical Assets' title,'viidentify_critical_assets'as viewname,'opsfolio/info/policy/viidentify_critical_assets.sql' as path,0 as used_path
UNION ALL
Select 'Risk Register' title,'virisk_register'as viewname,'opsfolio/info/policy/virisk_register.sql' as path,0 as used_path
UNION ALL
Select 'Security Incident' title,'visecurity_incident'as viewname,'opsfolio/info/policy/visecurity_incident.sql' as path,0 as used_path
UNION ALL
Select 'Security Incident Response Team' title,'visecurity_incident_team'as viewname,'opsfolio/info/policy/visecurity_incident_team.sql' as path,0 as used_path
UNION ALL
Select 'Security Impact Analysis' title,'visecurity_impact_analysis'as viewname,'opsfolio/info/policy/visecurity_impact_analysis.sql' as path,0 as used_path
UNION ALL
Select 'Confidential Asset Register' title,'viconfidential_asset_register'as viewname,'opsfolio/info/policy/viconfidential_asset_register.sql' as path,0 as used_path
UNION ALL
Select 'Disable USB device' title,'vidisable_usb_device'as viewname,'opsfolio/info/policy/vidisable_usb_device.sql' as path,0 as used_path
UNION ALL
Select 'Fraud assessment' title,'vifraud_assessment'as viewname,'opsfolio/info/policy/vifraud_assessment.sql' as path,0 as used_path
UNION ALL
Select 'Sample Tickets For Terminated Employees Have Been Revoked.(Gitlab)' title,'vigitlab_terminated_employee'as viewname,'opsfolio/info/policy/vigitlab_terminated_employee.sql' as path,0 as used_path
UNION ALL
Select 'Gitlab Tickets' title,'vigitlab_sample_ticket'as viewname,'opsfolio/info/policy/vigitlab_sample_ticket.sql' as path,0 as used_path
UNION ALL
Select 'Sample User Access Provisioning Ticket' title,'visample_access_provisioning_ticket'as viewname,'opsfolio/info/policy/visample_access_provisioning_ticket.sql' as path,0 as used_path
UNION ALL
Select 'Disaster Recovery Test Reports' title,'vidisaster_recovery_reports'as viewname,'opsfolio/info/policy/vidisaster_recovery_reports.sql' as path,0 as used_path
UNION ALL
Select 'Disaster Recovery Test Result' title,'vidisaster_recovery_reports'as viewname,'opsfolio/info/policy/vidisaster_recovery_reports.sql' as path,0 as used_path
UNION ALL
Select 'Sample Change Management Git Ticket' title,'visample_change_management_ticket'as viewname,'opsfolio/info/policy/visample_change_management_ticket.sql' as path,0 as used_path
UNION ALL
Select 'Medigy-Closed Gitlab Tickets' title,'vimedigy_closed_gitlab_tickets'as viewname,'opsfolio/info/policy/vimedigy_closed_gitlab_tickets.sql' as path,0 as used_path
UNION ALL
Select 'Medigy-Open Gitlab Tickets' title,'vimedigy_open_gitlab_tickets'as viewname,'opsfolio/info/policy/vimedigy_open_gitlab_tickets.sql' as path,0 as used_path
UNION ALL
Select 'Penetration Test Report' title,'vipenetration_test_report'as viewname,'opsfolio/info/policy/vipenetration_test_report.sql' as path,0 as used_path
UNION ALL
Select 'Firewall Inbound Rules' title,'vifirewall_inbound_rules'as viewname,'opsfolio/info/policy/vifirewall_inbound_rules.sql' as path,0 as used_path
UNION ALL
Select 'Firewall Outbound Rules' title,'vifirewall_outbound_rules'as viewname,'opsfolio/info/policy/vifirewall_outbound_rules.sql' as path,0 as used_path
UNION ALL
Select 'Firewall' title,'vifirewall'as viewname,'opsfolio/info/policy/vifirewall.sql' as path,0 as used_path
UNION ALL
Select 'Open Github Tickets' title,'viopen_github_tickets'as viewname,'opsfolio/info/policy/viopen_github_tickets.sql' as path,0 as used_path
UNION ALL
Select 'Closed Github Tickets' title,'viclosed_github_tickets'as viewname,'opsfolio/info/policy/viclosed_github_tickets.sql' as path,0 as used_path
UNION ALL
Select 'Open Github Tickets-Polyglot' title,'viopen_github_tickets_polyglot'as viewname,'opsfolio/info/policy/viopen_github_tickets_polyglot.sql' as path,0 as used_path
UNION ALL
Select 'Closed Github Tickets-Polyglot' title,'viclosed_github_tickets_polyglot'as viewname,'opsfolio/info/policy/viclosed_github_tickets_polyglot.sql' as path,0 as used_path;

DELETE FROM sqlpage_files
WHERE path IN (
    SELECT a.path
    FROM sqlpage_files a
    INNER JOIN vigetallviews b ON a.path = b.path
);

WITH get_allviewname AS (
    -- Select all table names
    SELECT viewname,title
    FROM vigetallviews
)
INSERT OR IGNORE INTO sqlpage_files (path, contents)
SELECT 
     'opsfolio/info/policy/' || viewname||'.sql' AS path,
    '
    SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

    SELECT ''breadcrumb'' as component;
    WITH RECURSIVE breadcrumbs AS (
        SELECT
            COALESCE(abbreviated_caption, caption) AS title,
            COALESCE(url, path) AS link,
            parent_path, 0 AS level,
            namespace
        FROM sqlpage_aide_navigation
        WHERE namespace = ''prime'' AND path = ''/drh/cgm-data''
        UNION ALL
        SELECT
            COALESCE(nav.abbreviated_caption, nav.caption) AS title,
            COALESCE(nav.url, nav.path) AS link,
            nav.parent_path, b.level + 1, nav.namespace
        FROM sqlpage_aide_navigation nav
        INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
    )
    SELECT title, link FROM breadcrumbs ORDER BY level DESC;
    SELECT ''' || title || ''' || '' Table'' AS title, ''#'' AS link;
    select ''title'' as component,'''||title||''' as contents ;
    
    SELECT ''table'' AS component ;
    SELECT  * from  ''' || viewname || ''''
   
FROM get_allviewname;

DROP VIEW IF EXISTS viup_time;
CREATE VIEW viup_time as
SELECT
    json_extract(value, '$.days') AS Days,
    json_extract(value, '$.hours') AS Hours,
    json_extract(value, '$.minutes') AS Minutes,
    json_extract(value, '$.seconds') AS Seconds
    FROM
    uniform_resource,
    json_each(content)
    WHERE
     uri ="osqueryUpTime";
DROP VIEW IF EXISTS viLog;
CREATE VIEW viLog as
SELECT
    json_extract(value, '$.date') AS date,
    json_extract(value, '$.message') AS message
    FROM
    uniform_resource,
    json_each(content)
    WHERE
    content like '%session%' and
    uri='authLogInfo' order by created_at desc limit 100;

DROP VIEW IF EXISTS viencrypted_passwords;
CREATE VIEW viencrypted_passwords AS 
SELECT
      json_extract(value, '$.md5') AS md5,
      json_extract(value, '$.sha1') AS sha1,
      json_extract(value, '$.sha256') AS sha256
      FROM
      uniform_resource,
      json_each(content)
      where uri ='osqueryEncryptedPasswords';

DROP VIEW IF EXISTS vinetwork_log;
 CREATE VIEW vinetwork_log AS       
 select  
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.atime') AS atime,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.category') AS category,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.ctime') AS ctime,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.gid') AS gid,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.hashed') AS hashed,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.inode') AS inode,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.md5') AS md5,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.mode') AS mode,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.mtime') AS mtime,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.sha1') AS sha1,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.sha256') AS sha256,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.size') AS size,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.target_path') AS target_path,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.time') AS time,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.transaction_id') AS transaction_id,
 json_extract(json(IIF(datas <> '', datas, NULL)),'$.uid') AS uid
 from
(SELECT
     json_extract(value,'$.columns') AS  datas
    FROM
   (select  content from uniform_resource ur 
  where uri ='osquerydFileEvents' and json_valid(content) limit 1 ) ,
  json_each(content)
 limit 100),
 json_each(datas) where json_valid(datas)=1 limit 100 ;


DROP VIEW IF EXISTS vissl_certificate;
CREATE VIEW vissl_certificate AS
SELECT distinct
      json_extract(value, '$.hostname') Hostname ,
       json_extract(value, '$.valid_to') Valid_to
      FROM
      uniform_resource,
      json_each(content)
      where uri ='osqueryWebsiteSslCertificate';

DROP VIEW IF EXISTS vistorage_available;
CREATE VIEW vistorage_available AS       
SELECT
   json_extract(value, '$.%_available') AS available,
   json_extract(value, '$.%_used') AS used,
   json_extract(value, '$.space_left_gb') AS space_left_gb,
   json_extract(value, '$.total_space_gb') AS total_space_gb,
   json_extract(value, '$.used_space_gb') AS used_space_gb
    FROM
    uniform_resource,
    json_each(content)
    WHERE
    uri='osqueryDiskUtilization' order by 
    last_modified_at desc
    limit 1;

DROP VIEW IF EXISTS viram_utilization;
CREATE VIEW viram_utilization AS        
SELECT
   json_extract(value, '$.memory_free_gb') AS memory_free_gb,
   json_extract(value, '$.memory_percentage_free') AS memory_percentage_free,
   json_extract(value, '$.memory_percentage_used') AS memory_percentage_used,
   json_extract(value, '$.memory_total_gb') AS memory_total_gb
    FROM
    uniform_resource,
    json_each(content)
    WHERE
    uri='osqueryMemoryUtilization' order by 
    last_modified_at desc
    limit 1;

DROP VIEW IF EXISTS vicpu_infomation;
CREATE VIEW vicpu_infomation AS     
SELECT 
    json_extract(value, '$.cpu_brand') AS cpu_brand,
    json_extract(value, '$.cpu_physical_cores') AS cpu_physical_cores,
    json_extract(value, '$.cpu_logical_cores') AS cpu_logical_cores,
    json_extract(value, '$.computer_name') AS computer_name,
    json_extract(value, '$.local_hostname') AS local_hostname
    from uniform_resource,
    json_each(content) where
     uri='osquerySystemInfo';    

DROP VIEW IF EXISTS viaccounts_removed;
CREATE VIEW viaccounts_removed   AS    
SELECT
    json_extract(value,'$.description') AS description,
    json_extract(value,'$.directory') AS directory,
    json_extract(value,'$.gid') AS gid,
    json_extract(value,'$.gid_signed') AS gid_signed,
    json_extract(value,'$.shell') AS shell,
    json_extract(value,'$.uid') AS uid,
    json_extract(value,'$.uid_signed') AS uid_signed,
    json_extract(value,'$.username') AS username,
    json_extract(value,'$.uuid') AS uuid
    FROM
   uniform_resource,
    json_each(content)
    where uri ='osqueryRemovedUserAccounts';


DROP VIEW IF EXISTS vissh_settings;
CREATE VIEW vissh_settings  AS     
select
   json_extract(value, '$.name') AS Name ,
   json_extract(value, '$.cmdline') AS cmdline,
   json_extract(value, '$.path') AS path
   from
   uniform_resource,
   json_each(content)
   where uri='osquerySshdProcess'; 

DROP VIEW IF EXISTS viunsuccessful_attempts_log;
CREATE VIEW viunsuccessful_attempts_log AS 
SELECT
    json_extract(value, '$.date') AS date,
    json_extract(value, '$.message') AS message
    FROM
    uniform_resource,
    json_each(content)
    WHERE
    uri='authLogInfo' order by created_at desc limit 100;

DROP VIEW IF EXISTS viauthentication;
CREATE VIEW viauthentication AS      
select
  json_extract(value, '$.node') AS node ,
  json_extract(value, '$.value') AS value,
  json_extract(value, '$.label') AS label ,
  json_extract(value, '$.path') AS path
  from
  uniform_resource,
  json_each(content)
  where uri='osqueryMfaEnabled';
  DROP VIEW IF EXISTS viram_utilization;
CREATE VIEW viram_utilization AS        
SELECT
   json_extract(value, '$.memory_free_gb') AS memory_free_gb,
   json_extract(value, '$.memory_percentage_free') AS memory_percentage_free,
   json_extract(value, '$.memory_percentage_used') AS memory_percentage_used,
   json_extract(value, '$.memory_total_gb') AS memory_total_gb
    FROM
    uniform_resource,
    json_each(content)
    WHERE
    uri='osqueryMemoryUtilization' order by 
    last_modified_at desc
    limit 1;

DROP VIEW IF EXISTS vicpu_infomation;
CREATE VIEW vicpu_infomation AS     
SELECT 
    json_extract(value, '$.cpu_brand') AS cpu_brand,
    json_extract(value, '$.cpu_physical_cores') AS cpu_physical_cores,
    json_extract(value, '$.cpu_logical_cores') AS cpu_logical_cores,
    json_extract(value, '$.computer_name') AS computer_name,
    json_extract(value, '$.local_hostname') AS local_hostname
    from uniform_resource,
    json_each(content) where
     uri='osquerySystemInfo';    

DROP VIEW IF EXISTS viaccounts_removed;
CREATE VIEW viaccounts_removed   AS    
SELECT
    json_extract(value,'$.description') AS description,
    json_extract(value,'$.directory') AS directory,
    json_extract(value,'$.gid') AS gid,
    json_extract(value,'$.gid_signed') AS gid_signed,
    json_extract(value,'$.shell') AS shell,
    json_extract(value,'$.uid') AS uid,
    json_extract(value,'$.uid_signed') AS uid_signed,
    json_extract(value,'$.username') AS username,
    json_extract(value,'$.uuid') AS uuid
    FROM
   uniform_resource,
    json_each(content)
    where uri ='osqueryRemovedUserAccounts';


DROP VIEW IF EXISTS vissh_settings;
CREATE VIEW vissh_settings  AS     
select
   json_extract(value, '$.name') AS Name ,
   json_extract(value, '$.cmdline') AS cmdline,
   json_extract(value, '$.path') AS path
   from
   uniform_resource,
   json_each(content)
   where uri='osquerySshdProcess'; 

DROP VIEW IF EXISTS viunsuccessful_attempts_log;
CREATE VIEW viunsuccessful_attempts_log AS 
SELECT
    json_extract(value, '$.date') AS date,
    json_extract(value, '$.message') AS message
    FROM
    uniform_resource,
    json_each(content)
    WHERE
    uri='authLogInfo' order by created_at desc limit 100;

DROP VIEW IF EXISTS viauthentication;
CREATE VIEW viauthentication AS      
select
  json_extract(value, '$.node') AS node ,
  json_extract(value, '$.value') AS value,
  json_extract(value, '$.label') AS label ,
  json_extract(value, '$.path') AS path
  from
  uniform_resource,
  json_each(content)
  where uri='osqueryMfaEnabled';

DROP VIEW IF EXISTS viawareness_training;
CREATE VIEW viawareness_training AS      
SELECT  DISTINCT  p.person_first_name || ' ' || p.person_last_name AS person_name,ort.value AS person_role,sub.value AS trainigng_subject,sv."value" as training_status,at.attended_date
    FROM awareness_training at
    INNER JOIN person p ON p.person_id = at.person_id
    INNER JOIN organization_role orl ON orl.person_id = at.person_id AND orl.organization_id = at.organization_id
    INNER JOIN organization_role_type ort ON ort.organization_role_type_id = orl.organization_role_type_id
    INNER JOIN status_value sv ON sv.status_value_id = at.training_status_id
    INNER JOIN training_subject sub ON sub.training_subject_id = at.training_subject_id;


DROP VIEW IF EXISTS viserver_details;
CREATE VIEW viserver_details AS      
SELECT  ast.name as server,o.name AS owner,sta.value as tag, ast.asset_retired_date, ast.asset_tag,ast.description,ast.criticality,
        aty.value as asset_type, ast.installed_date,ast.planned_retirement_date, ast.purchase_request_date,ast.purchase_order_date,ast.purchase_delivery_date,
        asymmetric_keys_encryption_enabled,cryptographic_key_encryption_enabled,
        symmetric_keys_encryption_enabled
          FROM asset ast
          INNER JOIN organization o ON o.organization_id=ast.organization_id
          INNER JOIN asset_status sta ON sta.asset_status_id=ast.asset_status_id
        INNER JOIN asset_type aty ON aty.asset_type_id=ast.asset_type_id;


DROP VIEW IF EXISTS viidentify_critical_assets;
CREATE VIEW viidentify_critical_assets AS      
SELECT
    ast.name as server,o.name AS owner,sta.value as tag, ast.asset_retired_date, ast.asset_tag,ast.description,ast.criticality,
	aty.value as asset_type, ast.installed_date,ast.planned_retirement_date, ast.purchase_request_date,ast.purchase_order_date,ast.purchase_delivery_date
    ,asymmetric_keys_encryption_enabled,cryptographic_key_encryption_enabled,
symmetric_keys_encryption_enabled FROM asset ast
    INNER JOIN organization o ON o.organization_id=ast.organization_id
    INNER JOIN asset_status sta ON sta.asset_status_id=ast.asset_status_id
	INNER JOIN asset_type aty ON aty.asset_type_id=ast.asset_type_id where ast.criticality= 'Critical';

DROP VIEW IF EXISTS virisk_register;
CREATE VIEW virisk_register AS      
SELECT risk_register_id, risk_subject_id, risk_type_id, impact_to_the_organization,
rating_likelihood_id, rating_impact_id,rating_overall_risk_id,
mitigation_further_actions, control_monitor_mitigation_actions_tracking_strategy, control_monitor_action_due_date,
control_monitor_risk_owner_id, created_at FROM risk_register;

DROP VIEW IF EXISTS visecurity_incident;
CREATE VIEW visecurity_incident AS      
SELECT i.title AS incident,i.incident_date,ast.name as asset_name,ic.value AS category,s.value AS severity,
    p.value AS priority,it.value AS internal_or_external,i.location,i.it_service_impacted,
    i.impacted_modules,i.impacted_dept,p1.person_first_name || ' ' || p1.person_last_name AS reported_by,
    p2.person_first_name || ' ' || p2.person_last_name AS reported_to,i.brief_description,
    i.detailed_description,p3.person_first_name || ' ' || p3.person_last_name AS assigned_to,
    i.assigned_date,i.investigation_details,i.containment_details,i.eradication_details,i.business_impact,
    i.lessons_learned,ist.value AS status,i.closed_date,i.feedback_from_business,i.reported_to_regulatory,i.report_date,i.report_time,
    irc.description AS root_cause_of_the_issue,p4.value AS probability_of_issue,irc.testing_analysis AS testing_for_possible_root_cause_analysis,
    irc.solution,p5.value AS likelihood_of_risk,irc.modification_of_the_reported_issue,irc.testing_for_modified_issue,irc.test_results
    FROM incident i
    INNER JOIN asset ast ON ast.asset_id = i.asset_id
    INNER JOIN incident_category ic ON ic.incident_category_id = i.category_id
    INNER JOIN severity s ON s.code = i.severity_id
    INNER JOIN priority p ON p.code = i.priority_id
    INNER JOIN incident_type it ON it.incident_type_id = i.internal_or_external_id
    INNER JOIN person p1 ON p1.person_id = i.reported_by_id
    INNER JOIN person p2 ON p2.person_id = i.reported_to_id
    INNER JOIN person p3 ON p3.person_id = i.assigned_to_id
    INNER JOIN incident_status ist ON ist.incident_status_id = i.status_id
    LEFT JOIN incident_root_cause irc ON irc.incident_id = i.incident_id
    LEFT JOIN priority p4 ON p4.code = irc.probability_id
    LEFT JOIN priority p5 ON p5.code = irc.likelihood_of_risk_id;

DROP VIEW IF EXISTS visecurity_incident_team;
CREATE VIEW visecurity_incident_team AS      
    SELECT  p.person_first_name || ' ' || p.person_last_name AS person_name, "Netspective Communications" AS organization_name, ort.value AS team_role,e.electronics_details AS email
    FROM security_incident_response_team sirt
    INNER JOIN person p ON p.person_id = sirt.person_id
    INNER JOIN organization o ON o.organization_id=sirt.organization_id
    INNER JOIN organization_role orl ON orl.person_id = sirt.person_id 
    INNER JOIN organization_role_type ort ON ort.organization_role_type_id = orl.organization_role_type_id
    INNER JOIN party pr ON pr.party_id = p.party_id
    INNER JOIN contact_electronic e ON e.party_id=pr.party_id AND 
    e.contact_type_id = (SELECT contact_type_id FROM contact_type WHERE code='OFFICIAL_EMAIL');

DROP VIEW IF EXISTS visecurity_impact_analysis;
CREATE VIEW visecurity_impact_analysis AS      

SELECT sia.security_impact_analysis_id, sia.vulnerability_id, sia.asset_risk_id, sia.risk_level_id, sia.impact_level_id,
sia.existing_controls, sia.priority_id, sia.reported_date, sia.reported_by_id,
sia.responsible_by_id, sia.created_at, ior.impact
FROM security_impact_analysis sia
inner join impact_of_risk ior on (sia.security_impact_analysis_id = ior.security_impact_analysis_id);


DROP VIEW IF EXISTS viconfidential_asset_register;
CREATE VIEW viconfidential_asset_register AS      

SELECT
    ast.name as server,o.name AS owner,sta.value as tag, ast.asset_retired_date, ast.asset_tag,ast.description,ast.criticality,
	aty.value as asset_type, ast.installed_date,ast.planned_retirement_date, ast.purchase_request_date,ast.purchase_order_date,ast.purchase_delivery_date
    ,asymmetric_keys_encryption_enabled,cryptographic_key_encryption_enabled,
symmetric_keys_encryption_enabled
  FROM asset ast
    INNER JOIN organization o ON o.organization_id=ast.organization_id
    INNER JOIN asset_status sta ON sta.asset_status_id=ast.asset_status_id
	INNER JOIN asset_type aty ON aty.asset_type_id=ast.asset_type_id;

DROP VIEW IF EXISTS viasset_details;
CREATE VIEW viasset_details AS 
SELECT
    asser.name,ast.name as server,ast.organization_id,astyp.value as asset_type,astyp.asset_service_type_id,bnt.name as boundary,asser.description,asser.port,asser.experimental_version,asser.production_version,asser.latest_vendor_version,asser.resource_utilization,asser.log_file,asser.url,
    asser.vendor_link,asser.installation_date,asser.criticality,o.name AS owner,sta.value as tag, ast.criticality as asset_criticality,ast.asymmetric_keys_encryption_enabled as asymmetric_keys,
    ast.cryptographic_key_encryption_enabled as cryptographic_key,ast.symmetric_keys_encryption_enabled as symmetric_keys
    FROM asset_service asser
    INNER JOIN asset_service_type astyp ON astyp.asset_service_type_id = asser.asset_service_type_id
    INNER JOIN asset ast ON ast.asset_id = asser.asset_id
    INNER JOIN organization o ON o.organization_id=ast.organization_id
    INNER JOIN asset_status sta ON sta.asset_status_id=ast.asset_status_id
    INNER JOIN boundary bnt ON bnt.boundary_id=ast.boundary_id;     

DROP VIEW IF EXISTS vidisable_usb_device;
CREATE VIEW vidisable_usb_device AS 
SELECT
    ast.name as server,o.name AS owner,sta.value as tag, ast.asset_retired_date, ast.asset_tag,ast.description,ast.criticality,
	aty.value as asset_type, ast.installed_date,ast.planned_retirement_date, ast.purchase_request_date,ast.purchase_order_date,ast.purchase_delivery_date
    ,asymmetric_keys_encryption_enabled,cryptographic_key_encryption_enabled,
symmetric_keys_encryption_enabled
  FROM asset ast
    INNER JOIN organization o ON o.organization_id=ast.organization_id
    INNER JOIN asset_status sta ON sta.asset_status_id=ast.asset_status_id
	INNER JOIN asset_type aty ON aty.asset_type_id=ast.asset_type_id where sta.value = 'In Use';

DROP VIEW IF EXISTS vifraud_assessment;
CREATE VIEW vifraud_assessment AS 
SELECT  v.short_name , ar.impact, sia.risk_level_id, sia.impact_level_id,
sia.existing_controls, sia.priority_id, sia.reported_date, p.person_first_name || ' ' ||p.person_last_name as Reported_Person,
p1.person_first_name || ' ' ||p1.person_last_name as Responsible_Person , sia.created_at, ior.impact
FROM security_impact_analysis sia inner join impact_of_risk ior on (sia.security_impact_analysis_id = ior.security_impact_analysis_id) join person p on p.person_id = sia.reported_by_id
join person p1 on p1.person_id=sia.responsible_by_id join vulnerability v on v.vulnerability_id = sia.vulnerability_id join asset_risk ar on ar.asset_risk_id = sia.asset_risk_id;

DROP VIEW IF EXISTS vigitlab_terminated_employee;
CREATE VIEW vigitlab_terminated_employee AS 
SELECT
    i.issue_id AS Issue,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE
    i.url LIKE '%issues/838%';


DROP VIEW IF EXISTS vigitlab_sample_ticket;
CREATE VIEW vigitlab_sample_ticket AS 
   SELECT 
    json_extract(ur.content, '$.iid') AS Issues,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM 
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    uniform_resource AS ur ON i.uniform_resource_id = ur.uniform_resource_id
LEFT JOIN 
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN 
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE 
    p.name="www.medigy.com"  AND Issues=838;

 DROP VIEW IF EXISTS visample_access_provisioning_ticket;
CREATE VIEW visample_access_provisioning_ticket AS 
    SELECT
    i.issue_id AS Issue,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE
    i.url LIKE '%issues/509%';


DROP VIEW IF EXISTS vidisaster_recovery_reports;
CREATE VIEW vidisaster_recovery_reports AS 
   SELECT
    i.issue_id AS Issue,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE
    i.url LIKE '%issues/667%';

DROP VIEW IF EXISTS visample_change_management_ticket;
CREATE VIEW visample_change_management_ticket AS 
   SELECT
    i.issue_id AS Issue,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE
    i.url LIKE '%issues/671%';

DROP VIEW IF EXISTS vimedigy_closed_gitlab_tickets;
CREATE VIEW vimedigy_closed_gitlab_tickets AS 
SELECT 
    json_extract(ur.content, '$.iid') AS Issues,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM 
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    uniform_resource AS ur ON i.uniform_resource_id = ur.uniform_resource_id
LEFT JOIN 
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN 
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE 
    p.name="www.medigy.com" AND i.state="closed";   

DROP VIEW IF EXISTS vimedigy_open_gitlab_tickets;
CREATE VIEW vimedigy_open_gitlab_tickets AS 
SELECT 
    json_extract(ur.content, '$.iid') AS Issues,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM 
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    uniform_resource AS ur ON i.uniform_resource_id = ur.uniform_resource_id
LEFT JOIN 
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN 
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE 
    p.name="www.medigy.com" AND i.state="opened";   


DROP VIEW IF EXISTS vipenetration_test_report;
CREATE VIEW vipenetration_test_report AS 
SELECT
    i.issue_id AS Issue,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE
    i.url LIKE '%issues/662%';  


DROP VIEW IF EXISTS vifirewall_inbound_rules;
CREATE VIEW vifirewall_inbound_rules AS 
SELECT
    json_extract(value, '$.id') AS id,
    json_extract(value, '$.title') AS title,
    json_extract(value, '$.category') AS category,
    json_extract(value, '$.from_id') AS from_id,
    json_extract(value, '$.to_id') AS to_id
FROM
    uniform_resource,
    json_each(content)
WHERE
     uri = 'steampipeListDoFirewallInboundRules'; 

DROP VIEW IF EXISTS vifirewall_outbound_rules;
CREATE VIEW vifirewall_outbound_rules AS 
SELECT
    json_extract(value, '$.id') AS id,
    json_extract(value, '$.title') AS title,
    json_extract(value, '$.category') AS category,
    json_extract(value, '$.from_id') AS from_id,
    json_extract(value, '$.to_id') AS to_id
FROM
    uniform_resource,
    json_each(content)
WHERE
     uri = 'steampipeListDoFirewallOutboundRules';

DROP VIEW IF EXISTS vifirewall;
CREATE VIEW vifirewall AS 
   SELECT
    json_extract(value, '$.firewalls') AS firewalls,
    json_extract(value, '$.status') AS status
    FROM
    uniform_resource,
    json_each(content)
    WHERE
     uri = 'steampipeListDoFirewalls';


DROP VIEW IF EXISTS viopen_github_tickets;
CREATE VIEW viopen_github_tickets AS 
SELECT 
    i.issue_number AS Issues,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM 
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN 
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN 
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE 
    p.name="suite.opsfolio.com" AND i.state="OPEN";

DROP VIEW IF EXISTS viclosed_github_tickets;
CREATE VIEW  viclosed_github_tickets AS 
SELECT 
    i.issue_number AS Issues,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM 
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN 
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN 
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id
WHERE 
    p.name="suite.opsfolio.com" AND i.state="CLOSED"; 

DROP VIEW IF EXISTS viopen_github_tickets_polyglot;
CREATE VIEW  viopen_github_tickets_polyglot AS 
SELECT 
    i.issue_number AS Issues,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM 
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN 
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN 
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id 
WHERE 
    p.name="polyglot-prime" AND i.state="OPEN";

DROP VIEW IF EXISTS viclosed_github_tickets_polyglot;
CREATE VIEW  viclosed_github_tickets_polyglot AS 
SELECT 
    i.issue_number AS Issues,
    i.title,
    i.url,
    i.body AS Description,
    i.state,
    i.created_at,
    i.updated_at,
    u.login AS assigned_to
FROM 
    ur_ingest_session_plm_acct_project_issue AS i
LEFT JOIN 
    ur_ingest_session_plm_user AS u ON i.assigned_to = u.ur_ingest_session_plm_user_id
JOIN 
    ur_ingest_session_plm_acct_project AS p ON p.ur_ingest_session_plm_acct_project_id = i.ur_ingest_session_plm_acct_project_id 
WHERE 
    p.name="polyglot-prime" AND i.state="CLOSED";

/* 'orchestrateStatefulPolicySQL' in '[object Object]' returned type undefined instead of string | string[] | SQLa.SqlTextSupplier */
-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.

DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS
SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    '/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content](/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    tbl.sql as sql_ddl
FROM sqlite_master tbl
JOIN pragma_table_info(tbl.name) col
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with view-specific information
DROP VIEW IF EXISTS console_information_schema_view;
CREATE VIEW console_information_schema_view AS
SELECT
    vw.name AS view_name,
    col.name AS column_name,
    col.type AS data_type,
    '/console/info-schema/view.sql?name=' || vw.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](/console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](/console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content](/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    vw.sql as sql_ddl
FROM sqlite_master vw
JOIN pragma_table_info(vw.name) col
WHERE vw.type = 'view' AND vw.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS console_content_tabular;
CREATE VIEW console_content_tabular AS
  SELECT 'table' as tabular_nature,
         table_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_table
  UNION ALL
  SELECT 'view' as tabular_nature,
         view_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_view;

-- Populate the table with table column foreign keys
DROP VIEW IF EXISTS console_information_schema_table_col_fkey;
CREATE VIEW console_information_schema_table_col_fkey AS
SELECT
    tbl.name AS table_name,
    f."from" AS column_name,
    f."from" || ' references ' || f."table" || '.' || f."to" AS foreign_key
FROM sqlite_master tbl
JOIN pragma_foreign_key_list(tbl.name) f
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with table column indexes
DROP VIEW IF EXISTS console_information_schema_table_col_index;
CREATE VIEW console_information_schema_table_col_index AS
SELECT
    tbl.name AS table_name,
    pi.name AS column_name,
    idx.name AS index_name
FROM sqlite_master tbl
JOIN pragma_index_list(tbl.name) idx
JOIN pragma_index_info(idx.name) pi
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Drop and create the table for storing navigation entries
-- for testing only: DROP TABLE IF EXISTS sqlpage_aide_navigation;
CREATE TABLE IF NOT EXISTS sqlpage_aide_navigation (
    path TEXT NOT NULL, -- the "primary key" within namespace
    caption TEXT NOT NULL, -- for human-friendly general-purpose name
    namespace TEXT NOT NULL, -- if more than one navigation tree is required
    parent_path TEXT, -- for defining hierarchy
    sibling_order INTEGER, -- orders children within their parent(s)
    url TEXT, -- for supplying links, if different from path
    title TEXT, -- for full titles when elaboration is required, default to caption if NULL
    abbreviated_caption TEXT, -- for breadcrumbs and other "short" form, default to caption if NULL
    description TEXT, -- for elaboration or explanation
    elaboration TEXT, -- optional attributes for e.g. { "target": "__blank" }
    -- TODO: figure out why Rusqlite does not allow this but sqlite3 does
    -- CONSTRAINT fk_parent_path FOREIGN KEY (namespace, parent_path) REFERENCES sqlpage_aide_navigation(namespace, path),
    CONSTRAINT unq_ns_path UNIQUE (namespace, parent_path, path)
);
DELETE FROM sqlpage_aide_navigation WHERE path LIKE '/console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE '/';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', NULL, 1, '/', '/', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)', NULL),
    ('prime', '/', 999, '/console', '/console/', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files', NULL),
    ('prime', '/console', 1, '/console/info-schema', '/console/info-schema/', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', '/console', 3, '/console/sqlpage-files', '/console/sqlpage-files/', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI', NULL),
    ('prime', '/console', 3, '/console/sqlpage-files/content.sql', '/console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables', NULL),
    ('prime', '/console', 3, '/console/sqlpage-nav', '/console/sqlpage-nav/', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table', NULL),
    ('prime', '/console', 2, '/console/notebooks', '/console/notebooks/', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;

INSERT OR REPLACE INTO code_notebook_cell (notebook_kernel_id, code_notebook_cell_id, notebook_name, cell_name, interpretable_code, interpretable_code_hash, description) VALUES (
  'SQL',
  'web-ui.auto_generate_console_content_tabular_sqlpage_files',
  'Web UI',
  'auto_generate_console_content_tabular_sqlpage_files',
  '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title, ''''/'''' AS link;
              SELECT ''''Console'''' as title, ''''/console'''' AS link;
              SELECT ''''Content'''' as title, ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows',
  'TODO',
  'A series of idempotent INSERT statements which will auto-generate "default" content for all tables and views'
);
      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in '*.auto.sql' with redirects
      DELETE FROM sqlpage_files WHERE path like 'console/content/table/%.auto.sql';
      DELETE FROM sqlpage_files WHERE path like 'console/content/view/%.auto.sql';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql',
            'SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

              SELECT ''breadcrumb'' AS component;
              SELECT ''Home'' as title, ''/'' AS link;
              SELECT ''Console'' as title, ''/console'' AS link;
              SELECT ''Content'' as title, ''/console/content'' AS link;
              SELECT ''' || tabular_name  || ' ' || tabular_nature || ''' as title, ''#'' AS link;

              SELECT ''title'' AS component, ''' || tabular_name || ' (' || tabular_nature || ') Content'' as contents;

              SET total_rows = (SELECT COUNT(*) FROM ' || tabular_name || ');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''text'' AS component, ''' || info_schema_link_full_md || ''' AS contents_md
              SELECT ''text'' AS component,
                ''- Start Row: '' || $offset || ''
'' ||
                ''- Rows per Page: '' || $limit || ''
'' ||
                ''- Total Rows: '' || $total_rows || ''
'' ||
                ''- Current Page: '' || $current_page || ''
'' ||
                ''- Total Pages: '' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''table'' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM ' || tabular_name || '
            LIMIT $limit
            OFFSET $offset;

            SELECT ''text'' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
                ''(Page '' || $current_page || '' of '' || $total_pages || '') '' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
                AS contents_md;'
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.sql',
            'SELECT ''redirect'' AS component, ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component, ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like '/fhir%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', '/', 1, '/ur', '/ur/', 'Uniform Resource', NULL, NULL, 'Explore ingested resources', NULL),
    ('prime', '/ur', 99, '/ur/info-schema.sql', '/ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects', NULL),
    ('prime', '/ur', 1, '/ur/uniform-resource-files.sql', '/ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
DROP VIEW IF EXISTS uniform_resource_file;
CREATE VIEW uniform_resource_file AS
  SELECT ur.uniform_resource_id,
         ur.nature,
         p.root_path AS source_path,
         pe.file_path_rel,
         ur.size_bytes
  FROM uniform_resource ur
  LEFT JOIN ur_ingest_session_fs_path p ON ur.ingest_fs_path_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id
  WHERE ur.ingest_fs_path_id IS NOT NULL;
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', '/', 1, '/orchestration', '/orchestration/', 'Orchestration', NULL, NULL, 'Explore details about all orchestration', NULL),
    ('prime', '/orchestration', 99, '/orchestration/info-schema.sql', '/orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
 DROP VIEW IF EXISTS orchestration_session_by_device;
 CREATE VIEW orchestration_session_by_device AS
 SELECT
     d.device_id,
     d.name AS device_name,
     COUNT(*) AS session_count
 FROM orchestration_session os
 JOIN device d ON os.device_id = d.device_id
 GROUP BY d.device_id, d.name;

 DROP VIEW IF EXISTS orchestration_session_duration;
 CREATE VIEW orchestration_session_duration AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     os.orch_started_at,
     os.orch_finished_at,
     (JULIANDAY(os.orch_finished_at) - JULIANDAY(os.orch_started_at)) * 24 * 60 * 60 AS duration_seconds
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 WHERE os.orch_finished_at IS NOT NULL;

 DROP VIEW IF EXISTS orchestration_success_rate;
 CREATE VIEW orchestration_success_rate AS
 SELECT
     onature.nature AS orchestration_nature,
     COUNT(*) AS total_sessions,
     SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS successful_sessions,
     (CAST(SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_state oss ON os.orchestration_session_id = oss.session_id
 WHERE oss.to_state IN ('surveilr_orch_completed', 'surveilr_orch_failed') -- Consider other terminal states if applicable
 GROUP BY onature.nature;

 DROP VIEW IF EXISTS orchestration_session_script;
 CREATE VIEW orchestration_session_script AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     COUNT(*) AS script_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_entry ose ON os.orchestration_session_id = ose.session_id
 GROUP BY os.orchestration_session_id, onature.nature;

 DROP VIEW IF EXISTS orchestration_executions_by_type;
 CREATE VIEW orchestration_executions_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS execution_count
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_execution_success_rate_by_type;
 CREATE VIEW orchestration_execution_success_rate_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS total_executions,
     SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS successful_executions,
     (CAST(SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_session_summary;
 CREATE VIEW orchestration_session_summary AS
 SELECT
     issue_type,
     COUNT(*) AS issue_count
 FROM orchestration_session_issue
 GROUP BY issue_type;

 DROP VIEW IF EXISTS orchestration_issue_remediation;
 CREATE VIEW orchestration_issue_remediation AS
 SELECT
     orchestration_session_issue_id,
     issue_type,
     issue_message,
     remediation
 FROM orchestration_session_issue
 WHERE remediation IS NOT NULL;

DROP VIEW IF EXISTS orchestration_logs_by_session;
 CREATE VIEW orchestration_logs_by_session AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     osl.category,
     COUNT(*) AS log_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_exec ose ON os.orchestration_session_id = ose.session_id
 JOIN orchestration_session_log osl ON ose.orchestration_session_exec_id = osl.parent_exec_id
 GROUP BY os.orchestration_session_id, onature.nature, osl.category;
-- delete all /ip-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like '/opsfolio/info/policy%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', '/', 1, '/opsfolio', '/opsfolio/', 'Opsfolio', NULL, NULL, 'Opsfolio', NULL),
    ('prime', '/opsfolio', 2, '/opsfolio/info/policy/policy_dashboard.sql', '/opsfolio/info/policy/policy_dashboard.sql', 'Information Assurance Policies', NULL, NULL, 'The Information Assurance Policies is designed to display and create views for policies
        specific to tenants within the Opsfolio platform. These policies are ingested
        from Markdown (.md) or Markdown with JSX (.mdx) files, originating from
        Opsfolio, and are stored in the uniform_resource table.', NULL),
    ('prime', '/opsfolio', 3, '/opsfolio/info/policy/policy.sql', '/opsfolio/info/policy/policy.sql', 'Policies', NULL, NULL, NULL, NULL),
    ('prime', '/opsfolio', 3, '/opsfolio/info/policy/evidence.sql', '/opsfolio/info/policy/evidence.sql', 'Evidences', NULL, NULL, NULL, NULL),
    ('prime', '/opsfolio', 4, '/opsfolio/info/policy/policy_list.sql', '/opsfolio/info/policy/policy_list.sql', 'Policy List', NULL, NULL, NULL, NULL),
    ('prime', '/opsfolio', 5, '/opsfolio/info/policy/policy_inner_list.sql', '/opsfolio/info/policy/policy_inner_list.sql', 'Policy Inner List', NULL, NULL, NULL, NULL),
    ('prime', '/opsfolio', 6, '/opsfolio/info/policy/policy_detail.sql', '/opsfolio/info/policy/policy_detail.sql', 'Policy Detail', NULL, NULL, NULL, NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Resource Surveillance State Database (RSSD)",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/surveilr-icon.png",
  "image": "https://www.surveilr.com/assets/brand/surveilr-icon.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "/",
  "menu_item": [
    {
      "link": "/",
      "title": "Home"
    }
  ],
  "javascript": [
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT ''shell'' AS component,
       ''Resource Surveillance State Database (RSSD)'' AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/surveilr-icon.png'' AS favicon,
       ''https://www.surveilr.com/assets/brand/surveilr-icon.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''/'' AS link,
       ''{"link":"/","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       json_object(
              ''link'', ''/ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/ur''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', ''/console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/console''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', ''/orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/orchestration''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || ''](/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), 2) || '')'' as footer;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''list'' AS component;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path = ''/console''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/console''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Tables'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || table_name || ''](table.sql?name='' || table_name || '')'' AS "Table",
    COUNT(column_name) AS "Column Count",
    content_web_ui_link_abbrev_md as "Content"
FROM console_information_schema_table
GROUP BY table_name;

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || view_name || ''](view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    content_web_ui_link_abbrev_md as "Content"
FROM console_information_schema_view
GROUP BY view_name;

SELECT ''title'' AS component, ''Migrations'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT from_state, to_state, transition_reason, transitioned_at
FROM code_notebook_state
ORDER BY transitioned_at;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/table.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' Table'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type",
    is_primary_key AS "PK",
    is_not_null AS "Required",
    default_value AS "Default"
FROM console_information_schema_table
WHERE table_name = $name;

SELECT ''title'' AS component, ''Foreign Keys'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    foreign_key AS "Foreign Key"
FROM console_information_schema_table_col_fkey
WHERE table_name = $name;

SELECT ''title'' AS component, ''Indexes'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    index_name AS "Index Name"
FROM console_information_schema_table_col_index
WHERE table_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/view.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type"
FROM console_information_schema_view
WHERE view_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/sqlpage-file.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              
      SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT $path || '' Path'' AS title, ''#'' AS link;

      SELECT ''title'' AS component, $path AS contents;
      SELECT ''text'' AS component,
             ''```sql
'' || (select contents FROM sqlpage_files where path = $path) || ''
```'' as contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/content.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql](/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql)
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%''
      AND NOT(path like ''console/content/%.auto.sql'')
      AND NOT(path like ''console/content/action%'')
ORDER BY path;

SELECT ''title'' AS component, ''Auto-generated "default" content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%.auto.sql''
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/content/action/regenerate-auto.sql',
      '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title, ''''/'''' AS link;
              SELECT ''''Console'''' as title, ''''/console'''' AS link;
              SELECT ''''Content'''' as title, ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, $redirect as link WHERE $redirect is NOT NULL;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-nav/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-nav''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage navigation in sqlpage_aide_navigation table'' AS contents;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT path, caption, description FROM sqlpage_aide_navigation ORDER BY namespace, parent_path, path, sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/notebooks''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
       ''['' || c.cell_name || ''](notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
       c.description,
       k.kernel_name as kernel
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/console/notebooks''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/ur''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path = ''/ur''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/ur''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
    ''['' || table_name || ''](/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''ur_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-files.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/ur/uniform-resource-files.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
      ''Uniform Resources'' AS title,
      "Size (bytes)" as align_right,
      TRUE AS sort,
      TRUE AS search,
      TRUE AS hover,
      TRUE AS striped_rows,
      TRUE AS small;
SELECT * FROM uniform_resource_file ORDER BY uniform_resource_id
 LIMIT $limit
OFFSET $offset;

SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/orchestration''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''/orchestration''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path = ''/orchestration''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
    ''['' || table_name || ''](/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              select
 ''card''             as component,
 3                 as columns;
  SELECT caption as title, COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND parent_path = ''/opsfolio'' AND sibling_order = 2
   ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/policy/policy_dashboard.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/policy_dashboard.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              select
 ''card''             as component,
 2                 as columns;
 select
"Policies" as title,
 ''arrow-big-right''       as icon,
 ''/opsfolio/info/policy/policy.sql'' as link;
  select
"Evidences" as title,
 ''arrow-big-right''       as icon,
 ''/opsfolio/info/policy/evidence.sql'' as link;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/policy/policy.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/policy.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              select
 ''card''             as component,
 3                 as columns;
 select
 UPPER(SUBSTR(title, 1, 1)) || LOWER(SUBSTR(title, 2)) as title,
 ''arrow-big-right''       as icon,
 ''/opsfolio/info/policy/policy_list.sql?segment='' || segment || '''' as link
 FROM policy_dashboard;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/policy/evidence.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/evidence.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              
    select
     ''card''             as component,
     3                 as columns;
     select
''card''             as component,
3                 as columns;
SELECT
A.title as title,
''arrow-big-right''       as icon,
replace(b.path, ''opsfolio/info/policy/'', '''')as link
FROM vigetallviews A
inner join sqlpage_files b on A.path=b.path
 where a.used_path=0;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/policy/policy_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/policy_list.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/policy_list.sql'') as contents;
    ;
    select
  ''card''             as component,
  1 as columns;
select
    title,
    ''arrow-big-right''       as icon,
    ''/opsfolio/info/policy/policy_detail.sql?id='' || uniform_resource_id || '''' as link
    FROM policy_list WHERE parentfolder = $segment::TEXT AND segment1=""

    UNION ALL

    SELECT
      REPLACE(segment1, ''-'', '' '') as title,
      ''chevrons-down'' as icon,
      ''/opsfolio/info/policy/policy_inner_list.sql?parentfolder='' || parentfolder || ''&segment='' || segment1  as link
  FROM
      policy_list
  WHERE
      parentfolder = $segment::TEXT
      AND segment1 != ''''
  GROUP BY
      segment1
    ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/policy/policy_inner_list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/policy_inner_list.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/policy_inner_list.sql'') as contents;
    ;
    select
  ''card''             as component,
  1 as columns;
select
    title,
    ''arrow-big-right''       as icon,
    ''/opsfolio/info/policy/policy_detail.sql?id='' || uniform_resource_id || '''' as link
    FROM policy_list WHERE parentfolder = $parentfolder::TEXT AND segment1= $segment::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/policy/policy_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/policy/policy_detail.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              
select ''card'' as component,
1      as columns;
  SELECT  json_extract(content_fm_body_attrs, ''$.attrs.title'') AS title,
json_extract(content_fm_body_attrs, ''$.body'') AS description_md
FROM policy_detail WHERE uniform_resource_id = $id::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
