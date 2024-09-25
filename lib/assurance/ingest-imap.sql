-- number of email accounts associated with each party and lists the email addresses.
DROP VIEW IF EXISTS party_email_accounts;
CREATE VIEW party_email_accounts AS
SELECT
    dpr.party_id,
    COUNT(DISTINCT ima.ur_ingest_session_imap_account_id) AS email_account_count,
    GROUP_CONCAT(DISTINCT ima.email) AS email_addresses
FROM device_party_relationship dpr 
JOIN ur_ingest_session uris ON dpr.device_id = uris.device_id  -- Use correct alias 'uris'
JOIN ur_ingest_session_imap_account ima ON uris.ur_ingest_session_id = ima.ingest_session_id
GROUP BY dpr.party_id; 


-- summary of messages in each folder, including total count, unique count, and counts for read, unread, and starred messages.
DROP VIEW IF EXISTS folder_message_summary;
CREATE VIEW folder_message_summary AS
WITH exploded_statuses AS (
    SELECT
        imaf.folder_name,
        imfm.message_id,
        value AS status
    FROM ur_ingest_session_imap_acct_folder imaf
    JOIN ur_ingest_session_imap_acct_folder_message imfm 
        ON imaf.ur_ingest_session_imap_acct_folder_id = imfm.ingest_imap_acct_folder_id,
    json_each(imfm.status)
)
SELECT
    folder_name,
    COUNT(*) AS message_count,
    COUNT(DISTINCT message_id) AS unique_message_count,
    SUM(CASE WHEN status = 'unread' THEN 1 ELSE 0 END) AS unread_count,
    SUM(CASE WHEN status = 'read' THEN 1 ELSE 0 END) AS read_count,
    SUM(CASE WHEN status = 'starred' THEN 1 ELSE 0 END) AS starred_count
FROM exploded_statuses
GROUP BY folder_name;

-- number of attachments extracted for each message.
DROP VIEW IF EXISTS attachment_extraction_summary;
CREATE VIEW attachment_extraction_summary AS
SELECT
    imfm.ur_ingest_session_imap_acct_folder_message_id AS message_id,
    imfm.subject,
    COUNT(DISTINCT attach.ur_ingest_session_attachment_id) AS attachment_count
FROM ur_ingest_session_imap_acct_folder_message imfm
LEFT JOIN ur_ingest_session_attachment attach ON imfm.uniform_resource_id = attach.uniform_resource_id
GROUP BY imfm.ur_ingest_session_imap_acct_folder_message_id, imfm.subject;

-- since this is executed without extract-attachments set to "uniform-resource", 
-- the extractions must only be in the attachments table
DROP VIEW IF EXISTS attachment_uniform_resource_consistency;
CREATE VIEW attachment_uniform_resource_consistency AS
SELECT
    attach.ur_ingest_session_attachment_id AS attachment_id,
    CASE 
        WHEN uris.behavior_json LIKE '%"extract_attachments": "uniform_resource"%' AND attach.uniform_resource_id IS NULL THEN 'Mismatch'
        WHEN uris.behavior_json NOT LIKE '%"extract_attachments": "uniform_resource"%' AND attach.uniform_resource_id IS NOT NULL THEN 'Mismatch'
        ELSE 'Consistent'
    END AS consistency_status
FROM ur_ingest_session_attachment attach
JOIN ur_ingest_session_imap_acct_folder_message imfm ON attach.uniform_resource_id = imfm.uniform_resource_id
JOIN ur_ingest_session uris ON imfm.ingest_session_id = uris.ur_ingest_session_id;

-- TAP Tests for Multi-Tenant IMAP Views
WITH expected_counts AS (
    SELECT 'party_email_accounts' AS table_name, 1 AS expected_count
    UNION ALL
    SELECT 'folder_message_summary', 3 AS expected_count
    UNION ALL
    SELECT 'attachment_extraction_summary', 22 AS expected_count
    UNION ALL
    SELECT 'attachment_uniform_resource_consistency' AS table_name, 0 AS expected_count
),
actual_counts AS (
    SELECT 'party_email_accounts' AS table_name, COUNT(*) AS actual_count FROM party_email_accounts
    UNION ALL
    SELECT 'folder_message_summary', COUNT(*) FROM folder_message_summary
    UNION ALL
    SELECT 'attachment_extraction_summary', COUNT(*) FROM attachment_extraction_summary
    UNION ALL
    SELECT 'attachment_uniform_resource_consistency' AS table_name, COUNT(*) AS actual_count 
    FROM attachment_uniform_resource_consistency
    WHERE consistency_status = 'Consistent'
),
results AS (
    SELECT
        ec.table_name,
        CASE
            WHEN ac.actual_count = ec.expected_count THEN 'ok - ' || ec.table_name || ' count matches expected (' || ec.expected_count || ')'
            ELSE 'not ok - ' || ec.table_name || ' count does not match expected (' || ec.expected_count || '), found: ' || ac.actual_count
        END AS tap_output
    FROM
        expected_counts ec
    JOIN
        actual_counts ac ON ec.table_name = ac.table_name
),
tap_plan AS (
    SELECT '1..' || COUNT(*) || ' - TAP tests for database tables' AS tap_output FROM results
)
SELECT tap_output FROM tap_plan
UNION ALL
SELECT tap_output FROM results;
