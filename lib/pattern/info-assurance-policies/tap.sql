DROP VIEW IF EXISTS "synthetic_test_suite";
CREATE VIEW "synthetic_test_suite" AS
    WITH
        tap_version AS (SELECT 'TAP version 14' AS tap_result),
        tap_plan AS (SELECT '1..32' AS tap_result),
        -- 0: Check if a view 'policy_dashboard' exists
"Check if a view 'policy_dashboard' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'policy_dashboard'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 0 ' || ('View "policy_dashboard" exists in the DB') ELSE 'not ok 0 ' || ('View "policy_dashboard" not exists in the DB') END AS tap_result FROM test_case
),
  -- 1: Ensure 'policy_dashboard' view has values 
"Ensure 'policy_dashboard' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS policy_dashboard_count FROM policy_dashboard
  )
  SELECT CASE WHEN policy_dashboard_count > 0 THEN 'ok 1 ' || ('policy_dashboard_count is greater than 0') ELSE 'not ok 1 ' || ('policy_dashboard_count should be greater than 0, is ' || policy_dashboard_count || ' instead') END AS tap_result FROM test_case
),
  -- 2: Check if a view 'policy_detail' exists
"Check if a view 'policy_detail' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'policy_detail'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 2 ' || ('View "policy_detail" exists in the DB') ELSE 'not ok 2 ' || ('View "policy_detail" not exists in the DB') END AS tap_result FROM test_case
),
  -- 3: Ensure 'policy_detail' view has values 
"Ensure 'policy_detail' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS policy_detail_count FROM policy_detail
  )
  SELECT CASE WHEN policy_detail_count > 0 THEN 'ok 3 ' || ('policy_detail_count is greater than 0') ELSE 'not ok 3 ' || ('policy_detail_count should be greater than 0, is ' || policy_detail_count || ' instead') END AS tap_result FROM test_case
),
  -- 4: Check if a view 'policy_list' exists
"Check if a view 'policy_list' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'policy_list'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 4 ' || ('View "policy_list" exists in the DB') ELSE 'not ok 4 ' || ('View "policy_list" not exists in the DB') END AS tap_result FROM test_case
),
  -- 5: Ensure 'policy_list' view has values 
"Ensure 'policy_list' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS policy_list_count FROM policy_list
  )
  SELECT CASE WHEN policy_list_count > 0 THEN 'ok 5 ' || ('policy_list_count is greater than 0') ELSE 'not ok 5 ' || ('policy_list_count should be greater than 0, is ' || policy_list_count || ' instead') END AS tap_result FROM test_case
),
  -- 6: Check if a view 'vigetallviews' exists
"Check if a view 'vigetallviews' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'vigetallviews'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 6 ' || ('View "vigetallviews" exists in the DB') ELSE 'not ok 6 ' || ('View "vigetallviews" not exists in the DB') END AS tap_result FROM test_case
),
  -- 7: Ensure 'vigetallviews' view has values 
"Ensure 'vigetallviews' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS vigetallviews_count FROM vigetallviews
  )
  SELECT CASE WHEN vigetallviews_count > 0 THEN 'ok 7 ' || ('vigetallviews_count is greater than 0') ELSE 'not ok 7 ' || ('vigetallviews_count should be greater than 0, is ' || vigetallviews_count || ' instead') END AS tap_result FROM test_case
),
  -- 8: Check if a view 'viup_time' exists
"Check if a view 'viup_time' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'viup_time'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 8 ' || ('View "viup_time" exists in the DB') ELSE 'not ok 8 ' || ('View "viup_time" not exists in the DB') END AS tap_result FROM test_case
),
  -- 9: Ensure 'viup_time' view has values 
"Ensure 'viup_time' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS viup_time_count FROM viup_time
  )
  SELECT CASE WHEN viup_time_count > 0 THEN 'ok 9 ' || ('viup_time_count is greater than 0') ELSE 'not ok 9 ' || ('viup_time_count should be greater than 0, is ' || viup_time_count || ' instead') END AS tap_result FROM test_case
),
  -- 10: Check if a view 'viLog' exists
"Check if a view 'viLog' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'viLog'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 10 ' || ('View "viLog" exists in the DB') ELSE 'not ok 10 ' || ('View "viLog" not exists in the DB') END AS tap_result FROM test_case
),
  -- 11: Ensure 'viLog' view has values 
"Ensure 'viLog' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS viLog_count FROM viLog
  )
  SELECT CASE WHEN viLog_count > 0 THEN 'ok 11 ' || ('viLog_count is greater than 0') ELSE 'not ok 11 ' || ('viLog_count should be greater than 0, is ' || viLog_count || ' instead') END AS tap_result FROM test_case
),
  -- 12: Check if a view 'viencrypted_passwords' exists
"Check if a view 'viencrypted_passwords' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'viencrypted_passwords'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 12 ' || ('View "viencrypted_passwords" exists in the DB') ELSE 'not ok 12 ' || ('View "viencrypted_passwords" not exists in the DB') END AS tap_result FROM test_case
),
  -- 13: Ensure 'viencrypted_passwords' view has values 
"Ensure 'viencrypted_passwords' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS viencrypted_passwords_count FROM viencrypted_passwords
  )
  SELECT CASE WHEN viencrypted_passwords_count > 0 THEN 'ok 13 ' || ('viencrypted_passwords_count is greater than 0') ELSE 'not ok 13 ' || ('viencrypted_passwords_count should be greater than 0, is ' || viencrypted_passwords_count || ' instead') END AS tap_result FROM test_case
),
  -- 14: Check if a view 'vinetwork_log' exists
"Check if a view 'vinetwork_log' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'vinetwork_log'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 14 ' || ('View "vinetwork_log" exists in the DB') ELSE 'not ok 14 ' || ('View "vinetwork_log" not exists in the DB') END AS tap_result FROM test_case
),
  -- 15: Ensure 'vinetwork_log' view has values 
"Ensure 'vinetwork_log' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS vinetwork_log_count FROM vinetwork_log
  )
  SELECT CASE WHEN vinetwork_log_count > 0 THEN 'ok 15 ' || ('vinetwork_log_count is greater than 0') ELSE 'not ok 15 ' || ('vinetwork_log_count should be greater than 0, is ' || vinetwork_log_count || ' instead') END AS tap_result FROM test_case
),
  -- 16: Check if a view 'vissl_certificate' exists
"Check if a view 'vissl_certificate' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'vissl_certificate'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 16 ' || ('View "vissl_certificate" exists in the DB') ELSE 'not ok 16 ' || ('View "vissl_certificate" not exists in the DB') END AS tap_result FROM test_case
),
  -- 17: Ensure 'vissl_certificate' view has values 
"Ensure 'vissl_certificate' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS vissl_certificate_count FROM vissl_certificate
  )
  SELECT CASE WHEN vissl_certificate_count > 0 THEN 'ok 17 ' || ('vissl_certificate_count is greater than 0') ELSE 'not ok 17 ' || ('vissl_certificate_count should be greater than 0, is ' || vissl_certificate_count || ' instead') END AS tap_result FROM test_case
),
  -- 18: Check if a view 'vistorage_available' exists
"Check if a view 'vistorage_available' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'vistorage_available'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 18 ' || ('View "vistorage_available" exists in the DB') ELSE 'not ok 18 ' || ('View "vistorage_available" not exists in the DB') END AS tap_result FROM test_case
),
  -- 19: Ensure 'vistorage_available' view has values 
"Ensure 'vistorage_available' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS vistorage_available_count FROM vistorage_available
  )
  SELECT CASE WHEN vistorage_available_count > 0 THEN 'ok 19 ' || ('vistorage_available_count is greater than 0') ELSE 'not ok 19 ' || ('vistorage_available_count should be greater than 0, is ' || vistorage_available_count || ' instead') END AS tap_result FROM test_case
),
  -- 20: Check if a view 'viram_utilization' exists
"Check if a view 'viram_utilization' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'viram_utilization'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 20 ' || ('View "viram_utilization" exists in the DB') ELSE 'not ok 20 ' || ('View "viram_utilization" not exists in the DB') END AS tap_result FROM test_case
),
  -- 21: Ensure 'viram_utilization' view has values 
"Ensure 'viram_utilization' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS viram_utilization_count FROM viram_utilization
  )
  SELECT CASE WHEN viram_utilization_count > 0 THEN 'ok 21 ' || ('viram_utilization_count is greater than 0') ELSE 'not ok 21 ' || ('viram_utilization_count should be greater than 0, is ' || viram_utilization_count || ' instead') END AS tap_result FROM test_case
),
  -- 22: Check if a view 'vicpu_infomation' exists
"Check if a view 'vicpu_infomation' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'vicpu_infomation'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 22 ' || ('View "vicpu_infomation" exists in the DB') ELSE 'not ok 22 ' || ('View "vicpu_infomation" not exists in the DB') END AS tap_result FROM test_case
),
  -- 23: Ensure 'vicpu_infomation' view has values 
"Ensure 'vicpu_infomation' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS vicpu_infomation_count FROM vicpu_infomation
  )
  SELECT CASE WHEN vicpu_infomation_count > 0 THEN 'ok 23 ' || ('vicpu_infomation_count is greater than 0') ELSE 'not ok 23 ' || ('vicpu_infomation_count should be greater than 0, is ' || vicpu_infomation_count || ' instead') END AS tap_result FROM test_case
),
  -- 24: Check if a view 'viaccounts_removed' exists
"Check if a view 'viaccounts_removed' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'viaccounts_removed'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 24 ' || ('View "viaccounts_removed" exists in the DB') ELSE 'not ok 24 ' || ('View "viaccounts_removed" not exists in the DB') END AS tap_result FROM test_case
),
  -- 25: Ensure 'viaccounts_removed' view has values 
"Ensure 'viaccounts_removed' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS viaccounts_removed_count FROM viaccounts_removed
  )
  SELECT CASE WHEN viaccounts_removed_count > 0 THEN 'ok 25 ' || ('viaccounts_removed_count is greater than 0') ELSE 'not ok 25 ' || ('viaccounts_removed_count should be greater than 0, is ' || viaccounts_removed_count || ' instead') END AS tap_result FROM test_case
),
  -- 26: Check if a view 'vissh_settings' exists
"Check if a view 'vissh_settings' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'vissh_settings'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 26 ' || ('View "vissh_settings" exists in the DB') ELSE 'not ok 26 ' || ('View "vissh_settings" not exists in the DB') END AS tap_result FROM test_case
),
  -- 27: Ensure 'vissh_settings' view has values 
"Ensure 'vissh_settings' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS vissh_settings_count FROM vissh_settings
  )
  SELECT CASE WHEN vissh_settings_count > 0 THEN 'ok 27 ' || ('vissh_settings_count is greater than 0') ELSE 'not ok 27 ' || ('vissh_settings_count should be greater than 0, is ' || vissh_settings_count || ' instead') END AS tap_result FROM test_case
),
  -- 28: Check if a view 'viunsuccessful_attempts_log' exists
"Check if a view 'viunsuccessful_attempts_log' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'viunsuccessful_attempts_log'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 28 ' || ('View "viunsuccessful_attempts_log" exists in the DB') ELSE 'not ok 28 ' || ('View "viunsuccessful_attempts_log" not exists in the DB') END AS tap_result FROM test_case
),
  -- 29: Ensure 'viunsuccessful_attempts_log' view has values 
"Ensure 'viunsuccessful_attempts_log' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS viunsuccessful_attempts_log_count FROM viunsuccessful_attempts_log
  )
  SELECT CASE WHEN viunsuccessful_attempts_log_count > 0 THEN 'ok 29 ' || ('viunsuccessful_attempts_log_count is greater than 0') ELSE 'not ok 29 ' || ('viunsuccessful_attempts_log_count should be greater than 0, is ' || viunsuccessful_attempts_log_count || ' instead') END AS tap_result FROM test_case
),
  -- 30: Check if a view 'viauthentication' exists
"Check if a view 'viauthentication' exists" AS (
  WITH test_case AS (
    SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = 'viauthentication'
  )
  SELECT CASE WHEN exist = 1 THEN 'ok 30 ' || ('View "viauthentication" exists in the DB') ELSE 'not ok 30 ' || ('View "viauthentication" not exists in the DB') END AS tap_result FROM test_case
),
  -- 31: Ensure 'viauthentication' view has values 
"Ensure 'viauthentication' view has values " AS (
  WITH test_case AS (
    SELECT COUNT(*) AS viauthentication_count FROM viauthentication
  )
  SELECT CASE WHEN viauthentication_count > 0 THEN 'ok 31 ' || ('viauthentication_count is greater than 0') ELSE 'not ok 31 ' || ('viauthentication_count should be greater than 0, is ' || viauthentication_count || ' instead') END AS tap_result FROM test_case
)
    SELECT tap_result FROM tap_version
    UNION ALL
    SELECT tap_result FROM tap_plan
    UNION ALL
    SELECT tap_result FROM "Check if a view 'policy_dashboard' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'policy_dashboard' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'policy_detail' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'policy_detail' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'policy_list' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'policy_list' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'vigetallviews' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'vigetallviews' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'viup_time' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'viup_time' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'viLog' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'viLog' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'viencrypted_passwords' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'viencrypted_passwords' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'vinetwork_log' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'vinetwork_log' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'vissl_certificate' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'vissl_certificate' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'vistorage_available' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'vistorage_available' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'viram_utilization' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'viram_utilization' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'vicpu_infomation' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'vicpu_infomation' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'viaccounts_removed' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'viaccounts_removed' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'vissh_settings' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'vissh_settings' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'viunsuccessful_attempts_log' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'viunsuccessful_attempts_log' view has values "
    UNION ALL
SELECT tap_result FROM "Check if a view 'viauthentication' exists"
    UNION ALL
SELECT tap_result FROM "Ensure 'viauthentication' view has values ";
SELECT * FROM synthetic_test_suite;
