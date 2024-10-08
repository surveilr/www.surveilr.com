DROP VIEW IF EXISTS "synthetic_test_suite";
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS (SELECT 'TAP version 14' AS tap_result),
        tap_plan AS (SELECT '1..10' AS tap_result),
        -- 0: Check if a view 'border_boundary' exists
"Check if a view 'border_boundary' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'border_boundary'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 0 ' || ('View "border_boundary" exists in the DB') ELSE 'not ok 0 ' || ('View "border_boundary" not exists in the DB') END AS tap_result FROM test_case
),
  -- 1: Ensure at least four boundaries
"Ensure at least four boundaries" AS (
  WITH test_case AS (
    SELECT COUNT(*) AS boundary_count FROM border_boundary
  )
  SELECT CASE WHEN boundary_count = 4 THEN 'ok 1 ' || ('boundary_count is 4') ELSE 'not ok 1 ' || ('boundary_count should be 4, is ' || boundary_count || ' instead') END AS tap_result FROM test_case
),
  -- 2: Check if a baundary named 'User Trust Boundary' exists in the View
"Check if a baundary named 'User Trust Boundary' exists in the View" AS (
  WITH test_case AS (
    SELECT name as boundary_name
  FROM border_boundary
 WHERE name = 'User Trust Boundary'
  )
  SELECT CASE WHEN boundary_name = 'User Trust Boundary' THEN 'ok 2 ' || ('boundary_name is ''User Trust Boundary''') ELSE 'not ok 2 ' || ('boundary_name should be ''User Trust Boundary'', is ' || boundary_name || ' instead') END AS tap_result FROM test_case
),
  -- 3: Check if a baundary named 'DigitalOcean Trust Boundary' exists in the View
"Check if a baundary named 'DigitalOcean Trust Boundary' exists in the View" AS (
  WITH test_case AS (
    SELECT name as boundary_name
  FROM border_boundary
 WHERE name = 'DigitalOcean Trust Boundary'
  )
  SELECT CASE WHEN boundary_name = 'DigitalOcean Trust Boundary' THEN 'ok 3 ' || ('boundary_name is ''DigitalOcean Trust Boundary''') ELSE 'not ok 3 ' || ('boundary_name should be ''DigitalOcean Trust Boundary'', is ' || boundary_name || ' instead') END AS tap_result FROM test_case
),
  -- 4: Check if a baundary named 'FCR Trust Boundary' exists in the View
"Check if a baundary named 'FCR Trust Boundary' exists in the View" AS (
  WITH test_case AS (
    SELECT name as boundary_name
  FROM border_boundary
 WHERE name = 'FCR Trust Boundary'
  )
  SELECT CASE WHEN boundary_name = 'FCR Trust Boundary' THEN 'ok 4 ' || ('boundary_name is ''FCR Trust Boundary''') ELSE 'not ok 4 ' || ('boundary_name should be ''FCR Trust Boundary'', is ' || boundary_name || ' instead') END AS tap_result FROM test_case
),
  -- 5: Check if a baundary named 'Hetzner Trust Boundary' exists in the View
"Check if a baundary named 'Hetzner Trust Boundary' exists in the View" AS (
  WITH test_case AS (
    SELECT name as boundary_name
  FROM border_boundary
 WHERE name = 'Hetzner Trust Boundary'
  )
  SELECT CASE WHEN boundary_name = 'Hetzner Trust Boundary' THEN 'ok 5 ' || ('boundary_name is ''Hetzner Trust Boundary''') ELSE 'not ok 5 ' || ('boundary_name should be ''Hetzner Trust Boundary'', is ' || boundary_name || ' instead') END AS tap_result FROM test_case
),
  -- 6: Check if a view 'asset_service_view' exists
"Check if a view 'asset_service_view' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'asset_service_view'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 6 ' || ('View "asset_service_view" exists in the DB') ELSE 'not ok 6 ' || ('View "asset_service_view" not exists in the DB') END AS tap_result FROM test_case
),
  -- 7: Check if a view 'server_data' exists
"Check if a view 'server_data' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'server_data'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 7 ' || ('View "server_data" exists in the DB') ELSE 'not ok 7 ' || ('View "server_data" not exists in the DB') END AS tap_result FROM test_case
),
  -- 8: Check if a view 'security_incident_response_view' exists
"Check if a view 'security_incident_response_view' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'security_incident_response_view'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 8 ' || ('View "security_incident_response_view" exists in the DB') ELSE 'not ok 8 ' || ('View "security_incident_response_view" not exists in the DB') END AS tap_result FROM test_case
),
  -- 9: Check if a view 'security_impact_analysis_view' exists
"Check if a view 'security_impact_analysis_view' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'security_impact_analysis_view'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 9 ' || ('View "security_impact_analysis_view" exists in the DB') ELSE 'not ok 9 ' || ('View "security_impact_analysis_view" not exists in the DB') END AS tap_result FROM test_case
)
    SELECT tap_result FROM tap_version
    UNION ALL
    SELECT tap_result FROM tap_plan
    UNION ALL
    SELECT tap_result FROM "Check if a view 'border_boundary' exists"
    UNION ALL
SELECT tap_result FROM "Ensure at least four boundaries"
    UNION ALL
SELECT tap_result FROM "Check if a baundary named 'User Trust Boundary' exists in the View"
    UNION ALL
SELECT tap_result FROM "Check if a baundary named 'DigitalOcean Trust Boundary' exists in the View"
    UNION ALL
SELECT tap_result FROM "Check if a baundary named 'FCR Trust Boundary' exists in the View"
    UNION ALL
SELECT tap_result FROM "Check if a baundary named 'Hetzner Trust Boundary' exists in the View"
    UNION ALL
SELECT tap_result FROM "Check if a view 'asset_service_view' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'server_data' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'security_incident_response_view' exists"
    UNION ALL
SELECT tap_result FROM "Check if a view 'security_impact_analysis_view' exists";
SELECT * FROM synthetic_test_suite;
