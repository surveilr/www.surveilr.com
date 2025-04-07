-- Create a virtual table to connect to Google Drive
WITH gdrive_files AS (
    SELECT * FROM surveilr_udi_dal_gdrive 
    WHERE access_token = 'ya29.a0AZYkNZhGdU7IdRFUln0Ur53GHLMFTFrq9y3fYL5-x2A_6_mYJBINH_jmVwZDOswY1OxPy9OB59bPIbcMwr2L396JeI-MOjRSAPJJ0vBUOmeP3y_1LZPRmySnhGwJU5AxAWk_wtogYvimi4kUoY1BxpMSFWK9qZavXxnmgsihaCgYKATISARESFQHGX2MiuGD2wIbaHM1e5WgEQLBNng0175'
    AND path_filter = '/'
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
    surveilr_device_id(),         -- Device identifier
    surveilr_ingest_session_id(), -- Session ID with timestamp
    NULL,                
    'https://drive.google.com/drive' || path,     -- URI using the GDrive path
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM gdrive_files
WHERE size < 10485760;       -- Limit to files under 10MB



