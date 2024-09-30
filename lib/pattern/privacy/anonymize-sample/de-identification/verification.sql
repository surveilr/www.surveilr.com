/********************************************************************************************
* This script verifies and validates that some tables and columns were created after a transformation
* orchestration has been performed by converting CSVs to tables. 
* This script might not be needed since you could visually look at what was orchestrated through the web-ui.
* If you'd prefer validating the orchestration through scripting then, this is for you and also, 
* this script is another type of orchestration (verification and validation).

* Functions used:
* - surveilr_assert_tabular_object(<name-of-table-or-view>)
* - surveilr_assert_tabular_column(<name-of-table-or-view>, <a-list-of-column-names>)
* - surveilr_orchestration_session_append_log(<category>, <content>)
 ********************************************************************************************/

 /********************************************************************************************
* Before executing this script, ensure that the following steps have been taken:
* 1. wget https://synthetichealth.github.io/synthea-sample-data/downloads/10k_synthea_covid19_csv.zip
* 2. mkdir ingest && cd ingest && unzip ../10k_synthea_covid19_csv.zip && cd ..
* 3. surveilr ingest files -r ./ingest
* 4. surveilr orchestrate transform-csv
* The above steps prepare the data and get it into the RSSD. This script can then be executed (orchestrated) in two ways:
* 1. Through stdin: cat ./verification.sql | surveilr orchestrate -n "v&v"
* 2. Passing the scripts argument: surveilr orchestrate -n "v&v" -s ./verification.sql
 ********************************************************************************************/

-- Ensure that the orchestration nature you require is in the RSSD. It will create it if it is not present
SELECT surveilr_ensure_orchestration_nature('V&V', 'Verification and Validation', NULL) AS orchestration_nature_id;

-- Define the tables and columns to verify
WITH table_checks AS (
    -- Verify the presence of the table 'uniform_resource_supplies'
    SELECT
        'uniform_resource_supplies' AS table_name,
        surveilr_assert_tabular_object('uniform_resource_supplies') AS table_exists
    UNION ALL
    -- Verify the presence of the table 'uniform_resource_allergies'
    SELECT
        'uniform_resource_allergies' AS table_name,
        surveilr_assert_tabular_object('uniform_resource_allergies') AS table_exists
    UNION ALL
    -- Verify the presence of the table 'uniform_resource_careplans'
    SELECT
        'uniform_resource_careplans' AS table_name,
        surveilr_assert_tabular_object('uniform_resource_careplans') AS table_exists
    UNION ALL
    -- Verify the presence of the table 'uniform_resource_conditions'
    SELECT
        'uniform_resource_conditions' AS table_name,
        surveilr_assert_tabular_object('uniform_resource_conditions') AS table_exists
),
column_checks AS (
    -- Verify the presence of specific columns in 'uniform_resource_supplies'
    SELECT
        'uniform_resource_supplies' AS table_name,
        surveilr_assert_tabular_column('uniform_resource_supplies', 'supply_id,supply_name') AS columns_exist
    UNION ALL
    -- Verify the presence of specific columns in 'uniform_resource_allergies'
    SELECT
        'uniform_resource_allergies' AS table_name,
        surveilr_assert_tabular_column('uniform_resource_allergies', 'allergy_id,allergy_name') AS columns_exist
    UNION ALL
    -- Verify the presence of specific columns in 'uniform_resource_careplans'
    SELECT
        'uniform_resource_careplans' AS table_name,
        surveilr_assert_tabular_column('uniform_resource_careplans', 'careplan_id,careplan_name') AS columns_exist
    UNION ALL
    -- Verify the presence of specific columns in 'uniform_resource_conditions'
    SELECT
        'uniform_resource_conditions' AS table_name,
        surveilr_assert_tabular_column('uniform_resource_conditions', 'condition_id,condition_name') AS columns_exist
)
-- Combine the table and column checks and log the results
SELECT
    surveilr_orchestration_session_append_log('Table Verification', 
        CASE 
            WHEN table_checks.table_exists THEN 'Table ' || table_checks.table_name || ' exists.'
            ELSE 'Table ' || table_checks.table_name || ' does not exist.'
        END
    ) AS table_log,
    surveilr_orchestration_session_append_log('Column Verification', 
        CASE 
            WHEN column_checks.columns_exist THEN 'Columns exist in table ' || column_checks.table_name || '.'
            ELSE 'Columns do not exist in table ' || column_checks.table_name || '.'
        END
    ) AS column_log
FROM table_checks
JOIN column_checks ON table_checks.table_name = column_checks.table_name;
