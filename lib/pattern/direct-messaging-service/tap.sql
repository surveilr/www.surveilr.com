DROP VIEW IF EXISTS "synthetic_test_suite"; 
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS(SELECT 'TAP version 14' AS tap_result), 
        tap_plan AS(SELECT '1..9' AS tap_result), 
        -- 0: Check if important tables exist
"Check if important tables exist" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'table' AND name in ('sqlpage_aide_navigation','sqlpage_files')
  )
  SELECT CASE WHEN COUNT(CASE WHEN name = 'sqlpage_aide_navigation' THEN 1 END) > 0 THEN 'ok 0.1 ' || ('Table "''sqlpage_aide_navigation''" exists in the DB') ELSE 'not ok 0.1 ' || ('Table "''sqlpage_aide_navigation''" exists in the DB') END AS tap_result FROM test_case
UNION ALL
SELECT CASE WHEN COUNT(CASE WHEN name = 'sqlpage_files' THEN 1 END) > 0 THEN 'ok 0.2 ' || ('Table "''sqlpage_files''" exists in the DB') ELSE 'not ok 0.2 ' || ('Table "''sqlpage_files''" exists in the DB') END AS tap_result FROM test_case
),
  -- 1: Check if important views exist
"Check if important views exist" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name in ('inbox','mail_content_attachment','patient_observation','patient_detail','author_detail')
  )
  SELECT CASE WHEN COUNT(CASE WHEN name = 'inbox' THEN 1 END) > 0 THEN 'ok 1.1 ' || ('View "''inbox''" exists in the DB') ELSE 'not ok 1.1 ' || ('View "''inbox''" exists in the DB') END AS tap_result FROM test_case
UNION ALL
SELECT CASE WHEN COUNT(CASE WHEN name = 'mail_content_attachment' THEN 1 END) > 0 THEN 'ok 1.2 ' || ('View "''mail_content_attachment''" exists in the DB') ELSE 'not ok 1.2 ' || ('View "''mail_content_attachment''" exists in the DB') END AS tap_result FROM test_case
UNION ALL
SELECT CASE WHEN COUNT(CASE WHEN name = 'patient_observation' THEN 1 END) > 0 THEN 'ok 1.3 ' || ('View "''patient_observation''" exists in the DB') ELSE 'not ok 1.3 ' || ('View "''patient_observation''" exists in the DB') END AS tap_result FROM test_case
UNION ALL
SELECT CASE WHEN COUNT(CASE WHEN name = 'patient_detail' THEN 1 END) > 0 THEN 'ok 1.4 ' || ('View "''patient_detail''" exists in the DB') ELSE 'not ok 1.4 ' || ('View "''patient_detail''" exists in the DB') END AS tap_result FROM test_case
UNION ALL
SELECT CASE WHEN COUNT(CASE WHEN name = 'author_detail' THEN 1 END) > 0 THEN 'ok 1.5 ' || ('View "''author_detail''" exists in the DB') ELSE 'not ok 1.5 ' || ('View "''author_detail''" exists in the DB') END AS tap_result FROM test_case
),
  -- 2: Ensure at least 1 inbox content exists
"Ensure at least 1 inbox content exists" AS (
  WITH test_case AS (
    SELECT COUNT(*) AS inbox_count FROM inbox
  )
  SELECT CASE WHEN inbox_count > 0 THEN 'ok 2 ' || ('inbox_count is greater than 0') ELSE 'not ok 2 ' || ('inbox_count should be greater than 0, is ' || inbox_count || ' instead') END AS tap_result FROM test_case
),
  -- 3: Check for each inbox item, a patient data exists in 'patient_detail'
"Check for each inbox item, a patient data exists in 'patient_detail'" AS (
  WITH test_case AS (
    SELECT count(*) as patient_count from inbox i INNER JOIN patient_detail WHERE i.id = message_uid
  )
  SELECT CASE WHEN patient_count = (select count(*) as inbox_count from inbox) THEN 'ok 3 ' || ('patient_count is (select count(*) as inbox_count from inbox)') ELSE 'not ok 3 ' || ('patient_count should be (select count(*) as inbox_count from inbox), is ' || patient_count || ' instead') END AS tap_result FROM test_case
) 
    SELECT tap_result FROM tap_version
    UNION ALL
    SELECT tap_result FROM tap_plan
    UNION ALL
    SELECT tap_result FROM "Check if important tables exist"
    UNION ALL
SELECT tap_result FROM "Check if important views exist"
    UNION ALL
SELECT tap_result FROM "Ensure at least 1 inbox content exists"
    UNION ALL
SELECT tap_result FROM "Check for each inbox item, a patient data exists in 'patient_detail'"; 
SELECT * FROM synthetic_test_suite; 
