-- =====================================================================
-- DROPBOX INTEGRATION WITH SURVEILR
-- =====================================================================
-- PREREQUISITES:
--   1. Surveilr installed and configured
--   2. Dropbox API access token
--   3. SQLite database with uniform_resource table
-- 
-- HOW TO GET DROPBOX ACCESS TOKEN:
--   1. Create a Dropbox app at https://www.dropbox.com/developers/apps
--   2. Select "Dropbox API" and choose appropriate access level
--   3. Generate an access token from your app's settings page
--   4. Replace empty string in access_token = '' with your token
--
-- HOW DROPBOX INGESTION WORKS:
--   - The surveilr_udi_dal_dropbox function connects to Dropbox
--   - Files are filtered based on criteria (extension, size, etc.)
--   - Data is mapped to Surveilr's uniform_resource table
--
-- RUNNING THE INTEGRATION:
--   This script must be executed through the Surveilr shell:
--   $ surveilr shell --file dropbox_ingestion.sql
-- =====================================================================

-- Create a virtual table to connect to Dropbox
WITH dropbox_files AS (
    SELECT name, size, last_modified, content_type, content, path
    FROM surveilr_udi_dal_dropbox('YOUR_ACCESS_TOKEN', '')  -- Second parameter is path filter
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
    hex(randomblob(16)),     -- Generate a random UUID for uniform_resource_id
    surveilr_device_id(),         
    surveilr_ingest_session_id(), 
    NULL,                
    'dropbox://' || path,     -- URI using the Dropbox path
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM dropbox_files
WHERE size < 10485760;       -- Limit to files under 10MB


-- =====================================================================
-- IMPORT DROPBOX FILES WITH SPECIFIC EXTENSIONS
-- =====================================================================

WITH dropbox_files AS (
    SELECT name, size, last_modified, content_type, content, path
    FROM surveilr_udi_dal_dropbox('YOUR_ACCESS_TOKEN', '')
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
    hex(randomblob(16)),     -- Generate a random UUID for uniform_resource_id
    surveilr_device_id(),         
    surveilr_ingest_session_id(), 
    NULL,                
    'dropbox://' || path,     -- URI using the Dropbox path
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
AND size < 5242880;  -- Limit to files under 5MB

