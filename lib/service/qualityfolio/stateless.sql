-- DROP VIEW IF EXISTS projects;
-- CREATE view projects AS
-- SELECT 
-- uniform_resource_id,
-- json_extract(frontmatter, '$.id') AS project_id,
-- json_extract(frontmatter, '$.name') AS project_name,
-- json_extract(frontmatter, '$.description') AS description,
-- json_extract(frontmatter, '$.created_by') AS created_by,
-- json_extract(frontmatter, '$.created_at') AS created_at,
-- json_extract(frontmatter, '$.last_updated_at') AS last_updated_at,
-- json_extract(frontmatter, '$.status') AS status,
-- json_extract(frontmatter, '$.tags') AS tags,
-- json_extract(frontmatter, '$.linked_requirements') AS linked_requirements,
-- json_extract(frontmatter, '$.dependencies') AS dependencies,
-- json_extract(frontmatter, '$.goals') AS goals,
-- json_extract(frontmatter, '$.critical_milestones') AS critical_milestones
-- FROM uniform_resource
-- WHERE uri LIKE '%/qf-project.md';

-- DROP VIEW IF EXISTS test_suites;
-- CREATE view test_suites AS
-- SELECT 
--     uniform_resource_id,
--     json_extract(frontmatter, '$.id') AS id,
--     json_extract(frontmatter, '$.projectId') AS project_id,
--     json_extract(frontmatter, '$.name') AS name,
--     json_extract(frontmatter, '$.description') AS description,
--     json_extract(frontmatter, '$.created_by') AS created_by,
--     json_extract(frontmatter, '$.created_at') AS created_at,
--     json_extract(frontmatter, '$.tags') AS tags,
--     json_extract(frontmatter, '$.linked_requirements') AS linked_requirements,
--     json_extract(content_fm_body_attrs, '$.body') AS body
-- FROM uniform_resource
-- WHERE uri LIKE '%/qf-suite.md';

-- DROP VIEW IF EXISTS groups;
-- CREATE view groups AS
-- SELECT 
--  json_extract(frontmatter, '$.id') AS id,
--     COALESCE(
--         json_extract(frontmatter, '$.SuiteId'),
--         json_extract(frontmatter, '$.suiteId')
--     ) AS suite_id,
--     json_extract(frontmatter, '$.planId') AS plan_id,
--     json_extract(frontmatter, '$.name') AS name,
--     json_extract(frontmatter, '$.description') AS description,
--     json_extract(frontmatter, '$.created_by') AS created_by,
--     json_extract(frontmatter, '$.created_at') AS created_at,
--     json_extract(frontmatter, '$.tags') AS tags,
--     json_extract(content_fm_body_attrs, '$.body') AS body 
-- FROM uniform_resource
-- WHERE uri LIKE '%/qf-case-group.md';


-- DROP VIEW IF EXISTS test_cases;
-- CREATE VIEW test_cases AS
-- with test_case_parsed as(
-- SELECT 
--     json_extract(frontmatter, '$.FII') AS test_case_id,
--     json_extract(frontmatter, '$.groupId') AS group_id,
--     json_extract(frontmatter, '$.planId') AS plan_id,    
--     json_extract(frontmatter, '$.title') AS title,
--     json_extract(frontmatter, '$.created_by') AS created_by,
--     json_extract(frontmatter, '$.test_type') AS test_type,    
--     json_extract(frontmatter, '$.created_at') AS created_at,
--     json_extract(frontmatter, '$.tags') AS tags,
--     json_extract(frontmatter, '$.priority') AS priority,
--     json_extract(content_fm_body_attrs, '$.frontMatter') AS front_matter,
--     json_extract(content_fm_body_attrs, '$.body') AS body
-- FROM uniform_resource
-- WHERE uri LIKE '%.case.md')
-- SELECT 
--     tc.test_case_id,
--     tc.group_id,
--     tc.plan_id,
--     tc.title,
--     tc.title AS test_case_title,
--     tc.created_by,
--     strftime('%d-%m-%Y', tc.created_at) AS formatted_test_case_created_at, -- Renamed alias
--     tc.test_type,
--     tc.created_at,
--     tc.tags,
--     tc.priority,
--     tc.front_matter,
--     tc.body,
--     g.name AS group_name,
--     g.suite_id,
--     g.description AS group_description,
--     g.created_by AS group_created_by,
--     g.created_at AS group_created_at,
--     g.tags AS group_tags,    
--     r.status as test_status
-- FROM 
--     test_case_parsed tc 
-- LEFT JOIN 
--     groups g ON g.id = tc.group_id
-- LEFT JOIN 
--     test_case_run_results r on r.test_case_id=tc.test_case_id;



-- DROP VIEW IF EXISTS test_case_run_results;
-- CREATE VIEW test_case_run_results AS
-- SELECT 
--     content,
--     json_extract(content, '$.test_case_fii') AS test_case_id,
--      json_extract(content, '$.group_id') AS group_id,
--     json_extract(content, '$.run_id') AS run_id,
--     json_extract(content, '$.title') AS title,
--     json_extract(content, '$.status') AS status,
--     strftime('%d-%m-%Y %H:%M:%S', json_extract(content, '$.start_time')) AS start_time,
--     strftime('%d-%m-%Y %H:%M:%S', json_extract(content, '$.end_time')) AS end_time,
--     json_extract(content, '$.total_duration') AS total_duration,
--     json_extract(content, '$.steps') AS steps -- Extracts the full array of steps
-- FROM uniform_resource
-- WHERE uri LIKE '%.result.json';


DROP VIEW IF EXISTS test_execution_log;
CREATE VIEW test_execution_log AS
SELECT 
    json_extract(content, '$.test_case_fii') AS test_case_id,
    json_extract(content, '$.title') AS title,
    json_extract(content, '$.status') AS status,
    json_extract(value, '$.step') AS step_number,
    json_extract(value, '$.stepname') AS step_name,
    json_extract(value, '$.status') AS step_status,
    strftime('%d-%m-%Y %H:%M:%S', json_extract(value, '$.start_time')) AS step_start_time,
    strftime('%d-%m-%Y %H:%M:%S', json_extract(value, '$.end_time')) AS step_end_time
FROM 
    uniform_resource,
    json_each(json_extract(content, '$.steps')) -- Expands the steps array into rows
WHERE 
    uri LIKE '%.result.json';   

DROP VIEW IF EXISTS test_cases_run_status;
CREATE VIEW test_cases_run_status AS 
SELECT 
    g.name AS group_name,
    g.suite_id,
    g.id AS group_id,
    g.created_by,   
    strftime('%d-%m-%Y', g.created_at) AS formatted_test_case_created_at,
    COUNT(tc.test_case_id) AS test_case_count,
    COUNT(CASE WHEN tc.test_status = 'passed' THEN tc.test_case_id END) AS success_status_count,
    COUNT(CASE WHEN tc.test_status = 'failed' THEN tc.test_case_id END) AS failed_status_count,
    COUNT(CASE WHEN tc.test_status is null THEN tc.test_case_id END) AS todo_status_count
    FROM groups g
LEFT JOIN test_cases tc
    ON g.id = tc.group_id
    GROUP BY g.name, g.id;    

-- DROP VIEW IF EXISTS test_cases_run_status;
-- CREATE VIEW test_cases_run_status AS 
-- SELECT 
--     g.name AS group_name,
--     g.suite_id,
--     g.id AS group_id,
--     g.created_by,   
--     strftime('%d-%m-%Y',  g.created_at) AS formatted_test_case_created_at,
--     COUNT(tc.test_case_id) AS test_case_count,
--     COUNT(p.test_case_id) AS success_status_count,
--     (COUNT(tc.test_case_id)-COUNT(p.test_case_id)) AS failed_status_count
-- FROM groups g
-- LEFT JOIN test_cases tc
--     ON g.id = tc.group_id
-- LEFT JOIN test_case_run_results p on p.test_case_id=tc.test_case_id and status='passed'
-- GROUP BY g.name, g.id;

DROP VIEW IF EXISTS test_plan;
CREATE VIEW test_plan AS
SELECT 
uniform_resource_id,
  JSON_EXTRACT(frontmatter, '$.id') AS id,  
  JSON_EXTRACT(frontmatter, '$.name') AS name,
  JSON_EXTRACT(frontmatter, '$.description') AS description,
  JSON_EXTRACT(frontmatter, '$.created_by') AS created_by,
  JSON_EXTRACT(frontmatter, '$.created_at') AS created_at,
  JSON_EXTRACT(frontmatter, '$.tags') AS tags,
  JSON_EXTRACT(frontmatter, '$.related_requirements') AS related_requirements,
  json_extract(content_fm_body_attrs, '$.body') AS body
FROM 
  uniform_resource
WHERE uri LIKE '%qf-plan.md';

DROP VIEW IF EXISTS test_plan_list;
CREATE VIEW test_plan_list AS 
 SELECT 
    id,
    name,
    ( SELECT
count(test_case_id) from test_cases
where group_id in (
SELECT
    id
FROM
    groups g
WHERE
    plan_id like '%'||t.id||'%')) as test_case_count,
    created_by,
    strftime('%d-%m-%Y',  created_at) as created_at
FROM test_plan t order by id asc;

DROP VIEW IF EXISTS suite_test_case_count;
CREATE VIEW suite_test_case_count AS 
SELECT 
st.id,
st.name,
st.created_by_user,
st.created_at,
sum(tc.test_case_count)
FROM
test_cases_run_status tc
INNER JOIN test_suites st on st.id=tc.suite_id;
-- test_cases_by_suite


DROP VIEW IF EXISTS test_run;
CREATE VIEW test_run AS 
SELECT 
uniform_resource_id,
json_extract(frontmatter, '$.test_case_fii') AS test_case_id,
json_extract(frontmatter, '$.run_date') AS run_date,
json_extract(frontmatter, '$.environment') AS environment,
json_extract(content_fm_body_attrs, '$.body') AS body
FROM uniform_resource
WHERE uri LIKE '%.run.md';


DROP VIEW IF EXISTS bug_report;
CREATE VIEW bug_report AS 
SELECT 
uniform_resource_id,
json_extract(frontmatter, '$.issue_id') AS id,
json_extract(frontmatter, '$.test_case_fii') AS test_case_id,
json_extract(frontmatter, '$.titleName') AS title,
json_extract(frontmatter, '$.created_by') AS created_by,
json_extract(frontmatter, '$.created_at') AS created_at,
json_extract(frontmatter, '$.test_type') AS type,
json_extract(frontmatter, '$.priority') AS priority,
json_extract(frontmatter, '$.assigned') AS assigned,
json_extract(frontmatter, '$.status') AS status,
json_extract(frontmatter, '$.endpoint') AS endpoint,
json_extract(content_fm_body_attrs, '$.body') AS body
FROM uniform_resource
WHERE uri LIKE '%.bug.md';

DROP VIEW IF EXISTS test_suite_success_and_failed_rate;
CREATE view test_suite_success_and_failed_rate AS
SELECT 
    t.uniform_resource_id,
    t.name AS suite_name,
    t.created_by_user,
    t.created_at,
    t.id as suite_id,
    sum(c.test_case_count) AS total_test_case,
    sum(c.success_status_count) AS success_count,
    sum(c.failed_status_count)  AS failed_count,
    sum(c.todo_status_count)  AS todo_count
FROM 
    test_suites t 
LEFT JOIN 
    test_cases_run_status c ON t.id = c.suite_id
GROUP BY suite_id;

DROP VIEW IF EXISTS test_case_bug_list;
CREATE view test_case_bug_list AS
WITH bug_data AS (
    SELECT test_case_id, json_group_array(json_each.value) AS bug_list_array
    FROM test_cases, json_each(test_cases.bug_list)
    GROUP BY test_case_id
)
SELECT test_case_id, 
       bug_list_array, 
       json_array_length(json(bug_list_array)) AS bug_count
FROM bug_data;

DROP VIEW IF EXISTS test_case_bug_count;
CREATE view test_case_bug_count AS
select 
tc.test_case_id,
case when bug_count is null then 0
else bug_count
end as test_bug_count
FROM  test_cases tc
LEFT JOIN
test_case_bug_list tbg on tc.test_case_id=tbg.test_case_id;

DROP VIEW  IF EXISTS bug_list;
CREATE view bug_list AS
 SELECT test_case_id,
 value as bug_id
    FROM test_cases, json_each(test_cases.bug_list);

-- TAP (Test Anything Protocol) Results View
-- Extracts and parses TAP format test results from uniform_resource table
-- Provides summary-level analysis of TAP files for QualityFolio display
DROP VIEW IF EXISTS tap_test_results;
CREATE VIEW tap_test_results AS
SELECT
    ur.uniform_resource_id,
    ur.uri AS source_file_uri,
    ur.created_at AS tap_file_created_at,
    ur.size_bytes AS tap_file_size_bytes,
    -- Extract filename without path and extension (dynamic extraction using simple string operations)
    CASE
        -- Remove .tap extension if present
        WHEN (
            -- Get filename part after last '/' (or full URI if no '/')
            CASE
                WHEN INSTR(ur.uri, '/') > 0
                THEN REPLACE(ur.uri, RTRIM(ur.uri, REPLACE(ur.uri, '/', '')), '')
                ELSE ur.uri
            END
        ) LIKE '%.tap'
        THEN SUBSTR(
            CASE
                WHEN INSTR(ur.uri, '/') > 0
                THEN REPLACE(ur.uri, RTRIM(ur.uri, REPLACE(ur.uri, '/', '')), '')
                ELSE ur.uri
            END,
            1,
            LENGTH(
                CASE
                    WHEN INSTR(ur.uri, '/') > 0
                    THEN REPLACE(ur.uri, RTRIM(ur.uri, REPLACE(ur.uri, '/', '')), '')
                    ELSE ur.uri
                END
            ) - 4
        )
        ELSE
            CASE
                WHEN INSTR(ur.uri, '/') > 0
                THEN REPLACE(ur.uri, RTRIM(ur.uri, REPLACE(ur.uri, '/', '')), '')
                ELSE ur.uri
            END
    END AS name,
    -- Extract test plan information dynamically (e.g., "1..N" where N can be any number)
    CASE
        WHEN CAST(ur.content AS TEXT) LIKE '%1..%' THEN
            CAST(
                TRIM(
                    SUBSTR(
                        SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT), '1..') + 3),
                        1,
                        CASE
                            WHEN INSTR(SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT), '1..') + 3), CHAR(10)) > 0
                            THEN INSTR(SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT), '1..') + 3), CHAR(10)) - 1
                            WHEN INSTR(SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT), '1..') + 3), ' ') > 0
                            THEN INSTR(SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT), '1..') + 3), ' ') - 1
                            ELSE 10
                        END
                    )
                ) AS INTEGER
            )
        ELSE NULL
    END AS total_planned_tests,
    -- Count actual test results
    (LENGTH(CAST(ur.content AS TEXT)) - LENGTH(REPLACE(CAST(ur.content AS TEXT), 'ok ', ''))) / 3 AS total_test_lines,
    (LENGTH(CAST(ur.content AS TEXT)) - LENGTH(REPLACE(CAST(ur.content AS TEXT), 'not ok', ''))) / 6 AS failed_tests,
    -- Calculate passed tests
    ((LENGTH(CAST(ur.content AS TEXT)) - LENGTH(REPLACE(CAST(ur.content AS TEXT), 'ok ', ''))) / 3) -
    ((LENGTH(CAST(ur.content AS TEXT)) - LENGTH(REPLACE(CAST(ur.content AS TEXT), 'not ok', ''))) / 6) AS passed_tests,
    -- Overall test status
    CASE
        WHEN (LENGTH(CAST(ur.content AS TEXT)) - LENGTH(REPLACE(CAST(ur.content AS TEXT), 'not ok', ''))) / 6 > 0 THEN 'mixed'
        WHEN (LENGTH(CAST(ur.content AS TEXT)) - LENGTH(REPLACE(CAST(ur.content AS TEXT), 'ok ', ''))) / 3 > 0 THEN 'passed'
        ELSE 'unknown'
    END AS overall_status,
    -- Calculate pass rate
    ur.content AS tap_result_content
FROM uniform_resource ur
WHERE ur.uri LIKE '%.tap'
   OR ur.uri LIKE '%/tap/%'
   OR (ur.content IS NOT NULL AND CAST(ur.content AS TEXT) LIKE '%ok %' AND CAST(ur.content AS TEXT) LIKE '%..%');

-- TAP Test Results Detail View
-- Dynamically extracts individual test cases from TAP content for drill-down capability
-- Parses any TAP file content in real-time using SQLite string functions
DROP VIEW IF EXISTS tap_test_results_detail;
CREATE VIEW tap_test_results_detail AS
WITH RECURSIVE tap_lines AS (
    -- Split TAP content into individual lines using recursive CTE
    -- Access full content directly from uniform_resource table
    SELECT
        ttr.uniform_resource_id,
        ttr.name AS tap_file_name,
        1 AS line_number,
        CASE
            WHEN INSTR(CAST(ur.content AS TEXT), CHAR(10)) > 0
            THEN TRIM(SUBSTR(CAST(ur.content AS TEXT), 1, INSTR(CAST(ur.content AS TEXT), CHAR(10)) - 1))
            ELSE TRIM(CAST(ur.content AS TEXT))
        END AS tap_line,
        CASE
            WHEN INSTR(CAST(ur.content AS TEXT), CHAR(10)) > 0
            THEN SUBSTR(CAST(ur.content AS TEXT), INSTR(CAST(ur.content AS TEXT), CHAR(10)) + 1)
            ELSE ''
        END AS remaining_content
    FROM tap_test_results ttr
    JOIN uniform_resource ur ON ttr.uniform_resource_id = ur.uniform_resource_id
    WHERE ur.content IS NOT NULL

    UNION ALL

    SELECT
        uniform_resource_id,
        tap_file_name,
        line_number + 1,
        CASE
            WHEN INSTR(remaining_content, CHAR(10)) > 0
            THEN TRIM(SUBSTR(remaining_content, 1, INSTR(remaining_content, CHAR(10)) - 1))
            ELSE TRIM(remaining_content)
        END AS tap_line,
        CASE
            WHEN INSTR(remaining_content, CHAR(10)) > 0
            THEN SUBSTR(remaining_content, INSTR(remaining_content, CHAR(10)) + 1)
            ELSE ''
        END AS remaining_content
    FROM tap_lines
    WHERE remaining_content != '' AND line_number < 300  -- Limit to prevent infinite recursion
),
parsed_test_lines AS (
    -- Parse TAP test lines to extract test components
    SELECT
        uniform_resource_id,
        tap_file_name,
        line_number,
        tap_line,
        -- Extract test number from "ok N" or "not ok N" patterns
        CASE
            WHEN tap_line LIKE 'ok %' AND NOT tap_line LIKE 'not ok %' THEN
                CAST(TRIM(SUBSTR(SUBSTR(tap_line, 4), 1,
                    CASE WHEN INSTR(SUBSTR(tap_line, 4), ' ') > 0
                         THEN INSTR(SUBSTR(tap_line, 4), ' ') - 1
                         ELSE LENGTH(SUBSTR(tap_line, 4)) END)) AS INTEGER)
            WHEN tap_line LIKE 'not ok %' THEN
                CAST(TRIM(SUBSTR(SUBSTR(tap_line, 8), 1,
                    CASE WHEN INSTR(SUBSTR(tap_line, 8), ' ') > 0
                         THEN INSTR(SUBSTR(tap_line, 8), ' ') - 1
                         ELSE LENGTH(SUBSTR(tap_line, 8)) END)) AS INTEGER)
            ELSE NULL
        END AS test_number,
        -- Determine test status
        CASE
            WHEN tap_line LIKE 'ok %' AND NOT tap_line LIKE 'not ok %' THEN 'passed'
            WHEN tap_line LIKE 'not ok %' THEN 'failed'
            ELSE NULL
        END AS test_status,
        -- Extract test case ID pattern [TC-XXX-NNNN] or similar
        CASE
            WHEN INSTR(tap_line, '[') > 0 AND INSTR(tap_line, ']') > INSTR(tap_line, '[') THEN
                SUBSTR(tap_line, INSTR(tap_line, '['), INSTR(tap_line, ']') - INSTR(tap_line, '[') + 1)
            ELSE NULL
        END AS test_case_id,
        -- Extract test description (text after test case ID or after status)
        CASE
            WHEN INSTR(tap_line, ']') > 0 THEN
                TRIM(SUBSTR(tap_line, INSTR(tap_line, ']') + 1))
            WHEN tap_line LIKE 'ok %' AND NOT tap_line LIKE 'not ok %' THEN
                TRIM(SUBSTR(tap_line, 4 + LENGTH(TRIM(SUBSTR(SUBSTR(tap_line, 4), 1,
                    CASE WHEN INSTR(SUBSTR(tap_line, 4), ' ') > 0
                         THEN INSTR(SUBSTR(tap_line, 4), ' ') - 1
                         ELSE LENGTH(SUBSTR(tap_line, 4)) END))) + 1))
            WHEN tap_line LIKE 'not ok %' THEN
                TRIM(SUBSTR(tap_line, 8 + LENGTH(TRIM(SUBSTR(SUBSTR(tap_line, 8), 1,
                    CASE WHEN INSTR(SUBSTR(tap_line, 8), ' ') > 0
                         THEN INSTR(SUBSTR(tap_line, 8), ' ') - 1
                         ELSE LENGTH(SUBSTR(tap_line, 8)) END))) + 1))
            ELSE NULL
        END AS test_description
    FROM tap_lines
    WHERE tap_line LIKE 'ok %' OR tap_line LIKE 'not ok %'
)
SELECT
    uniform_resource_id,
    tap_file_name,
    test_number,
    test_status,
    test_case_id,
    -- Clean up test description by removing common prefixes
    CASE
        WHEN test_description LIKE '- %' THEN TRIM(SUBSTR(test_description, 3))
        WHEN test_description LIKE '● › %' THEN TRIM(SUBSTR(test_description, 5))
        WHEN test_description LIKE '● %' THEN TRIM(SUBSTR(test_description, 3))
        WHEN test_description LIKE '› %' THEN TRIM(SUBSTR(test_description, 3))
        ELSE TRIM(test_description)
    END AS test_description,
    tap_line AS original_tap_line
FROM parsed_test_lines
WHERE test_number IS NOT NULL
ORDER BY uniform_resource_id, test_number;

