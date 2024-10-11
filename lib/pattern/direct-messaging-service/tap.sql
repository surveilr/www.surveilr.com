DROP VIEW IF EXISTS "synthetic_test_suite";
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS (SELECT 'TAP version 14' AS tap_result),
        tap_plan AS (SELECT '1..12' AS tap_result),
        -- 0: Check table 'sql_page_aide_navigation' exists
"Check table 'sql_page_aide_navigation' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'inbox'
  )
  SELECT CASE WHEN name = 'inbox' THEN 'ok 0 ' || ('View "inbox" exists in the DB') ELSE 'not ok 0 ' || ('View "inbox" exists in the DB') END AS tap_result FROM test_case
),
  -- 1: Check if a view 'inbox' exists
"Check if a view 'inbox' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'inbox'
  )
  SELECT CASE WHEN name = 'inbox' THEN 'ok 1 ' || ('View "inbox" exists in the DB') ELSE 'not ok 1 ' || ('View "inbox" exists in the DB') END AS tap_result FROM test_case
),
  -- 2: Ensure at least 1 inbox content exists
"Ensure at least 1 inbox content exists" AS (
  WITH test_case AS (
    SELECT COUNT(*) AS inbox_count FROM inbox
  )
  SELECT CASE WHEN inbox_count > 0 THEN 'ok 2 ' || ('inbox_count is greater than 0') ELSE 'not ok 2 ' || ('inbox_count should be greater than 0, is ' || inbox_count || ' instead') END AS tap_result FROM test_case
),
  -- 3: Check if a view 'mail_content_attachment' exists
"Check if a view 'mail_content_attachment' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'mail_content_attachment'
  )
  SELECT CASE WHEN name = 'mail_content_attachment' THEN 'ok 3 ' || ('View "mail_content_attachment" exists in the DB') ELSE 'not ok 3 ' || ('View "mail_content_attachment" exists in the DB') END AS tap_result FROM test_case
),
  -- 4: Check if a view 'patient_detail' exists
"Check if a view 'patient_detail' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'patient_detail'
  )
  SELECT CASE WHEN name = 'patient_detail' THEN 'ok 4 ' || ('View "patient_detail" exists in the DB') ELSE 'not ok 4 ' || ('View "patient_detail" exists in the DB') END AS tap_result FROM test_case
),
  -- 5: Check for each inbox item, a patient data exists in 'patient_detail'
"Check for each inbox item, a patient data exists in 'patient_detail'" AS (
  WITH test_case AS (
    SELECT count(*) as patient_count from inbox i INNER JOIN patient_detail WHERE i.id = message_uid
  )
  SELECT CASE WHEN patient_count = (select count(*) as inbox_count from inbox) THEN 'ok 5 ' || ('patient_count is (select count(*) as inbox_count from inbox)') ELSE 'not ok 5 ' || ('patient_count should be (select count(*) as inbox_count from inbox), is ' || patient_count || ' instead') END AS tap_result FROM test_case
),
  -- 6: Check if a view 'patient_observation' exists
"Check if a view 'patient_observation' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'patient_observation'
  )
  SELECT CASE WHEN name = 'patient_observation' THEN 'ok 6 ' || ('View "patient_observation" exists in the DB') ELSE 'not ok 6 ' || ('View "patient_observation" exists in the DB') END AS tap_result FROM test_case
),
  -- 7: Check if a view 'author_detail' exists
"Check if a view 'author_detail' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'author_detail'
  )
  SELECT CASE WHEN name = 'author_detail' THEN 'ok 7 ' || ('View "author_detail" exists in the DB') ELSE 'not ok 7 ' || ('View "author_detail" exists in the DB') END AS tap_result FROM test_case
),
  -- 8: Check if a view 'patient_lab_report' exists
"Check if a view 'patient_lab_report' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'patient_lab_report'
  )
  SELECT CASE WHEN name = 'patient_lab_report' THEN 'ok 8 ' || ('View "patient_lab_report" exists in the DB') ELSE 'not ok 8 ' || ('View "patient_lab_report" exists in the DB') END AS tap_result FROM test_case
),
  -- 9: Check if a view 'patient_social_history' exists
"Check if a view 'patient_social_history' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'patient_social_history'
  )
  SELECT CASE WHEN name = 'patient_social_history' THEN 'ok 9 ' || ('View "patient_social_history" exists in the DB') ELSE 'not ok 9 ' || ('View "patient_social_history" exists in the DB') END AS tap_result FROM test_case
),
  -- 10: Check if a view 'patient_immunization_data' exists
"Check if a view 'patient_immunization_data' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'patient_immunization_data'
  )
  SELECT CASE WHEN name = 'patient_immunization_data' THEN 'ok 10 ' || ('View "patient_immunization_data" exists in the DB') ELSE 'not ok 10 ' || ('View "patient_immunization_data" exists in the DB') END AS tap_result FROM test_case
),
  -- 11: Check if a view 'patient_medical_equipment' exists
"Check if a view 'patient_medical_equipment' exists" AS (
  WITH test_case AS (
    SELECT name FROM sqlite_master WHERE type = 'view' AND name = 'patient_medical_equipment'
  )
  SELECT CASE WHEN name = 'patient_medical_equipment' THEN 'ok 11 ' || ('View "patient_medical_equipment" exists in the DB') ELSE 'not ok 11 ' || ('View "patient_medical_equipment" exists in the DB') END AS tap_result FROM test_case
)
    SELECT tap_result FROM tap_version
    UNION ALL
    SELECT tap_result FROM tap_plan
    UNION ALL
    SELECT tap_result FROM "Check table 'sql_page_aide_navigation' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'inbox' exists"
    UNION ALL
SELECT tap_result FROM "Ensure at least 1 inbox content exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'mail_content_attachment' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'patient_detail' exists"
    UNION ALL
SELECT tap_result FROM "Check for each inbox item, a patient data exists in 'patient_detail'"
    UNION ALL
SELECT tap_result FROM "Check if a view 'patient_observation' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'author_detail' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'patient_lab_report' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'patient_social_history' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'patient_immunization_data' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'patient_medical_equipment' exists";
SELECT * FROM synthetic_test_suite;
