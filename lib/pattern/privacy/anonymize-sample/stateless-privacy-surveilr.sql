-- Drop and recreate the device_data view
DROP VIEW IF EXISTS device_data;
CREATE VIEW device_data AS
SELECT device_id, name, created_at
FROM device d;

-- Drop and recreate the number_of_files_converted view
DROP VIEW IF EXISTS number_of_files_converted;
CREATE VIEW number_of_files_converted AS
SELECT COUNT(*) AS file_count
FROM uniform_resource
WHERE content_digest != '-';

-- Drop and recreate the converted_files_list view
DROP VIEW IF EXISTS converted_files_list;
CREATE VIEW converted_files_list AS
SELECT file_basename
FROM ur_ingest_session_fs_path_entry
WHERE file_extn IN ('csv', 'xls', 'xlsx', 'json','html');


-- Drop and recreate the converted_table_list view
DROP VIEW IF EXISTS converted_table_list;
CREATE VIEW converted_table_list AS
SELECT tbl_name AS table_name
FROM sqlite_master
WHERE type = 'table'
  AND name LIKE 'uniform_resource%'
  AND name != 'uniform_resource_transform'
  AND name != 'uniform_resource';

-- Drop and recreate the uniform_resource_study_nature view
DROP VIEW IF EXISTS uniform_resource_study_nature;
CREATE VIEW uniform_resource_study_nature AS
SELECT
    json_extract(elaboration, '$.uniform_resource_id') AS uniform_resource_id,
    json_extract(elaboration, '$.new_table') AS new_table,
    json_extract(elaboration, '$.from_nature') AS from_nature,
    json_extract(elaboration, '$.to_nature') AS to_nature
FROM uniform_resource_study;

-- Drop and recreate the orch_session_view view
DROP VIEW IF EXISTS orch_session_view;
CREATE VIEW orch_session_view AS
SELECT
    orchestration_session_id, device_id, orchestration_nature_id,
    version, orch_started_at, orch_finished_at,
    diagnostics_json, diagnostics_md
FROM orchestration_session;

-- Drop and recreate the orch_session_deidentifyview view
DROP VIEW IF EXISTS orch_session_deidentifyview;
CREATE VIEW orch_session_deidentifyview AS
SELECT
    orchestration_session_id, device_id, orchestration_nature_id,
    version, orch_started_at, orch_finished_at,
    diagnostics_json, diagnostics_md
FROM orchestration_session
WHERE orchestration_nature_id = 'deidentify';

-- Drop and recreate the orchestration_session_entry_view view
DROP VIEW IF EXISTS orchestration_session_entry_view;
CREATE VIEW orchestration_session_entry_view AS
SELECT
    orchestration_session_entry_id, session_id, ingest_src, ingest_table_name
FROM orchestration_session_entry;

-- Drop and recreate the orchestration_session_exec_view view
DROP VIEW IF EXISTS orchestration_session_exec_view;
CREATE VIEW orchestration_session_exec_view AS
SELECT
    orchestration_session_exec_id, exec_nature, session_id, session_entry_id,
    parent_exec_id, namespace, exec_identity, exec_code, exec_status,
    input_text, exec_error_text, output_text, output_nature, narrative_md
FROM orchestration_session_exec;

-- Drop and recreate the study_data view
DROP VIEW IF EXISTS study_data;
CREATE VIEW study_data AS
SELECT
    study_id, study_name, 'start_date', end_date, treatment_modalities,
    funding_source, nct_number, study_description
FROM uniform_resource_study
LIMIT 10;

-- Drop and recreate the cgmfilemetadata_view view
DROP VIEW IF EXISTS cgmfilemetadata_view;
CREATE VIEW cgmfilemetadata_view AS
SELECT
    metadata_id, devicename, device_id, source_platform, patient_id,
    file_name, 'file_format', file_upload_date, data_start_date,
    data_end_date, study_id
FROM uniform_resource_cgm_file_metadata
LIMIT 10;

-- Drop and recreate the author_data view
DROP VIEW IF EXISTS author_data;
CREATE VIEW author_data AS
SELECT
    author_id, name, email, investigator_id, study_id
FROM uniform_resource_author;

-- Drop and recreate the institution_data view
DROP VIEW IF EXISTS institution_data;
CREATE VIEW institution_data AS
SELECT
    institution_id, institution_name, city, state, country
FROM uniform_resource_institution;

-- Drop and recreate the investigator_data view
DROP VIEW IF EXISTS investigator_data;
CREATE VIEW investigator_data AS
SELECT
    investigator_id, investigator_name, email, institution_id, study_id
FROM uniform_resource_investigator;

-- Drop and recreate the lab_data view
DROP VIEW IF EXISTS lab_data;
CREATE VIEW lab_data AS
SELECT
    lab_id, lab_name, lab_pi, institution_id, study_id
FROM uniform_resource_lab;

-- Drop and recreate the participant_data view
DROP VIEW IF EXISTS participant_data;
CREATE VIEW participant_data AS
SELECT
    participant_id, study_id, site_id, diagnosis_icd, med_rxnorm,
    treatment_modality, gender, race_ethnicity, age, bmi, baseline_hba1c,
    diabetes_type, study_arm
FROM uniform_resource_participant;

-- Drop and recreate the publication_data view
DROP VIEW IF EXISTS publication_data;
CREATE VIEW publication_data AS
SELECT
    publication_id, publication_title, digital_object_identifier,
    publication_site, study_id
FROM uniform_resource_publication;

-- Drop and recreate the site_data view
DROP VIEW IF EXISTS site_data;
CREATE VIEW site_data AS
SELECT
    study_id, site_id, site_name, site_type
FROM uniform_resource_site;
