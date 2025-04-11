-- =====================================================================
-- LOCAL FILESYSTEM INTEGRATION WITH SURVEILR
-- =====================================================================
-- PREREQUISITES:
--   1. Surveilr installed and configured
--   2. Access to local filesystem paths
--   3. SQLite database with uniform_resource table
-- 
-- HOW LOCAL FILESYSTEM INGESTION WORKS:
--   - The surveilr_udi_dal_fs function connects to a local directory
--   - Files are automatically discovered from the specified directory
--   - Content is read directly from the filesystem
--   - Files can be filtered by extension, size, etc.
--
-- RUNNING THE INTEGRATION:
--   This script must be executed through the Surveilr shell:
--   $ surveilr shell --file fs_ingestion.sql
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
    hex(randomblob(16)),     -- Generate a random UUID for uniform_resource_id
    surveilr_device_id(),         
    surveilr_ingest_session_id(), 
    NULL,                
    'https://drive.google.com/drive' || path,     -- URI using the GDrive path
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM fs
WHERE size < 10485760;       -- Limit to files under 10MB


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
    hex(randomblob(16)),     -- Generate a random UUID for uniform_resource_id
    surveilr_device_id(),         
    surveilr_ingest_session_id(), 
    NULL,                
    'https://drive.google.com/drive/' || path,     -- URI using the GDrive path
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


-- Organize files by content type

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
    hex(randomblob(16)),     -- Generate a random UUID for uniform_resource_id
    surveilr_device_id(),         
    surveilr_ingest_session_id(), 
    NULL,                
    'https://drive.google.com/drive/' || path,     -- URI using the GDrive path
    CASE
        WHEN content_type LIKE 'image/%' THEN 'image'
        WHEN content_type LIKE 'video/%' THEN 'video'
        WHEN content_type LIKE 'audio/%' THEN 'audio'
        WHEN content_type LIKE 'application/pdf' THEN 'document'
        WHEN content_type LIKE 'text/%' THEN 'text'
        ELSE 'other'
    END AS content_digest,            
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM fs
WHERE size < 20971520;    -- Limit to files under 10MB