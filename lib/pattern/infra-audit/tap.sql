DROP VIEW IF EXISTS "synthetic_test_suite";
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS (SELECT 'TAP version 14' AS tap_result),
        tap_plan AS (SELECT '1..34' AS tap_result),
        -- 0: Check if a view 'tenant_based_control_regime' exists
"Check if a view 'tenant_based_control_regime' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'tenant_based_control_regime'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 0 ' || ('View "tenant_based_control_regime" exists in the DB') ELSE 'not ok 0 ' || ('View "tenant_based_control_regime" not exists in the DB') END AS tap_result FROM test_case
),
  -- 1: Ensure 'tenant_based_control_regime' view has values 
"Ensure 'tenant_based_control_regime' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS tenant_based_control_regime_count FROM tenant_based_control_regime
  )
  SELECT CASE WHEN tenant_based_control_regime_count > 0 THEN 'ok 1 ' || ('tenant_based_control_regime_count is greater than 0') ELSE 'not ok 1 ' || ('tenant_based_control_regime_count should be greater than 0, is ' || tenant_based_control_regime_count || ' instead') END AS tap_result FROM test_case
),
  -- 2: Check if a view 'audit_session_control' exists
"Check if a view 'audit_session_control' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'audit_session_control'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 2 ' || ('View "audit_session_control" exists in the DB') ELSE 'not ok 2 ' || ('View "audit_session_control" not exists in the DB') END AS tap_result FROM test_case
),
  -- 3: Ensure 'audit_session_control' view has values 
"Ensure 'audit_session_control' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS audit_session_control_count FROM audit_session_control
  )
  SELECT CASE WHEN audit_session_control_count > 0 THEN 'ok 3 ' || ('audit_session_control_count is greater than 0') ELSE 'not ok 3 ' || ('audit_session_control_count should be greater than 0, is ' || audit_session_control_count || ' instead') END AS tap_result FROM test_case
),
  -- 4: Check if a view 'audit_session_list' exists
"Check if a view 'audit_session_list' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'audit_session_list'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 4 ' || ('View "audit_session_list" exists in the DB') ELSE 'not ok 4 ' || ('View "audit_session_list" not exists in the DB') END AS tap_result FROM test_case
),
  -- 5: Ensure 'audit_session_list' view has values 
"Ensure 'audit_session_list' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS audit_session_list_count FROM audit_session_list
  )
  SELECT CASE WHEN audit_session_list_count > 0 THEN 'ok 5 ' || ('audit_session_list_count is greater than 0') ELSE 'not ok 5 ' || ('audit_session_list_count should be greater than 0, is ' || audit_session_list_count || ' instead') END AS tap_result FROM test_case
),
  -- 6: Check if a view 'query_result' exists
"Check if a view 'query_result' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'query_result'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 6 ' || ('View "query_result" exists in the DB') ELSE 'not ok 6 ' || ('View "query_result" not exists in the DB') END AS tap_result FROM test_case
),
  -- 7: Ensure 'query_result' view has values 
"Ensure 'query_result' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS query_result_count FROM query_result
  )
  SELECT CASE WHEN query_result_count > 0 THEN 'ok 7 ' || ('query_result_count is greater than 0') ELSE 'not ok 7 ' || ('query_result_count should be greater than 0, is ' || query_result_count || ' instead') END AS tap_result FROM test_case
),
  -- 8: Check if a view 'audit_session_info' exists
"Check if a view 'audit_session_info' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'audit_session_info'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 8 ' || ('View "audit_session_info" exists in the DB') ELSE 'not ok 8 ' || ('View "audit_session_info" not exists in the DB') END AS tap_result FROM test_case
),
  -- 9: Ensure 'audit_session_info' view has values 
"Ensure 'audit_session_info' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS audit_session_info_count FROM audit_session_info
  )
  SELECT CASE WHEN audit_session_info_count > 0 THEN 'ok 9 ' || ('audit_session_info_count is greater than 0') ELSE 'not ok 9 ' || ('audit_session_info_count should be greater than 0, is ' || audit_session_info_count || ' instead') END AS tap_result FROM test_case
),
  -- 10: Check if a view 'evidence_query_result' exists
"Check if a view 'evidence_query_result' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'evidence_query_result'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 10 ' || ('View "evidence_query_result" exists in the DB') ELSE 'not ok 10 ' || ('View "evidence_query_result" not exists in the DB') END AS tap_result FROM test_case
),
  -- 11: Ensure 'evidence_query_result' view has values 
"Ensure 'evidence_query_result' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS evidence_query_result_count FROM evidence_query_result
  )
  SELECT CASE WHEN evidence_query_result_count > 0 THEN 'ok 11 ' || ('evidence_query_result_count is greater than 0') ELSE 'not ok 11 ' || ('evidence_query_result_count should be greater than 0, is ' || evidence_query_result_count || ' instead') END AS tap_result FROM test_case
),
  -- 12: Check if a view 'audit_session_control_group' exists
"Check if a view 'audit_session_control_group' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'audit_session_control_group'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 12 ' || ('View "audit_session_control_group" exists in the DB') ELSE 'not ok 12 ' || ('View "audit_session_control_group" not exists in the DB') END AS tap_result FROM test_case
),
  -- 13: Ensure 'audit_session_control_group' view has values 
"Ensure 'audit_session_control_group' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS audit_session_control_group_count FROM audit_session_control_group
  )
  SELECT CASE WHEN audit_session_control_group_count > 0 THEN 'ok 13 ' || ('audit_session_control_group_count is greater than 0') ELSE 'not ok 13 ' || ('audit_session_control_group_count should be greater than 0, is ' || audit_session_control_group_count || ' instead') END AS tap_result FROM test_case
),
  -- 14: Check if a view 'audit_control_evidence' exists
"Check if a view 'audit_control_evidence' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'audit_control_evidence'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 14 ' || ('View "audit_control_evidence" exists in the DB') ELSE 'not ok 14 ' || ('View "audit_control_evidence" not exists in the DB') END AS tap_result FROM test_case
),
  -- 15: Ensure 'audit_control_evidence' view has values 
"Ensure 'audit_control_evidence' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS audit_control_evidence_count FROM audit_control_evidence
  )
  SELECT CASE WHEN audit_control_evidence_count > 0 THEN 'ok 15 ' || ('audit_control_evidence_count is greater than 0') ELSE 'not ok 15 ' || ('audit_control_evidence_count should be greater than 0, is ' || audit_control_evidence_count || ' instead') END AS tap_result FROM test_case
),
  -- 16: Check if a view 'policy' exists
"Check if a view 'policy' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'policy'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 16 ' || ('View "policy" exists in the DB') ELSE 'not ok 16 ' || ('View "policy" not exists in the DB') END AS tap_result FROM test_case
),
  -- 17: Ensure 'policy' view has values 
"Ensure 'policy' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS policy_count FROM policy
  )
  SELECT CASE WHEN policy_count > 0 THEN 'ok 17 ' || ('policy_count is greater than 0') ELSE 'not ok 17 ' || ('policy_count should be greater than 0, is ' || policy_count || ' instead') END AS tap_result FROM test_case
),
  -- 18: Check if a view 'evidence' exists
"Check if a view 'evidence' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'evidence'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 18 ' || ('View "evidence" exists in the DB') ELSE 'not ok 18 ' || ('View "evidence" not exists in the DB') END AS tap_result FROM test_case
),
  -- 19: Ensure 'evidence' view has values 
"Ensure 'evidence' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS evidence_count FROM evidence
  )
  SELECT CASE WHEN evidence_count > 0 THEN 'ok 19 ' || ('evidence_count is greater than 0') ELSE 'not ok 19 ' || ('evidence_count should be greater than 0, is ' || evidence_count || ' instead') END AS tap_result FROM test_case
),
  -- 20: Check if a view 'evidence_evidenceresult' exists
"Check if a view 'evidence_evidenceresult' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'evidence_evidenceresult'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 20 ' || ('View "evidence_evidenceresult" exists in the DB') ELSE 'not ok 20 ' || ('View "evidence_evidenceresult" not exists in the DB') END AS tap_result FROM test_case
),
  -- 21: Ensure 'evidence_evidenceresult' view has values 
"Ensure 'evidence_evidenceresult' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS evidence_evidenceresult_count FROM evidence_evidenceresult
  )
  SELECT CASE WHEN evidence_evidenceresult_count > 0 THEN 'ok 21 ' || ('evidence_evidenceresult_count is greater than 0') ELSE 'not ok 21 ' || ('evidence_evidenceresult_count should be greater than 0, is ' || evidence_evidenceresult_count || ' instead') END AS tap_result FROM test_case
),
  -- 22: Check if a view 'evidence_customtag' exists
"Check if a view 'evidence_customtag' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'evidence_customtag'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 22 ' || ('View "evidence_customtag" exists in the DB') ELSE 'not ok 22 ' || ('View "evidence_customtag" not exists in the DB') END AS tap_result FROM test_case
),
  -- 23: Ensure 'evidence_customtag' view has values 
"Ensure 'evidence_customtag' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS evidence_customtag_count FROM evidence_customtag
  )
  SELECT CASE WHEN evidence_customtag_count > 0 THEN 'ok 23 ' || ('evidence_customtag_count is greater than 0') ELSE 'not ok 23 ' || ('evidence_customtag_count should be greater than 0, is ' || evidence_customtag_count || ' instead') END AS tap_result FROM test_case
),
  -- 24: Check if a view 'evidence_anchortag' exists
"Check if a view 'evidence_anchortag' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'evidence_anchortag'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 24 ' || ('View "evidence_anchortag" exists in the DB') ELSE 'not ok 24 ' || ('View "evidence_anchortag" not exists in the DB') END AS tap_result FROM test_case
),
  -- 25: Ensure 'evidence_anchortag' view has values 
"Ensure 'evidence_anchortag' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS evidence_anchortag_count FROM evidence_anchortag
  )
  SELECT CASE WHEN evidence_anchortag_count > 0 THEN 'ok 25 ' || ('evidence_anchortag_count is greater than 0') ELSE 'not ok 25 ' || ('evidence_anchortag_count should be greater than 0, is ' || evidence_anchortag_count || ' instead') END AS tap_result FROM test_case
),
  -- 26: Check if a view 'evidence_imagetag' exists
"Check if a view 'evidence_imagetag' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'evidence_imagetag'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 26 ' || ('View "evidence_imagetag" exists in the DB') ELSE 'not ok 26 ' || ('View "evidence_imagetag" not exists in the DB') END AS tap_result FROM test_case
),
  -- 27: Ensure 'evidence_imagetag' view has values 
"Ensure 'evidence_imagetag' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS evidence_imagetag_count FROM evidence_imagetag
  )
  SELECT CASE WHEN evidence_imagetag_count > 0 THEN 'ok 27 ' || ('evidence_imagetag_count is greater than 0') ELSE 'not ok 27 ' || ('evidence_imagetag_count should be greater than 0, is ' || evidence_imagetag_count || ' instead') END AS tap_result FROM test_case
),
  -- 28: Check if a view 'audit_session_control_status' exists
"Check if a view 'audit_session_control_status' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'audit_session_control_status'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 28 ' || ('View "audit_session_control_status" exists in the DB') ELSE 'not ok 28 ' || ('View "audit_session_control_status" not exists in the DB') END AS tap_result FROM test_case
),
  -- 29: Ensure 'audit_session_control_status' view has values 
"Ensure 'audit_session_control_status' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS audit_session_control_status_count FROM audit_session_control_status
  )
  SELECT CASE WHEN audit_session_control_status_count > 0 THEN 'ok 29 ' || ('audit_session_control_status_count is greater than 0') ELSE 'not ok 29 ' || ('audit_session_control_status_count should be greater than 0, is ' || audit_session_control_status_count || ' instead') END AS tap_result FROM test_case
),
  -- 30: Check if a view 'control_group' exists
"Check if a view 'control_group' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'control_group'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 30 ' || ('View "control_group" exists in the DB') ELSE 'not ok 30 ' || ('View "control_group" not exists in the DB') END AS tap_result FROM test_case
),
  -- 31: Ensure 'control_group' view has values 
"Ensure 'control_group' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS control_group_count FROM control_group
  )
  SELECT CASE WHEN control_group_count > 0 THEN 'ok 31 ' || ('control_group_count is greater than 0') ELSE 'not ok 31 ' || ('control_group_count should be greater than 0, is ' || control_group_count || ' instead') END AS tap_result FROM test_case
),
  -- 32: Check if a view 'control' exists
"Check if a view 'control' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'control'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 32 ' || ('View "control" exists in the DB') ELSE 'not ok 32 ' || ('View "control" not exists in the DB') END AS tap_result FROM test_case
),
  -- 33: Ensure 'control' view has values 
"Ensure 'control' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS control_count FROM control
  )
  SELECT CASE WHEN control_count > 0 THEN 'ok 33 ' || ('control_count is greater than 0') ELSE 'not ok 33 ' || ('control_count should be greater than 0, is ' || control_count || ' instead') END AS tap_result FROM test_case
)
    SELECT tap_result FROM tap_version
    UNION ALL
    SELECT tap_result FROM tap_plan
    UNION ALL
    SELECT tap_result FROM "Check if a view 'tenant_based_control_regime' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'tenant_based_control_regime' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'audit_session_control' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'audit_session_control' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'audit_session_list' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'audit_session_list' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'query_result' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'query_result' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'audit_session_info' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'audit_session_info' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'evidence_query_result' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'evidence_query_result' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'audit_session_control_group' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'audit_session_control_group' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'audit_control_evidence' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'audit_control_evidence' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'policy' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'policy' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'evidence' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'evidence' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'evidence_evidenceresult' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'evidence_evidenceresult' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'evidence_customtag' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'evidence_customtag' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'evidence_anchortag' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'evidence_anchortag' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'evidence_imagetag' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'evidence_imagetag' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'audit_session_control_status' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'audit_session_control_status' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'control_group' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'control_group' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'control' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'control' view has values ";
SELECT * FROM synthetic_test_suite;
