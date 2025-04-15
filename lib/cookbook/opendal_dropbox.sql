-- =====================================================================
-- DROPBOX INTEGRATION WITH SURVEILR
-- =====================================================================
-- HOW TO GET DROPBOX ACCESS TOKEN:
--   1. Create a Dropbox app at https://www.dropbox.com/developers/apps
--   2. Select "Dropbox API" and choose appropriate access level
--   3. Generate an access token from your app's settings page
--   4. Replace empty string in access_token = '' with your token`

--Setting Up with Environment Variables
-- Create a .env file in your project directory:
--  *ACCESS_TOKEN=your_access_token
--  *path=file_root

-- RUNNING THE INTEGRATION:
--   This script must be executed through the Surveilr shell:
--   $ surveilr shell dropbox_ingestion.sql
-- =====================================================================

-- Create a virtual table to connect to Dropbox
WITH dropbox_files AS (
    SELECT name, size, last_modified, content_type, content, path
    FROM surveilr_udi_dal_dropbox('YOUR_ACCESS_TOKEN', '/') 
)
--Testing by passing env variables
WITH dropbox_files AS (
    SELECT name, size, last_modified, content_type, content, path
    FROM surveilr_udi_dal_dropbox() 
)
-- Insert files from Dropbox into the uniform_resource table
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
    'dropbox://' || path,    
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM dropbox_files
WHERE size < 10485760;      


-- =====================================================================
-- IMPORT DROPBOX FILES WITH SPECIFIC EXTENSIONS
-- =====================================================================

WITH dropbox_files AS (
    SELECT name, size, last_modified, content_type, content, path
    FROM surveilr_udi_dal_dropbox('YOUR_ACCESS_TOKEN', 'root')
)

--Testing by passing env variables
WITH dropbox_files AS (
    SELECT name, size, last_modified, content_type, content, path
    FROM surveilr_udi_dal_dropbox() 
)
-- Insert files from Dropbox into the uniform_resource table
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
    'dropbox://' || path,   
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM dropbox_files
WHERE (
    name LIKE '%.docx' OR
    name LIKE '%.pdf' OR
    name LIKE '%.txt'
)
AND size < 5242880; 

