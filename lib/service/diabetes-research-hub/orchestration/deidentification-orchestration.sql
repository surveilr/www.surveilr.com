-- BEGIN TRANSACTION
--BEGIN;

-- Perform De-identification
-- Anonymize email addresses in the uniform_resource_investigator table
UPDATE uniform_resource_investigator
SET email = anonymize_email(email)
WHERE email IS NOT NULL;

-- Anonymize email addresses in the uniform_resource_author table
UPDATE uniform_resource_author
SET email = anonymize_email(email)
WHERE email IS NOT NULL;


CREATE TEMP VIEW IF NOT EXISTS device_info AS
SELECT device_id, name, created_at
FROM device d;


-- Insert into orchestration_nature only if it doesn't exist
INSERT OR IGNORE INTO orchestration_nature (
    orchestration_nature_id,
    nature,
    elaboration,
    created_at,
    created_by,
    updated_at,
    updated_by,
    deleted_at,
    deleted_by,
    activity_log
) 
SELECT
    'deidentification',         -- Unique ID for the orchestration nature
    'De-identification',        -- Human-readable name for the orchestration nature
    NULL,                       -- No elaboration provided at insert time
    CURRENT_TIMESTAMP,          -- Timestamp of creation
    d.device_id,                  -- Creator's name
    NULL,                       -- No updated timestamp yet
    NULL,                       -- No updater yet
    NULL,                       -- Not deleted
    NULL,                       -- No deleter yet
    NULL                        -- No activity log yet
FROM device_info d
LIMIT 1;  -- Limiting to 1 device

-- Insert into orchestration_session only if it doesn't exist
INSERT OR IGNORE INTO orchestration_session (
    orchestration_session_id,
    device_id,
    orchestration_nature_id,
    version,
    orch_started_at,
    orch_finished_at,
    elaboration,
    args_json,
    diagnostics_json,
    diagnostics_md
)
SELECT
    'ORCHSESSID-' || hex(randomblob(16)),  -- Generate a random hex blob for orchestration_session_id
    d.device_id,                             -- Pull device_id from the device_info view
    'deidentification',                      -- Reference to the orchestration_nature_id we just inserted
    '',                                      -- Version (placeholder)
    CURRENT_TIMESTAMP,                       -- Start time
    NULL,                                    -- Finished time (to be updated later)
    NULL,                                    -- Elaboration (if any)
    NULL,                                    -- Args JSON (if any)
    NULL,                                    -- Diagnostics JSON (if any)
    NULL                                     -- Diagnostics MD (if any)
FROM device_info d
LIMIT 1;  -- Limiting to 1 device

-- Create a temporary view to retrieve orchestration session information
CREATE TEMP VIEW IF NOT EXISTS session_info AS
SELECT
    orchestration_session_id
FROM 
    orchestration_session
WHERE 
    orchestration_nature_id = 'deidentification'
LIMIT 1;

-- Insert into orchestration_session_entry only if it doesn't exist
INSERT OR IGNORE INTO orchestration_session_entry (
    orchestration_session_entry_id,
    session_id,
    ingest_src,
    ingest_table_name,
    elaboration
) VALUES (
    'ORCHSESSENID-' || hex(randomblob(16)),  -- Generate a random hex blob for orchestration_session_entry_id
    (SELECT orchestration_session_id FROM session_info limit 1),  -- Session ID from previous insert
    'deidentification-orchestration.sql',  -- Replace with actual ingest source
    '',  -- Placeholder for actual table name
    NULL  -- Elaboration (if any)
);

-- Create or replace a temporary view for session execution tracking
DROP VIEW IF EXISTS temp_session_info;  -- Remove any existing view
CREATE TEMP VIEW temp_session_info AS
SELECT
    orchestration_session_id,
    (SELECT orchestration_session_entry_id FROM orchestration_session_entry WHERE session_id = orchestration_session_id LIMIT 1) AS orchestration_session_entry_id
FROM orchestration_session 
WHERE orchestration_nature_id = 'deidentification'
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
    'ORCHSESSEXID-' || ((SELECT COUNT(*) FROM orchestration_session_exec) + 1),  -- Unique ID based on count
    'De-identification',                                -- Nature of execution
    s.orchestration_session_id,                         -- Session ID from the temp view
    s.orchestration_session_entry_id,                   -- Session Entry ID from the temp view
    'UPDATE uniform_resource_investigator SET email = anonymize_email(email) executed',  -- Description of the executed code
    'SUCCESS',                                          -- Execution status
    'email column in uniform_resource_investigator',   -- Input text reference
    'De-identification completed',                      -- Output text summary
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated'  -- Capture update status
        ELSE NULL 
    END,
    'username in email is masked'                       -- Narrative for clarification
FROM temp_session_info s;  -- From the temporary session info view

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
    'ORCHSESSEXID-' || ((SELECT COUNT(*) FROM orchestration_session_exec) + 1),  -- Unique ID based on count
    'De-identification',                                -- Nature of execution
    s.orchestration_session_id,                         -- Session ID from the temp view
    s.orchestration_session_entry_id,                   -- Session Entry ID from the temp view
    'UPDATE uniform_resource_author SET email = anonymize_email(email) executed',  -- Description of the executed code
    'SUCCESS',                                          -- Execution status
    'email column in uniform_resource_author',          -- Input text reference
    'De-identification completed',                      -- Output text summary
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated'  -- Capture update status
        ELSE NULL 
    END,
    'username in email is masked'                       -- Narrative for clarification
FROM temp_session_info s;  -- From the temporary session info view

-- Update orchestration_session to set finished timestamp and diagnostics
UPDATE orchestration_session
SET 
    orch_finished_at = CURRENT_TIMESTAMP,             -- Set the finish time
    diagnostics_json = '{"status": "completed"}',     -- Diagnostics status in JSON format
    diagnostics_md = 'De-identification process completed'  -- Markdown summary
WHERE orchestration_session_id = (SELECT orchestration_session_id FROM temp_session_info LIMIT 1);  -- Update the session identified in the temp view

-- COMMIT TRANSACTION
--COMMIT;
