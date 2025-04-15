-- =====================================================================
-- LOCAL FILESYSTEM INTEGRATION WITH SURVEILR
-- =====================================================================
-- RUNNING THE INTEGRATION:
--   This script must be executed through the Surveilr shell:
--   $ surveilr shell fs_ingestion.sql
--   Or:

-- Create a virtual table to connect to Google Drive
WITH fs AS (
    SELECT * FROM surveilr_udi_dal_fs('/Users/mac/Downloads/resource-surveillance/support/test-fixtures');
)
-- Insert files from Google Drive into the uniform_resource table
INSERT INTO uniform_resource (
    uniform_resource_id,
    device_id,
    ingest_session_id,
    ingest_fs_path_id,
    uri,
    content_digest,
    content,
    size_bytes,
    last_modified_at,
    nature,
    created_by,
    created_at
)
SELECT
    hex(randomblob(16)),    
    surveilr_device_id(),         
    surveilr_ingest_session_id(), 
    NULL,                
    'https://drive.google.com/drive' || path,    
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM fs
WHERE size < 10485760;       


--Import Google Drive files with specific extensions

WITH fs AS (
    SELECT * FROM surveilr_udi_dal_fs('/Users/mac/Downloads/resource-surveillance/support/test-fixtures');
)
-- Insert files from Google Drive into the uniform_resource table
INSERT INTO uniform_resource (
    uniform_resource_id,
    device_id,
    ingest_session_id,
    ingest_fs_path_id,
    uri,
    content_digest,
    content,
    size_bytes,
    last_modified_at,
    nature,
    created_by,
    created_at
)
SELECT
    hex(randomblob(16)),     
    surveilr_device_id(),         
    surveilr_ingest_session_id(), 
    NULL,                
    'https://drive.google.com/drive/' || path,     
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM fs
WHERE (
    path LIKE '%.docx' OR
    path LIKE '%.pdf' OR
    path LIKE '%.txt'
)
AND size < 5242880; 