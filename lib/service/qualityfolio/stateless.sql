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
    strftime('%d-%m-%Y',  g.created_at) AS formatted_test_case_created_at,
    COUNT(tc.test_case_id) AS test_case_count,
    COUNT(p.test_case_id) AS success_status_count,
    (COUNT(tc.test_case_id)-COUNT(p.test_case_id)) AS failed_status_count
FROM groups g
LEFT JOIN test_cases tc
    ON g.id = tc.group_id
LEFT JOIN test_case_run_results p on p.test_case_id=tc.test_case_id and status='passed'
GROUP BY g.name, g.id;

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
    (sum(c.test_case_count) - sum(c.success_status_count)) AS failed_count
FROM 
    test_suites t 
LEFT JOIN 
    test_cases_run_status c ON t.id = c.suite_id
GROUP BY suite_id;