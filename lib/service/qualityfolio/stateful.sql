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
WHERE uri LIKE '%.result.json';


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
    (select 
test_case_id,status
from test_case_run_results
group by test_case_id order by start_time desc) r on r.test_case_id=tc.test_case_id;



