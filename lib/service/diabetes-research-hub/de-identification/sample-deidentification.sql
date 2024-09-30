-- BEGINNING OF THE SCRIPT

-- **Perform De-identification on Email Addresses**
-- Update the 'uniform_resource_investigator' table by anonymizing email addresses.
-- Only non-null email addresses are processed.
UPDATE uniform_resource_investigator
SET email = anonymize_email(email)  -- Anonymize the email addresses.
WHERE email IS NOT NULL;           -- Process only rows where email is not null.

-- Similarly, update the 'uniform_resource_author' table.
UPDATE uniform_resource_author
SET email = anonymize_email(email)  -- Anonymize the email addresses.
WHERE email IS NOT NULL;           -- Process only rows where email is not null.

-- **Create a Temporary Table for Session Information**
-- Drop the temporary view if it already exists to avoid conflicts.
DROP VIEW IF EXISTS temp_session_info;

-- Create a new temporary view to store session information.
CREATE TEMP VIEW temp_session_info AS
SELECT
    orchestration_session_id,  -- ID of the orchestration session.
    (SELECT orchestration_session_entry_id FROM orchestration_session_entry WHERE session_id = orchestration_session_id LIMIT 1) AS orchestration_session_entry_id
    -- Retrieve the session entry ID associated with the orchestration session ID.
FROM orchestration_session 
WHERE orchestration_nature_id = 'deidentification'  -- Filter sessions related to de-identification.
LIMIT 1;  -- Limit to the first result for simplicity.

-- **Log Execution Details in orchestration_session_exec Table**

-- Insert a new record into 'orchestration_session_exec' for the 'uniform_resource_investigator' de-identification process.
INSERT OR IGNORE INTO orchestration_session_exec (
    orchestration_session_exec_id,  -- Unique ID for this execution record.
    exec_nature,                    -- Nature of the execution (e.g., 'De-identification').
    session_id,                     -- ID of the orchestration session.
    session_entry_id,              -- ID of the session entry.
    exec_code,                     -- Description of the executed code.
    exec_status,                   -- Status of the execution (e.g., 'SUCCESS').
    input_text,                    -- Input text or context related to the execution.
    output_text,                   -- Output text or result of the execution.
    exec_error_text,              -- Error text if any issues occurred.
    narrative_md                   -- Narrative or detailed description of the execution.
)
SELECT
    'ORCHSESSEXID-' || ((SELECT COUNT(*) FROM orchestration_session_exec) + 1 ),  -- Generate a new unique execution ID.
    'De-identification',  -- Execution nature.
    s.orchestration_session_id,  -- Session ID from temporary view.
    s.orchestration_session_entry_id,  -- Session entry ID from temporary view.
    'UPDATE uniform_resource_investigator SET email = anonymize_email(email) executed',  -- Description of the executed code.
    'SUCCESS',  -- Status of the execution.
    'email column in uniform_resource_investigator',  -- Input context.
    'De-identification completed',  -- Output text.
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated'  -- If no rows were updated, log this message.
        ELSE NULL  -- No error text if rows were updated.
    END,
    'username in email is masked'  -- Narrative description.
FROM temp_session_info s;  -- Use session information from the temporary view.

-- Similarly, log execution details for 'uniform_resource_author'.
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
    'ORCHSESSEXID-' || ((SELECT COUNT(*) FROM orchestration_session_exec) + 1),  -- Generate a new unique execution ID.
    'De-identification',  -- Execution nature.
    s.orchestration_session_id,  -- Session ID from temporary view.
    s.orchestration_session_entry_id,  -- Session entry ID from temporary view.
    'UPDATE uniform_resource_author SET email = anonymize_email(email) executed',  -- Description of the executed code.
    'SUCCESS',  -- Status of the execution.
    'email column in uniform_resource_author',  -- Input context.
    'De-identification completed',  -- Output text.
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated'  -- If no rows were updated, log this message.
        ELSE NULL  -- No error text if rows were updated.
    END,
    'username in email is masked'  -- Narrative description.
FROM temp_session_info s;  -- Use session information from the temporary view.

-- **Update Orchestration Session with Completion Details**
-- Update the orchestration session to mark it as finished and add diagnostics.
UPDATE orchestration_session
SET 
    orch_finished_at = CURRENT_TIMESTAMP,  -- Set the finish timestamp to the current time.
    diagnostics_json = '{"status": "completed"}',  -- JSON diagnostics for status.
    diagnostics_md = 'De-identification process completed'  -- Markdown diagnostics for status.
WHERE orchestration_session_id = (SELECT orchestration_session_id FROM temp_session_info LIMIT 1);  -- Update the specific orchestration session.

-- END OF THE SCRIPT
