DROP VIEW IF EXISTS "synthetic_test_suite";
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS (SELECT 'TAP version 14' AS tap_result),
        tap_plan AS (SELECT '1..6' AS tap_result),
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
  -- 5: Check for each inbox item a patient data exists in 'patient_detail'
"Check for each inbox item a patient data exists in 'patient_detail'" AS (
  WITH test_case AS (
    SELECT count(*) as patient_count from inbox i INNER JOIN patient_detail WHERE i.id = message_uid
  )
  SELECT CASE WHEN patient_count = (select count(*) as inbox_count from inbox) THEN 'ok 5 ' || ('patient_count is (select count(*) as inbox_count from inbox)') ELSE 'not ok 5 ' || ('patient_count should be (select count(*) as inbox_count from inbox), is ' || patient_count || ' instead') END AS tap_result FROM test_case
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
SELECT tap_result FROM "Check for each inbox item a patient data exists in 'patient_detail'";
SELECT * FROM synthetic_test_suite;
