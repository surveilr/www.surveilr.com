-- aggregates file stats for each party based on the devices they own.
DROP VIEW IF EXISTS party_file_summary;
CREATE VIEW party_file_summary AS
SELECT
    p.party_id,
    p.party_name,
    COUNT(DISTINCT ur.uniform_resource_id) AS total_files,
    COUNT(DISTINCT CASE WHEN ur.content IS NOT NULL THEN ur.uniform_resource_id END) AS files_with_content,
    SUM(ur.size_bytes) AS total_size_bytes
FROM party p
JOIN device_party_relationship dpr ON p.party_id = dpr.party_id
JOIN ur_ingest_session uris ON dpr.device_id = uris.device_id  -- Corrected join and alias
JOIN ur_ingest_session_fs_path_entry isfpe ON uris.ur_ingest_session_id = isfpe.ingest_session_id
JOIN uniform_resource ur ON isfpe.uniform_resource_id = ur.uniform_resource_id
GROUP BY p.party_id, p.party_name;


-- list the distribution of file types (based on extension) for each device.
DROP VIEW IF EXISTS device_file_types;
CREATE VIEW device_file_types AS
SELECT
    d.device_id,
    d.name AS device_name,
    isfpe.file_extn,
    COUNT(*) AS file_count
FROM device d
JOIN ur_ingest_session uris ON d.device_id = uris.device_id  -- Corrected join and alias
JOIN ur_ingest_session_fs_path_entry isfpe ON uris.ur_ingest_session_id = isfpe.ingest_session_id
GROUP BY d.device_id, d.name, isfpe.file_extn;



-- aggregate compliance violations by party, 
-- allowing you to see which parties have files containing potential violations and the types of violations.
DROP VIEW IF EXISTS party_compliance_violations;
CREATE VIEW party_compliance_violations AS
SELECT
    p.party_id,
    p.party_name,
    cv.violation_type,
    COUNT(*) AS violation_count
FROM party p
JOIN device_party_relationship dpr ON p.party_id = dpr.party_id
JOIN ur_ingest_session uris ON dpr.device_id = uris.device_id -- Corrected join and alias
JOIN ur_ingest_session_fs_path_entry isfpe ON uris.ur_ingest_session_id = isfpe.ingest_session_id
JOIN uniform_resource ur ON isfpe.uniform_resource_id = ur.uniform_resource_id
JOIN compliance_violations cv ON ur.uniform_resource_id = cv.uniform_resource_id
GROUP BY p.party_id, p.party_name, cv.violation_type;


WITH expected_counts AS (
    SELECT 'party_file_summary' AS table_name, 0 AS expected_count
    UNION ALL
    SELECT 'device_file_types', 16 AS expected_count
    UNION ALL
    SELECT 'party_compliance_violations', 0 AS expected_count 
),
actual_counts AS (
    SELECT 'party_file_summary' AS table_name, COUNT(*) AS actual_count FROM party_file_summary
    UNION ALL
    SELECT 'device_file_types', COUNT(*) FROM device_file_types
    UNION ALL
    SELECT 'party_compliance_violations', COUNT(*) FROM party_compliance_violations
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