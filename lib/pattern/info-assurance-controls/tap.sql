DROP VIEW IF EXISTS "synthetic_test_suite";
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS (SELECT 'TAP version 14' AS tap_result),
        tap_plan AS (SELECT '1..6' AS tap_result),
        -- 0: Check if a view 'control_regimes' exists
"Check if a view 'control_regimes' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'control_regimes'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 0 ' || ('View "control_regimes" exists in the DB') ELSE 'not ok 0 ' || ('View "control_regimes" not exists in the DB') END AS tap_result FROM test_case
),
  -- 1: Ensure 'control_regimes' view has values 
"Ensure 'control_regimes' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS control_regimes_count FROM control_regimes
  )
  SELECT CASE WHEN control_regimes_count > 0 THEN 'ok 1 ' || ('control_regimes_count is greater than 0') ELSE 'not ok 1 ' || ('control_regimes_count should be greater than 0, is ' || control_regimes_count || ' instead') END AS tap_result FROM test_case
),
  -- 2: Check if a view 'control_group' exists
"Check if a view 'control_group' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'control_group'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 2 ' || ('View "control_group" exists in the DB') ELSE 'not ok 2 ' || ('View "control_group" not exists in the DB') END AS tap_result FROM test_case
),
  -- 3: Ensure 'control_group' view has values 
"Ensure 'control_group' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS control_group_count FROM control_group
  )
  SELECT CASE WHEN control_group_count > 0 THEN 'ok 3 ' || ('control_group_count is greater than 0') ELSE 'not ok 3 ' || ('control_group_count should be greater than 0, is ' || control_group_count || ' instead') END AS tap_result FROM test_case
),
  -- 4: Check if a view 'control' exists
"Check if a view 'control' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'control'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 4 ' || ('View "control" exists in the DB') ELSE 'not ok 4 ' || ('View "control" not exists in the DB') END AS tap_result FROM test_case
),
  -- 5: Ensure 'control' view has values 
"Ensure 'control' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS control_count FROM control
  )
  SELECT CASE WHEN control_count > 0 THEN 'ok 5 ' || ('control_count is greater than 0') ELSE 'not ok 5 ' || ('control_count should be greater than 0, is ' || control_count || ' instead') END AS tap_result FROM test_case
)
    SELECT tap_result FROM tap_version
    UNION ALL
    SELECT tap_result FROM tap_plan
    UNION ALL
    SELECT tap_result FROM "Check if a view 'control_regimes' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'control_regimes' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'control_group' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'control_group' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'control' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'control' view has values ";
SELECT * FROM synthetic_test_suite;
