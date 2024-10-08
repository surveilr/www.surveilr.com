DROP VIEW IF EXISTS "synthetic_test_suite";
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS (SELECT 'TAP version 14' AS tap_result),
        tap_plan AS (SELECT '1..4' AS tap_result),
        -- 0: Check if a view 'threat_model' exists
"Check if a view 'threat_model' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'threat_model'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 0 ' || ('View "threat_model" exists in the DB') ELSE 'not ok 0 ' || ('View "threat_model" not exists in the DB') END AS tap_result FROM test_case
),
  -- 1: Ensure 'threat_model' view has values 
"Ensure 'threat_model' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS threat_model_count FROM threat_model
  )
  SELECT CASE WHEN threat_model_count > 0 THEN 'ok 1 ' || ('threat_model_count is greater than 0') ELSE 'not ok 1 ' || ('threat_model_count should be greater than 0, is ' || threat_model_count || ' instead') END AS tap_result FROM test_case
),
  -- 2: Check if a view 'sql_database' exists
"Check if a view 'sql_database' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'sql_database'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 2 ' || ('View "sql_database" exists in the DB') ELSE 'not ok 2 ' || ('View "sql_database" not exists in the DB') END AS tap_result FROM test_case
),
  -- 3: Ensure 'sql_database' view has values 
"Ensure 'sql_database' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS sql_database_count FROM threat_model
  )
  SELECT CASE WHEN sql_database_count > 0 THEN 'ok 3 ' || ('sql_database_count is greater than 0') ELSE 'not ok 3 ' || ('sql_database_count should be greater than 0, is ' || sql_database_count || ' instead') END AS tap_result FROM test_case
)
    SELECT tap_result FROM tap_version
    UNION ALL
    SELECT tap_result FROM tap_plan
    UNION ALL
    SELECT tap_result FROM "Check if a view 'threat_model' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'threat_model' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'sql_database' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'sql_database' view has values ";
SELECT * FROM synthetic_test_suite;
