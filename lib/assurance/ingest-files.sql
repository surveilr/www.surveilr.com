-- track the history of changes to files within the system by recording the number of ingestion sessions 
-- where each file was observed, along with the timestamps of the first and last time it was ingested.
DROP VIEW IF EXISTS file_change_history;
CREATE VIEW file_change_history AS
SELECT
    ur.uniform_resource_id,
    ur.uri,
    COUNT(DISTINCT isfp.ingest_session_id) AS ingest_session_count,
    GROUP_CONCAT(DISTINCT isfp.ingest_session_id) AS ingest_sessions,
    MIN(ing_sess.ingest_started_at) AS first_seen,
    MAX(ing_sess.ingest_started_at) AS last_seen
FROM uniform_resource ur
JOIN ur_ingest_session_fs_path_entry isfpe ON ur.uniform_resource_id = isfpe.uniform_resource_id
JOIN ur_ingest_session_fs_path isfp ON isfpe.ingest_fs_path_id = isfp.ur_ingest_session_fs_path_id
JOIN ur_ingest_session ing_sess ON isfp.ingest_session_id = ing_sess.ur_ingest_session_id
GROUP BY ur.uniform_resource_id, ur.uri;

-- summary of user activity by showing which devices users have accessed and used to execute queries, 
-- how many ingestion sessions they have initiated, and how many SQL queries they have executed.
DROP VIEW IF EXISTS user_activity_summary;
CREATE VIEW user_activity_summary AS
SELECT
    p.person_id,
    p.person_first_name || ' ' || p.person_last_name AS full_name,
    COUNT(DISTINCT dpr.device_id) AS devices_accessed,
    COUNT(DISTINCT uris.ur_ingest_session_id) AS ingest_sessions,
    COUNT(DISTINCT udi.ur_ingest_session_udi_pgp_sql_id) AS sql_queries_executed
FROM person p
LEFT JOIN device_party_relationship dpr ON p.person_id = dpr.party_id
LEFT JOIN ur_ingest_session uris ON dpr.device_id = uris.device_id
LEFT JOIN ur_ingest_session_udi_pgp_sql udi ON uris.ur_ingest_session_id = udi.ingest_session_id
GROUP BY p.person_id, full_name;

--  identify files that might pose a security risk based on whether they are executable, a script, 
--  or have a suspicious file extension.
DROP VIEW IF EXISTS potential_risk_files;
CREATE VIEW potential_risk_files AS
SELECT
    ur.uniform_resource_id,
    ur.uri,
    ur.content_digest,
    CASE
        WHEN ur.nature LIKE '%executable%' THEN 'Executable'
        WHEN ur.nature LIKE '%script%' THEN 'Script'
        WHEN isfpe.file_extn IN ('.exe', '.dll', '.bat', '.ps1', '.sh') THEN 'Suspicious Extension'
        ELSE 'Other'
    END AS risk_category
FROM uniform_resource ur
JOIN ur_ingest_session_fs_path_entry isfpe ON ur.uniform_resource_id = isfpe.uniform_resource_id
WHERE ur.nature LIKE '%executable%' OR ur.nature LIKE '%script%' 
OR isfpe.file_extn IN ('.exe', '.dll', '.bat', '.ps1', '.sh');

-- detect potential compliance violations within file content by looking for patterns indicating sensitive data or PII exposure.
DROP VIEW IF EXISTS compliance_violations;
CREATE VIEW compliance_violations AS
SELECT
    ur.uniform_resource_id,
    ur.uri,
    isfpe.file_path_abs,
    CASE
        WHEN ur.content LIKE '%confidential%' OR ur.content LIKE '%secret%' THEN 'Sensitive Data Exposure'
        WHEN ur.content LIKE '%password%' OR ur.content LIKE '%credit card%' THEN 'PII Exposure'
        ELSE 'Other Violation'
    END AS violation_type
FROM uniform_resource ur
JOIN ur_ingest_session_fs_path_entry isfpe ON ur.uniform_resource_id = isfpe.uniform_resource_id
WHERE ur.content LIKE '%confidential%' OR ur.content LIKE '%secret%' 
OR ur.content LIKE '%password%' OR ur.content LIKE '%credit card%';


WITH expected_counts AS (
    SELECT 'file_change_history' AS table_name, 17 AS expected_count
    UNION ALL
    SELECT 'user_activity_summary', 0 AS expected_count 
    UNION ALL
    SELECT 'potential_risk_files', 0 AS expected_count 
    UNION ALL
    SELECT 'compliance_violations', 1 AS expected_count 
),
actual_counts AS (
    SELECT 'file_change_history' AS table_name, COUNT(*) AS actual_count FROM file_change_history
    UNION ALL
    SELECT 'user_activity_summary', COUNT(*) FROM user_activity_summary
    UNION ALL
    SELECT 'potential_risk_files', COUNT(*) FROM potential_risk_files
    UNION ALL
    SELECT 'compliance_violations', COUNT(*) FROM compliance_violations
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