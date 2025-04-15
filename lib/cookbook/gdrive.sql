-- =====================================================================
-- GOOGLE DRIVE INTEGRATION WITH SURVEILR
-- =====================================================================
-- HOW TO GET ACCESS TOKEN:
-- Step 1: Create a Google Cloud Project
-- Go to https://console.cloud.google.com/
-- Create a new project
-- Enable "Google Drive API" via APIs & Services > Library

-- Step 2: Create OAuth 2.0 Credentials
-- Go to APIs & Services > Credentials
-- Click "Create Credentials" > "OAuth Client ID"
-- Choose application type: Desktop or Web
-- Set redirect URI (e.g. http://localhost:8080)
-- Download the client_secret.json (contains client_id & client_secret)

-- Step 3: Construct Authorization URL
-- Format:
-- https://accounts.google.com/o/oauth2/v2/auth?
--   client_id=YOUR_CLIENT_ID&
--   redirect_uri=YOUR_REDIRECT_URI&
--   response_type=code&
--   scope=https://www.googleapis.com/auth/drive.readonly&
--   access_type=offline

-- Replace YOUR_CLIENT_ID and YOUR_REDIRECT_URI

-- Step 4: User opens URL in browser
-- User signs in and consents
-- Google redirects to:
--   http://localhost:8080/?code=AUTH_CODE
-- Extract the `code` from the URL

-- Step 5: Exchange Authorization Code for Access Token
-- Make a POST request to:
--   https://oauth2.googleapis.com/token
-- Body:
-- {
--   code=AUTH_CODE,
--   client_id=YOUR_CLIENT_ID,
--   client_secret=YOUR_CLIENT_SECRET,
--   redirect_uri=YOUR_REDIRECT_URI,
--   grant_type=authorization_code
-- }
-- Response contains access_token, refresh_token, etc.

--Setting Up with Environment Variables
-- Create a .env file in your project directory:
--  *GDRIVE_ACCESS_TOKEN=your_oauth_access_token
--  *GDRIVE_BASE_PATH=/


-- RUNNING THE INTEGRATION:
--   This script must be executed through the Surveilr shell:
--   $ surveilr shell gdrive.sql




-- Create a virtual table to connect to Google Drive
WITH gdrive_files AS (
    SELECT * FROM surveilr_udi_dal_gdrive 
    WHERE access_token = ''
    AND path_filter = '/'
)

 --Testing by passing env variables
WITH gdrive_files AS (
    SELECT * FROM surveilr_udi_dal_gdrive();
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
FROM gdrive_files
WHERE size < 10485760;      


--Import Google Drive files with specific extensions
WITH gdrive_files AS (
    SELECT * FROM surveilr_udi_dal_gdrive 
    WHERE access_token = ''
    AND path_filter = '/'
)

 --Testing by passing env variables
WITH gdrive_files AS (
    SELECT * FROM surveilr_udi_dal_gdrive();
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
FROM gdrive_files
WHERE (
    path LIKE '%.docx' OR
    path LIKE '%.pdf' OR
    path LIKE '%.txt'
)
AND size < 5242880; 
