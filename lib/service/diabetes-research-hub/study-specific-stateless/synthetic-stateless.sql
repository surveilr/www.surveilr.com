

-- Perform De-identification
-- Anonymize email addresses in the uniform_resource_investigator table
UPDATE uniform_resource_investigator
SET email = surveilr_anonymize_email(email)
WHERE email IS NOT NULL;

-- Anonymize email addresses in the uniform_resource_author table
UPDATE uniform_resource_author
SET email = surveilr_anonymize_email(email)
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
    'stateless sql file',  -- Replace with actual ingest source
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
    'UPDATE uniform_resource_investigator SET email = surveilr_anonymize_email(email) executed',  -- Description of the executed code
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
    'UPDATE uniform_resource_author SET email = surveilr_anonymize_email(email) executed',  -- Description of the executed code
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


-----------------------------------------------------------------------------
-- Verification and validation process

-- Create a view that represents the expected schema with required columns and properties
CREATE VIEW IF NOT EXISTS expected_schema_view AS
SELECT 
'uniform_resource_institution' AS table_name, 'institution_id' AS column_name, 'TEXT' AS column_type, 1 AS is_primary_key, 1 AS not_null
UNION ALL SELECT 'uniform_resource_institution', 'institution_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_institution', 'city', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_institution', 'state', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_institution', 'country', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_institution', 'tenant_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_lab', 'lab_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_lab', 'lab_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_lab', 'lab_pi', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_lab', 'institution_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_lab', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_lab', 'tenant_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_study', 'study_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_study', 'study_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'start_date', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'end_date', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'treatment_modalities', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'funding_source', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'nct_number', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'study_description', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'tenant_id', 'TEXT', 0, 1


UNION ALL SELECT 'uniform_resource_participant', 'participant_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_participant', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'site_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'diagnosis_icd', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'med_rxnorm', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'treatment_modality', 'TEXT', 0, 0
UNION ALL SELECT 'uniform_resource_participant', 'gender', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'race_ethnicity', 'TEXT', 0, 0
UNION ALL SELECT 'uniform_resource_participant', 'age', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'bmi', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'baseline_hba1c', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'diabetes_type', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'study_arm', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_participant', 'tenant_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_site', 'site_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_site', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_site', 'site_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_site', 'site_type', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_site', 'tenant_id', 'TEXT', 0, 1


UNION ALL SELECT 'uniform_resource_investigator', 'investigator_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_investigator', 'investigator_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_investigator', 'email', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_investigator', 'institution_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_investigator', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_investigator', 'tenant_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_publication', 'publication_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_publication', 'publication_title', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_publication', 'digital_object_identifier', 'TEXT', 0, 0
UNION ALL SELECT 'uniform_resource_publication', 'publication_site', 'TEXT', 0, 0
UNION ALL SELECT 'uniform_resource_publication', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_publication', 'tenant_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_author', 'author_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_author', 'name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_author', 'email', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_author', 'investigator_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_author', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_author', 'tenant_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'metadata_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'devicename', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'device_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'source_platform', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'patient_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'file_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'file_format', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'file_upload_date', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'data_start_date', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'data_end_date', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'tenant_id', 'TEXT', 0, 1;

CREATE TEMP VIEW IF NOT EXISTS device_info AS
SELECT device_id, name, created_at
FROM device d;


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
    'V&V',                                   -- orchestration_nature_id (unique identifier)
    'Verification and Validation',           -- nature
    NULL,                                    -- elaboration
    CURRENT_TIMESTAMP,          -- Timestamp of creation
    d.device_id,                               -- created_by
    NULL,                                    -- updated_at
    NULL,                                    -- updated_by
    NULL,                                    -- deleted_at
    NULL,                                    -- deleted_by
    NULL                                     -- activity_log
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
    'V&V',                      -- Reference to the orchestration_nature_id we just inserted
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
    orchestration_nature_id = 'V&V'
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
    'dclp1-single-cgm-tracing.sql',  -- Replace with actual ingest source
    '',  -- Placeholder for actual table name
    NULL  -- Elaboration (if any)
);


-- Create or Replace Temp Session Info View
DROP VIEW IF EXISTS temp_session_info;
CREATE TEMP VIEW temp_session_info AS
SELECT
    orchestration_session_id,
    (SELECT orchestration_session_entry_id FROM orchestration_session_entry WHERE session_id = orchestration_session_id LIMIT 1) AS orchestration_session_entry_id
FROM orchestration_session 
WHERE orchestration_nature_id = 'V&V'
LIMIT 1;

-- Create or Replace Temp Schema Validation Missing Columns View
DROP VIEW IF EXISTS temp_SchemaValidationMissingColumns;
CREATE TEMP VIEW temp_SchemaValidationMissingColumns AS
SELECT 
    'Schema Validation: Missing Columns' AS heading,
    e.table_name,
    e.column_name,
    e.column_type,
    e.is_primary_key,
    'Missing column: ' || e.column_name || ' in table ' || e.table_name AS status,
    'Include the ' || e.column_name || ' in table ' || e.table_name AS remediation
FROM 
    expected_schema_view e
LEFT JOIN (
    SELECT 
        m.name AS table_name,
        p.name AS column_name,
        p.type AS column_type,
        p.pk AS is_primary_key
    FROM 
        sqlite_master m
    JOIN 
        pragma_table_info(m.name) p
    WHERE 
        m.type = 'table' AND
        m.name NOT LIKE 'uniform_resource_cgm_tracing%' AND
        m.name != 'uniform_resource_transform' AND 
        m.name LIKE 'uniform_resource_%'
) a ON e.table_name = a.table_name AND e.column_name = a.column_name
WHERE 
    a.column_name IS NULL;

--  Insert Operation into orchestration_session_issue Table
INSERT OR IGNORE INTO orchestration_session_issue (
    orchestration_session_issue_id, 
    session_id, 
    session_entry_id, 
    issue_type, 
    issue_message, 
    issue_row, 
    issue_column, 
    invalid_value, 
    remediation, 
    elaboration
)
SELECT 
    lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6))) AS orchestration_session_issue_id,
    tsi.orchestration_session_id,
    tsi.orchestration_session_entry_id,
    svc.heading AS issue_type,
    svc.status AS issue_message,
    NULL AS issue_row,
    svc.column_name AS issue_column,
    NULL AS invalid_value,
    svc.remediation,
    NULL AS elaboration
FROM 
    temp_SchemaValidationMissingColumns svc
JOIN 
    temp_session_info tsi ON 1=1;





DROP VIEW IF EXISTS temp_DataIntegrityInvalidDates;
CREATE TEMP VIEW temp_DataIntegrityInvalidDates AS
SELECT 
    'Data Integrity Checks: Invalid Dates' AS heading,
    table_name,
    column_name,
    value,
    'Dates must be in YYYY-MM-DD format: ' || value AS status,
    'The date value in column: ' || column_name || ' of table ' || table_name || ' does not follow the YYYY-MM-DD format. Please ensure the dates are in this format' AS remediation
FROM (
    SELECT 
        'uniform_resource_study' AS table_name,
        'start_date' AS column_name,
        start_date AS value
    FROM 
        uniform_resource_study
    WHERE 
        start_date IS NOT NULL AND start_date != ''
    
    UNION ALL
    
    SELECT 
        'uniform_resource_study' AS table_name,
        'end_date' AS column_name,
        end_date AS value
    FROM 
        uniform_resource_study
    WHERE 
        end_date IS NOT NULL AND end_date != ''
    
    UNION ALL
    
    SELECT 
        'uniform_resource_cgm_file_metadata' AS table_name,
        'file_upload_date' AS column_name,
        file_upload_date AS value
    FROM 
        uniform_resource_cgm_file_metadata
    WHERE 
        file_upload_date IS NOT NULL AND file_upload_date != ''
    
    UNION ALL
    
    SELECT 
        'uniform_resource_cgm_file_metadata' AS table_name,
        'data_start_date' AS column_name,
        data_start_date AS value
    FROM 
        uniform_resource_cgm_file_metadata
    WHERE 
        data_start_date IS NOT NULL AND data_start_date != ''
    
    UNION ALL
    
    SELECT 
        'uniform_resource_cgm_file_metadata' AS table_name,
        'data_end_date' AS column_name,
        data_end_date AS value
    FROM 
        uniform_resource_cgm_file_metadata
    WHERE 
        data_end_date IS NOT NULL AND data_end_date != ''
) 
WHERE 
    value NOT LIKE '____-__-__';


INSERT OR IGNORE INTO orchestration_session_issue (
    orchestration_session_issue_id, 
    session_id, 
    session_entry_id, 
    issue_type, 
    issue_message, 
    issue_row, 
    issue_column, 
    invalid_value, 
    remediation, 
    elaboration
)
SELECT 
    lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6))) AS orchestration_session_issue_id,
    tsi.orchestration_session_id,
    tsi.orchestration_session_entry_id,
    diid.heading AS issue_type,
    diid.status AS issue_message,
    NULL AS issue_row,
    diid.column_name AS issue_column,
    diid.value AS invalid_value,
    diid.remediation,
    NULL AS elaboration
FROM temp_DataIntegrityInvalidDates diid
JOIN 
    temp_session_info tsi ON 1=1;

-- Generate SQL for finding empty or NULL values in table

DROP VIEW IF EXISTS DataIntegrityEmptyCells;
CREATE TEMP VIEW DataIntegrityEmptyCells AS
    SELECT 
        'Data Integrity Checks: Empty Cells' AS heading,
        table_name,
        column_name,
        'The rows empty are:'|| GROUP_CONCAT(rowid) AS issue_row,  -- Concatenates row IDs with empty values
        'The following rows in column ' || column_name || ' of file ' || substr(table_name, 18) || ' are either NULL or empty.' AS status,
        'Please provide values for the ' || column_name || ' column in file ' || substr(table_name, 18) ||'.The Rows are:'|| GROUP_CONCAT(rowid) AS remediation
    FROM (
        
        SELECT 
            'uniform_resource_study' AS table_name,
            'study_id' AS column_name,
            study_id AS value,
            rowid
        FROM 
            uniform_resource_study  
        WHERE 
            study_id IS NULL OR study_id = ''

        UNION ALL

        SELECT 
            'uniform_resource_study' AS table_name,
            'study_name' AS column_name,
            study_name AS value,
            rowid
        FROM 
            uniform_resource_study  
        WHERE 
            study_name IS NULL OR study_name = ''

        UNION ALL

        SELECT 
            'uniform_resource_study' AS table_name,
            'start_date' AS column_name,
            start_date AS value,
            rowid
        FROM 
            uniform_resource_study  
        WHERE 
            start_date IS NULL OR start_date = ''
        
        UNION ALL
        
        
        SELECT 
            'uniform_resource_study' AS table_name,
            'end_date' AS column_name,
            end_date AS value,
            rowid
        FROM 
            uniform_resource_study 
        WHERE 
            end_date IS NULL OR end_date = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_study' AS table_name,
            'treatment_modalities' AS column_name,
            treatment_modalities AS value,
            rowid
        FROM 
            uniform_resource_study 
        WHERE 
            treatment_modalities IS NULL OR treatment_modalities = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_study' AS table_name,
            'funding_source' AS column_name,
            funding_source AS value,
            rowid
        FROM 
            uniform_resource_study 
        WHERE 
            funding_source IS NULL OR funding_source = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_study' AS table_name,
            'nct_number' AS column_name,
            nct_number AS value,
            rowid
        FROM 
            uniform_resource_study 
        WHERE 
            nct_number IS NULL OR nct_number = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_study' AS table_name,
            'study_description' AS column_name,
            study_description AS value,
            rowid
        FROM 
            uniform_resource_study 
        WHERE 
            study_description IS NULL OR study_description = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_study' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_study 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL



        --- uniform_resource_institution table

        SELECT 
            'uniform_resource_institution' AS table_name,
            'institution_id' AS column_name,
            institution_id AS value,
            rowid
        FROM 
            uniform_resource_institution 
        WHERE 
            institution_id IS NULL OR institution_id = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_institution' AS table_name,
            'institution_name' AS column_name,
            institution_name AS value,
            rowid
        FROM 
            uniform_resource_institution 
        WHERE 
            institution_name IS NULL OR institution_name = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_institution' AS table_name,
            'city' AS column_name,
            city AS value,
            rowid
        FROM 
            uniform_resource_institution 
        WHERE 
            city IS NULL OR city = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_institution' AS table_name,
            'state' AS column_name,
            state AS value,
            rowid
        FROM 
            uniform_resource_institution 
        WHERE 
            state IS NULL OR state = ''
        
        UNION ALL

         SELECT 
            'uniform_resource_institution' AS table_name,
            'country' AS column_name,
            country AS value,
            rowid
        FROM 
            uniform_resource_institution 
        WHERE 
            country IS NULL OR country = ''
        
        UNION ALL       
        
        SELECT 
            'uniform_resource_institution' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_institution 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL

        -- uniform_resource_site table

        SELECT 
            'uniform_resource_site' AS table_name,
            'site_id' AS column_name,
            site_id AS value,
            rowid
        FROM 
            uniform_resource_site  
        WHERE 
            site_id IS NULL OR site_id = ''
        
        UNION ALL
        

        SELECT 
            'uniform_resource_site' AS table_name,
            'study_id' AS column_name,
            study_id AS value,
            rowid
        FROM 
            uniform_resource_site  
        WHERE 
            study_id IS NULL OR study_id = ''
        
        UNION ALL


        SELECT 
            'uniform_resource_site' AS table_name,
            'site_name' AS column_name,
            site_name AS value,
            rowid
        FROM 
            uniform_resource_site  
        WHERE 
            site_name IS NULL OR site_name = ''
        
        UNION ALL

        
        SELECT 
            'uniform_resource_site' AS table_name,
            'site_type' AS column_name,
            site_type AS value,
            rowid
        FROM 
            uniform_resource_site  
        WHERE 
            site_type IS NULL OR site_type = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_site' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_site 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL    

        -- uniform_resource_lab table

        SELECT 
            'uniform_resource_lab' AS table_name,
            'lab_id' AS column_name,
            lab_id AS value,
            rowid
        FROM 
            uniform_resource_lab  
        WHERE 
            lab_id IS NULL OR lab_id = ''
        
        UNION ALL       

        SELECT 
            'uniform_resource_lab' AS table_name,
            'lab_name' AS column_name,
            lab_name AS value,
            rowid
        FROM 
            uniform_resource_lab  
        WHERE 
            lab_name IS NULL OR lab_name = ''
        
        UNION ALL      

         SELECT 
            'uniform_resource_lab' AS table_name,
            'lab_pi' AS column_name,
            lab_pi AS value,
            rowid
        FROM 
            uniform_resource_lab  
        WHERE 
            lab_pi IS NULL OR lab_pi = ''
        
        UNION ALL    

          SELECT 
            'uniform_resource_lab' AS table_name,
            'institution_id' AS column_name,
            institution_id AS value,
            rowid
        FROM 
            uniform_resource_lab  
        WHERE 
            institution_id IS NULL OR institution_id = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_lab' AS table_name,
            'study_id' AS column_name,
            study_id AS value,
            rowid
        FROM 
            uniform_resource_lab  
        WHERE 
            study_id IS NULL OR study_id = ''
        
        UNION ALL    


        SELECT 
            'uniform_resource_lab' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_lab 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL    
        

        -- uniform_resource_cgm_file_metadata 

        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'metadata_id' AS column_name,
            metadata_id AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            metadata_id IS NULL OR metadata_id = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'devicename' AS column_name,
            devicename AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            devicename IS NULL OR devicename = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'device_id' AS column_name,
            device_id AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            device_id IS NULL OR device_id = ''
        
        UNION ALL


        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'source_platform' AS column_name,
            source_platform AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            source_platform IS NULL OR source_platform = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'patient_id' AS column_name,
            patient_id AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            patient_id IS NULL OR patient_id = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'file_name' AS column_name,
            file_name AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            file_name IS NULL OR file_name = ''
        
        UNION ALL

        
        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'file_format' AS column_name,
            file_format AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            file_format IS NULL OR file_format = ''
        
        UNION ALL



        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'file_upload_date' AS column_name,
            file_upload_date AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            file_upload_date IS NULL OR file_upload_date = ''
        
        UNION ALL
        
        
        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'data_start_date' AS column_name,
            data_start_date AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata 
        WHERE 
            data_start_date IS NULL OR data_start_date = ''
        
        UNION ALL
        

        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'data_end_date' AS column_name,
            data_end_date AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata 
        WHERE 
            data_end_date IS NULL OR data_end_date = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'study_id' AS column_name,
            study_id AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata  
        WHERE 
            study_id IS NULL OR study_id = ''
        
        UNION ALL


        SELECT 
            'uniform_resource_cgm_file_metadata' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_cgm_file_metadata 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL    

        -- uniform_resource_investigator
        SELECT 
            'uniform_resource_investigator' AS table_name,
            'investigator_id' AS column_name,
            investigator_id AS value,
            rowid
        FROM 
            uniform_resource_investigator 
        WHERE 
            investigator_id IS NULL OR investigator_id = ''

        UNION ALL

        SELECT 
            'uniform_resource_investigator' AS table_name,
            'investigator_name' AS column_name,
            investigator_name AS value,
            rowid
        FROM 
            uniform_resource_investigator 
        WHERE 
            investigator_name IS NULL OR investigator_name = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_investigator' AS table_name,
            'email' AS column_name,
            email AS value,
            rowid
        FROM 
            uniform_resource_investigator 
        WHERE 
            email IS NULL OR email = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_investigator' AS table_name,
            'institution_id' AS column_name,
            institution_id AS value,
            rowid
        FROM 
            uniform_resource_investigator 
        WHERE 
            institution_id IS NULL OR institution_id = ''

        UNION ALL

        SELECT 
            'uniform_resource_investigator' AS table_name,
            'study_id' AS column_name,
            study_id AS value,
            rowid
        FROM 
            uniform_resource_investigator 
        WHERE 
            study_id IS NULL OR study_id = ''

        UNION ALL

        SELECT 
            'uniform_resource_investigator' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_investigator 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL    

        -- uniform_resource_publication table

        SELECT 
            'uniform_resource_publication' AS table_name,
            'publication_id' AS column_name,
            publication_id AS value,
            rowid
        FROM 
            uniform_resource_publication 
        WHERE 
            publication_id IS NULL OR publication_id = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_publication' AS table_name,
            'publication_title' AS column_name,
            publication_title AS value,
            rowid
        FROM 
            uniform_resource_publication 
        WHERE 
            publication_title IS NULL OR publication_title = ''

        UNION ALL

        SELECT 
            'uniform_resource_publication' AS table_name,
            'digital_object_identifier' AS column_name,
            digital_object_identifier AS value,
            rowid
        FROM 
            uniform_resource_publication 
        WHERE 
            digital_object_identifier IS NULL OR digital_object_identifier = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_publication' AS table_name,
            'publication_site' AS column_name,
            publication_site AS value,
            rowid
        FROM 
            uniform_resource_publication 
        WHERE 
            publication_site IS NULL OR publication_site = ''

        UNION ALL

        SELECT 
            'uniform_resource_publication' AS table_name,
            'study_id' AS column_name,
            study_id AS value,
            rowid
        FROM 
            uniform_resource_publication 
        WHERE 
            study_id IS NULL OR study_id = ''

        UNION ALL

        SELECT 
            'uniform_resource_publication' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_publication 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL    
        
        -- uniform_resource_author table        

        SELECT 
            'uniform_resource_author' AS table_name,
            'author_id' AS column_name,
            author_id AS value,
            rowid
        FROM 
            uniform_resource_author 
        WHERE 
            author_id IS NULL OR author_id = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_author' AS table_name,
            'name' AS column_name,
            name AS value,
            rowid
        FROM 
            uniform_resource_author 
        WHERE 
            name IS NULL OR name = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_author' AS table_name,
            'email' AS column_name,
            email AS value,
            rowid
        FROM 
            uniform_resource_author 
        WHERE 
            email IS NULL OR email = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_author' AS table_name,
            'investigator_id' AS column_name,
            investigator_id AS value,
            rowid
        FROM 
            uniform_resource_author 
        WHERE 
            investigator_id IS NULL OR investigator_id = ''
        
        UNION ALL

        SELECT 
            'uniform_resource_author' AS table_name,
            'study_id' AS column_name,
            study_id AS value,
            rowid
        FROM 
            uniform_resource_author 
        WHERE 
            study_id IS NULL OR study_id = ''

        UNION ALL

        SELECT 
            'uniform_resource_author' AS table_name,
            'tenant_id' AS column_name,
            tenant_id AS value,
            rowid
        FROM 
            uniform_resource_author 
        WHERE 
            tenant_id IS NULL OR tenant_id = ''
        
        UNION ALL

        SELECT
            'uniform_resource_participant' AS table_name,
            'participant_id' AS column_name,
            participant_id AS value,
            rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        participant_id IS NULL OR participant_id = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'study_id' AS column_name,
	        study_id AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        study_id IS NULL
	        OR study_id = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'site_id' AS column_name,
	        site_id AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        site_id IS NULL
	        OR site_id = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'diagnosis_icd' AS column_name,
	        diagnosis_icd AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        diagnosis_icd IS NULL
	        OR diagnosis_icd = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'med_rxnorm' AS column_name,
	        med_rxnorm AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        med_rxnorm IS NULL
	        OR med_rxnorm = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'treatment_modality' AS column_name,
	        treatment_modality AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        treatment_modality IS NULL
	        OR treatment_modality = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'gender' AS column_name,
	        gender AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        gender IS NULL
	        OR gender = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'race_ethnicity' AS column_name,
	        race_ethnicity AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        race_ethnicity IS NULL
	        OR race_ethnicity = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'age' AS column_name,
	        age AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        age IS NULL
	        OR age = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'bmi' AS column_name,
	        bmi AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        bmi IS NULL
	        OR bmi = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'baseline_hba1c' AS column_name,
	        baseline_hba1c AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        baseline_hba1c IS NULL
	        OR baseline_hba1c = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'diabetes_type' AS column_name,
	        diabetes_type AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        diabetes_type IS NULL
	        OR diabetes_type = ''
	    UNION ALL
	    SELECT
	        'uniform_resource_participant' AS table_name,
	        'study_arm' AS column_name,
	        study_arm AS value,
	        rowid
	    FROM
	        uniform_resource_participant
	    WHERE
	        study_arm IS NULL
	        OR study_arm = ''
	
	    UNION ALL	
	    SELECT 
	            'uniform_resource_participant' AS table_name,
	            'tenant_id' AS column_name,
	            tenant_id AS value,
	            rowid
	        FROM 
	            uniform_resource_participant 
	        WHERE 
	            tenant_id IS NULL OR tenant_id = ''

    )
    GROUP BY table_name, column_name ; 


INSERT OR IGNORE INTO orchestration_session_issue (
    orchestration_session_issue_id, 
    session_id, 
    session_entry_id, 
    issue_type, 
    issue_message, 
    issue_row, 
    issue_column, 
    invalid_value, 
    remediation, 
    elaboration
)
SELECT 
    lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6))) AS orchestration_session_issue_id,
    tsi.orchestration_session_id,
    tsi.orchestration_session_entry_id,
    d_empty.heading AS issue_type,
    d_empty.status AS issue_message,
    d_empty.issue_row AS issue_row,
    d_empty.column_name AS issue_column,
    NULL AS invalid_value,
    d_empty.remediation AS remediation,
    NULL AS elaboration
FROM DataIntegrityEmptyCells d_empty
JOIN 
    temp_session_info tsi ON 1=1;


DROP VIEW IF EXISTS table_counts;
CREATE TEMP VIEW table_counts AS
SELECT 
    'uniform_resource_study' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_study
UNION ALL
SELECT 'uniform_resource_cgm_file_metadata' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_cgm_file_metadata
UNION ALL
SELECT 'uniform_resource_participant' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_participant
UNION ALL
SELECT 'uniform_resource_institution' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_institution
UNION ALL
SELECT 'uniform_resource_lab' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_lab
UNION ALL
SELECT 'uniform_resource_site' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_site
UNION ALL
SELECT 'uniform_resource_investigator' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_investigator
UNION ALL
SELECT 'uniform_resource_publication' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_publication
UNION ALL
SELECT 'uniform_resource_author' AS table_name,
    COUNT(*) AS row_count
FROM uniform_resource_author;


DROP VIEW IF EXISTS empty_tables;
CREATE TEMP VIEW empty_tables AS
SELECT 
    table_name,
    row_count,
    'The File ' || substr(table_name, 18) || ' is empty' AS status,
    'The file ' || substr(table_name, 18) || ' has zero records. Please check and ensure the file is populated with data.' AS remediation
FROM 
    table_counts
WHERE 
    row_count = 0;


INSERT OR IGNORE INTO orchestration_session_issue (
    orchestration_session_issue_id, 
    session_id, 
    session_entry_id, 
    issue_type, 
    issue_message, 
    issue_row, 
    issue_column, 
    invalid_value, 
    remediation, 
    elaboration
)
SELECT 
    lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6))) AS orchestration_session_issue_id,
    tsi.orchestration_session_id,
    tsi.orchestration_session_entry_id,
    'Data Integrity Checks: Empty Tables' AS issue_type,
    ed.status AS issue_message,
    NULL AS issue_row,
    NULL AS issue_column,
    NULL AS invalid_value,
    ed.remediation,
    NULL AS elaboration
FROM 
    empty_tables ed
JOIN 
    temp_session_info tsi ON 1=1;


-- Update orchestration_session to set finished timestamp and diagnostics
UPDATE orchestration_session
SET 
    orch_finished_at = CURRENT_TIMESTAMP,             -- Set the finish time
    diagnostics_json = '{"status": "completed"}',     -- Diagnostics status in JSON format
    diagnostics_md = 'Verification Validation process completed'  -- Markdown summary
WHERE orchestration_session_id = (SELECT orchestration_session_id FROM temp_session_info LIMIT 1);  -- Update the session identified in the temp view
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

-- stateless views

-- Drop and recreate the device view
DROP VIEW IF EXISTS drh_device;
CREATE VIEW drh_device AS
SELECT (
    select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,
    device_id, name, created_at
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




-- Drop and recreate the participant view
DROP VIEW IF EXISTS drh_participant;
CREATE VIEW drh_participant AS
SELECT
    (SELECT db_file_id FROM file_meta_ingest_data LIMIT 1) AS db_file_id, 
    (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,
    participant_id, 
    site_id, diagnosis_icd, med_rxnorm,
    treatment_modality, gender, race_ethnicity, age, bmi, baseline_hba1c,
    diabetes_type, study_arm
FROM uniform_resource_participant;

CREATE TABLE IF NOT EXISTS participant AS
    SELECT *
    FROM drh_participant;

ALTER TABLE participant 
RENAME COLUMN study_id TO study_display_id;

ALTER TABLE participant 
RENAME COLUMN participant_id TO participant_display_id;


CREATE TABLE study_meta_data AS
SELECT
    CAST((SELECT db_file_id FROM file_meta_ingest_data LIMIT 1) AS TEXT) AS db_file_id,  
    CAST(lower(hex(randomblob(16))) AS TEXT) AS study_meta_id,
    CAST((SELECT party_id FROM party LIMIT 1) AS TEXT) AS tenant_id, 
    CAST(s.study_id AS TEXT) AS study_display_id,
    CAST(s.study_name AS TEXT) AS study_name,
    CAST(s.start_date AS TEXT) AS start_date,
    CAST(s.end_date AS TEXT) AS end_date,
    CAST(s.treatment_modalities AS TEXT) AS treatment_modalities,
    CAST(s.funding_source AS TEXT) AS funding_source,
    CAST(s.nct_number AS TEXT) AS nct_number,
    CAST(s.study_description AS TEXT) AS study_description,  
    -- Investigators as JSON Array (Text)
    CAST((SELECT JSON_GROUP_ARRAY(
        JSON_OBJECT(
            'investigator_name', i.investigator_name,
            'email', i.email,
            'institution_id', i.institution_id
        )
     ) FROM uniform_resource_investigator i) AS TEXT) AS investigators,

    -- Publications as JSON Array (Text)
    CAST((SELECT JSON_GROUP_ARRAY(
        JSON_OBJECT(
            'title', p.publication_title,
            'doi', p.digital_object_identifier,
            'publication_site', p.publication_site
        )
     ) FROM uniform_resource_publication p) AS TEXT) AS publications,

    -- Authors as JSON Array (Text)
    CAST((SELECT JSON_GROUP_ARRAY(
        JSON_OBJECT(
            'name', a.name,
            'email', a.email,
            'investigator_id', a.investigator_id
        )
     ) FROM uniform_resource_author a) AS TEXT) AS authors,

    -- Institutions as JSON Array (Text)
    CAST((SELECT JSON_GROUP_ARRAY(
        JSON_OBJECT(
            'name', iv.institution_name,
            'city', iv.city,
            'state', iv.state,
            'country', iv.country
        )
     ) FROM uniform_resource_institution iv) AS TEXT) AS institutions,

    -- Labs as JSON Array (Text)
    CAST((SELECT JSON_GROUP_ARRAY(
        JSON_OBJECT(
            'lab_name', l.lab_name,
            'lab_pi', l.lab_pi,
            'institution_id', l.institution_id
        )
     ) FROM uniform_resource_lab l) AS TEXT) AS labs,

    -- Sites as JSON Array (Text)
    CAST((SELECT JSON_GROUP_ARRAY(
        JSON_OBJECT(
            'site_name', si.site_name,
            'site_type', si.site_type
        )
     ) FROM uniform_resource_site si) AS TEXT) AS sites,
     
    -- Mark studies as synthetic or real in JSON format
    CAST(JSON_OBJECT('type', 'synthetic' ) AS TEXT) AS elaboration

FROM uniform_resource_study s;


-- Drop and recreate the study view
DROP VIEW IF EXISTS drh_study;
CREATE VIEW drh_study AS
SELECT
    study_id, study_name, start_date, end_date, treatment_modalities,
    funding_source, nct_number, study_description,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_study;


-- Drop and recreate the cgmfilemetadata_view view
DROP VIEW IF EXISTS drh_cgmfilemetadata_view;
CREATE VIEW drh_cgmfilemetadata_view AS
SELECT
    metadata_id, devicename, device_id, source_platform, patient_id,
    file_name, file_format, file_upload_date, data_start_date,
    data_end_date, (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_cgm_file_metadata;

-- Drop and recreate the author view
DROP VIEW IF EXISTS drh_author;
CREATE VIEW drh_author AS
SELECT
    author_id, name, email, investigator_id, (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_author;

-- Drop and recreate the institution view
DROP VIEW IF EXISTS drh_institution;
CREATE VIEW drh_institution AS
SELECT
    institution_id, institution_name, city, state, country,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_institution;

-- Drop and recreate the investigator view
DROP VIEW IF EXISTS drh_investigator;
CREATE VIEW drh_investigator AS
SELECT
    investigator_id, investigator_name, email, institution_id, (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_investigator;

-- Drop and recreate the lab view
DROP VIEW IF EXISTS drh_lab;
CREATE VIEW drh_lab AS
SELECT
    lab_id, lab_name, lab_pi, institution_id, (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_lab;

-- Drop and recreate the publication view
DROP VIEW IF EXISTS drh_publication;
CREATE VIEW drh_publication AS
SELECT
    publication_id, publication_title, digital_object_identifier,
    publication_site, (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_publication;

-- Drop and recreate the site view
DROP VIEW IF EXISTS drh_site;
CREATE VIEW drh_site AS
SELECT
    (select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id, site_id, site_name, site_type,(
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id
FROM uniform_resource_site;


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



DROP VIEW IF EXISTS drh_raw_cgm_table_lst;
CREATE VIEW
    drh_raw_cgm_table_lst AS
SELECT
    (
        SELECT
            party_id
        FROM
            party
        LIMIT
            1
    ) AS tenant_id,
    (
        SELECT
            study_id
        FROM
            uniform_resource_study
        LIMIT
            1
    ) AS study_id,
    name,
    tbl_name AS table_name,
    files.file_name || '.' || files.file_format as raw_cgm_file_name
FROM
    sqlite_master
    LEFT JOIN drh_study_files_table_info files ON lower(files.table_name) = lower(tbl_name)
WHERE
    type = 'table' and  name LIKE 'uniform_resource_cgm_tracing%';

DROP VIEW IF EXISTS drh_number_cgm_count;
CREATE VIEW drh_number_cgm_count AS
SELECT count(*) as number_of_cgm_raw_files
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_cgm_tracing%';

DROP VIEW IF EXISTS study_wise_csv_file_names;
CREATE VIEW study_wise_csv_file_names AS
SELECT name 
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_%' and name !='uniform_resource_transform';


DROP VIEW IF EXISTS study_wise_number_cgm_raw_files_count;
CREATE VIEW study_wise_number_cgm_raw_files_count AS
SELECT count(*) as number_of_cgm_raw_files
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_cgm_tracing%';


DROP VIEW IF EXISTS drh_participant_file_names;
CREATE VIEW IF NOT EXISTS drh_participant_file_names AS
SELECT
  patient_id,
  GROUP_CONCAT(file_name, ', ') AS file_names
FROM
  uniform_resource_cgm_file_metadata
GROUP BY
  patient_id;

DROP VIEW IF EXISTS drh_study_vanity_metrics_details;
CREATE VIEW drh_study_vanity_metrics_details AS
SELECT (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id, s.study_id, 
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
LEFT JOIN drh_participant p ON s.study_id = p.study_id 
LEFT JOIN uniform_resource_investigator i ON s.study_id = i.study_id 
GROUP BY s.study_id, s.study_name, s.study_description, s.start_date, s.end_date, s.nct_number;



DROP VIEW IF EXISTS drh_study_files_table_info;

CREATE VIEW
    IF NOT EXISTS drh_study_files_table_info AS
SELECT
    ur.uniform_resource_id,
    ur.nature AS file_format,
    SUBSTR (
        pe.file_path_rel,
        INSTR (pe.file_path_rel, '/') + 1,
        INSTR (pe.file_path_rel, '.') - INSTR (pe.file_path_rel, '/') - 1
    ) as file_name,
    'uniform_resource_' || SUBSTR (
        pe.file_path_rel,
        INSTR (pe.file_path_rel, '/') + 1,
        INSTR (pe.file_path_rel, '.') - INSTR (pe.file_path_rel, '/') - 1
    ) AS table_name
FROM
    uniform_resource ur
    LEFT JOIN uniform_resource_edge ure ON ur.uniform_resource_id = ure.uniform_resource_id
    AND ure.nature = 'ingest_fs_path'
    LEFT JOIN ur_ingest_session_fs_path p ON ure.node_id = p.ur_ingest_session_fs_path_id
    LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id;

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



DROP VIEW IF EXISTS combined_cgm_tracing;
CREATE VIEW combined_cgm_tracing AS
select 
    (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
        (
        select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,
    SID as participant_id, 
    strftime('%Y-%m-%d %H:%M:%S', Date_Time) as Date_Time, 
    CAST(CGM_Value as REAL) as CGM_Value 
from uniform_resource_cgm_tracing;

DROP VIEW IF EXISTS study_combined_dashboard_participant_metrics_view;
CREATE VIEW study_combined_dashboard_participant_metrics_view AS
WITH combined_data AS (
    SELECT 
        dg.tenant_id,
        dg.study_id,             
        dg.participant_id,
        dg.gender,
        dg.age,
        dg.study_arm,
        dg.baseline_hba1c,
        GROUP_CONCAT(DISTINCT cfm.devicename) AS cgm_devices,  -- Combine devices into a single string
        GROUP_CONCAT(DISTINCT cfm.file_name || '.' || cfm.file_format) AS cgm_files,    -- Combine file names into a single string
        ROUND(SUM(CASE WHEN dc.CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tir,
        ROUND(SUM(CASE WHEN dc.CGM_Value > 250 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tar_vh,
        ROUND(SUM(CASE WHEN dc.CGM_Value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tar_h,
        ROUND(SUM(CASE WHEN dc.CGM_Value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tbr_l,
        ROUND(SUM(CASE WHEN dc.CGM_Value < 54 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tbr_vl,
        ROUND(SUM(CASE WHEN dc.CGM_Value > 180 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tar,
        ROUND(SUM(CASE WHEN dc.CGM_Value < 70 THEN 1 ELSE 0 END) * 1.0 / COUNT(dc.CGM_Value) * 100, 2) AS tbr,
        CEIL((AVG(dc.CGM_Value) * 0.155) + 95) AS gmi,
        ROUND((SQRT(AVG(dc.CGM_Value * dc.CGM_Value) - AVG(dc.CGM_Value) * AVG(dc.CGM_Value)) / AVG(dc.CGM_Value)) * 100, 2) AS percent_gv,
        ROUND((3.0 * ((SUM(CASE WHEN dc.CGM_Value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                      (0.8 * (SUM(CASE WHEN dc.CGM_Value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))) + 
              (1.6 * ((SUM(CASE WHEN dc.CGM_Value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                      (0.5 * (SUM(CASE WHEN dc.CGM_Value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))), 2) AS gri,
        COUNT(DISTINCT DATE(dc.Date_Time)) AS days_of_wear,
        MIN(DATE(dc.Date_Time)) AS data_start_date,
        MAX(DATE(dc.Date_Time)) AS data_end_date,   
        ROUND(
            COALESCE(
                (COUNT(DISTINCT DATE(dc.Date_Time)) * 1.0 / 
                (JULIANDAY(MAX(DATE(dc.Date_Time))) - JULIANDAY(MIN(DATE(dc.Date_Time))) + 1)) * 100, 
                0), 
            2) AS wear_time_percentage
    FROM drh_participant dg 
    JOIN combined_cgm_tracing dc ON dg.participant_id = dc.participant_id
    LEFT JOIN uniform_resource_cgm_file_metadata cfm 
        ON dc.participant_id = cfm.patient_id
    GROUP BY dg.study_id, dg.tenant_id, dg.participant_id
)
SELECT * 
FROM combined_data
ORDER BY     
    CASE 
        WHEN LENGTH(participant_id) - LENGTH(REPLACE(participant_id, '-', '')) = 1 THEN 
            CAST(SUBSTR(participant_id, INSTR(participant_id, '-') + 1) AS INTEGER) 
        ELSE participant_id 
    END ASC;


--------------------------------------------
 
DROP VIEW IF EXISTS participant_cgm_date_range_view;
CREATE VIEW participant_cgm_date_range_view AS 
SELECT 
    (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    (
        select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,
    participant_id,
    CAST(strftime('%Y-%m-%d', MIN(Date_Time)) AS TEXT) AS participant_cgm_start_date,
    CAST(strftime('%Y-%m-%d', MAX(Date_Time)) AS TEXT) AS participant_cgm_end_date,
    CAST(strftime('%Y-%m-%d', DATE(MAX(Date_Time), '-1 day')) AS TEXT) AS end_date_minus_1_day,
    CAST(strftime('%Y-%m-%d', DATE(MAX(Date_Time), '-7 day')) AS TEXT) AS end_date_minus_7_days,
    CAST(strftime('%Y-%m-%d', DATE(MAX(Date_Time), '-14 day')) AS TEXT) AS end_date_minus_14_days,
    CAST(strftime('%Y-%m-%d', DATE(MAX(Date_Time), '-30 day')) AS TEXT) AS end_date_minus_30_days,
    CAST(strftime('%Y-%m-%d', DATE(MAX(Date_Time), '-90 day')) AS TEXT) AS end_date_minus_90_days
FROM 
    combined_cgm_tracing  
GROUP BY 
    participant_id;

DROP VIEW IF EXISTS study_wise_number_cgm_raw_files_count;
CREATE VIEW study_wise_number_cgm_raw_files_count AS
SELECT count(*) as number_of_cgm_raw_files
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_cgm_tracing%';


DROP VIEW IF EXISTS study_wise_csv_file_names;
CREATE VIEW study_wise_csv_file_names AS
SELECT (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    (
        select
            study_id
        from
            uniform_resource_study
        limit
            1
    ) as study_id,name 
FROM sqlite_master
WHERE type = 'table' AND name LIKE 'uniform_resource_%' and name !='uniform_resource_transform';

-- cached tables


DROP TABLE IF EXISTS raw_cgm_lst_cached;
CREATE TABLE raw_cgm_lst_cached AS 
  SELECT * FROM drh_raw_cgm_table_lst;


DROP TABLE IF EXISTS study_cgm_file_count_cached;
CREATE TABLE study_cgm_file_count_cached AS 
SELECT count(*) AS total_count FROM sqlite_master WHERE type = 'table' AND name LIKE 'uniform_resource_cgm_tracing%';



DROP TABLE IF EXISTS participant_dashboard_cached;

CREATE TABLE participant_dashboard_cached AS
SELECT *
FROM study_combined_dashboard_participant_metrics_view;

DROP TABLE IF EXISTS combined_cgm_tracing_cached;

CREATE TABLE combined_cgm_tracing_cached AS
SELECT *
FROM combined_cgm_tracing;

DROP TABLE IF EXISTS participant_cgm_date_range_cached;

CREATE TABLE participant_cgm_date_range_cached AS
SELECT *
FROM participant_cgm_date_range_view;


DROP TABLE IF EXISTS study_details_cached;

CREATE TABLE study_details_cached AS
SELECT (
        select
            party_id
        from
            party
        limit
            1
    ) as tenant_id,
    s.study_id,        
s.study_name,        
s.study_description,        
s.start_date,        
s.end_date,        
s.nct_number,        
COUNT(DISTINCT p.participant_id) AS total_number_of_participants,        
ROUND(AVG(p.age), 2) AS average_age,        
FLOOR((CAST(SUM(CASE WHEN p.gender = 'F' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100) AS percentage_of_females,        
GROUP_CONCAT(DISTINCT i.investigator_name) AS investigators 
FROM uniform_resource_study s 
LEFT JOIN drh_participant p ON s.study_id = p.study_id 
LEFT JOIN uniform_resource_investigator i ON s.study_id = i.study_id 
GROUP BY s.study_id, s.study_name, s.study_description, s.start_date, s.end_date, s.nct_number ;

DROP TABLE IF EXISTS cgm_table_name_cached;

CREATE TABLE cgm_table_name_cached AS 
SELECT DISTINCT 
    pdc.tenant_id,
    pdc.study_id, 
    sm.tbl_name AS table_name, 
    REPLACE(sm.tbl_name, 'uniform_resource_', '') || '.' || ur.nature AS file_name
FROM 
    participant_dashboard_cached pdc
JOIN 
    sqlite_master sm
    ON sm.type = 'table'
    AND sm.name LIKE 'uniform_resource%'
    AND sm.name != 'uniform_resource_transform'
    AND sm.name != 'uniform_resource'
JOIN 
    uniform_resource ur 
    ON ur.uri LIKE '%' || REPLACE(sm.tbl_name, 'uniform_resource_', '') || '%';


--indexes



-- DROP INDEX IF EXISTS idx_uniform_resource_cgm_tracing_datetime;
-- DROP INDEX IF EXISTS idx_uniform_resource_cgm_tracing_sid;
-- DROP INDEX IF EXISTS idx_uniform_resource_cgm_tracing_sid_datetime;

-- CREATE INDEX IF NOT EXISTS idx_uniform_resource_cgm_tracing_datetime ON uniform_resource_cgm_tracing(Date_Time);

-- CREATE INDEX IF NOT EXISTS idx_uniform_resource_cgm_tracing_sid ON uniform_resource_cgm_tracing(SID);

-- CREATE INDEX IF NOT EXISTS idx_uniform_resource_cgm_tracing_sid_datetime ON uniform_resource_cgm_tracing(SID, Date_Time);




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
        WHERE namespace = ''prime'' AND path = ''drh/cgm-data''
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


