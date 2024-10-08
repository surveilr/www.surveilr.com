
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