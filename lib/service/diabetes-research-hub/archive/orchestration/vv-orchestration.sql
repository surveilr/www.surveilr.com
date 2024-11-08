
-- Create a view that represents the expected schema with required columns and properties
CREATE VIEW IF NOT EXISTS expected_schema_view AS
SELECT 
'uniform_resource_institution' AS table_name, 'institution_id' AS column_name, 'TEXT' AS column_type, 1 AS is_primary_key, 1 AS not_null
UNION ALL SELECT 'uniform_resource_institution', 'institution_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_institution', 'city', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_institution', 'state', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_institution', 'country', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_lab', 'lab_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_lab', 'lab_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_lab', 'lab_pi', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_lab', 'institution_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_lab', 'study_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_study', 'study_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_study', 'study_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'start_date', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'end_date', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'treatment_modalities', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'funding_source', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'nct_number', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_study', 'study_description', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_site', 'site_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_site', 'study_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_site', 'site_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_site', 'site_type', 'TEXT', 0, 1

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

UNION ALL SELECT 'uniform_resource_investigator', 'investigator_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_investigator', 'investigator_name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_investigator', 'email', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_investigator', 'institution_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_investigator', 'study_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_publication', 'publication_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_publication', 'publication_title', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_publication', 'digital_object_identifier', 'TEXT', 0, 0
UNION ALL SELECT 'uniform_resource_publication', 'publication_site', 'TEXT', 0, 0
UNION ALL SELECT 'uniform_resource_publication', 'study_id', 'TEXT', 0, 1

UNION ALL SELECT 'uniform_resource_author', 'author_id', 'TEXT', 1, 1
UNION ALL SELECT 'uniform_resource_author', 'name', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_author', 'email', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_author', 'investigator_id', 'TEXT', 0, 1
UNION ALL SELECT 'uniform_resource_author', 'study_id', 'TEXT', 0, 1

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
UNION ALL SELECT 'uniform_resource_cgm_file_metadata', 'study_id', 'TEXT', 0, 1;

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
    'vv-orchestration.sql',  -- Replace with actual ingest source
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
INSERT INTO orchestration_session_issue (
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



--- Validate the schema to check for additional columns

DROP VIEW IF EXISTS temp_SchemaValidationAdditionalColumns;
CREATE TEMP VIEW  temp_SchemaValidationAdditionalColumns As
SELECT 
    'Schema Validation: Additional Columns' AS heading,
    a.table_name,
    a.column_name,
    a.column_type,
    a.is_primary_key,
    'Additional column found: ' || a.column_name || ' in table ' || a.table_name AS status,
    'Warning: Additional column found: ' || a.column_name || ' in table ' || a.table_name || '. The column can be maintained or removed as desired.' AS remediation
FROM 
    (
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
    ) a
LEFT JOIN expected_schema_view e ON a.table_name = e.table_name AND a.column_name = e.column_name
WHERE 
    e.column_name IS NULL;


INSERT INTO orchestration_session_issue (
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
    tsa.heading as issue_type,
    tsa.status as issue_message,
    NULL AS issue_row, 
    tsa.column_name AS issue_column,
    NULL AS invalid_value, 
    tsa.remediation,
    NULL AS elaboration  
FROM 
    temp_SchemaValidationAdditionalColumns tsa
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


INSERT INTO orchestration_session_issue (
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
        

        -- uniform_resource_participant table
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
            study_id IS NULL OR study_id = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_participant' AS table_name,
            'site_id' AS column_name,
            site_id AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            site_id IS NULL OR site_id = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_participant' AS table_name,
            'diagnosis_icd' AS column_name,
            diagnosis_icd AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            diagnosis_icd IS NULL OR diagnosis_icd = ''
        
        UNION ALL   

        SELECT 
            'uniform_resource_participant' AS table_name,
            'med_rxnorm' AS column_name,
            med_rxnorm AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            med_rxnorm IS NULL OR med_rxnorm = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_participant' AS table_name,
            'treatment_modality' AS column_name,
            treatment_modality AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            treatment_modality IS NULL OR treatment_modality = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_participant' AS table_name,
            'gender' AS column_name,
            gender AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            gender IS NULL OR gender = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_participant' AS table_name,
            'race_ethnicity' AS column_name,
            race_ethnicity AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            race_ethnicity IS NULL OR race_ethnicity = ''
        
        UNION ALL   

        SELECT 
            'uniform_resource_participant' AS table_name,
            'age' AS column_name,
            age AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            age IS NULL OR age = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_participant' AS table_name,
            'bmi' AS column_name,
            bmi AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            bmi IS NULL OR bmi = ''
        
        UNION ALL    

        SELECT 
            'uniform_resource_participant' AS table_name,
            'baseline_hba1c' AS column_name,
            baseline_hba1c AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            baseline_hba1c IS NULL OR baseline_hba1c = ''
        
        UNION ALL    

        
        SELECT 
            'uniform_resource_participant' AS table_name,
            'diabetes_type' AS column_name,
            diabetes_type AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            diabetes_type IS NULL OR diabetes_type = ''
        
        UNION ALL 

        SELECT 
            'uniform_resource_participant' AS table_name,
            'study_arm' AS column_name,
            study_arm AS value,
            rowid
        FROM 
            uniform_resource_participant  
        WHERE 
            study_arm IS NULL OR study_arm = ''
        
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
        
        -- uniform_resource_author table

        UNION ALL

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

    )
    GROUP BY table_name, column_name ; 


INSERT INTO orchestration_session_issue (
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


INSERT INTO orchestration_session_issue (
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



