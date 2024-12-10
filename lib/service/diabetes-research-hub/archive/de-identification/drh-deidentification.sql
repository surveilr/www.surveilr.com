
--BEGIN;

-- Perform De-identification
UPDATE uniform_resource_investigator
SET email = surveilr_anonymize_email(email)
WHERE email IS NOT NULL;

UPDATE uniform_resource_author
SET email = surveilr_anonymize_email(email)
WHERE email IS NOT NULL;


-- Create a temporary table
DROP VIEW IF EXISTS temp_session_info;
CREATE TEMP VIEW temp_session_info AS
SELECT
    orchestration_session_id,
    (SELECT orchestration_session_entry_id FROM orchestration_session_entry WHERE session_id = orchestration_session_id LIMIT 1) AS orchestration_session_entry_id
FROM orchestration_session where orchestration_nature_id ='deidentification'
LIMIT 1;



-- Insert into orchestration_session_exec for uniform_resource_investigator
INSERT OR IGNORE INTO orchestration_session_exec (
    orchestration_session_exec_id,
    exec_nature,
    session_id,
    session_entry_id,
    exec_code,
    exec_status,
    input_text,
    output_text,
    exec_error_text,
    narrative_md
)
SELECT
    'ORCHSESSEXID-' || ((SELECT COUNT(*) FROM orchestration_session_exec) + 1 ),
    'De-identification',
    s.orchestration_session_id,
    s.orchestration_session_entry_id,
    'UPDATE uniform_resource_investigator SET email = surveilr_anonymize_email(email) executed',
    'SUCCESS',
    'email column in uniform_resource_investigator',
    'De-identification completed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated' 
        ELSE NULL 
    END,
    'username in email is masked'
FROM temp_session_info s;

-- Insert into orchestration_session_exec for uniform_resource_author
INSERT OR IGNORE INTO orchestration_session_exec (
    orchestration_session_exec_id,
    exec_nature,
    session_id,
    session_entry_id,
    exec_code,
    exec_status,
    input_text,
    output_text,
    exec_error_text,
    narrative_md
)
SELECT
    'ORCHSESSEXID-' || ((SELECT COUNT(*) FROM orchestration_session_exec) + 1) ,
    'De-identification',
    s.orchestration_session_id,
    s.orchestration_session_entry_id,
    'UPDATE uniform_resource_author SET email = surveilr_anonymize_email(email) executed',
    'SUCCESS',
    'email column in uniform_resource_author',
    'De-identification completed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated' 
        ELSE NULL 
    END,
    'username in email is masked'
FROM temp_session_info s;

-- Update orchestration_session to set finished timestamp and diagnostics
UPDATE orchestration_session
SET 
    orch_finished_at = CURRENT_TIMESTAMP,
    diagnostics_json = '{"status": "completed"}',
    diagnostics_md = 'De-identification process completed'
WHERE orchestration_session_id = (SELECT orchestration_session_id FROM temp_session_info LIMIT 1);

