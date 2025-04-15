-- =====================================================================
-- AWS S3 INTEGRATION WITH SURVEILR
-- =====================================================================
-- HOW TO CONFIGURE AWS S3 ACCESS:
-- Step 1: Create an S3 Bucket
-- Go to https://s3.console.aws.amazon.com/s3/
-- Click "Create bucket"
-- Give it a name and choose region (e.g. eu-west-2 for London)
-- Leave defaults or configure as needed
-- Click "Create bucket"

-- Step 2: Set Up IAM User or Role with S3 Permissions
-- Go to https://console.aws.amazon.com/iam/
-- Create a new user or role
-- Attach the policy: "AmazonS3FullAccess" (or a custom policy)

-- Step 3: Get AWS Access Keys
-- After creating the user, go to Security credentials
-- Generate Access Key and Secret Access Key
-- Save them securely

-- Step 4: Configure AWS CLI (Optional but Useful)
-- Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
-- Run:
aws configure
-- Enter:
--   AWS Access Key ID:     <your-access-key-id>
--   AWS Secret Access Key: <your-secret-access-key>
--   Default region:        eu-west-2 (or your region)
--   Output format:         json

-- Step 5: Test Access to Bucket via CLI
aws s3 ls s3://your-bucket-name

-- Step 6: Upload or Download Files
-- Upload:
aws s3 cp myfile.txt s3://your-bucket-name/
-- Download:
aws s3 cp s3://your-bucket-name/myfile.txt .

--Setting Up with Environment Variables
-- Create a .env file in your project directory:
--  *S3_BUCKET=bucket_name
--  *S3_ENDPOINT=s3_endpoint
--  *S3_REGION=region
--  *AWS_ACCESS_KEY_ID=access_key
--  *AWS_SECRET_ACCESS_KEY=secret_key


-- RUNNING THE INTEGRATION:
--   This script must be executed through the Surveilr shell:
--   $ surveilr shell s3_ingestion.sql
-- =====================================================================

-- Create a virtual table to connect to S3
WITH s3_files AS (
    SELECT name, size, last_modified, content_type, content
    FROM surveilr_udi_dal_s3('S3_BUCKET','S3_ENDPOINT','S3_REGION','AWS_ACCESS_KEY_ID','AWS_SECRET_ACCESS_KEY')
)

 --Testing by passing env variables
WITH s3_files AS (
    SELECT name, size, last_modified, content_type, content
    FROM surveilr_udi_dal_s3();
)

-- Insert files from S3 into the uniform_resource table
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
    's3://your-bucket-name/' || name, 
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM s3_files
WHERE size < 10485760;     


-- =====================================================================
-- IMPORT S3 FILES WITH SPECIFIC EXTENSIONS
-- =====================================================================

WITH s3_files AS (
    SELECT name, size, last_modified, content_type, content
    FROM surveilr_udi_dal_s3('S3_BUCKET','S3_ENDPOINT','S3_REGION','AWS_ACCESS_KEY_ID','AWS_SECRET_ACCESS_KEY')
)

 --Testing by passing env variables
WITH s3_files AS (
    SELECT name, size, last_modified, content_type, content
    FROM surveilr_udi_dal_s3();
)

-- Insert files from S3 into the uniform_resource table
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
    's3://your-bucket-name/' || name, ,  
    hex(md5(content)),              
    content,                       
    size AS size_bytes,             
    last_modified AS last_modified_at, 
    content_type AS nature,        
    'system',                       
    CURRENT_TIMESTAMP
FROM s3_files
WHERE (
    key LIKE '%.docx' OR
    key LIKE '%.pdf' OR
    key LIKE '%.txt'
)
AND size < 5242880;  
