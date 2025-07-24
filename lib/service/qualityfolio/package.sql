-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
DROP TABLE IF EXISTS projects;

CREATE TABLE projects AS
SELECT 
uniform_resource_id,
json_extract(frontmatter, '$.id') AS project_id,
json_extract(frontmatter, '$.name') AS project_name,
json_extract(frontmatter, '$.description') AS description,
json_extract(frontmatter, '$.created_by') AS created_by,
json_extract(frontmatter, '$.created_at') AS created_at,
json_extract(frontmatter, '$.last_updated_at') AS last_updated_at,
json_extract(frontmatter, '$.status') AS status,
json_extract(frontmatter, '$.tags') AS tags,
json_extract(frontmatter, '$.linked_requirements') AS linked_requirements,
json_extract(frontmatter, '$.dependencies') AS dependencies,
json_extract(frontmatter, '$.goals') AS goals,
json_extract(frontmatter, '$.critical_milestones') AS critical_milestones
FROM uniform_resource
WHERE uri LIKE '%/qf-project.md';

DROP TABLE IF EXISTS test_suites;
CREATE TABLE test_suites AS
SELECT 
    uniform_resource_id,
    json_extract(frontmatter, '$.id') AS id,
    json_extract(frontmatter, '$.projectId') AS project_id,
    json_extract(frontmatter, '$.name') AS name,
    json_extract(frontmatter, '$.description') AS description,
    json_extract(frontmatter, '$.created_by') AS created_by_user,
    json_extract(frontmatter, '$.created_at') AS created_at,
    json_extract(frontmatter, '$.tags') AS tags,
    json_extract(frontmatter, '$.linked_requirements') AS linked_requirements,
    json_extract(content_fm_body_attrs, '$.body') AS body
FROM uniform_resource
WHERE uri LIKE '%/qf-suite.md';

DROP TABLE IF EXISTS groups;
CREATE TABLE groups AS
SELECT 
 json_extract(frontmatter, '$.id') AS id,
    COALESCE(
        json_extract(frontmatter, '$.SuiteId'),
        json_extract(frontmatter, '$.suiteId')
    ) AS suite_id,
    json_extract(frontmatter, '$.planId') AS plan_id,
    json_extract(frontmatter, '$.name') AS name,
    json_extract(frontmatter, '$.description') AS description,
    json_extract(frontmatter, '$.created_by') AS created_by,
    json_extract(frontmatter, '$.created_at') AS created_at,
    json_extract(frontmatter, '$.tags') AS tags,
    json_extract(content_fm_body_attrs, '$.body') AS body 
FROM uniform_resource
WHERE uri LIKE '%/qf-case-group.md';

DROP TABLE IF EXISTS test_case_run_results;
CREATE TABLE test_case_run_results AS
with test_case_result as(
SELECT 
    content,
    json_extract(content, '$.test_case_fii') AS test_case_id,
     json_extract(content, '$.group_id') AS group_id,
    json_extract(content, '$.run_id') AS run_id,
    json_extract(content, '$.title') AS title,
    json_extract(content, '$.status') AS status,
    strftime('%d-%m-%Y %H:%M:%S', json_extract(content, '$.start_time')) AS start_time,
    strftime('%d-%m-%Y %H:%M:%S', json_extract(content, '$.end_time')) AS end_time,
    json_extract(content, '$.total_duration') AS total_duration,
    json_extract(content, '$.steps') AS steps -- Extracts the full array of steps
FROM uniform_resource
WHERE uri LIKE '%.result.json')
SELECT * FROM test_case_result order by start_time desc;

DROP TABLE IF EXISTS test_cases;
CREATE TABLE test_cases AS
with test_case_parsed as(
SELECT 
    json_extract(frontmatter, '$.FII') AS test_case_id,
    json_extract(frontmatter, '$.groupId') AS group_id,
    json_extract(frontmatter, '$.planId') AS plan_id,    
    json_extract(frontmatter, '$.title') AS title,
    json_extract(frontmatter, '$.created_by') AS created_by,
    json_extract(frontmatter, '$.test_type') AS test_type,    
    json_extract(frontmatter, '$.created_at') AS created_at,
    json_extract(frontmatter, '$.tags') AS tags,
    json_extract(frontmatter, '$.priority') AS priority,
    json_extract(frontmatter, '$.bugId') AS bug_list,
    json_extract(content_fm_body_attrs, '$.frontMatter') AS front_matter,
    json_extract(content_fm_body_attrs, '$.body') AS body
FROM uniform_resource
WHERE uri LIKE '%.case.md')
SELECT 
    tc.test_case_id,
    tc.group_id,
    tc.plan_id,
    tc.title,
    tc.title AS test_case_title,
    tc.created_by,
    strftime('%d-%m-%Y', tc.created_at) AS formatted_test_case_created_at, -- Renamed alias
    tc.test_type,
    tc.created_at,
    tc.tags,
    tc.priority,
    tc.front_matter,
    tc.body,
    tc.bug_list,
    g.name AS group_name,
    g.suite_id,
    g.description AS group_description,
    g.created_by AS group_created_by,
    g.created_at AS group_created_at,
    g.tags AS group_tags,    
    r.status as test_status
FROM 
    test_case_parsed tc 
LEFT JOIN 
    groups g ON g.id = tc.group_id
LEFT JOIN 
    (SELECT test_case_id test_case_id, status, max(start_time)
FROM test_case_run_results
group BY test_case_id) r on r.test_case_id=tc.test_case_id;


DROP TABLE IF EXISTS jira_issues;
CREATE TABLE jira_issues AS
SELECT 
json_extract(content, '$.key') AS bug_id, 
json_extract(content, '$.fields.summary') AS title, 
json_extract(content, '$.fields.assignee.displayName') AS assignee, 
json_extract(content, '$.fields.description') AS description, 
json_extract(content, '$.fields.reporter.displayName') AS reporter, 
json_extract(content, '$.fields.status.name') AS status, 
json_extract(content, '$.fields.created') AS created, 
json_extract(content, '$.fields.updated') AS updated,
json_extract(content, '$.fields.issuetype.name') AS type
FROM 
uniform_resource where uri like 'https://civco.atlassian.net/rest/api/%' and nature='json'
and json_extract(content, '$.fields.issuetype.name')='Bug';


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


-- delete all /qualityfolio-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE parent_path like 'qualityfolio'||'/index.sql';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'qualityfolio/index.sql', 'qualityfolio/index.sql', 'Test Management System', NULL, NULL, 'Test management system', NULL),
    ('prime', 'qualityfolio/index.sql', 3, 'qualityfolio/test-cases.sql', 'qualityfolio/test-cases.sql', 'Test Cases', NULL, NULL, 'Complete list of all test cases across all projects and suites', NULL),
    ('prime', 'qualityfolio/index.sql', 1, 'qualityfolio/test-management.sql', 'qualityfolio/test-management.sql', 'Projects', NULL, NULL, NULL, NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.
-- select 'test' into absolute_url;
DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS

SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    'console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    'console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    tbl.sql as sql_ddl
FROM sqlite_master tbl
JOIN pragma_table_info(tbl.name) col
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with view-specific information
DROP VIEW IF EXISTS console_information_schema_view;
CREATE VIEW console_information_schema_view AS
SELECT
    vw.name AS view_name,
    col.name AS column_name,
    col.type AS data_type,
    '/console/info-schema/view.sql?name=' || vw.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    vw.sql as sql_ddl
FROM sqlite_master vw
JOIN pragma_table_info(vw.name) col
WHERE vw.type = 'view' AND vw.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS console_content_tabular;
CREATE VIEW console_content_tabular AS
  SELECT 'table' as tabular_nature,
         table_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_table
  UNION ALL
  SELECT 'view' as tabular_nature,
         view_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_view;

-- Populate the table with table column foreign keys
DROP VIEW IF EXISTS console_information_schema_table_col_fkey;
CREATE VIEW console_information_schema_table_col_fkey AS
SELECT
    tbl.name AS table_name,
    f."from" AS column_name,
    f."from" || ' references ' || f."table" || '.' || f."to" AS foreign_key
FROM sqlite_master tbl
JOIN pragma_foreign_key_list(tbl.name) f
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with table column indexes
DROP VIEW IF EXISTS console_information_schema_table_col_index;
CREATE VIEW console_information_schema_table_col_index AS
SELECT
    tbl.name AS table_name,
    pi.name AS column_name,
    idx.name AS index_name
FROM sqlite_master tbl
JOIN pragma_index_list(tbl.name) idx
JOIN pragma_index_info(idx.name) pi
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS rssd_statistics_overview;
CREATE VIEW rssd_statistics_overview AS
SELECT 
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024), 2) FROM pragma_page_count(), pragma_page_size()) AS db_size_mb,
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024 * 1024), 4) FROM pragma_page_count(), pragma_page_size()) AS db_size_gb,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'table') AS total_tables,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'index') AS total_indexes,
    (SELECT SUM(tbl_rows) FROM (
        SELECT name, 
              (SELECT COUNT(*) FROM sqlite_master sm WHERE sm.type='table' AND sm.name=t.name) AS tbl_rows
        FROM sqlite_master t WHERE type='table'
    )) AS total_rows,
    (SELECT page_size FROM pragma_page_size()) AS page_size,
    (SELECT page_count FROM pragma_page_count()) AS total_pages;

CREATE TABLE IF NOT EXISTS surveilr_table_size (
    table_name TEXT PRIMARY KEY,
    table_size_mb REAL
);
DROP VIEW IF EXISTS rssd_table_statistic;
CREATE VIEW rssd_table_statistic AS
SELECT 
    m.name AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info(m.name)) AS total_columns,
    (SELECT COUNT(*) FROM pragma_index_list(m.name)) AS total_indexes,
    (SELECT COUNT(*) FROM pragma_foreign_key_list(m.name)) AS foreign_keys,
    (SELECT COUNT(*) FROM pragma_table_info(m.name) WHERE pk != 0) AS primary_keys,
    (SELECT table_size_mb FROM surveilr_table_size WHERE table_name = m.name) AS table_size_mb
FROM sqlite_master m
WHERE m.type = 'table';

-- Drop and create the table for storing navigation entries
-- for testing only: DROP TABLE IF EXISTS sqlpage_aide_navigation;
CREATE TABLE IF NOT EXISTS sqlpage_aide_navigation (
    path TEXT NOT NULL, -- the "primary key" within namespace
    caption TEXT NOT NULL, -- for human-friendly general-purpose name
    namespace TEXT NOT NULL, -- if more than one navigation tree is required
    parent_path TEXT, -- for defining hierarchy
    sibling_order INTEGER, -- orders children within their parent(s)
    url TEXT, -- for supplying links, if different from path
    title TEXT, -- for full titles when elaboration is required, default to caption if NULL
    abbreviated_caption TEXT, -- for breadcrumbs and other "short" form, default to caption if NULL
    description TEXT, -- for elaboration or explanation
    elaboration TEXT, -- optional attributes for e.g. { "target": "__blank" }
    -- TODO: figure out why Rusqlite does not allow this but sqlite3 does
    -- CONSTRAINT fk_parent_path FOREIGN KEY (namespace, parent_path) REFERENCES sqlpage_aide_navigation(namespace, path),
    CONSTRAINT unq_ns_path UNIQUE (namespace, parent_path, path)
);
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'index.sql';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', NULL, 1, 'index.sql', 'index.sql', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)', NULL),
    ('prime', 'index.sql', 999, 'console/index.sql', 'console/index.sql', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files', NULL),
    ('prime', 'console/index.sql', 1, 'console/info-schema/index.sql', 'console/info-schema/index.sql', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/index.sql', 'console/sqlpage-files/index.sql', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/content.sql', 'console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-nav/index.sql', 'console/sqlpage-nav/index.sql', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table', NULL),
    ('prime', 'console/index.sql', 2, 'console/notebooks/index.sql', 'console/notebooks/index.sql', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks', NULL),
    ('prime', 'console/index.sql', 2, 'console/migrations/index.sql', 'console/migrations/index.sql', 'RSSD Lifecycle (migrations)', 'Migrations', NULL, 'Explore RSSD Migrations to determine what was executed and not', NULL),
    ('prime', 'console/index.sql', 2, 'console/about.sql', 'console/about.sql', 'Resource Surveillance Details', 'About', NULL, 'Detailed information about the underlying surveilr binary', NULL),
    ('prime', 'console/index.sql', 1, 'console/statistics/index.sql', 'console/statistics/index.sql', 'RSSD Statistics', 'Statistics', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 5, 'console/behavior/index.sql', 'console/behavior/index.sql', 'Behavior Configuration', 'Behavior', NULL, 'Explore behavior configurations and presets used to drive application operations at runtime', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;

INSERT OR REPLACE INTO code_notebook_cell (notebook_kernel_id, code_notebook_cell_id, notebook_name, cell_name, interpretable_code, interpretable_code_hash, description) VALUES (
  'SQL',
  'web-ui.auto_generate_console_content_tabular_sqlpage_files',
  'Web UI',
  'auto_generate_console_content_tabular_sqlpage_files',
  '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows',
  'TODO',
  'A series of idempotent INSERT statements which will auto-generate "default" content for all tables and views'
);
      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in '*.auto.sql' with redirects
      DELETE FROM sqlpage_files WHERE path like 'console/content/table/%.auto.sql';
      DELETE FROM sqlpage_files WHERE path like 'console/content/view/%.auto.sql';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql',
            'SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

              SELECT ''breadcrumb'' AS component;
              SELECT ''Home'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
              SELECT ''Console'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console'' AS link;
              SELECT ''Content'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content'' AS link;
              SELECT ''' || tabular_name  || ' ' || tabular_nature || ''' as title, ''#'' AS link;

              SELECT ''title'' AS component, ''' || tabular_name || ' (' || tabular_nature || ') Content'' as contents;

              SET total_rows = (SELECT COUNT(*) FROM ' || tabular_name || ');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''text'' AS component, ''' || info_schema_link_full_md || ''' AS contents_md
              SELECT ''text'' AS component,
                ''- Start Row: '' || $offset || ''
'' ||
                ''- Rows per Page: '' || $limit || ''
'' ||
                ''- Total Rows: '' || $total_rows || ''
'' ||
                ''- Current Page: '' || $current_page || ''
'' ||
                ''- Total Pages: '' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''table'' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM ' || tabular_name || '
            LIMIT $limit
            OFFSET $offset;

            SELECT ''text'' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
                ''(Page '' || $current_page || '' of '' || $total_pages || '') '' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
                AS contents_md;'
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.sql',
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'docs/index.sql', 'docs/index.sql', 'Docs', NULL, NULL, 'Explore surveilr functions and release notes', NULL),
    ('prime', 'docs/index.sql', 99, 'docs/release-notes.sql', 'docs/release-notes.sql', 'Release Notes', NULL, NULL, 'surveilr releases details', NULL),
    ('prime', 'docs/index.sql', 2, 'docs/functions.sql', 'docs/functions.sql', 'SQL Functions', NULL, NULL, 'surveilr specific SQLite functions for extensibilty', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like 'ur%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'ur/index.sql', 'ur/index.sql', 'Uniform Resource', NULL, NULL, 'Explore ingested resources', NULL),
    ('prime', 'ur/index.sql', 99, 'ur/info-schema.sql', 'ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-files.sql', 'ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-imap-account.sql', 'ur/uniform-resource-imap-account.sql', 'Uniform Resources (IMAP)', NULL, NULL, 'Easily access and view your emails with our Uniform Resource (IMAP) system. Ingested from various mail sources, this feature organizes and displays your messages directly in the Web UI, ensuring all your communications are available in one convenient place.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
DROP VIEW IF EXISTS uniform_resource_file;
CREATE VIEW uniform_resource_file AS
  SELECT ur.uniform_resource_id,
         ur.nature,
         p.root_path AS source_path,
         pe.file_path_rel,
         ur.size_bytes
  FROM uniform_resource ur
  LEFT JOIN uniform_resource_edge ure ON ur.uniform_resource_id = ure.uniform_resource_id AND ure.nature = 'ingest_fs_path'
  LEFT JOIN ur_ingest_session_fs_path p ON ure.node_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id;

  DROP VIEW IF EXISTS uniform_resource_imap;
  CREATE VIEW uniform_resource_imap AS
  SELECT
      ur.uniform_resource_id,
      graph.name,
      iac.ur_ingest_session_imap_account_id,
      iac.email,
      iac.host,
      iacm.subject,
      iacm."from",
      iacm.message,
      iacm.date,
      iaf.ur_ingest_session_imap_acct_folder_id,
      iaf.ingest_account_id,
      iaf.folder_name,
      ur.size_bytes,
      ur.nature,
      ur.content
  FROM uniform_resource ur
  INNER JOIN uniform_resource_edge edge ON edge.uniform_resource_id=ur.uniform_resource_id
  INNER JOIN uniform_resource_graph graph ON graph.name=edge.graph_name
  INNER JOIN ur_ingest_session_imap_acct_folder_message iacm ON iacm.ur_ingest_session_imap_acct_folder_message_id = edge.node_id
  INNER JOIN ur_ingest_session_imap_acct_folder iaf ON iacm.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
  LEFT JOIN ur_ingest_session_imap_account iac ON iac.ur_ingest_session_imap_account_id = iaf.ingest_account_id
  WHERE ur.nature = 'text' AND graph.name='imap' AND ur.ingest_session_imap_acct_folder_message IS NOT NULL;

  DROP VIEW IF EXISTS uniform_resource_imap_content;
  CREATE  VIEW uniform_resource_imap_content AS
  SELECT
      uri.uniform_resource_id,
      base_ur.uniform_resource_id baseID,
      ext_ur.uniform_resource_id extID,
      base_ur.uri as base_uri,
      ext_ur.uri as ext_uri,
      base_ur.nature as base_nature,
      ext_ur.nature as ext_nature,
      json_extract(part.value, '$.body.Html') AS html_content
  FROM
      uniform_resource_imap uri
  INNER JOIN uniform_resource base_ur ON base_ur.uniform_resource_id=uri.uniform_resource_id
  INNER JOIN uniform_resource ext_ur ON ext_ur.uri = base_ur.uri ||'/json' AND ext_ur.nature = 'json',
  json_each(ext_ur.content, '$.parts') AS part
  WHERE ext_ur.nature = 'json' AND html_content NOT NULL;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats" AS
    WITH Summary AS (
        SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_fs_path_entry.file_extn, '') AS file_extension,
            ur_ingest_session_fs_path.ur_ingest_session_fs_path_id as ingest_session_fs_path_id,
            ur_ingest_session_fs_path.root_path AS ingest_session_root_fs_path,
            COUNT(ur_ingest_session_fs_path_entry.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_fs_path ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_fs_path.ingest_session_id
        LEFT JOIN
            ur_ingest_session_fs_path_entry ON ur_ingest_session_fs_path.ur_ingest_session_fs_path_id = ur_ingest_session_fs_path_entry.ingest_fs_path_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_fs_path_entry.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_fs_path_entry.file_extn,
            ur_ingest_session_fs_path.root_path
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        file_extension,
        ingest_session_fs_path_id,
        ingest_session_root_fs_path,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        file_extension;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_files_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats" AS
      WITH Summary AS (
          SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_task.ur_status, 'Ok') AS ur_status,
            COALESCE(uniform_resource.nature, 'UNKNOWN') AS nature,
            COUNT(ur_ingest_session_task.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_task ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_task.ingest_session_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_task.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_task.captured_executable
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        ur_status,
        nature,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        ur_status;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_tasks_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_file_issue";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_file_issue" AS
      SELECT us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics
        FROM ur_ingest_session_fs_path_entry ufs
        JOIN ur_ingest_session_fs_path usp ON ufs.ingest_fs_path_id = usp.ur_ingest_session_fs_path_id
        JOIN ur_ingest_session us ON usp.ingest_session_id = us.ur_ingest_session_id
       WHERE ufs.ur_status IS NOT NULL
    GROUP BY us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics;
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'orchestration/index.sql', 'orchestration/index.sql', 'Orchestration', NULL, NULL, 'Explore details about all orchestration', NULL),
    ('prime', 'orchestration/index.sql', 99, 'orchestration/info-schema.sql', 'orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
 DROP VIEW IF EXISTS orchestration_session_by_device;
 CREATE VIEW orchestration_session_by_device AS
 SELECT
     d.device_id,
     d.name AS device_name,
     COUNT(*) AS session_count
 FROM orchestration_session os
 JOIN device d ON os.device_id = d.device_id
 GROUP BY d.device_id, d.name;

 DROP VIEW IF EXISTS orchestration_session_duration;
 CREATE VIEW orchestration_session_duration AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     os.orch_started_at,
     os.orch_finished_at,
     (JULIANDAY(os.orch_finished_at) - JULIANDAY(os.orch_started_at)) * 24 * 60 * 60 AS duration_seconds
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 WHERE os.orch_finished_at IS NOT NULL;

 DROP VIEW IF EXISTS orchestration_success_rate;
 CREATE VIEW orchestration_success_rate AS
 SELECT
     onature.nature AS orchestration_nature,
     COUNT(*) AS total_sessions,
     SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS successful_sessions,
     (CAST(SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_state oss ON os.orchestration_session_id = oss.session_id
 WHERE oss.to_state IN ('surveilr_orch_completed', 'surveilr_orch_failed') -- Consider other terminal states if applicable
 GROUP BY onature.nature;

 DROP VIEW IF EXISTS orchestration_session_script;
 CREATE VIEW orchestration_session_script AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     COUNT(*) AS script_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_entry ose ON os.orchestration_session_id = ose.session_id
 GROUP BY os.orchestration_session_id, onature.nature;

 DROP VIEW IF EXISTS orchestration_executions_by_type;
 CREATE VIEW orchestration_executions_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS execution_count
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_execution_success_rate_by_type;
 CREATE VIEW orchestration_execution_success_rate_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS total_executions,
     SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS successful_executions,
     (CAST(SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_session_summary;
 CREATE VIEW orchestration_session_summary AS
 SELECT
     issue_type,
     COUNT(*) AS issue_count
 FROM orchestration_session_issue
 GROUP BY issue_type;

 DROP VIEW IF EXISTS orchestration_issue_remediation;
 CREATE VIEW orchestration_issue_remediation AS
 SELECT
     orchestration_session_issue_id,
     issue_type,
     issue_message,
     remediation
 FROM orchestration_session_issue
 WHERE remediation IS NOT NULL;

DROP VIEW IF EXISTS orchestration_logs_by_session;
 CREATE VIEW orchestration_logs_by_session AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     osl.category,
     COUNT(*) AS log_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_exec ose ON os.orchestration_session_id = ose.session_id
 JOIN orchestration_session_log osl ON ose.orchestration_session_exec_id = osl.parent_exec_id
 GROUP BY os.orchestration_session_id, onature.nature, osl.category;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-suites-common.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                 
     SELECT ''html'' as component,
       ''<style>
       p strong {
       color: red !important;
   }

   /* Escape the dot in the class name */
   tr.rowClass-100 p strong {
       color: green !important;
   }
   .btn-list {
       display: flex;
       justify-content: flex-end;
   }
   </style>
  
   
   ''
   
 as html;
 select
   ''button'' as component;
   select
     ''Generate Report''           as title,
     ''download-test-suites.sql'' as link,
     ''_blank''                   as target;
SELECT ''table'' as component,
       ''Column Count'' as align_right,
       TRUE as sort,
       TRUE as search,
       ''id'' as markdown,
       ''Success Rate'' as markdown;
     SELECT
     ''[''||suite_id||''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/suite-data.sql''||''?id=''||suite_id||'')'' as id,
     
     suite_name,
     created_by_user as "Created By",
     total_test_case as "test case count",
   --   CASE
   --     WHEN total_test_case > 0
   --     THEN
   --         ''**''||ROUND(
   --             100.0 * success_count /
   --             (total_test_case-todo_count),
   --             2
   --         ) || ''%**'' ||'' *(''||success_count || ''/'' || (total_test_case-todo_count)  ||''*)''
   --     ELSE ''0%''
   -- END AS "Success Rate",
      CASE
       WHEN total_test_case > 0
       THEN
           ''**''||ROUND(
               100.0 * success_count /
               total_test_case,
               2
           ) || ''%**'' ||'' *(''||success_count || ''/'' || total_test_case  ||''*)''
       ELSE ''0%''
   END AS "Success Rate",
   --  todo_count as "TO DO",
     strftime(''%d-%m-%Y'', created_at) as "Created On",
      ''rowClass-''||(100* success_count/(total_test_case)) as _sqlpage_css_class
     
     FROM test_suite_success_and_failed_rate st order by suite_id asc;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-suites.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
 select
''breadcrumb'' as component;
select
''Home'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
select
''Test Management System'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
select
''Test Suites'' as title;

 
SELECT ''title''AS component, 
 ''Test Suite'' as contents; 
    SELECT ''text'' as component,
    ''Test suite is a collection of test cases designed to verify the functionality, performance, and security of a software application. It ensures that the application meets the specified requirements by executing predefined tests across various scenarios, identifying defects, and validating that the system works as intended.'' as contents;

 select ''dynamic'' as component, sqlpage.run_sql(''qualityfolio/test-suites-common.sql'') as properties;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-plan.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''qualityfolio/test-plan.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
select
''Home'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
select
''Test Management System'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
select
''Test Plans'' as title;



SELECT ''title''AS component, 
 ''Test Plans'' as contents; 
    SELECT ''text'' as component,
    ''A test plan is a high-level document that outlines the overall approach to testing a software application. It serves as a blueprint for the testing process.'' as contents;

 SELECT ''table'' as component,
    ''Column Count'' as align_right,
    TRUE as sort,
    TRUE as search,
    ''id'' as markdown,
    ''test case count'' as markdown;
  SELECT 
  ''[''||id||''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/plan-overview.sql''||''?id=''||id||'')'' as id,      
  name,
  ''[''||test_case_count||''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-cases-list.sql''||''?id=''||id||'')'' as "test case count",   
  created_by as "Created By",
  created_at as "Created On"
  FROM test_plan_list  order by id asc;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''qualityfolio/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              
    
    SELECT ''text'' as component,
    ''The dashboard provides a centralized view of your testing efforts, displaying key metrics such as test progress, results, and team productivity. It offers visual insights with charts and reports, enabling efficient tracking of test runs, milestones, and issue trends, ensuring streamlined collaboration and enhanced test management throughout the project lifecycle.'' as contents;
    select 
    ''card'' as component,
    4      as columns;

    SELECT
    ''## Automation Coverage'' AS description_md,
    ''white'' AS background_color,
    ''##  '' || ROUND(100.0 * SUM(CASE WHEN test_type = ''Automation'' THEN 1 ELSE 0 END) / COUNT(*), 2) || ''%'' AS description_md,    
    ''orange'' AS color,
    ''brand-ansible'' AS icon
    FROM
    test_cases;

     SELECT
    ''## Automated Test Cases'' AS description_md,
    ''white'' AS background_color,
    ''##  '' || SUM(CASE WHEN test_type = ''Automation'' THEN 1 ELSE 0 END) AS description_md,    
    ''green'' AS color,
    ''brand-ansible'' AS icon
    FROM
    test_cases;

    SELECT
    ''## Manual Test Cases'' AS description_md,
    ''white'' AS background_color,
    ''##  '' || SUM(CASE WHEN test_type = ''Manual'' THEN 1 ELSE 0 END) AS description_md,    
    ''yellow'' AS color,
    ''analyze'' AS icon
    FROM
    test_cases;
    
    

select
    ''## Total Test Cases Count'' as description_md,
 
    ''white'' as background_color,
    ''## ''||count(DISTINCT test_case_id) as description_md,
    ''12'' as width,
     ''red'' as color,
    ''brand-speedtest''       as icon,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-cases-full-list.sql'' as link
    
    FROM test_cases ;

     select
    ''## Total Test Suites Count'' as description_md,
    ''white'' as background_color,
    ''## ''||count(id) as description_md,
    ''12'' as width,
    ''sum''       as icon,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-suites.sql'' as link
    FROM test_suites ; 

  select
    ''## Total Test Plans Count'' as description_md,
 
    ''white'' as background_color,
    ''## ''||count(id) as description_md,
    ''12'' as width,
     ''pink'' as color,
    ''timeline-event''       as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-plan.sql'' as link
    FROM test_plan ; 

    select
    ''## Success Rate'' as description_md,

    ''white'' as background_color,
    ''## ''||ROUND(100.0 * SUM(CASE WHEN r.status = ''passed'' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2)||''%'' as description_md,
    ''12'' as width,
     ''lime'' as color,
    ''circle-dashed-check''       as icon,
    ''background-color: #FFFFFF'' as style
    FROM 
    test_cases t
LEFT JOIN 
    (select * from test_case_run_results group by test_case_id) r
    ON
    t.test_case_id = r.test_case_id;

    


    select
    ''## Failed Rate'' as description_md,

    ''white'' as background_color,
    ''## ''||ROUND(100.0 * SUM(CASE WHEN r.status = ''failed'' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2)||''%'' as description_md,
    ''12'' as width,
     ''red'' as color,
    ''details-off''       as icon,
    ''background-color: #FFFFFF'' as style
    FROM 
    test_cases t
LEFT JOIN 
    (select * from test_case_run_results group by test_case_id) r
    ON
    t.test_case_id = r.test_case_id;


 select
    ''## Total Defects'' as description_md,

    ''white'' as background_color,
    ''## ''||count(bug_id) as description_md,
    ''12'' as width,
     ''red'' as color,
    ''details-off''       as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/bug-list.sql'' as link
    FROM 
    jira_issues t ;
    select
    ''## Open Defects'' as description_md,

    ''white'' as background_color,
    ''## ''||count(bug_id) as description_md,
    ''12'' as width,
     ''orange'' as color,
    ''details-off''       as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/bug-list.sql?status=To Do'' as link
    FROM 
    jira_issues t  where status=''To Do'';


    select
    ''## Closed Defects'' as description_md,

    ''white'' as background_color,
    ''## ''||count(bug_id) as description_md,
    ''12'' as width,
     ''purple'' as color,
    ''details-off''       as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/bug-list.sql?status=Completed'' as link
    FROM 
    jira_issues t where status=''Completed'';


    select
    ''## Rejected Defects'' as description_md,

    ''white'' as background_color,
    ''## ''||count(bug_id) as description_md,
    ''12'' as width,
     ''cyan'' as color,
    ''details-off''       as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/bug-list.sql?status=Rejected'' as link
    FROM 
    jira_issues t where status=''Rejected'';


SELECT ''html'' as component,
''<style>
.apexcharts-legend-seriesd {
    color: #ffff; /* Red color */
    font-weight: bold; /* Makes the text bold */
}



</style>'' 
as html;

select 
    ''card'' as component,
    2      as columns;
select 
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/chart1.sql?_sqlpage_embed'' as embed;
select 
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/chart2.sql?_sqlpage_embed'' as embed;
    
 SELECT ''title''AS component, 
     ''Test Suite List'' as contents; 
        SELECT ''text'' as component;

        
select ''dynamic'' as component, sqlpage.run_sql(''qualityfolio/test-suites-common.sql'') as properties;

-- select 
--     ''chart''             as component,
--     ''Test Suites'' as title,
--     -- ''area''              as type,
--     -- ''purple''            as color,
--     0         as ymin,
--      5                   as marker,
--     ''Success Test Case'' as ytitle,
--     ''Total Test Case'' as xtitle;

-- select 
--     total_test_case as x,
--     success_count    as value,
    
--     suite_name as series
--     FROM test_suite_success_and_failed_rate;

-- TAP Test Results Section
SELECT ''title'' AS component,
''TAP Test Results'' as contents;

SELECT ''text'' as component,
''Test Anything Protocol (TAP) results from automated test runs. Click on any TAP file name to view detailed test case information and individual test results.'' as contents;

SELECT ''table'' as component,
       ''Total Tests,Passed,Failed,Pass Rate'' as align_right,
       TRUE as sort,
       TRUE as search,
       ''File Name'' as markdown;

SELECT
    ''[''||name||''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/tap-details.sql''||''?file=''||REPLACE(REPLACE(name, '' '', ''%20''), ''&'', ''%26'')||'')'' as "File Name",
    COALESCE(total_planned_tests, total_test_lines, 0) as "Total Tests",
    COALESCE(passed_tests, 0) as "Passed",
    COALESCE(failed_tests, 0) as "Failed",
    CASE
        WHEN total_test_lines > 0
        THEN ROUND((passed_tests * 100.0) / total_test_lines, 1) || ''%''
        ELSE ''0%''
    END as "Pass Rate",
    CASE
        WHEN overall_status = ''passed'' THEN ''✅ Passed''
        WHEN overall_status = ''mixed'' THEN ''⚠️ Mixed''
        WHEN overall_status = ''failed'' THEN ''❌ Failed''
        ELSE ''❓ Unknown''
    END as "Status",
    strftime(''%d-%m-%Y %H:%M'', tap_file_created_at) as "Created",
    CASE
        WHEN total_test_lines > 0
        THEN ''rowClass-''||CAST((passed_tests * 100) / total_test_lines AS INTEGER)
        ELSE ''rowClass-0''
    END as _sqlpage_css_class
FROM tap_test_results
ORDER BY tap_file_created_at DESC;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/tap-details.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
select
''Home'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
select
''Test Management System'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
select
''TAP Test Results'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
select
COALESCE($file, ''TAP File Details'') as title;

SELECT ''title'' AS component,
  ''TAP File: '' || COALESCE($file, ''Unknown'') as contents;

SELECT ''text'' as component,
''Individual test case details from the selected TAP file. Each row represents a single test case with its execution status and description.'' as contents;

-- TAP File Summary Cards
select
''card'' as component,
4 as columns;

SELECT
''## Total Tests'' AS description_md,
''white'' AS background_color,
''## '' || COALESCE(total_test_lines, 0) AS description_md,
''blue'' AS color,
''check-circle'' AS icon
FROM tap_test_results WHERE name = $file;

SELECT
''## Passed Tests'' AS description_md,
''white'' AS background_color,
''## '' || COALESCE(passed_tests, 0) AS description_md,
''green'' AS color,
''circle-check'' AS icon
FROM tap_test_results WHERE name = $file;

SELECT
''## Failed Tests'' AS description_md,
''white'' AS background_color,
''## '' || COALESCE(failed_tests, 0) AS description_md,
''red'' AS color,
''circle-x'' AS icon
FROM tap_test_results WHERE name = $file;

SELECT
''## Pass Rate'' AS description_md,
''white'' AS background_color,
''## '' || CASE
    WHEN total_test_lines > 0
    THEN ROUND((passed_tests * 100.0) / total_test_lines, 1) || ''%''
    ELSE ''0%''
END AS description_md,
''lime'' AS color,
''percentage'' AS icon
FROM tap_test_results WHERE name = $file;

-- Pagination Controls (Top)
SET total_rows = (SELECT COUNT(*) FROM tap_test_results_detail WHERE tap_file_name = $file);
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Individual Test Cases Table
SELECT ''table'' as component,
       TRUE as sort,
       TRUE as search;

SELECT
    COALESCE(ttrd.test_case_id, ''N/A'') as "Test Case ID",
    CASE
        WHEN ttrd.test_status = ''passed'' THEN ''✅ Passed''
        WHEN ttrd.test_status = ''failed'' THEN ''❌ Failed''
        ELSE ''❓ Unknown''
    END as "Status",
    COALESCE(ttrd.test_description, ''No description'') as "Test Description",
    ttrd.original_tap_line as "Original TAP Line",
    CASE
        WHEN ttrd.test_status = ''passed'' THEN ''rowClass-100''
        WHEN ttrd.test_status = ''failed'' THEN ''rowClass-0''
        ELSE ''rowClass-50''
    END as _sqlpage_css_class
FROM tap_test_results_detail ttrd
WHERE ttrd.tap_file_name = $file
ORDER BY ttrd.test_number ASC
LIMIT $limit OFFSET $offset;

-- Pagination Controls (Bottom)
SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&file='' || replace($file, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&file='' || replace($file, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/download-test-suites.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select ''csv'' as component, ''test_suites.csv'' as filename;
SELECT * FROM test_suites;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/chart1.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    --First Chart: Test Case Status Distribution
    SELECT
    ''chart'' AS component,
      ''Comprehensive Test Status'' AS title,
        ''pie'' AS type,
          TRUE AS labels,
            ''green'' as color,
            ''red'' as color,
            ''azure'' as color,
            ''chart-left'' AS class; --Custom class for styling the first chart

    --Data for the first chart
SELECT
    ''Passed'' AS label,
      ROUND(100.0 * SUM(CASE WHEN r.status = ''passed'' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2) AS value
    FROM 
    test_cases t
LEFT JOIN 
    test_case_run_results r
    ON
    t.test_case_id = r.test_case_id;

    SELECT
    ''Failed'' AS label,
      ROUND(100.0 * SUM(CASE WHEN r.status = ''failed'' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2) AS value
    FROM 
    test_cases t
LEFT JOIN 
    (select * from test_case_run_results group by test_case_id ) r
    ON
    t.test_case_id = r.test_case_id;

    SELECT
    ''Todo'' AS label,
      ROUND(100.0 * SUM(CASE WHEN r.status IS NULL THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2) AS value
    FROM 
    test_cases t
LEFT JOIN 
    test_case_run_results r
    ON
    t.test_case_id = r.test_case_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/progress-bar.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''chart'' as component,
  ''treemap'' as type,
  ''Quarterly Results By Region (in k$)'' as title,
  TRUE as labels;
select
''North America'' as series,
  ''United States'' as label,
  35 as value;
select
''North America'' as series,
  ''Canada'' as label,
  15 as value;
select
''Europe'' as series,
  ''France'' as label,
  30 as value;
select
''Europe'' as series,
  ''Germany'' as label,
  55 as value;
select
''Asia'' as series,
  ''China'' as label,
  20 as value;
select
''Asia'' as series,
  ''Japan'' as label,
  10 as value;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/chart2.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    SELECT
    ''chart'' AS component,
      ''Total Automated Test Case Coverage'' AS title,
        ''pie'' AS type,
          TRUE AS labels,
            ''green'' as color,
            ''yellow'' as color,
            ''chart-right'' AS class; --Custom class for styling the second chart

    --Data for the second chart
SELECT
    ''Automated'' AS label,
      ROUND(100.0 * SUM(CASE WHEN test_type = ''Automation'' THEN 1 ELSE 0 END) / COUNT(*), 2) AS value
    FROM
    test_cases;

    SELECT
    ''Manual'' AS label,
      ROUND(100.0 * SUM(CASE WHEN test_type = ''Manual'' THEN 1 ELSE 0 END) / COUNT(*), 2) AS value
    FROM
    test_cases;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/suite-data.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    select
    ''breadcrumb'' as component;
    select
    ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
    select
    ''Test Management System'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
    select
    "name" as title from test_suites where CAST(id AS TEXT) = CAST($id AS TEXT);
    SELECT ''title''AS component,
      name as contents FROM test_suites  WHERE id = $id;

    -- Custom CSS for accordion styling
    SELECT ''html'' AS component,
      ''<style>
        .custom-accordion {
          margin: 20px 0;
          border: 1px solid #ddd;
          border-radius: 4px;
          overflow: hidden;
        }
        .custom-accordion details {
          border: none;
          margin: 0;
        }
        .custom-accordion details + details {
          border-top: 1px solid #ddd;
        }
        .custom-accordion summary {
          background-color: #f5f5f5;
          padding: 15px 20px;
          cursor: pointer;
          font-weight: 500;
          color: #333;
          border: none;
          outline: none;
          position: relative;
          user-select: none;
          list-style: none;
        }
        .custom-accordion summary::-webkit-details-marker {
          display: none;
        }
        .custom-accordion summary::after {
          content: "+";
          position: absolute;
          right: 20px;
          top: 50%;
          transform: translateY(-50%);
          font-size: 18px;
          font-weight: bold;
          color: #666;
        }
        .custom-accordion details[open] summary::after {
          content: "−";
        }
        .custom-accordion summary:hover {
          background-color: #ebebeb;
        }
        .custom-accordion .content {
          padding: 20px;
          background-color: white;
          border-top: 1px solid #ddd;
        }
      </style>'' AS html;

    -- Accordion container
    SELECT ''html'' AS component,
      ''<div class="custom-accordion">'' AS html;

    -- Suite Details Section (open by default)
    SELECT ''html'' AS component,
      ''<details open>
        <summary>Suite Details</summary>
        <div class="content">'' AS html;

    SELECT ''card'' AS component,
           1 AS columns;

    SELECT
    ''**Description:** '' || COALESCE(rn."description", ''No description available'') ||
    ''

**Created By:** '' || COALESCE(rn.created_by_user, ''Unknown'') ||
    ''

**Created At:** '' || strftime(''%d-%m-%Y'', rn.created_at) ||
    ''

**Linked Requirements:** '' || COALESCE(rn.linked_requirements, ''None specified'') ||
    CASE
      WHEN rn.body IS NOT NULL AND rn.body != ''''
      THEN ''

**Additional Details:**
'' || rn.body
      ELSE ''''
    END AS description_md
    FROM test_suites rn WHERE id = $id;

    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

    -- Test Case Groups Section (closed by default)
    SELECT ''html'' AS component,
      ''<details>
        <summary>Test Case Groups ('' || COUNT(*) || '')</summary>
        <div class="content">'' AS html
    FROM (SELECT DISTINCT group_id FROM test_cases_run_status WHERE suite_id = $id);

    SELECT ''text'' AS component,
      ''This section contains all test case groups within this test suite. Each group represents a collection of related test cases organized by functionality or testing scope.'' AS contents;

    -- Create individual accordion for each group
    SELECT ''html'' AS component,
      ''<div class="groups-accordion-container">'' AS html;

    -- Generate accordion for each group
    SELECT ''html'' AS component,
      ''<details class="group-accordion">
        <summary class="group-summary">'' || tcrs.group_id || '' - '' || tcrs.group_name || ''</summary>
        <div class="group-content">
          <div class="group-info-card">
            <h4>Group Information</h4>
            <p><strong>Description:</strong> '' || COALESCE(g.description, ''No description available for this group.'') || ''</p>
            <p><strong>Created by:</strong> '' || tcrs.created_by || ''</p>
            <p><strong>Created on:</strong> '' || tcrs.formatted_test_case_created_at || ''</p>

            <h4>Test Case Statistics</h4>
            <div class="stats-grid">
              <div class="stat-item">
                <span class="stat-label">Total Test Cases:</span>
                <span class="stat-value stat-total">'' ||
                COALESCE((SELECT COUNT(*) FROM test_cases WHERE group_id = tcrs.group_id), 0) || ''</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Passed:</span>
                <span class="stat-value stat-passed">'' ||
                COALESCE((SELECT COUNT(*) FROM test_cases WHERE group_id = tcrs.group_id AND test_status = "passed"), 0) || ''</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Failed:</span>
                <span class="stat-value stat-failed">'' ||
                COALESCE((SELECT COUNT(*) FROM test_cases WHERE group_id = tcrs.group_id AND test_status = "failed"), 0) || ''</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Pending:</span>
                <span class="stat-value stat-pending">'' ||
                COALESCE((SELECT COUNT(*) FROM test_cases WHERE group_id = tcrs.group_id AND (test_status IS NULL OR test_status = "TODO")), 0) || ''</span>
              </div>
            </div>

            <div class="action-buttons">
              <a href="'' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/group-detail.sql?id='' || tcrs.group_id || ''" class="view-details-btn">View Full Details</a>
            </div>
          </div>
        </div>
      </details>'' AS html
    FROM test_cases_run_status tcrs
    LEFT JOIN groups g ON g.id = tcrs.group_id
    WHERE tcrs.suite_id = $id
    ORDER BY tcrs.group_id ASC;

    SELECT ''html'' AS component,
      ''</div>'' AS html;

    -- Add custom CSS for the accordion styling
    SELECT ''html'' AS component,
      ''<style>
        .groups-accordion-container {
          margin: 20px 0;
        }

        .group-accordion {
          border: 1px solid #ddd;
          border-radius: 8px;
          margin-bottom: 10px;
          overflow: hidden;
        }

        .group-summary {
          background-color: #f5f5f5;
          padding: 15px 20px;
          cursor: pointer;
          font-weight: 600;
          color: #333;
          border: none;
          outline: none;
          user-select: none;
          list-style: none;
          position: relative;
          transition: background-color 0.2s;
        }

        .group-summary::-webkit-details-marker {
          display: none;
        }

        .group-summary::after {
          content: "+";
          position: absolute;
          right: 20px;
          top: 50%;
          transform: translateY(-50%);
          font-size: 18px;
          font-weight: bold;
          color: #666;
        }

        .group-accordion[open] .group-summary::after {
          content: "−";
        }

        .group-summary:hover {
          background-color: #ebebeb;
        }

        .group-content {
          padding: 0;
          background-color: white;
          border-top: 1px solid #ddd;
        }

        .group-info-card {
          padding: 20px;
        }

        .group-info-card h4 {
          margin: 0 0 15px 0;
          color: #333;
          font-size: 16px;
          border-bottom: 1px solid #eee;
          padding-bottom: 8px;
        }

        .group-info-card p {
          margin: 8px 0;
          line-height: 1.5;
        }

        .stats-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 10px;
          margin: 15px 0;
        }

        .stat-item {
          display: flex;
          justify-content: space-between;
          padding: 8px 12px;
          background-color: #f8f9fa;
          border-radius: 4px;
          border-left: 3px solid #dee2e6;
        }

        .stat-label {
          color: #666;
          font-weight: 500;
        }

        .stat-value {
          font-weight: bold;
        }

        .stat-total {
          color: #333;
        }

        .stat-passed {
          color: #28a745;
        }

        .stat-item:has(.stat-passed) {
          border-left-color: #28a745;
        }

        .stat-failed {
          color: #dc3545;
        }

        .stat-item:has(.stat-failed) {
          border-left-color: #dc3545;
        }

        .stat-pending {
          color: #ffc107;
        }

        .stat-item:has(.stat-pending) {
          border-left-color: #ffc107;
        }

        .action-buttons {
          margin-top: 20px;
          padding-top: 15px;
          border-top: 1px solid #eee;
        }

        .view-details-btn {
          display: inline-block;
          padding: 10px 20px;
          background-color: #007bff;
          color: white;
          text-decoration: none;
          border-radius: 5px;
          font-weight: 500;
          transition: background-color 0.2s;
        }

        .view-details-btn:hover {
          background-color: #0056b3;
          color: white;
          text-decoration: none;
        }

        @media (max-width: 768px) {
          .stats-grid {
            grid-template-columns: 1fr;
          }
        }
      </style>'' AS html;

    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

    -- Close accordion container
    SELECT ''html'' AS component,
      ''</div>'' AS html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-cases.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''qualityfolio/test-cases.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''qualityfolio/test-cases.sql/index.sql'') as contents;
    ;

-- Page description based on context
SELECT ''text'' AS component,
  CASE
    WHEN $id IS NOT NULL THEN
      ''This page displays test cases for the selected group: '' || (SELECT group_name FROM test_cases WHERE group_id = $id LIMIT 1) || ''. Use the search and filter functionality to find specific test cases.''
    ELSE
      ''This page displays a comprehensive list of all test cases across all projects and test suites. Use the search and filter functionality to find specific test cases by name, status, group, or priority.''
  END AS contents;

-- Status overview based on context
SELECT ''alert'' AS component,
       ''info'' AS color,
       CASE
         WHEN $id IS NOT NULL THEN ''Group Test Case Overview''
         ELSE ''Test Case Overview''
       END AS title,
       ''Total test cases: '' ||
       CASE
         WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id)
         ELSE (SELECT COUNT(*) FROM test_cases)
       END ||
       '' | Passed: '' ||
       CASE
         WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id AND test_status = ''passed'')
         ELSE (SELECT COUNT(*) FROM test_cases WHERE test_status = ''passed'')
       END ||
       '' | Failed: '' ||
       CASE
         WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id AND test_status = ''failed'')
         ELSE (SELECT COUNT(*) FROM test_cases WHERE test_status = ''failed'')
       END ||
       '' | Pending: '' ||
       CASE
         WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id AND (test_status IS NULL OR test_status = ''TODO''))
         ELSE (SELECT COUNT(*) FROM test_cases WHERE test_status IS NULL OR test_status = ''TODO'')
       END AS description;

SELECT ''html'' as component,
  ''<style>
     tr td.test_status {
          color: blue !important;
      }
      tr.rowClass-passed td.test_status {
          color: green !important;
      }
       tr.rowClass-failed td.test_status {
          color: red !important;
      }
      tr.rowClass-TODO td.test_status {
          color: orange !important;
      }
      .btn-list {
      display: flex;
      justify-content: flex-end;
  }
  </style>'' as html;

SELECT ''button'' as component;

-- Show "View All Test Cases" button when filtering by group
SELECT ''View All Test Cases'' as title,
       ''test-cases.sql'' as link,
       ''list'' as icon
WHERE $id IS NOT NULL
UNION ALL
-- Show "Export Group Test Cases" button when filtering by group
SELECT ''Export Group Test Cases'' as title,
       ''download-test-case.sql?group_id='' || $id as link,
       ''download'' as icon
WHERE $id IS NOT NULL
UNION ALL
-- Show "Export All Test Cases" button when showing all test cases
SELECT ''Export All Test Cases'' as title,
       ''download-full_list.sql'' as link,
       ''download'' as icon
WHERE $id IS NULL;

SET total_rows = (SELECT COUNT(*) FROM test_cases WHERE ($id IS NULL OR group_id = $id));
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

SELECT ''table'' as component,
       TRUE AS sort,
       TRUE AS search,
       ''Test Case ID'' as markdown,
       ''Title'' as markdown,
       ''Group'' as markdown,
       ''Suite'' as markdown,
       ''Status'' as markdown;

SELECT
  ''['' || tc.test_case_id || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=actual-result&id=''|| tc.test_case_id || '')'' as "Test Case ID",
  tc.test_case_title AS "Title",
  ''['' || tc.group_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/group-detail.sql?id=''|| tc.group_id || '')'' AS "Group",
  ''['' || ts.name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/suite-data.sql?id=''|| ts.id || '')'' AS "Suite",
  CASE
    WHEN tc.test_status IS NOT NULL THEN tc.test_status
    ELSE ''TODO''
  END AS "Status",
  ''rowClass-'' || COALESCE(tc.test_status, ''TODO'') as _sqlpage_css_class,
  tc.test_type AS "Type",
  tc.priority AS "Priority",
  tc.created_by AS "Created By",
  tc.formatted_test_case_created_at AS "Created On"
FROM test_cases tc
LEFT JOIN test_suites ts ON ts.id = tc.suite_id
WHERE ($id IS NULL OR tc.group_id = $id)
ORDER BY tc.test_case_id
LIMIT $limit OFFSET $offset;

SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&id='' || replace($id, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&id='' || replace($id, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/download-test-case.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select ''csv'' as component, ''test_suites_''||$group_id||''.csv'' as filename;
 SELECT
  test_case_id as id,
  test_case_title AS "title",
  group_name AS "group",
  test_status,
  created_by as "Created By",
  formatted_test_case_created_at as "Created On",
  priority as "Priority"
FROM test_cases t
WHERE  group_id = $group_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/download-full_list.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select ''csv'' as component, ''test_cases.csv'' as filename;
 SELECT
  test_case_id as id,
  test_case_title AS "title",
  group_name AS "group",
  test_status,
  created_by as "Created By",
  formatted_test_case_created_at as "Created On",
  priority as "Priority"
FROM test_cases t;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/bug-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''html'' as component,
''<style>
    
    tr td.Statealign-middle {
        color: blue !important; /* Default to blue */
    }
    tr.rowClass-Completed td.state {
        color: green !important; /* Default to blue */
    }
     tr.rowClass-Rejected td.state {
        color: red !important; /* Default to blue */
    }
     tr.rowClass-Completed td.Statealign-middle {
        color: green !important; /* Default to blue */
    }
     tr.rowClass-Rejected td.Statealign-middle {
        color: red !important; /* Default to blue */
    }

}
</style>'' as html;
 select
''breadcrumb'' as component;
select
''Home'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
select
''Test Management System'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link; 
select ''bug list'' as title;  

 SELECT ''table'' as component,
  TRUE AS sort,
    TRUE AS search,
      ''URL'' AS align_left,
        ''title'' AS align_left,
          ''group'' as markdown,
          ''id'' as markdown,
          "status_new" as markdown,
          ''count'' as markdown;
SELECT
''['' || bug_id || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/bug-detail.sql?id=''|| bug_id || '')'' as id,
  title,
  reporter as ''Reporter'',
  strftime(''%d-%m-%Y'', created) as "Created At",
  assignee,
  status as "State",
  ''rowClass-''||status as _sqlpage_css_class
FROM jira_issues t WHERE ($status IS NOT NULL AND status = $status) OR $status IS NULL;
--  FROM jira_issues t
--  LIMIT $limit
--   OFFSET $offset;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/suite-group.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              

    --Define tabs
    SELECT
    ''tab'' AS component,
      TRUE AS center;

    --Tab 1: Test Suite list
    SELECT
    ''Test Plan List'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/suite-group?tab=test_suites'' AS link,
        $tab = ''test_suites'' AS active;


    --Tab 2: Test case list
    SELECT
    ''Test Case List'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/suite-group?tab=test_cases'' AS link,
        $tab = ''test_cases'' AS active;

    --Tab 3: Meta Tags Missing URLs
    SELECT
    ''Test Run List'' AS title,
      $tab = ''test_run'' AS active;

    SELECT 
      case when $tab = ''test_suites'' THEN ''card''
      END AS component,
       1                          as columns;

   
    SELECT
    '' **Name**  :  '' || rn.name AS description_md,
      ''
 **Description**  :  '' || rn."description" AS description_md,
        ''
 **Created By**  :  '' || rn.created_by_user AS description_md,
          ''
 **Created At**  :  '' || strftime(''%d-%m-%Y'', rn.created_at) AS description_md,
            ''
 **Priority**  :  '' || rn.linked_requirements AS description_md,
              ''
'' || rn.body AS description_md
FROM test_suites rn WHERE id = $id;


    --Define component type based on active tab
    SELECT
    CASE
        WHEN $tab = ''test_cases'' THEN ''table''
        WHEN $tab = ''test_suites'' THEN ''table''
        WHEN $tab = ''test_run'' THEN ''table''
      END AS component,
      TRUE AS sort,
        --TRUE AS search,
          ''URL'' AS align_left,
            ''title'' AS align_left,
              ''group'' as markdown,
              ''id'' as markdown,
              ''count'' as markdown;

    --Conditional content based on active tab

    --Tab - specific content for "test_suites"
    SELECT
      ''['' || test_case_id || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=actual-result&id=''|| test_case_id || '')'' as id,
      test_case_title AS "title",
        group_name AS "group",
          created_by as "Created By",
          formatted_test_case_created_at as "Created On",
          priority as "Priority"
    FROM test_cases
    WHERE $tab = ''test_cases'' and group_id = $id 
    order by test_case_id;




    --Tab - specific content for "test_run"
   SELECT
      name AS "Property Name"
    FROM groups
    WHERE $tab = ''test_run'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-management.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''qualityfolio/test-management.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''qualityfolio/test-management.sql/index.sql'') as contents;
    ;

  SELECT ''list'' AS component,
  ''Column Count'' as align_right,
  TRUE as sort,
  TRUE as search;



SELECT
''['' || project_name || ''](/qualityfolio/detail.sql?name='' || project || '')'' as description_md
  from projects;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''qualityfolio/test-detail.sql/index.sql'') as contents;
    ;

    select
    ''breadcrumb'' as component;
    select
    ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
    select
    ''Test Management System'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link; 
    select s.name as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/suite-data.sql?id='' || s.id as link
         FROM test_cases r
         INNER JOIN groups g on g.id = r.group_id 
         INNER JOIN test_suites s on s.id = g.suite_id
         where test_case_id = $id
         group by title;  
    select g.name as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-cases.sql?id='' || g.id as link
         FROM test_cases r
         INNER JOIN groups g on g.id = r.group_id 
         where test_case_id = $id
         group by title;
         
    SELECT title FROM test_cases where test_case_id = $id order by created_at desc limit 1;      
         

         

    SELECT ''title''AS component,
      title as contents FROM test_cases where test_case_id = $id order by created_at desc limit 1;

    -- Test Case Details Accordion Container
    SELECT ''html'' AS component,
      ''<details class="test-detail-outer-accordion" open>
        <summary class="test-detail-outer-summary">Test Case Details</summary>
        <div class="test-detail-outer-content">'' AS html;

     SELECT ''card''  AS component,
    1                          as columns;
    SELECT
    ''
 **Title**  :  '' || bd.title AS description_md,
    ''
 **Group**  :  '' || bd.group_name AS description_md,
    ''
 **Created By**  :  '' || bd.created_by AS description_md,
    ''
 **Created At**  :  '' || strftime(''%d-%m-%Y'',  bd.created_at) AS description_md,
    ''
 **Priority**  :  '' || bd.priority AS description_md,
    ''
'' || bd.body AS description_md
FROM  test_cases bd WHERE bd.test_case_id = $id  group by bd.test_case_id;

    -- Close Test Case Details Accordion
    SELECT ''html'' AS component,
      ''</div></details>'' AS html;


  SELECT ''html'' as component,
    ''<style>
        tr.actualClass-passed td.State {
            color: green !important; /* Default to red */
        }
         tr.actualClass-failed td.State {
            color: red !important; /* Default to red */
        }
          tr.actualClass-passed td.Statealign-middle {
            color: green !important; /* Default to red */
        }
          tr.actualClass-failed td.Statealign-middle {
            color: red !important; /* Default to red */
        }
        
        .btn-list {
        display: flex;
        justify-content: flex-end;
        }
       h2.accordion-header button {
        font-weight: 700;
      }

      /* Test Detail Outer Accordion Styles */
      .test-detail-outer-accordion {
        border: 1px solid #ddd;
        border-radius: 8px;
        margin: 20px 0;
        overflow: hidden;
      }

      .test-detail-outer-summary {
        background-color: #f5f5f5;
        padding: 15px 20px;
        cursor: pointer;
        font-weight: 600;
        color: #333;
        border: none;
        outline: none;
        user-select: none;
        list-style: none;
        position: relative;
        transition: background-color 0.2s;
      }

      .test-detail-outer-summary::-webkit-details-marker {
        display: none;
      }

      .test-detail-outer-summary::after {
        content: "+";
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 18px;
        font-weight: bold;
        color: #666;
      }

      .test-detail-outer-accordion[open] .test-detail-outer-summary::after {
        content: "−";
      }

      .test-detail-outer-summary:hover {
        background-color: #ebebeb;
      }

      .test-detail-outer-content {
        padding: 20px;
        background-color: white;
        border-top: 1px solid #ddd;
      }
    </style>

    '' as html FROM test_case_run_results where test_case_id = $id group by group_id;

    -- Test Execution Data Accordion Container
    SELECT ''html'' AS component,
      ''<details class="test-detail-outer-accordion" open>
        <summary class="test-detail-outer-summary">Test Execution Data</summary>
        <div class="test-detail-outer-content">'' AS html;

    --Define tabs
    SELECT
    ''tab'' AS component,
      TRUE AS center
     FROM test_case_run_results where test_case_id = $id group by group_id;

    --Tab 1: Actual Result
    SELECT
    ''Actual Result'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=actual-result&id=''|| $id || ''#actual-result-content''  AS link,
      $tab = ''actual-result'' AS active
        FROM test_case_run_results where test_case_id = $id group by group_id;


    --Tab 2: Test Run
    SELECT
    ''Test Run'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=test-run&id=''|| $id || ''#test-run-content''  AS link,
      $tab = ''test-run'' AS active
         FROM test_case_run_results where test_case_id = $id group by group_id;

--Tab 3: Bug Report
    SELECT
    ''Bug Report'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=bug-report&id=''|| $id || ''#bug-report-content''  AS link,
      $tab = ''bug-report'' AS active
         FROM bug_list  where test_case_id = $id;



    SELECT
    CASE
        WHEN $tab = ''actual-result'' THEN ''title''
    END AS component,
      ''Actual Result'' as contents
    FROM test_case_run_results WHERE test_case_id = $id group by group_id;

    SELECT
    CASE
        WHEN $tab = ''actual-result'' THEN ''table''
        WHEN $tab = ''test-run'' THEN ''list''
         WHEN $tab = ''bug-report'' THEN ''foldable''
      END AS component,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search
        FROM test_case_run_results  where test_case_id = $id group by group_id;


    --Tab - specific content for "actual-result"


    SELECT
    step_name as ''Activity'',
      step_status as ''State'',
      ''actualClass-''||step_status as _sqlpage_css_class,
      step_start_time as ''Start Time'',
      step_end_time as ''End Time''
          FROM test_execution_log
          WHERE $tab = ''actual-result'' and  test_case_id = $id order by step_start_time desc;
    SELECT
    CASE
        WHEN $tab = ''actual-result'' THEN ''html''
    END AS component,
      ''<div id="actual-result-content"></div>'' as html
       FROM test_execution_log
          WHERE $tab = ''actual-result'' and  test_case_id = $id;



    --Tab - specific content for "test-run"
    SELECT
    ''
 **Run Date**  :  '' || strftime(''%d-%m-%Y'',run_date) AS description_md,
      ''
 **Environment**  :  '' || environment AS description_md,
        ''
'' || body AS description_md
    FROM  test_run WHERE $tab = ''test-run'' and test_case_id = $id;

    SELECT
    CASE
        WHEN $tab = ''test-run'' THEN ''html''
    END AS component,
      ''<div id="test-run-content"></div>'' as html
      FROM  test_run WHERE $tab = ''test-run'' and test_case_id = $id;
   

    --Tab - specific content for "bug-report"


    select
    title         as title,
     ''
 

**id**  :  '' || l.bug_id AS description_md,
    ''
 **Created By**  :  '' || reporter AS description_md,
    ''
 **Run Date**  :  '' || strftime(''%d-%m-%Y'', created) AS description_md,
    ''
 **Type**  :  '' || type AS description_md,
    ''
 **Assigned**  :  '' || assignee AS description_md,
    ''
 **Status**  :  '' || status AS description_md,
    ''
'' || description AS description_md
    FROM
    bug_list l
    inner join
    jira_issues j on l.bug_id=j.bug_id
    where l.test_case_id=$id;

    SELECT
    CASE
        WHEN $tab = ''bug-report'' THEN ''html''
    END AS component,
      ''<div id="bug-report-content"></div>'' as html
    FROM  bug_list l
    inner join
    jira_issues j on l.bug_id=j.bug_id
    where l.test_case_id=$id;

    -- Close Test Execution Data Accordion
    SELECT ''html'' AS component,
      ''</div></details>'' AS html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/bug-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''qualityfolio/bug-detail.sql/index.sql'') as contents;
    ;

    select
    ''breadcrumb'' as component;
    select
    ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
    select
    ''Test Management System'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link; 
    select ''bug list'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/bug-list.sql'' as link;  
      
    SELECT title FROM jira_issues where bug_id = $id order by created desc ;      
         

         

    /*SELECT ''title''AS component,
      title as contents FROM jira_issues where id = $id order by created_at desc;*/

    select 
    ''datagrid''      as component,
    title         as title,
    ''bulb''          as icon,
     ''
 

**id**  :  '' || bug_id AS description_md,    
    ''
 **Created By**  :  '' || reporter AS description_md,
    ''
 **Run Date**  :  '' || strftime(''%d-%m-%Y'', created) AS description_md,
    ''
 **Type**  :  '' || type AS description_md,
    ''
 **Assigned**  :  '' || assignee AS description_md,
    ''
 **Status**  :  '' || status AS description_md,
    ''
'' || description AS description_md 
      FROM  jira_issues  WHERE bug_id = $id;
     
    /*SELECT ''datagrid''AS component;
     SELECT
    ''
 **id**  :  '' || id AS description_md
    
    ''
 **Title**  :  '' || title AS description_md,
    ''
 **Created By**  :  '' || b.created_by AS description_md,
    ''
 **Run Date**  :  '' || strftime(''%d-%m-%Y'', b.created_at) AS description_md,
    ''
 **Type**  :  '' || b.type AS description_md,
    ''
 **Priority**  :  '' || b.priority AS description_md,
    ''
 **Assigned**  :  '' || b.assigned AS description_md,
    ''
 **Status**  :  '' || b.status AS description_md,
    ''
'' || b.body AS description_md
    FROM  bug_report b 
    WHERE b.id = $id;*/;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/group-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''qualityfolio/group-detail.sql/index.sql'') as contents;
    ;

    select
    ''breadcrumb'' as component;
    select
    ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
    select
    ''Test Management System'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
    select
    s."name" as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/suite-data.sql?id='' || s.id as link
         from groups g
        inner join  test_suites s on s.id = g.suite_id where g.id = $id;
    select
    g."name" as title from groups g
        inner join  test_suites s on s.id = g.suite_id where g.id = $id;


    SELECT ''title''AS component,
      name as contents FROM groups where id = $id;

    -- Custom CSS for accordion styling (same as suite-data)
    SELECT ''html'' AS component,
      ''<style>
        .custom-accordion {
          margin: 20px 0;
          border: 1px solid #ddd;
          border-radius: 4px;
          overflow: hidden;
        }
        .custom-accordion details {
          border: none;
          margin: 0;
        }
        .custom-accordion details + details {
          border-top: 1px solid #ddd;
        }
        .custom-accordion summary {
          background-color: #f5f5f5;
          padding: 15px 20px;
          cursor: pointer;
          font-weight: 500;
          color: #333;
          border: none;
          outline: none;
          position: relative;
          user-select: none;
          list-style: none;
        }
        .custom-accordion summary::-webkit-details-marker {
          display: none;
        }
        .custom-accordion summary::after {
          content: "+";
          position: absolute;
          right: 20px;
          top: 50%;
          transform: translateY(-50%);
          font-size: 18px;
          font-weight: bold;
          color: #666;
        }
        .custom-accordion details[open] summary::after {
          content: "−";
        }
        .custom-accordion summary:hover {
          background-color: #ebebeb;
        }
        .custom-accordion .content {
          padding: 20px;
          background-color: white;
          border-top: 1px solid #ddd;
        }
        tr td.test_status {
             color: blue !important;
         }
         tr.rowClass-passed td.test_status {
             color: green !important;
         }
          tr.rowClass-failed td.test_status {
             color: red !important;
         }
         tr.rowClass-TODO td.test_status {
             color: orange !important;
         }

         /* Test Case Accordion Styles */
         .test-cases-accordion-container {
           margin: 20px 0;
         }

         .test-case-accordion {
           border: 1px solid #ddd;
           border-radius: 8px;
           margin-bottom: 10px;
           overflow: hidden;
         }

         .test-case-summary {
           background-color: #f5f5f5;
           padding: 15px 20px;
           cursor: pointer;
           font-weight: 600;
           color: #333;
           border: none;
           outline: none;
           user-select: none;
           list-style: none;
           position: relative;
           transition: background-color 0.2s;
         }

         .test-case-summary::-webkit-details-marker {
           display: none;
         }

         .test-case-summary::after {
           content: "+";
           position: absolute;
           right: 20px;
           top: 50%;
           transform: translateY(-50%);
           font-size: 18px;
           font-weight: bold;
           color: #666;
         }

         .test-case-accordion[open] .test-case-summary::after {
           content: "−";
         }

         .test-case-summary:hover {
           background-color: #ebebeb;
         }

         .test-case-content {
           padding: 0;
           background-color: white;
           border-top: 1px solid #ddd;
         }

         .test-case-info-card {
           padding: 20px;
         }

         .test-case-info-card h4 {
           margin: 0 0 15px 0;
           color: #333;
           font-size: 16px;
           border-bottom: 1px solid #eee;
           padding-bottom: 8px;
         }

         .test-case-info-card p {
           margin: 8px 0;
           line-height: 1.5;
         }

         .execution-stats {
           display: grid;
           grid-template-columns: 1fr;
           gap: 8px;
           margin: 15px 0;
         }

         .exec-stat-item {
           display: flex;
           justify-content: space-between;
           padding: 10px 15px;
           background-color: #f8f9fa;
           border-radius: 4px;
           border-left: 3px solid #dee2e6;
         }

         .exec-stat-label {
           color: #666;
           font-weight: 500;
         }

         .exec-stat-value {
           font-weight: bold;
         }

         .status-passed {
           color: #28a745;
         }

         .exec-stat-item:has(.status-passed) {
           border-left-color: #28a745;
         }

         .status-failed {
           color: #dc3545;
         }

         .exec-stat-item:has(.status-failed) {
           border-left-color: #dc3545;
         }

         .status-TODO {
           color: #ffc107;
         }

         .exec-stat-item:has(.status-TODO) {
           border-left-color: #ffc107;
         }

         .action-buttons {
           margin-top: 20px;
           padding-top: 15px;
           border-top: 1px solid #eee;
         }

         .view-details-btn {
           display: inline-block;
           padding: 10px 20px;
           background-color: #007bff;
           color: white;
           text-decoration: none;
           border-radius: 5px;
           font-weight: 500;
           transition: background-color 0.2s;
         }

         .view-details-btn:hover {
           background-color: #0056b3;
           color: white;
           text-decoration: none;
         }

         @media (max-width: 768px) {
           .execution-stats {
             grid-template-columns: 1fr;
           }
         }
      </style>'' AS html;

    -- Accordion container
    SELECT ''html'' AS component,
      ''<div class="custom-accordion">'' AS html;

    -- Group Details Section (open by default)
    SELECT ''html'' AS component,
      ''<details open>
        <summary>Group Details</summary>
        <div class="content">'' AS html;

    SELECT ''card''  AS component,
    1                          as columns;
    SELECT
    ''**Group ID:** '' || rn.id ||
    ''

**Name:** '' || rn."name" ||
    ''

**Description:** '' || COALESCE(rn."description", ''No description available'') ||
    ''

**Created By:** '' || COALESCE(rn."created_by", ''Unknown'') ||
    ''

**Created On:** '' || strftime(''%d-%m-%Y'', rn."created_at") ||
    CASE
      WHEN rn.body IS NOT NULL AND rn.body != ''''
      THEN ''

**Additional Details:**
'' || rn.body
      ELSE ''''
    END AS description_md
FROM groups rn
INNER JOIN test_suites st ON st.id = rn.suite_id
WHERE rn.id = $id;

    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

    -- Test Cases Section (closed by default)
    SELECT ''html'' AS component,
      ''<details>
        <summary>Test Cases ('' || COUNT(*) || '')</summary>
        <div class="content">'' AS html
    FROM test_cases WHERE group_id = $id;

    SELECT ''text'' AS component,
      ''This section displays all test cases associated with this group, including their current status and execution details.'' AS contents;

    -- Show test case count for this group
    SELECT ''alert'' AS component,
           ''info'' AS color,
           ''Test Cases Summary'' AS title,
           ''Total: '' || COUNT(*) ||
           '' | Passed: '' || SUM(CASE WHEN test_status = ''passed'' THEN 1 ELSE 0 END) ||
           '' | Failed: '' || SUM(CASE WHEN test_status = ''failed'' THEN 1 ELSE 0 END) ||
           '' | Pending: '' || SUM(CASE WHEN test_status IS NULL OR test_status = ''TODO'' THEN 1 ELSE 0 END) AS description
    FROM test_cases WHERE group_id = $id;

    -- Create individual accordion for each test case
    SELECT ''html'' AS component,
      ''<div class="test-cases-accordion-container">'' AS html;

    -- Generate accordion for each test case
    SELECT ''html'' AS component,
      ''<details class="test-case-accordion">
        <summary class="test-case-summary">'' || tc.test_case_id || '' - '' || tc.test_case_title || ''</summary>
        <div class="test-case-content">
          <div class="test-case-info-card">
            <h4>Test Case Information</h4>
            <p><strong>Test Case ID:</strong> '' || tc.test_case_id || ''</p>
            <p><strong>Title:</strong> '' || tc.test_case_title || ''</p>
            <p><strong>Group:</strong> '' || tc.group_name || ''</p>
            <p><strong>Type:</strong> '' || COALESCE(tc.test_type, ''Not specified'') || ''</p>
            <p><strong>Priority:</strong> '' || COALESCE(tc.priority, ''Not specified'') || ''</p>
            <p><strong>Created by:</strong> '' || COALESCE(tc.created_by, ''Unknown'') || ''</p>
            <p><strong>Created on:</strong> '' || tc.formatted_test_case_created_at || ''</p>

            <h4>Test Execution Details</h4>
            <div class="execution-stats">
              <div class="exec-stat-item">
                <span class="exec-stat-label">Current Status:</span>
                <span class="exec-stat-value status-'' || COALESCE(tc.test_status, ''TODO'') || ''">'' ||
                CASE
                  WHEN tc.test_status IS NOT NULL THEN tc.test_status
                  ELSE ''TODO''
                END || ''</span>
              </div>
              <div class="exec-stat-item">
                <span class="exec-stat-label">Execution Count:</span>
                <span class="exec-stat-value">'' ||
                COALESCE((SELECT COUNT(*) FROM test_execution_log WHERE test_case_id = tc.test_case_id), 0) || ''</span>
              </div>
            </div>

            <div class="action-buttons">
              <a href="'' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=actual-result&id='' || tc.test_case_id || ''" class="view-details-btn">View Full Details</a>
            </div>
          </div>
        </div>
      </details>'' AS html
    FROM test_cases tc
    WHERE tc.group_id = $id
    ORDER BY tc.test_case_id;

    SELECT ''html'' AS component,
      ''</div>'' AS html;

    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

    -- Close accordion container
    SELECT ''html'' AS component,
      ''</div>'' AS html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/plan-overview.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    select
    ''breadcrumb'' as component;
    select
    ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
    select
    ''Test Management System'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
    select
    ''Plan List'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-plan.sql'' as link;

    select
    "name" as title from test_plan where id = $id;
              

          SELECT ''title''AS component,
      name as contents FROM groups where id = $id; 

          SELECT ''card''  AS component,
      1 as columns;
    SELECT
    '' **Id**  :  '' || id AS description_md,
      ''
 **name**  :  '' || "name" AS description_md,
        ''
 **Description**  :  '' || "description" AS description_md,
          ''
 **Created By**  :  '' || "created_by" AS description_md,
            ''
 **Created On**  :  '' || strftime(''%d-%m-%Y'', "created_at") AS description_md,
              ''
'' || body AS description_md
      FROM test_plan 
      WHERE id = $id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-cases-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                 select
   ''breadcrumb'' as component;
   select
   ''Home'' as title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''as link;
   select
   ''Test Management System'' as title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql''as link;
   select
   ''Plan List'' as title,
     sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-plan.sql''as link;
   select
   "name" as title from test_plan where id = $id;
   SELECT ''list''  AS component,
     name as title FROM test_plan
   WHERE  id = $id;
   SELECT
   ''A structured summary of a specific test scenario, detailing its purpose, preconditions, test data, steps, and expected results. The description ensures clarity on the tests objective, enabling accurate validation of functionality or compliance. It aligns with defined requirements, identifies edge cases, and facilitates efficient defect detection during execution.
   '' as description;

SELECT ''html'' as component,
     ''<style>
    tr td.test_status {
     color: blue!important; /* Default to blue */
   }
   tr.rowClass - passed td.test_status {
     color: green!important; /* Default to blue */
   }
   tr.rowClass - failed td.test_status {
     color: red!important; /* Default to blue */
   }
       .btn - list {
     display: flex;
     justify - content: flex - end;
   }
   </style>

   '' as html;

   SELECT ''table'' as component,
     TRUE AS sort,
       --TRUE AS search,
         ''URL'' AS align_left,
           ''title'' AS align_left,
             ''group'' as markdown,
             ''id'' as markdown,
             ''count'' as markdown;
   SELECT
   ''['' || t.test_case_id || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=actual-result&id=''|| t.test_case_id || '')'' as id,
     t.title,
      case when t.test_status is not null then t.test_status
       else ''TODO'' END AS "test_status",
     t.created_by as "Created By",
     strftime(''%d-%m-%Y'', t.created_at) as "Created On",
     t.priority,
     ''rowClass-'' || p.status as _sqlpage_css_class
   FROM test_cases t
   inner join groups g on t.group_id = g.id
   left join test_case_run_results p on p.test_case_id = t.test_case_id
   WHERE  g.plan_id like ''%'' || $id || ''%'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/jsonviewer.sql',
      '-- not including shell
-- not including breadcrumbs from sqlpage_aide_navigation
-- not including page title from sqlpage_aide_navigation


select "dynamic" as component, sqlpage.run_sql(''qualityfolio/progress-bar.sql'') as properties;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'qualityfolio/test-cases-full-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               select
 ''breadcrumb'' as component;
 select
 ''Home'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
 select
 ''Test Management System'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/index.sql'' as link;
 select
 ''Test Cases'' as title;  
 

SELECT ''html'' as component,
   ''<style>
    tr td.State {
   color: blue!important; /* Default to blue */
 }
 tr.rowClass - passed td.State {
   color: green!important; /* Default to red */
 }
 tr.rowClass - failed td.State {
   color: red!important; /* Default to red */
 }

     tr td.Statealign - middle {
   color: blue!important; /* Default to blue */
 }
 tr.rowClass - passed td.Statealign - middle {
   color: green!important; /* Default to red */
 }
 tr.rowClass - failed td.Statealign - middle {
   color: red!important; /* Default to red */
 }

     
     .btn - list {
   display: flex;
   justify - content: flex - end;
 }
 </style>

 '' as html;
 select
 ''button'' as component;
 select
 ''Generate Report'' as title,
   ''download-full_list.sql'' as link;
SET total_rows = (SELECT COUNT(*) FROM test_cases );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
 SELECT ''table'' as component,
   TRUE AS sort,
     TRUE AS search,
       ''URL'' AS align_left,
         ''title'' AS align_left,
           ''group'' as markdown,
           ''id'' as markdown,
           "status_new" as markdown,
           ''count'' as markdown;
 SELECT
 ''['' || test_case_id || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/qualityfolio/test-detail.sql?tab=actual-result&id=''|| test_case_id || '')'' as id,
   test_case_title AS "title",
     group_name AS "group",
     case when test_status is not null then test_status
     else ''TODO'' END AS "State",
   ''rowClass-'' || test_status as _sqlpage_css_class,
   created_by as "Created By",
   formatted_test_case_created_at as "Created On",
   priority as "Priority"
 FROM test_cases t
  LIMIT $limit
   OFFSET $offset;
   SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'sqlpage/templates/shell-custom.handlebars',
      '              
              
              
              

              <!DOCTYPE html>
      <html lang="{{language}}" style="font-size: {{default font_size 18}}px" {{#if class}} class="{{class}}" {{/if}}>
        <head>
        <meta charset="utf-8" />

          <!--Base CSS-->
            <link rel="stylesheet" href="{{static_path ''sqlpage.css''}}">
              {{#each (to_array css)}}
              {{#if this}}
<link rel="stylesheet" href="{{this}}">
  {{/if}}
{{/each}}

<!--Font Setup-->
  {{#if font}}
{{#if (starts_with font "/")}}
<style>
  @font-face {
  font-family: ''LocalFont'';
  src: url(''{{font}}'') format(''woff2'');
  font-weight: normal;
  font-style: normal;
}
                      :root {
  --tblr-font-sans-serif: ''LocalFont'', Arial, sans-serif;
}
</style>
{{else}}
<link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family={{font}}&display=fallback">
      <style>
                      :root {
  --tblr-font-sans-serif: ''{{font}}'', Arial, sans-serif;
}
</style>
{{/if}}
{{/if}}

<!--JavaScript-->
  <script src="{{static_path ''sqlpage.js''}}" defer nonce="{{@csp_nonce}}"></script>
{{#each (to_array javascript)}}
{{#if this}}
<script src="{{this}}" defer nonce="{{@../csp_nonce}}"></script>
{{/if}}
{{/each}}
{{#each (to_array javascript_module)}}
{{#if this}}
<script src="{{this}}" type="module" defer nonce="{{@../csp_nonce}}"></script>
{{/if}}
{{/each}}
</head>

  <body class="layout-{{#if sidebar}}fluid{{else}}{{default layout ''boxed''}}{{/if}}" {{#if theme}} data-bs-theme="{{theme}}" {{/if}}>
    <div class="page">
      <!--Header-->


        <!--Page Wrapper-->
          <div class="page-wrapper">
            <main class="page-body w-full flex-grow-1 px-0" id="sqlpage_main_wrapper">
              {{~#each_row~}}{{~/each_row~}}
</main>
  </div>
  </div>
  </body>
  </html>;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''list'' AS component;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''console''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''console''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Tables'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || table_name || ''](table.sql?name='' || table_name || '')'' AS "Table",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_table
GROUP BY table_name;

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || view_name || ''](view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_view
GROUP BY view_name;

SELECT ''title'' AS component, ''Migrations'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT from_state, to_state, transition_reason, transitioned_at
FROM code_notebook_state
ORDER BY transitioned_at;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/table.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' Table'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type",
    is_primary_key AS "PK",
    is_not_null AS "Required",
    default_value AS "Default"
FROM console_information_schema_table
WHERE table_name = $name;

SELECT ''title'' AS component, ''Foreign Keys'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    foreign_key AS "Foreign Key"
FROM console_information_schema_table_col_fkey
WHERE table_name = $name;

SELECT ''title'' AS component, ''Indexes'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    index_name AS "Index Name"
FROM console_information_schema_table_col_index
WHERE table_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/view.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component,
$name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type"
FROM console_information_schema_view
WHERE view_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
   SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
   LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/sqlpage-file.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $path || '' Path'' AS title, ''#'' AS link;

      SELECT ''title'' AS component, $path AS contents;
      SELECT ''text'' AS component,
             ''```sql
'' || (select contents FROM sqlpage_files where path = $path) || ''
```'' as contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/content.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql'' || '')
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
      SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '')[📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%''
      AND NOT(path like ''console/content/%.auto.sql'')
      AND NOT(path like ''console/content/action%'')
ORDER BY path;

SELECT ''title'' AS component, ''Auto-generated "default" content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
    SELECT
      ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%.auto.sql''
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/content/action/regenerate-auto.sql',
      '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || $redirect as link WHERE $redirect is NOT NULL;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-nav/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-nav/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage navigation in sqlpage_aide_navigation table'' AS contents;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT path, caption, description FROM sqlpage_aide_navigation ORDER BY namespace, parent_path, path, sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
    ''['' || c.cell_name || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' ||
    replace(c.notebook_name, '' '', ''%20'') ||
    ''&cell='' ||
    replace(c.cell_name, '' '', ''%20'') ||
    '')'' AS "Cell",
     c.description,
       k.kernel_name as kernel
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
    ''foldable'' as component;
SELECT
    ''RSSD Lifecycle(Migration) Documentation'' as title,
    ''
This document provides an organized and comprehensive overview of ``surveilr``''''s RSSD migration process starting from ``v 1.0.0``, breaking down each component and the steps followed to ensure smooth and efficient migrations. It covers the creation of key tables and views, the handling of migration cells, and the sequence for executing migration scripts.

---

## Session and State Initialization

To manage temporary session data and track user state, we use the ``session_state_ephemeral`` table, which stores essential session information like the current user. This table is temporary, meaning it only persists data for the duration of the session, and it''''s especially useful for identifying the user responsible for specific actions during the migration.

Each time the migration process runs, we initialize session data in this table, ensuring all necessary information is available without affecting the core database tables. This initialization prepares the system for more advanced operations that rely on knowing the user executing each action.

---

## Assurance Schema Table

The ``assurance_schema`` table is designed to store various schema-related details, including the type of schema assurance, associated codes, and related governance data. This table is central to defining the structure of assurance records, which are useful for validating data, tracking governance requirements, and recording creation timestamps. All updates to the schema are logged to track when they were last modified and by whom.

---

## Code Notebook Kernel, Cell, and State Tables

``surveilr`` uses a structured system of code notebooks to store and execute SQL commands. These commands, or “cells,” are grouped into notebooks, and each notebook is associated with a kernel, which provides metadata about the notebook''''s language and structure. The main tables involved here are:

- **``code_notebook_kernel``**: Stores information about different kernels, each representing a unique execution environment or language.
- **``code_notebook_cell``**: Holds individual code cells within each notebook, along with their associated metadata and execution history.
- **``code_notebook_state``**: Tracks each cell''''s state changes, such as when it was last executed and any errors encountered.

By organizing migration scripts into cells and notebooks, ``surveilr`` can maintain detailed control over execution order and track the state of each cell individually. This tracking is essential for handling updates, as it allows us to execute migrations only when necessary.

---

## Views for Managing Cell Versions and Migrations

Several views are defined to simplify and organize the migration process by managing different versions of code cells and identifying migration candidates. These views help filter, sort, and retrieve the cells that need execution.

### Key Views

- **``code_notebook_cell_versions``**: Lists all available versions of each cell, allowing the migration tool to retrieve older versions if needed for rollback or auditing.
- **``code_notebook_cell_latest``**: Shows only the latest version of each cell, simplifying the migration by focusing on the most recent updates.
- **``code_notebook_sql_cell_migratable``**: Filters cells to include only those that are eligible for migration, ensuring that non-executable cells are ignored.

---

## Migration-Oriented Views and Dynamic Migration Scripts

To streamline the migration process, several migration-oriented views organize the data by listing cells that require execution or are ready for re-execution. By grouping these cells in specific views, ``surveilr`` dynamically generates a script that executes only the necessary cells.

### Key Views

- **``code_notebook_sql_cell_migratable_not_executed``**: Lists migratable cells that haven’t yet been executed.
- **``code_notebook_sql_cell_migratable_state``**: Shows the latest migratable cells, along with their current state transitions.

---

## How Migrations Are Executed

When it''''s time to apply changes to the database, this section explains the process in detail, focusing on how ``surveilr`` prepares the environment, identifies which cells to migrate, executes the appropriate SQL code, and ensures data integrity throughout.

---

### 1. Initialization

The first step in the migration process involves setting up the essential database tables and seeding initial values. This lays the foundation for the migration process, making sure that all tables, views, and temporary values needed are in place.

- **Check for Core Tables**: ``surveilr`` first verifies whether the required tables, such as ``code_notebook_cell``, ``code_notebook_state``, and others starting with ``code_notebook%``, are already set up in the database.
- **Setup**: If these tables do not yet exist, ``surveilr`` automatically initiates the setup by running the initial SQL script, known as ``bootstrap.sql``. This script contains SQL commands that create all the essential tables and views discussed in previous sections.
- **Seeding**: During the execution of ``bootstrap.sql``, essential data, such as temporary values in the ``session_state_ephemeral`` table (e.g., information about the current user), is also added to ensure that the migration session has the data it needs to proceed smoothly.

---

### 2. Migration Preparation and Identification of Cells to Execute

Once the environment is ready, ``surveilr`` examines which specific cells (code blocks in the migration notebook) need to be executed to bring the database up to the latest version.

- **Listing Eligible Cells**: ``surveilr`` begins by consulting views such as ``code_notebook_sql_cell_migratable_not_executed``. This view is a pre-filtered list of cells that are eligible for migration but haven’t yet been executed.
- **Idempotent vs. Non-Idempotent Cells**: ``surveilr`` then checks whether each cell is marked as “idempotent” or “non-idempotent.”
   - **Idempotent Cells** can be executed multiple times without adverse effects. If they have been run before, they can safely be run again without impacting data integrity.
   - **Non-Idempotent Cells**, identified by names containing ``_once_``, should only be executed once. If these cells have been executed previously, they are skipped in the migration process to prevent unintentional re-runs.

---

### 3. Dynamic Script Generation and Execution

``surveilr`` then assembles a custom SQL script that includes only the cells identified as eligible for execution. This script is crafted carefully to ensure each cell''''s SQL code is executed in the correct order and with the right contextual information.

- **Script Creation**: We start by generating a dynamic script in a single transaction block. Transactions are a way of grouping a series of commands so that they are either all applied or none are, which protects data integrity.
- **Inclusion of Cells Based on Eligibility**:
   - For each cell, ``surveilr`` checks its eligibility status. If it''''s non-idempotent and already executed, it''''s marked with a comment noting that it''''s excluded from the script due to previous execution.
   - If the cell is idempotent or eligible for re-execution, its SQL code is added to the script, along with additional details such as comments about the cell''''s last execution date.
- **State Transition Records**: After each cell''''s SQL code, additional commands are added to record the cell''''s transition state. This step inserts information into ``code_notebook_state``, logging details such as the cell ID, transition state (from “Pending” to “Executed”), and the reason for the transition (“Migration” or “Reapplication”). These logs are invaluable for auditing purposes.

---

### 4. Execution in a Transactional Block

With the script prepared, ``surveilr`` then executes the entire batch of SQL commands within a transactional block.

- **BEGIN TRANSACTION**: The script begins with a transaction, ensuring that all changes are applied as a single, atomic unit.
- **Running Cell Code**: Within this transaction, each cell''''s SQL code is executed in the order it appears in the script.
- **Error Handling**: If any step in the transaction fails, all changes are rolled back. This prevents partial updates from occurring, ensuring that the database remains in a consistent state.
- **COMMIT**: If the script executes successfully without errors, the transaction is committed, finalizing the changes. The ``COMMIT`` command signifies the end of the migration session, making all updates permanent.

---

### 5. Finalizing Migration and Recording Results

After a successful migration session, ``surveilr`` concludes by recording details about the migration process.

- **Final Updates to ``code_notebook_state``**: Any cells marked as “Executed” are updated in ``code_notebook_state`` with the latest timestamp, indicating their successful migration.
- **Logging Completion**: Activity logs are updated with relevant details, ensuring a clear record of the migration.
- **Cleanup of Temporary Data**: Finally, temporary data is cleared, such as entries in ``session_state_ephemeral``, since these values were only needed during the migration process.
    '' as description_md;


SELECT ''title'' AS component, ''Pending Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_not_executed lists all cells eligible for migration but not yet executed.
    If migrations have been completed successfully, this list will be empty,
    indicating that all migratable cells have been processed and marked as executed.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp
FROM
    code_notebook_sql_cell_migratable_not_executed AS c
ORDER BY
    c.cell_name;

-- State of Executed Migrations
SELECT ''title'' AS component, ''State of Executed Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_state displays all cells that have been successfully executed as part of the migration process,
    showing the latest version of each migratable cell.
    For each cell, it provides details on its transition states,
    the reason and result of the migration, and the timestamp of when the migration occurred.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp,
    c.from_state,
    c.to_state,
    c.transition_reason,
    c.transition_result,
    c.transitioned_at
FROM
    code_notebook_sql_cell_migratable_state AS c
ORDER BY
    c.cell_name;


-- Executable Migrations
SELECT ''title'' AS component, ''Executable Migrations'' AS contents;
SELECT ''text'' AS component, ''All cells that are candidates for migration (including duplicates)'' as contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
        c.code_notebook_cell_id,
        c.notebook_name,
        c.cell_name,
        ''['' || c.cell_name || ''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
        c.interpretable_code_hash,
        c.is_idempotent,
        c.version_timestamp
    FROM
        code_notebook_sql_cell_migratable_version AS c
    ORDER BY
        c.cell_name;

-- All Migrations
SELECT ''button'' as component;
SELECT
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks'' as link,
    ''See all notebook entries'' as title;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/about.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/about.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                 -- Title Component
    SELECT
    ''text'' AS component,
    (''Resource Surveillance v'' || replace(sqlpage.exec(''surveilr'', ''--version''), ''surveilr '', '''')) AS title;

    -- Description Component
      SELECT
          ''text'' AS component,
          ''A detailed description of what is incorporated into surveilr. It informs of critical dependencies like rusqlite, sqlpage, pgwire, e.t.c, ensuring they are present and meet version requirements. Additionally, it scans for and executes capturable executables in the PATH and evaluates surveilr_doctor_* database views for more insights.''
          AS contents_md;

      -- Section: Dependencies
      SELECT
          ''title'' AS component,
          ''Internal Dependencies'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          "Dependency",
          "Version"
      FROM (
          SELECT
              ''SQLPage'' AS "Dependency",
              json_extract(json_data, ''$.versions.sqlpage'') AS "Version"
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Pgwire'',
              json_extract(json_data, ''$.versions.pgwire'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Rusqlite'',
              json_extract(json_data, ''$.versions.rusqlite'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
      );

      -- Section: Static Extensions
      SELECT
          ''title'' AS component,
          ''Statically Linked Extensions'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          json_extract(value, ''$.name'') AS "Extension Name",
          json_extract(value, ''$.url'') AS "URL",
          json_extract(value, ''$.version'') AS "Version"
      FROM json_each(
          json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.static_extensions'')
      );

    -- Section: Dynamic Extensions
    SELECT
        ''title'' AS component,
        ''Dynamically Linked Extensions'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Extension Name",
        json_extract(value, ''$.path'') AS "Path"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.dynamic_extensions'')
    );

    -- Section: Environment Variables
    SELECT
        ''title'' AS component,
        ''Environment Variables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Variable",
        json_extract(value, ''$.value'') AS "Value"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.env_vars'')
    );

    -- Section: Capturable Executables
    SELECT
        ''title'' AS component,
        ''Capturable Executables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Executable Name",
        json_extract(value, ''$.output'') AS "Output"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.capturable_executables'')
    );

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;

SELECT
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md, ''$SITE_PREFIX_URL'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') AS "Content"
FROM console_information_schema_view
WHERE view_name LIKE ''surveilr_doctor%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/statistics/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/statistics/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''datagrid'' as component;
SELECT ''Size'' as title, "db_size_mb" || '' MB'' as description FROM rssd_statistics_overview;
SELECT ''Tables'' as title, "total_tables" as description FROM rssd_statistics_overview;
SELECT ''Indexes'' as title, "total_indexes" as description FROM rssd_statistics_overview;
SELECT ''Rows'' as title, "total_rows" as description FROM rssd_statistics_overview;
SELECT ''Page Size'' as title, "page_size" as description FROM rssd_statistics_overview;
SELECT ''Total Pages'' as title, "total_pages" as description FROM rssd_statistics_overview;

select ''text'' as component, ''Tables'' as title;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT * FROM rssd_table_statistic ORDER BY table_size_mb DESC;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/behavior/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/behavior/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Behavior Configuration'' AS contents;

SELECT ''text'' AS component,
  ''Behaviors are configuration presets that drive application operations at runtime, including ingest behaviors, file scanning configurations, and device-specific settings.'' AS contents;

-- Summary cards
SELECT ''card'' AS component, 3 AS columns;
SELECT
    ''Total Behaviors'' AS title,
    COUNT(*) AS description,
    ''blue'' AS color
FROM behavior
WHERE deleted_at IS NULL;

SELECT
    ''Active Devices'' AS title,
    COUNT(DISTINCT device_id) AS description,
    ''green'' AS color
FROM behavior
WHERE deleted_at IS NULL;

SELECT
    ''Unique Behavior Types'' AS title,
    COUNT(DISTINCT behavior_name) AS description,
    ''orange'' AS color
FROM behavior
WHERE deleted_at IS NULL;

-- Initialize pagination
SET total_rows = (SELECT COUNT(*) FROM behavior );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Behavior table with pagination
SELECT ''title'' AS component, ''Behavior Configurations'' AS contents, 2 AS level;
SELECT ''table'' AS component,
       ''Behavior Name'' as markdown,
       ''Device'' as markdown,
       TRUE as sort,
       TRUE as search;
SELECT
    ''['' || b.behavior_name || ''](behavior-detail.sql?behavior_id='' || b.behavior_id || '')'' AS "Behavior Name",
    ''['' || d.name || ''](/console/info-schema/table.sql?name=device)'' AS "Device",
    CASE
        WHEN LENGTH(b.behavior_conf_json) > 100
        THEN SUBSTR(b.behavior_conf_json, 1, 100) || ''...''
        ELSE b.behavior_conf_json
    END AS "Configuration Preview",
    b.created_at AS "Created",
    CASE
        WHEN b.updated_at IS NOT NULL THEN b.updated_at
        ELSE b.created_at
    END AS "Last Modified"
FROM behavior b
LEFT JOIN device d ON b.device_id = d.device_id
WHERE b.deleted_at IS NULL
ORDER BY b.created_at DESC
LIMIT $limit
OFFSET $offset;

-- Pagination controls
SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/behavior/behavior-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              -- Breadcrumbs
SELECT ''breadcrumb'' as component;
SELECT ''Home'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT ''Console'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/index.sql'' as link;
SELECT ''Behavior'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/behavior/index.sql'' as link;
SELECT behavior_name as title FROM behavior WHERE behavior_id = $behavior_id;

SELECT ''title'' AS component,
       (SELECT behavior_name FROM behavior WHERE behavior_id = $behavior_id) AS contents;

SELECT ''text'' AS component,
  ''Detailed view of behavior configuration including JSON configuration, governance settings, and associated device information.'' AS contents;

-- Behavior details card
SELECT ''card'' AS component, 2 AS columns;
SELECT
    ''Behavior ID'' AS title,
    behavior_id AS description,
    ''blue'' AS color
FROM behavior
WHERE behavior_id = $behavior_id;

SELECT
    ''Device'' AS title,
    (SELECT name FROM device WHERE device_id = b.device_id) AS description,
    ''green'' AS color
FROM behavior b
WHERE behavior_id = $behavior_id;

-- Configuration details
SELECT ''title'' AS component, ''Configuration Details'' AS contents, 2 AS level;
SELECT ''table'' AS component;
SELECT
    ''Behavior Name'' AS "Property",
    behavior_name AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Device ID'' AS "Property",
    device_id AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Created At'' AS "Property",
    created_at AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Created By'' AS "Property",
    created_by AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Updated At'' AS "Property",
    COALESCE(updated_at, ''Never'') AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Updated By'' AS "Property",
    COALESCE(updated_by, ''N/A'') AS "Value"
FROM behavior WHERE behavior_id = $behavior_id;

-- JSON Configuration
SELECT ''title'' AS component, ''JSON Configuration'' AS contents, 2 AS level;
SELECT ''code'' AS component;
SELECT
    ''json'' as language,
    behavior_conf_json as contents
FROM behavior
WHERE behavior_id = $behavior_id;

-- Governance (if available)
SELECT ''title'' AS component, ''Governance'' AS contents, 2 AS level
WHERE EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);

SELECT ''code'' AS component
WHERE EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);

SELECT
    ''json'' as language,
    governance as contents
FROM behavior
WHERE behavior_id = $behavior_id AND governance IS NOT NULL;

-- Show message if no governance
SELECT ''text'' AS component,
       ''No governance configuration available for this behavior.'' AS contents
WHERE NOT EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''docs''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''docs''||''/index.sql''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/release-notes.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/release-notes.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Release Notes for surveilr Versions'' as contents;

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.9'' as title, ''# `surveilr ` v1.8.9 Release Notes

## 🚀 What''''s New

### **1. Surveilr ingestion Improvements**
- Image Ingestion Support - Fixed issues with image format ingestion during file processing
- GitHub API Rate Limiting - Enhanced rate limiting handling for GitHub PLM integration

### **2. Dependencies Update**
- OIDC/SSO Support - Added OpenID Connect and Single Sign-On support for surveilr web UI
- SQLPage Upgrade - Updated to latest SQLPage version'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.8'' as title, ''# `surveilr ` v1.8.8 Release Notes

## 🚀 What''''s New

### **1. Bug-fixes**
## Ingestion & PLM Issues (#320)
  - Fixed TLS crypto provider initialization issues
  - Fixed ingestion PLM issues with github
## CSV Transform Issues (#194)
  - Fixed CSV transform duplicate detection issues
## File Carving (#299)
  - Fixed file carving functionality'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.5'' as title, ''# `surveilr ` v1.8.5 Release Notes

## 🚀 What''''s New
### **1. Surveilr ingestion Improvements**
Prevent Duplication of Records in surveilr ingest files --csv-transform-auto Command

### **2. Changes to Osquery-ms**
- Platform Consistency: Darwin is the actual kernel name that macOS runs on, making it more technically
  accurate
- OSQuery Compatibility: Aligns with osquery''''s internal platform detection which uses "darwin"'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.4'' as title, ''# `surveilr ` v1.8.4 Release Notes

## 🚀 What''''s New
### **1. Surveilr ingestion Improvements**
Automatically detects and adds missing columns during surveilr ingestion.

### **2. Installation Config**
-The mac archive no longer contains a nested folder — you can now upgrade surveilr by running surveilr upgrade
-This fixes installation issues with scripts like install.ps1 and allows surveilr.exe to run immediately after extraction.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.3'' as title, ''# `surveilr ` v1.8.3 Release Notes

## 🚀 What''''s New
### **1. Admin Merge Improvements**
Automatically detects and adds missing columns during database schema merging.

### **2. Markdown Transformation Enhancements**
Introduced transform-md for parsing Markdown files and converting them into structured JSON.
Added support for Markdown querying using --md-select with the mdq library.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.2'' as title, ''# `surveilr ` v1.8.2 Release Notes

---

## 🚀 What''''s New

### **1. surveilr osquery-ms` Server**
- Significant enhancements and a complete overhaul of the file carving architecture in osQuery MS server'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.1'' as title, ''# `surveilr` v1.8.1 Release Notes

---

## 🚀 What''''s New

### **1. `sureilr osquery-ms` Server**
- Added distributed queries and file carving to the server.

'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.0'' as title, ''# `surveilr` v1.8.0 Release Notes

---

## 🚀 What''''s New

### **1. SQLPage**
- Updated SQLPage to the latest version, `v0.34.0`, ensuring compatibility and access to the newest features and bug fixes.

### 2. Introduced `surveilr_notebook_cell_exec`
`surveilr_notebook_cell_exec` is a function designed to execute queries stored in `code_notebook_cell`s against the RSSD. This is the SQLite function equivalent of the `surveilr notebook cat` command which only outputs the content of the `code_notebook_cell`, this function on other hand, executes it. It takes two arguments, the `notebook_name` and the `cell_name` and it returns either `true` or `false` to denote if the execution was succesful.

## Bug Fixes
1. Fixed the SQL query issue when `--persist-raw-logs` is passed to the `surveilr osquery-ms` server.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.25'' as title, ''# `surveilr` v1.7.13 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.16'' as title, ''# `surveilr` v1.7.16 Release Notes

## Bug Fixes
1. Enhanced the CSV transform functionality to correctly include partyID for each ingested CSV table when provided.

2. Resolved an issue where ingesting multiple CSV files with the same name from different folders resulted in data loss. Now, all files are consolidated into a single table while preserving distinct data sources with the partyID field.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.13'' as title, ''# `surveilr` v1.7.13 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.12'' as title, ''# `surveilr` v1.7.12 Release Notes

## 🚀 What''''s New

### 1. `surveilr osquery-ms` Server
The server has been fully setup, configured with boundaries and the corresponding WebUI, fully configurable with `code_notebooks`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.11'' as title, ''# `surveilr` v1.7.11 Release Notes

## 🚀 What''''s New

### 1. Upgraded SQLPage
SQLPage has been updated to version 0.33.1, aligning with the latest releases.

## Bug Fixes
### 1. `surveilr admin merge`
- Added recent and new tables to the merge structure ensuring all tables in each RSSD are present in the final merged RSSD.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.10'' as title, ''# `surveilr` v1.7.10 Release Notes

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Added support for boundaries to enable grouping of nodes for better viewing
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.9'' as title, ''# `surveilr` v1.7.9 Release Notes

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Introduced a new flag `--keep-status-logs` to indicate whether the server should store status logs received from osQuery in the RSSD.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.8'' as title, ''# `surveilr` v1.7.8 Release Notes

This release focuses on enhancing the `surveilr osquery-ms` UI by adding new tables and optimizing data management. No bugs were fixed or new features introduced. Please review the Web UI for updates.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.7'' as title, ''# `surveilr` v1.7.7 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.6'' as title, ''# `surveilr` v1.7.6 Release Notes

---

## 🚀 Bug Fixes

### 1. `surveilr` Bootstrap SQL
This release fixes the "no such table: device" error introduced in the previous version by propagating any erroors during the SQL initialization of the RSSD with `surveilr`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.5'' as title, ''# `surveilr` v1.7.5 Release Notes

---


### 🆕 **New Features**
- **osQuery Management Server Integration**:  
  - `surveilr` now acts as a management layer for osQuery, enabling secure and efficient monitoring of infrastructure.
  - Supports remote configuration, logging, and query execution for osQuery nodes.

- **Behavior & Notebooks Support**:  
  - Introduced **Notebooks**, which store predefined queries in the `code_notebook_cell` table.
  - **Behaviors** allow defining and managing query execution for different node groups.

- **Secure Node Enrollment**:  
  - Nodes authenticate using an **enrollment secret key** (`SURVEILR_OSQUERY_MS_ENROLL_SECRET`).
  - Secure communication via **TLS certificates** (`cert.pem`, `key.pem`).

- **Automated Query Execution**:  
  - Default queries from **"osQuery Management Server (Prime)"** execute automatically.
  - Custom notebooks and queries can be added dynamically via SQL.

- **Centralized Logging & Config Fetching**:  
  - Osquery logs and configurations are fetched via TLS endpoints (`/logger`, `/config`).
  - All communication is secured using **server-side TLS certificates**.

- **Web UI for Query Results Visualization**:  
  - `surveilr web-ui` provides an intuitive dashboard to inspect query results across enrolled nodes.
  - Simply start with `surveilr web-ui -p 3050 --host <server-ip>`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.1'' as title, ''# `surveilr` v1.7.1 Release Notes

---

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Introduced a new flag--behavior` or `-b` to specify behavior name to queries to run automatically enrolled nodes.
- a new SQLite function called `surveilr_osquery_ms_create_behaviour` to facilitate the creation of behaviors, making process smooth and easy.

### Example
When starting the `surveilr osquery-ms` server without passing a behavior, a default behavior with the following query configuration is created:
```json
{
  "surveilr-cli": {
    ...
    "osquery_ms": {
      "tls_proc": {
 "query": "select * from processes",
        "interval": 60
      }
    }
  }
}
```
To use a behavior with the `surveilr` osQuery management server first create a behavior using the new function: 
```bash
surveilr shell --cmd "select surveil_osquery_ms_create_behaviour(''''-behaviour'''', ''''{\"tls_proc\": {\"query\": \"select * from processes\", \"interval\": 60}, \"routes\": {\"query\": \"SELECT * FROM routes WHERE destination = ''''''''::1''''''''\", \"interval\": 60}}'''');"
```
Then, pass that behavior to the server by:

```bash
surveilr osquery-ms --cert ./cert.pem --key ./key.pem --enroll-secret "<secret>" -b "initial-behaviour"
```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.0'' as title, ''# `surveilr` v1.7.0 Release Notes

---

## 🚀 What''''s New

### **1. `surveilr` OSQuery Management Server**
Introducing Osquery Management Server using `surveilr`, enabling secure and centralized monitoring of your infrastructure. The setup ensures secure node enrollment through TLS authentication and secret keys, allowing only authorized devices to connect. Users can easily configure and manage node behaviors dynamically via `surveilr`’s behavior tables.

### **2. OpenDAL Dropbox Integration**
The `surveilr_udi_dal_dropbox` SQLite function, is a powerful new virtual table module that enables seamless interaction with Dropbox files directly within your SQL queries. This module allows users to access and query comprehensive file metadata, including name, path, size, last modified timestamp, content, and more, within specified directories.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.6.0'' as title, ''# `surveilr` v1.6.0 Release Notes

---

## 🚀 What''''s New

### **1. SQLPage**
- Updated SQLPage to the latest version, ensuring compatibility and access to the newest features and bug fixes.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.11'' as title, ''# `surveilr` v1.5.11 Release Notes

---

### Overview
This release includes updates to dependencies, bug fixes, and performance improvements to enhance stability and functionality.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.10'' as title, ''# `surveilr` v1.5.9 Release Notes

---

## 🚀 Bug Fixes

### **1. WebUI Page for About**
- A dedicated About page has been added in the WebUI to visualize the response of `surveilr doctor`:
  - **Dependencies Table**:
    - The display of versions and their generation process has been fixed.
  - **Diagnostic Views**:
    - A new section has been added to display the contents and details of all views prefixed with `surveilr_doctor*`, facilitating the of details and logs for diagnostics.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.8'' as title, ''# `surveilr` v1.5.8 Release Notes 🎉

---

### **1. WebUI Page for About**
- Added a dedicated About page in the WebUI visiualizing the response of `surveilr doctor`:
  - **Dependencies Table**:
    - Displays the versions of `sqlpage`, `rusqlite`, and `pgwire` in a table.
  - **Extensions List**:
    - Lists all synamic and static extensions .
  - **Capturable executables**:
    - Lists all capturable executables that were found in the `PATH`.
  - **Env variables**
    - Captures all environment variables starting with `SURVEILR_` and `SQLPAGE_`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.6'' as title, ''# `surveilr` v1.5.6 Release Notes 🎉

---

## 🚀 What''''s New
### **1. Enhanced Diagnostics Command**
- **`surveilr doctor` Command Improvements**:
  - **Dependencies Check**:
    - Verifies versions of critical dependencies: `Deno`, `Rustc`, and `SQLite`.
    - Ensures dependencies meet minimum version requirements for seamless functionality.
  - **Capturable Executables Detection**:
    - Searches for executables in the `PATH` matching `surveilr-doctor*.*`.
    - Executes these executables, assuming their output is in JSON format, and integrates their results into the diagnostics report.
  - **Database Views Analysis**:
    - Queries all views starting with the prefix `surveilr_doctor_` in the specified RSSD.
    - Displays their contents in tabular format for comprehensive insights.

---

### **2. JSON Mode**
- Added a `--json` flag to the `surveilr doctor` command.
  - Outputs the entire diagnostics report, including versions, extensions, and database views, in structured JSON format.

---

### **3. WebUI Page for Diagnostics**
- Added a dedicated page in the WebUI for the `surveilr doctor` diagnostics:
  - **Versions Table**:
    - Displays the versions of `Deno`, `Rustc`, and `SQLite` in a table.
  - **Extensions List**:
    - Lists all detected extensions.
  - **Database Views Content**:
    - Automatically identifies and displays the contents of views starting with `surveilr_doctor_` in individual tables.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.5'' as title, ''# `surveilr` v1.5.5 Release Notes 🎉

---

## 🚀 What''''s New

### Virtual Table: `surveilr_function_docs`

**Description**  
The `surveilr_function_docs` virtual table offers a structured method to query metadata about `surveilr` SQLite functions registered in the system.

**Columns**  
- `name` (`TEXT`): The function''''s name.
- `description` (`TEXT`): A concise description of the function''''s purpose.
- `parameters` (`JSON`): A JSON object detailing the function''''s parameters, including:
  - `name`: The name of the parameter.
  - `data_type`: The parameter''''s expected data type.
  - `description`: An explanation of the parameter''''s role.
- `return_type` (`TEXT`): The function''''s return type.
- `introduced_in_version` (`TEXT`): The version in which the function was first introduced.

**Use Cases**  
- Utilized in the Web UI for generating documentation on the functions.

---

### Virtual Table: `surveilr_udi_dal_fs`

**Description**  
The `surveilr_udi_dal_fs` virtual table acts as an abstraction layer for interacting with the file system. It enables users to list and examine file metadata in a structured, SQL-friendly manner. This table can list files and their metadata recursively from a specified path.

**Columns**  
- `name` (`TEXT`): The file''''s name.
- `path` (`TEXT`): The complete file path.
- `last_modified` (`TEXT`): The file''''s last modified timestamp, when available.
- `content` (`BLOB`): The content of the file (optional).
- `size` (`INTEGER`): The size of the file in bytes.
- `content_type` (`TEXT`): The MIME type of the file or an inferred content type (e.g., based on the extension).
- `digest` (`TEXT`): The MD5 digest of the file, if available.
- `arg_path` (`TEXT`, hidden): The base path for querying files, specified in the `filter` method.

**Key Features**  
- Lists files recursively from a specified directory.
- Facilitates metadata extraction, such as file size, last modified timestamp, and MDhash).

---

### Virtual Table: `surveilr_udi_dal_s3`

**Description**  
The `surveilr_udi_dal_s3` virtual table is an abstraction layer that interacts with the S3 bucket in a given region. It allows listing and inspecting file metadata in a structured, SQL-accessible way.

**Columns**  
- `name` (`TEXT`): The name of the file.
- `path` (`TEXT`): The full path to the file.
- `last_modified` (`TEXT`): The last modified timestamp of the file, if available.
- `content` (`BLOB`): The file''''s content (optional).
- `size` (`INTEGER`): The file size in bytes.
- `content_type` (`TEXT`): The file''''s MIME type or inferred content type (e.g., based on the extension).
- `digest` (`TEXT`): The file''''s MD5 digest, if available.
- `arg_path` (`TEXT`, hidden): The base path to query files from, specified in the `filter` method.

**Key Features**  
- Supports metadata extraction (e.g., file size, last modified timestamp, MD5 hash).

---

## Example Queries

### Querying Function Documentation
```sql
SELECT * FROM surveilr_function_docs WHERE introduced_in_version = ''''1.0.0'''';
```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.3'' as title, ''# `surveilr` v1.5.3 Release Notes 🎉

---

## 🚀 What''''s New

### 1. **Open Project Data Extension**
`surveilr` now includes additional data from Open Project PLM ingestion. Details such as a work package''''s versions and relations are now encapsulated in JSON format in a new `elaboration` column within the `ur_ingest_session_plm_acct_project_issue` table. The JSON structure is as follows, with the possibility for extension:
```json
elaboration: {"issue_id": 78829, "relations": [...], "version": {...}}
```

### 2. **Functions for Extension Verification**
Two new functions have been introduced to verify and ensure the presence of certain intended functions and extensions before their use:
- The `select surveilr_ensure_function(''''func'''', ''''if not found msg'''', ''''func2'''', ''''if func2 not found msg'''')` function can be used to declaratively specify the required function(s), and will produce an error with guidance on how to obtain the function if it is not found.

- The `select surveilr_ensure_extension(''''extn.so'''', ''''../bin/extn2.so'''')` function allows for the declarative indication of necessary extensions, and will dynamically load them if they are not already available.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.2'' as title, ''# `surveilr` v1.5.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. **`surveilr` SQLite Extensions**
`surveilr` extensions are now statically linked, resolving all extensions and function usage issues. The following extensions are included by default in `surveilr`, with additional ones planned for future releases:
- [`sqlean`](https://github.com/nalgeon/sqlean)
- [`sqlite-url`](https://github.com/asg017/sqlite-url)
- [`sqlite-hashes`](https://github.com/nyurik/sqlite-hashes)
- [`sqlite-lines`](https://github.com/asg017/sqlite-lines)'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.3'' as title, ''# `surveilr` v1.4.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. Utilizing Custom Extensions with `surveilr`
In the previous release, we introduced the feature of automatically loading extensions from the default `sqlpkg` location. However, this posed a security risk, and we have since disabled that feature. To use extensions installed by `sqlpkg`, simply pass `--sqlpkg`, and the default location will be utilized. If you wish to change the directory from which extensions are loaded, use `--sqlpkg /path/to/extensions`, or specify the directory with the new `SURVEILR_SQLPKG` environment variable.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.2'' as title, ''# `surveilr` v1.4.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. Utilizing Custom Extensions with **`surveilr`**
Loading extensions is now straightforward with the `--sqlite-dyn-extn` flag. As long as your extensions are installed via [`sqlpkg`](https://sqlpkg.org/), `surveilr` will automatically detect the default location of `sqlpkg` and all installed extensions. Simply install the extension using `sqlpkg`. To specify a custom path for `sqlpkg`, use the `--sql-pkg-home` argument with a directory containing the extensions, regardless of depth, and `surveilr` will locate them. Additionally, the `SURVEILR_SQLITE_DYN_EXTNS` environment variable has been introduced to designate an extension path instead of using `--sqlite-dyn-extn`.
**Note**: Using `--sqlite-dyn-extn` won''''t prevent `surveilr` from loading extensions from `sqlpkg`''''s default directory. To disable loading from `sqlpkg`, use the `--no-sqlpkg` flag.

Here''''s a detailed example of using `surveilr shell` and `surveilr orchestrate` with dynamic extensions.
**Using `sqlpkg` defaults**
- Download the [`sqlpkg` CLI](https://github.com/nalgeon/sqlpkg-cli?tab=readme-ov-file#download-and-install-preferred-method).
- Download the [text extension](https://sqlpkg.org/?q=text), which offers various text manipulation functions: `sqlpkg install nalgeon/sqlean`
- Run the following command:
  ```bash
  surveilr shell --cmd "select text_substring(''''hello world'''', 7, 5) AS result" # surveilr loads all extensions from the .sqlpkg default directory
  ```

**Including an additional extension with `sqlpkg`**
Combine `--sqlite-dyn-extn` with `surveilr`''''s ability to load extensions from `sqlpkg`
- Add the `path` extension to `sqlpkg`''''s installed extensions: `sqlpkg install asg017/path`
- Execute:
  ```bash
  surveilr shell --cmd "SELECT
        text_substring(''''hello world'''', 7, 5) AS substring_result,
        math_sqrt(9) AS sqrt_result,
        path_parts.type,
        path_parts.part 
    FROM 
        (SELECT * FROM path_parts(''''/usr/bin/sqlite3'''')) AS path_parts;
    " --sqlite-dyn-extn .extensions/math.so
  ```

**Specify a Custom Directory to Load Extensions From**
A `--sqlpkg-home` flag has been introduced to specify a custom path for extensions. They do not need to be installed by `sqlpkg` to be used. `surveilr` will navigate the specified folder and load all compatible extensions for the operating system—`.so` for Linux, `.dll` for Windows, and `.dylib` for macOS. (If you installed with `sqlpkg`, you don''''t need to know the file type).
```bash
surveilr shell --cmd "SELECT text_substring(''''hello world'''', 7, 5) AS substring_result, math_sqrt(9) AS sqrt_result" --sqlpkg-home ./src/resource_serde/src/functions/extensions/
```

### 2. Upgraded SQLPage
SQLPage has been updated to version 0.31.0, aligning with the latest releases.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.1'' as title, ''# `surveilr` v1.4.1 Release Notes 🎉

---

## 🚀 Bug Fixes

### 1. **`surveilr` SQLite Extensions**
To temporarily mitigate the issue with `surveilr` intermittently working due to the dynamic loading of extensions, `surveilr` no longer supports dynamic loading by default. It is now supported only upon request by using the `--sqlite-dyn-extn` flag. This flag is a multiple option that specifies the path to an extension to be loaded into `surveilr`. To obtain the dynamic versions (`.dll`, `.so`, or `.dylib`), you can use [`sqlpkg`](https://sqlpkg.org/) to install the necessary extension.

For instance, to utilize the `text` functions:
- Install the extension with [`sqlpkg`](https://sqlpkg.org/?q=text): `sqlpkg install nalgeon/text`
- Then execute it:
  ```bash
  surveilr shell --cmd "select text_substring(''''hello world'''', 7, 5);" --sqlite-dyn-extn ./text.so
  ```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.3.1'' as title, ''# `surveilr` v1.3.1 Release Notes 🎉

---

## 🚀 Bug Fixes

### 1. **`surveilr` SQLite Extensions**
This release fixes the `glibc` compatibility error that occured with `surveilr` while registering function extensions.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.3.0'' as title, ''# `surveilr` Release Announcement: Now Fully Compatible Across All Distros 🎉

We are thrilled to announce that `surveilr` is now fully compatible with all major Linux distributions, resolving the longstanding issue related to OpenSSL compatibility! 🚀

## What''''s New?
- **Universal Compatibility**: `surveilr` now works seamlessly on **Ubuntu**, **Debian**, **Kali Linux**, and other Linux distributions, across various versions and architectures. Whether you''''re using Ubuntu 18.04, Debian 10, or the latest Kali Linux, `surveilr` is ready to perform without any hiccups.
- **Resolved OpenSSL Bug**: We’ve fixed the recurring OpenSSL-related issue that caused headaches for users on older and varied systems. With this update, you no longer need to worry about OpenSSL version mismatches or missing libraries.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.2.0'' as title, ''# `surveilr` v1.2.0 Release Notes 🎉

## What''''s New?
This update introduces two major additions that streamline file system integration and ingestion session management.

---

### New Features

#### 1. `surveilr_ingest_session_id` Scalar Function
The `surveilr_ingest_session_id` function is now available, offering robust management of ingestion sessions. This function ensures efficient session handling by:
- Reusing existing session IDs for devices with active sessions.
- Creating new ingestion sessions when none exist.
- Associating sessions with metadata for improved traceability.


#### 2. `surveilr_udi_dal_fs` Virtual Table Function
The `surveilr_udi_dal_fs` virtual table function provides seamless access to file system resources directly within your SQL queries. With this feature, you can:
- Query file metadata, such as names, paths, sizes, and timestamps.
- Retrieve file content and calculate digests for integrity checks.
- Traverse directories recursively to handle large and nested file systems effortlessly.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.1.0'' as title, ''# `surveilr` v1.1.0 Release Notes 🎉

## 🚀 New Features

### 1. **Integrated Documentation in Web UI**

This release introduces a comprehensive update to the RSSD Web UI, allowing users to access and view all `surveilr`-related SQLite functions, release notes, and internal documentation directly within the interface. This feature enhances user experience by providing integrated, easily navigable documentation without the need to leave the web environment, ensuring that all necessary information is readily available for efficient reference and usage.

### 2. **`uniform_resource` Graph Infrastructure**

The foundational framework for tracking `uniform_resource` content using graph representations has been laid out in this release. This infrastructure allows users to visualize `uniform_resource` data as connected graphs in addition to the traditional relational database structure. To facilitate this, three dedicated views—`imap_graph`, `plm_graph`, and `filesystem_graph`—have been created. These views provide a structured way to observe and interact with data from different ingestion sources:

- **`imap_graph`**: Represents the graphical relationships for content ingested through IMAP processes, allowing for a visual mapping of email and folder structures.
- **`plm_graph`**: Visualizes content from PLM (Product Lifecycle Management) ingestion, showcasing project and issue-based connections.
- **`filesystem_graph`**: Illustrates file ingestion paths and hierarchies, enabling users to track and manage file-based data more intuitively.

This release marks an important step towards enhancing data tracking capabilities, providing a dual approach of relational and graphical views for better data insights and management.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.0.0'' as title, ''# `surveilr` v1.0.0 Release Notes 🎉

We’re thrilled to announce the release of `surveilr` v1.0, a significant milestone in our journey to deliver powerful tools for continuous security, quality and compliance evidence workflows. This release introduces a streamlined migration system and a seamless, user-friendly experience for accessing the `surveilr` Web UI.

---

## 🚀 New Features

### 1. **Database Migration System**

This release introduces a comprehensive database migration feature that allows smooth and controlled updates to the RSSD structure. Our migration system includes:

- **Structured Notebooks and Cells**: A structured system organizes SQL migration scripts into modular code notebooks, making migration scripts easy to track, audit, and execute as needed.
- **Idempotent vs. Non-Idempotent Handling**: Ensures each migration runs in an optimal and secure manner by tracking cell execution history, allowing for re-execution where safe.
- **Automated State Tracking**: All state changes are logged for complete auditing, showing timestamps, transition details, and the results of each migration step.
- **Transactional Execution**: All migrations run within a single transaction block for seamless rollbacks and data consistency.
- **Dynamic Migration Scripts**: Cells marked for migration are dynamically added to the migration script, reducing manual effort and risk of errors.

This system ensures safe, controlled migration of database changes, enhancing reliability and traceability for every update.

### 2. **Enhanced Default Command and Web UI Launch**

The surveilr executable now starts the Web UI as the default command when no specific CLI commands are passed. This feature aims to enhance accessibility and ease of use for new users and teams. Here’s what happens by default:

- **Automatic Web UI Startup**: By default, running surveilr without additional commands launches the surveilr Web UI.
- **Auto-Browser Launch**: Opens the default browser on the workstation, pointing to the Web UI’s URL and port, providing a user-friendly experience right from the first run.'' as description_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/functions.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/functions.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              -- To display title
SELECT
  ''text'' AS component,
  ''Surveilr SQLite Functions'' AS title;

SELECT
  ''text'' AS component,
  ''Below is a comprehensive list and description of all Surveilr SQLite functions. Each function includes details about its parameters, return type, and version introduced.''
  AS contents_md;

SELECT
''list'' AS component,
''Surveilr Functions'' AS title;

  SELECT  name AS title,
        NULL AS icon,  -- Add an icon field if applicable
        ''functions-inner.sql?function='' || name || ''#function'' AS link,
        $function = name AS active
  FROM surveilr_function_doc
  ORDER BY name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/functions-inner.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
select
  ''breadcrumb'' as component;
select
  ''Home'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
select
  ''Docs'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/index.sql'' as link;
select
  ''SQL Functions'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/functions.sql'' as link;
select
  $function as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/functions-inner.sql?function=''  || $function AS link;


  SELECT
    ''text'' AS component,
    '''' || name || ''()'' AS title, ''function'' AS id
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''text'' AS component,
    description AS contents_md
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''text'' AS component,
    ''Introduced in version '' || version || ''.'' AS contents
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''title'' AS component,
    3 AS level,
    ''Parameters'' AS contents
  WHERE $function IS NOT NULL;

  SELECT
    ''card'' AS component,
    3 AS columns
    WHERE $function IS NOT NULL;
  SELECT
      json_each.value ->> ''$.name'' AS title,
      json_each.value ->> ''$.description'' AS description,
      json_each.value ->> ''$.data_type'' AS footer,
      ''azure'' AS color
  FROM surveilr_function_doc, json_each(surveilr_function_doc.parameters)
  WHERE name = $function;

  -- Navigation Buttons
  SELECT ''button'' AS component, ''sm'' AS size, ''pill'' AS shape;
  SELECT name AS title,
        NULL AS icon,  -- Add an icon field if needed
        sqlpage.link(''functions-inner.sql'', json_object(''function'', name)) AS link
  FROM surveilr_function_doc
  ORDER BY name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''ur''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''ur''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
  SELECT ''table'' AS component,
  ''Name'' AS markdown,
    ''Column Count'' as align_right,
    TRUE as sort,
    TRUE as search;

SELECT
''Table'' as "Type",
  ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_table
  WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
  GROUP BY table_name

  UNION ALL

SELECT
''View'' as "Type",
  ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_view
  WHERE view_name like ''ur_%''
  GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-files.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-files.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-files.sql/index.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small;
SELECT * FROM uniform_resource_file ORDER BY uniform_resource_id
   LIMIT $limit
  OFFSET $offset;

  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-account.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-imap-account.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-imap-account.sql/index.sql'') as contents;
    ;

select
  ''title''   as component,
  ''Mailbox'' as contents;
-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''email'' AS markdown;
SELECT    
''['' || email || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id || '')'' AS "email"
      FROM uniform_resource_imap
      GROUP BY ur_ingest_session_imap_account_id
      ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-folder.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''breadcrumb'' as component;
SELECT
   ''Home'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT
  ''Uniform Resource'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' as link;
SELECT
  ''Folder'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || $imap_account_id:: TEXT as link;
SELECT
  ''title'' as component,
  (SELECT email FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT) as contents;

--Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''folder'' AS markdown;
  SELECT ''['' || folder_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id || '')'' AS "folder"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_account_id = $imap_account_id:: TEXT
    GROUP BY ur_ingest_session_imap_acct_folder_id
    ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''
SELECT
  ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
  ''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id=''|| ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  ''title''   as component,
  (SELECT email || '' ('' || folder_name || '')''  FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT) as contents;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_imap );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''subject'' AS markdown;;
SELECT
''['' || subject || ''](uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id || '')'' AS "subject"
  , "from",
  CASE
      WHEN ROUND(julianday(''now'') - julianday(date)) = 0 THEN ''Today''
      WHEN ROUND(julianday(''now'') - julianday(date)) = 1 THEN ''1 day ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 30 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 365 THEN CAST(ROUND((julianday(''now'') - julianday(date)) / 30) AS INT) || '' months ago''
      ELSE CAST(ROUND((julianday(''now'') - julianday(date)) / 365) AS INT) || '' years ago''
  END AS "Relative Time",
  strftime(''%Y-%m-%d'', substr(date, 1, 19)) as date
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
  ORDER BY uniform_resource_id
  LIMIT $limit
  OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&folder_id='' || replace($folder_id, '' '', ''%20'') ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&folder_id='' || replace($folder_id, '' '', ''%20'') ||  '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
SELECT
 ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' AS link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id=$resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   subject AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Breadcrumb ends-- -

  --- back button-- -
    select ''button'' as component;
select
"<< Back" as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id as link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Display uniform_resource table with pagination
  SELECT
''datagrid'' as component;
SELECT
''From'' as title,
  "from" as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''To'' as title,
  email as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''Subject'' as title,
  subject as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;

  SELECT ''html'' AS component;
  SELECT html_content AS html FROM uniform_resource_imap_content WHERE uniform_resource_id=$resource_id::TEXT ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''orchestration''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''orchestration''||''/index.sql''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
     ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
     ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "case when sqlpage.environment_variable(''EOH_INSTANCE'')=1 then ''shell-custom'' else ''shell'' END",
  "title": "",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/qf-favicon.ico",
  "image": "https://www.surveilr.com/assets/brand/qf-logo.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "index.sql",
  "menu_item": [
    {
      "link": "index.sql",
      "title": "Home"
    }
  ],
  "javascript": [
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js",
    "data:text/javascript,document.addEventListener(''DOMContentLoaded'',function(){document.title=''Qualityfolio'';});"
  ],
  "footer": "Resource Surveillance Web UI",
  "css": "\n        /* Hide all text content in navbar-brand except images */\n        .navbar-brand {\n          font-size: 0 !important;\n        }\n        .navbar-brand img {\n          font-size: initial !important;\n          display: inline-block !important;\n        }\n        /* Alternative approach - hide text nodes */\n        .navbar-brand > *:not(img) {\n          display: none !important;\n        }\n        /* Hide any span or text elements in navbar */\n        .navbar-brand span,\n        .navbar-brand .navbar-text {\n          display: none !important;\n        }\n      "
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT case when sqlpage.environment_variable(''EOH_INSTANCE'')=1 then ''shell-custom'' else ''shell'' END AS component,
       NULL AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/qf-favicon.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/qf-logo.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       ''data:text/javascript,document.addEventListener(''''DOMContentLoaded'''',function(){document.title=''''Qualityfolio'''';});'' AS javascript,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''/docs/index.sql'',
              ''title'', ''Docs'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/docs/index.sql/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''ur/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''console/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''orchestration/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Surveilr ''|| (SELECT json_extract(session_agent, ''$.version'') AS version FROM ur_ingest_session LIMIT 1) || '' Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), LENGTH(sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'')) + 2 ) || '')'' as footer,
       ''
        /* Hide all text content in navbar-brand except images */
        .navbar-brand {
          font-size: 0 !important;
        }
        .navbar-brand img {
          font-size: initial !important;
          display: inline-block !important;
        }
        /* Alternative approach - hide text nodes */
        .navbar-brand > *:not(img) {
          display: none !important;
        }
        /* Hide any span or text elements in navbar */
        .navbar-brand span,
        .navbar-brand .navbar-text {
          display: none !important;
        }
      '' AS css;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
