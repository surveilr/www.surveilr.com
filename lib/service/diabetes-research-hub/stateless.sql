-- Drop and recreate the device view
DROP VIEW IF EXISTS drh_device;
CREATE VIEW drh_device AS
SELECT device_id, name, created_at
FROM device d;

-- Drop and recreate the number_of_files_converted view
DROP VIEW IF EXISTS drh_number_of_files_converted;
CREATE VIEW drh_number_of_files_converted AS
SELECT COUNT(*) AS file_count
FROM uniform_resource
WHERE content_digest != '-';

-- Drop and recreate the converted_files_list view
DROP VIEW IF EXISTS drh_converted_files_list;
CREATE VIEW drh_converted_files_list AS
SELECT file_basename
FROM ur_ingest_session_fs_path_entry
WHERE file_extn IN ('csv', 'xls', 'xlsx', 'json','html');

-- Drop and recreate the converted_table_list view
DROP VIEW IF EXISTS drh_converted_table_list;
CREATE VIEW drh_converted_table_list AS
SELECT tbl_name AS table_name
FROM sqlite_master
WHERE type = 'table'
  AND name LIKE 'uniform_resource%'
  AND name != 'uniform_resource_transform'
  AND name != 'uniform_resource';


-- Drop and recreate the orch_session_view view
DROP VIEW IF EXISTS drh_orch_session_view;
CREATE VIEW drh_orch_session_view AS
SELECT
    orchestration_session_id, device_id, orchestration_nature_id,
    version, orch_started_at, orch_finished_at,
    diagnostics_json, diagnostics_md
FROM orchestration_session;

-- Drop and recreate the orch_session_deidentifyview view
DROP VIEW IF EXISTS drh_orch_session_deidentifyview;
CREATE VIEW drh_orch_session_deidentifyview AS
SELECT
    orchestration_session_id, device_id, orchestration_nature_id,
    version, orch_started_at, orch_finished_at,
    diagnostics_json, diagnostics_md
FROM orchestration_session
WHERE orchestration_nature_id = 'deidentification';

-- Drop and recreate the orchestration_session_entry_view view
DROP VIEW IF EXISTS drh_orchestration_session_entry_view;
CREATE VIEW drh_orchestration_session_entry_view AS
SELECT
    orchestration_session_entry_id, session_id, ingest_src, ingest_table_name
FROM orchestration_session_entry;

-- Drop and recreate the orchestration_session_exec_view view
DROP VIEW IF EXISTS drh_orchestration_session_exec_view;
CREATE VIEW drh_orchestration_session_exec_view AS
SELECT
    orchestration_session_exec_id, exec_nature, session_id, session_entry_id,
    parent_exec_id, namespace, exec_identity, exec_code, exec_status,
    input_text, exec_error_text, output_text, output_nature, narrative_md
FROM orchestration_session_exec;

-- Drop and recreate the study view
DROP VIEW IF EXISTS drh_study;
CREATE VIEW drh_study AS
SELECT
    study_id, study_name, start_date, end_date, treatment_modalities,
    funding_source, nct_number, study_description
FROM uniform_resource_study;


-- Drop and recreate the cgmfilemetadata_view view
DROP VIEW IF EXISTS drh_cgmfilemetadata_view;
CREATE VIEW drh_cgmfilemetadata_view AS
SELECT
    metadata_id, devicename, device_id, source_platform, patient_id,
    file_name, file_format, file_upload_date, data_start_date,
    data_end_date, study_id
FROM uniform_resource_cgm_file_metadata;

-- Drop and recreate the author view
DROP VIEW IF EXISTS drh_author;
CREATE VIEW drh_author AS
SELECT
    author_id, name, email, investigator_id, study_id
FROM uniform_resource_author;

-- Drop and recreate the institution view
DROP VIEW IF EXISTS drh_institution;
CREATE VIEW drh_institution AS
SELECT
    institution_id, institution_name, city, state, country
FROM uniform_resource_institution;

-- Drop and recreate the investigator view
DROP VIEW IF EXISTS drh_investigator;
CREATE VIEW drh_investigator AS
SELECT
    investigator_id, investigator_name, email, institution_id, study_id
FROM uniform_resource_investigator;

-- Drop and recreate the lab view
DROP VIEW IF EXISTS drh_lab;
CREATE VIEW drh_lab AS
SELECT
    lab_id, lab_name, lab_pi, institution_id, study_id
FROM uniform_resource_lab;

-- Drop and recreate the participant view
DROP VIEW IF EXISTS drh_participant;
CREATE VIEW drh_participant AS
SELECT
    participant_id, study_id, site_id, diagnosis_icd, med_rxnorm,
    treatment_modality, gender, race_ethnicity, age, bmi, baseline_hba1c,
    diabetes_type, study_arm
FROM uniform_resource_participant;

-- Drop and recreate the publication view
DROP VIEW IF EXISTS drh_publication;
CREATE VIEW drh_publication AS
SELECT
    publication_id, publication_title, digital_object_identifier,
    publication_site, study_id
FROM uniform_resource_publication;

-- Drop and recreate the site view
DROP VIEW IF EXISTS drh_site;
CREATE VIEW drh_site AS
SELECT
    study_id, site_id, site_name, site_type
FROM uniform_resource_site;

-- SQLPage query to count tables matching the pattern 'uniform_resource_cgm_tracing%'
DROP VIEW IF EXISTS drh_number_of_cgm_tracing_files_view;
CREATE VIEW drh_number_of_cgm_tracing_files_view AS
SELECT COUNT(*) AS table_count
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_cgm_tracing%';

-- Drop and recreate the vw_orchestration_deidentify view
DROP VIEW IF EXISTS drh_vw_orchestration_deidentify;
CREATE VIEW drh_vw_orchestration_deidentify AS
SELECT
    osex.orchestration_session_exec_id,
    osex.exec_nature,
    osex.session_id,
    osex.session_entry_id,
    osex.parent_exec_id,
    osex.namespace,
    osex.exec_identity,
    osex.exec_code,
    osex.exec_status,
    osex.input_text,
    osex.exec_error_text,
    osex.output_text,
    osex.output_nature,
    osex.narrative_md,    
    os.device_id,
    os.orchestration_nature_id,
    os.version,
    os.orch_started_at,
    os.orch_finished_at,    
    os.args_json,
    os.diagnostics_json,
    os.diagnostics_md
FROM
    orchestration_session_exec osex
    JOIN orchestration_session os ON osex.session_id = os.orchestration_session_id
WHERE
    os.orchestration_nature_id = 'deidentification';

-- Create a view to display the files transformed
DROP VIEW IF EXISTS drh_vw_ingest_session_entries_status;
CREATE VIEW drh_vw_ingest_session_entries_status AS
SELECT
    isession.ur_ingest_session_id,
    isession.device_id,
    isession.behavior_id,
    isession.behavior_json,
    isession.ingest_started_at,
    isession.ingest_finished_at,
    isession.session_agent,    
    isession.created_at AS session_created_at,
    isession.created_by AS session_created_by,
    isession.updated_at AS session_updated_at,
    isession.updated_by AS session_updated_by,
    isession.deleted_at AS session_deleted_at,
    isession.deleted_by AS session_deleted_by,
    isession.activity_log AS session_activity_log,
    fspath.ur_ingest_session_fs_path_id,
    fspath.ingest_session_id AS fspath_ingest_session_id,
    fspath.root_path,    
    fspath.created_at AS fspath_created_at,
    fspath.created_by AS fspath_created_by,
    fspath.updated_at AS fspath_updated_at,
    fspath.updated_by AS fspath_updated_by,
    fspath.deleted_at AS fspath_deleted_at,
    fspath.deleted_by AS fspath_deleted_by,
    fspath.activity_log AS fspath_activity_log,
    entry.ur_ingest_session_fs_path_entry_id,
    entry.ingest_session_id AS entry_ingest_session_id,
    entry.ingest_fs_path_id,
    entry.uniform_resource_id,
    entry.file_path_abs,
    entry.file_path_rel_parent,
    entry.file_path_rel,
    entry.file_basename,
    entry.file_extn,
    entry.captured_executable,
    entry.ur_status,
    entry.ur_diagnostics,
    entry.ur_transformations,    
    entry.created_at AS entry_created_at,
    entry.created_by AS entry_created_by,
    entry.updated_at AS entry_updated_at,
    entry.updated_by AS entry_updated_by,
    entry.deleted_at AS entry_deleted_at,
    entry.deleted_by AS entry_deleted_by,
    entry.activity_log AS entry_activity_log
FROM
    ur_ingest_session isession
    JOIN ur_ingest_session_fs_path fspath ON isession.ur_ingest_session_id = fspath.ingest_session_id
    JOIN ur_ingest_session_fs_path_entry entry ON fspath.ur_ingest_session_fs_path_id = entry.ingest_fs_path_id;


DROP VIEW IF EXISTS drh_raw_cgm_table_lst;
CREATE VIEW drh_raw_cgm_table_lst AS
SELECT name, tbl_name as table_name
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_cgm_tracing%';

DROP VIEW IF EXISTS drh_number_cgm_count;
CREATE VIEW drh_number_cgm_count AS
SELECT count(*) as number_of_cgm_raw_files
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_cgm_tracing%';


-- DROP VIEW IF EXISTS drh_participant_file_names;
-- CREATE VIEW IF NOT EXISTS drh_participant_file_names AS
-- SELECT
--   patient_id,
--   GROUP_CONCAT(file_name, ', ') AS file_names
-- FROM
--   uniform_resource_cgm_file_metadata
-- GROUP BY
--   patient_id;

DROP VIEW IF EXISTS drh_study_vanity_metrics_details;
CREATE VIEW drh_study_vanity_metrics_details AS
SELECT s.study_id, 
       s.study_name, 
       s.study_description, 
       s.start_date, 
       s.end_date, 
       s.nct_number, 
       COUNT(DISTINCT p.participant_id) AS total_number_of_participants, 
       ROUND(AVG(p.age), 2) AS average_age, 
       (CAST(SUM(CASE WHEN p.gender = 'F' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS percentage_of_females, 
       GROUP_CONCAT(DISTINCT i.investigator_name) AS investigators 
FROM uniform_resource_study s 
LEFT JOIN uniform_resource_participant p ON s.study_id = p.study_id 
LEFT JOIN uniform_resource_investigator i ON s.study_id = i.study_id 
GROUP BY s.study_id, s.study_name, s.study_description, s.start_date, s.end_date, s.nct_number;


DROP TABLE IF EXISTS raw_cgm_lst_cached;
CREATE TABLE raw_cgm_lst_cached AS 
  SELECT * FROM drh_raw_cgm_table_lst;

DROP VIEW IF EXISTS drh_study_files_table_info;
CREATE VIEW IF NOT EXISTS drh_study_files_table_info AS
       SELECT ur.uniform_resource_id,
       ur.nature AS file_format,
       SUBSTR(pe.file_path_rel, INSTR(pe.file_path_rel, '/') + 1, INSTR(pe.file_path_rel, '.') - INSTR(pe.file_path_rel, '/') - 1) as file_name,
       'uniform_resource_' || SUBSTR(pe.file_path_rel, INSTR(pe.file_path_rel, '/') + 1, INSTR(pe.file_path_rel, '.') - INSTR(pe.file_path_rel, '/') - 1) AS table_name
FROM uniform_resource ur
LEFT JOIN ur_ingest_session_fs_path p ON ur.ingest_fs_path_id = p.ur_ingest_session_fs_path_id
LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id
WHERE ur.ingest_fs_path_id IS NOT NULL;


DROP VIEW IF EXISTS drh_vandv_orch_issues;
CREATE VIEW drh_vandv_orch_issues AS
SELECT    
    osi.issue_type as 'Issue Type',
    osi.issue_message as 'Issue Message',
    osi.issue_column as 'Issue column',
    osi.remediation,
    osi.issue_row as 'Issue Row',    
    osi.invalid_value  
FROM
    orchestration_session_issue osi
JOIN
    orchestration_session os
ON
    osi.session_id = os.orchestration_session_id
WHERE
    os.orchestration_nature_id = 'V&V';


DROP VIEW IF EXISTS drh_device_file_count_view;
CREATE VIEW drh_device_file_count_view AS
SELECT 
    devicename, 
    COUNT(DISTINCT file_name) AS number_of_files
FROM 
    uniform_resource_cgm_file_metadata
GROUP BY 
    devicename
ORDER BY 
    number_of_files DESC;


-------------Dynamically insert the sqlpages for CGM raw tables--------------------------

WITH raw_cgm_table_name AS (
    -- Select all table names
    SELECT table_name
    FROM drh_raw_cgm_table_lst
)
INSERT OR IGNORE INTO sqlpage_files (path, contents)
SELECT 
    'drh/cgm-data/raw-cgm/' || table_name||'.sql' AS path,
    '
    SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
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
    SELECT ''' || table_name || ''' || '' Table'' AS title, ''#'' AS link;
    
    SELECT ''title'' AS component, ''' || table_name || ''' AS contents;
    

    -- Initialize pagination
    SET total_rows = (SELECT COUNT(*) FROM ''' || table_name || ''');
    SET limit = COALESCE($limit, 50);
    SET offset = COALESCE($offset, 0);
    SET total_pages = ($total_rows + $limit - 1) / $limit;
    SET current_page = ($offset / $limit) + 1;

    -- Display table with pagination
    SELECT ''table'' AS component,
        TRUE AS sort,
        TRUE AS search;
    SELECT * FROM ''' || table_name || '''
    LIMIT $limit
    OFFSET $offset;    

    SELECT ''text'' AS component,
        (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
        ''(Page '' || $current_page || '' of '' || $total_pages || '')'' || '' '' ||
        (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
        AS contents_md;
    '
FROM raw_cgm_table_name;



