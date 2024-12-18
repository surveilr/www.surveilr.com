DROP VIEW IF EXISTS projects;
CREATE view projects AS
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

DROP VIEW IF EXISTS test_suites;
CREATE view test_suites AS
SELECT 
    uniform_resource_id,
    json_extract(frontmatter, '$.id') AS id,
    json_extract(frontmatter, '$.projectId') AS project_id,
    json_extract(frontmatter, '$.name') AS name,
    json_extract(frontmatter, '$.description') AS description,
    json_extract(frontmatter, '$.created_by') AS created_by,
    json_extract(frontmatter, '$.created_at') AS created_at,
    json_extract(frontmatter, '$.tags') AS tags,
    json_extract(frontmatter, '$.linked_requirements') AS linked_requirements,
    json_extract(content_fm_body_attrs, '$.body') AS body
FROM uniform_resource
WHERE uri LIKE '%/qf-suite.md';

DROP VIEW IF EXISTS groups;
CREATE view groups AS
SELECT 
 json_extract(frontmatter, '$.id') AS id,
    json_extract(frontmatter, '$.SuiteId') AS suite_id,
    json_extract(frontmatter, '$.name') AS name,
    json_extract(frontmatter, '$.description') AS description,
    json_extract(frontmatter, '$.created_by') AS created_by,
    json_extract(frontmatter, '$.created_at') AS created_at,
    json_extract(frontmatter, '$.tags') AS tags,
    json_extract(frontmatter, '$.linked_requirements') AS linked_requirements,
    json_extract(content_fm_body_attrs, '$.body') AS body
 
FROM uniform_resource
WHERE uri LIKE '%/qf-case-group.md';


DROP VIEW IF EXISTS test_cases;
CREATE VIEW test_cases AS
SELECT 
    json_extract(frontmatter, '$.FII') AS FII,
    json_extract(frontmatter, '$.groupId') AS group_id,
    json_extract(frontmatter, '$.title') AS title,
    json_extract(frontmatter, '$.created_by') AS created_by,
    json_extract(frontmatter, '$.created_at') AS created_at,
    json_extract(frontmatter, '$.tags') AS tags,
    json_extract(frontmatter, '$.priority') AS priority
FROM uniform_resource
WHERE uri LIKE '%.case.md';

DROP VIEW IF EXISTS test_case_data;
CREATE VIEW test_case_data AS
SELECT 
    g.id AS group_id,
    g.name AS group_name,
    g.suite_id,
    g.description AS group_description,
    g.created_by AS group_created_by,
    g.created_at AS group_created_at,
    g.tags AS group_tags,
    g.linked_requirements AS group_linked_requirements,
    tc.FII AS test_case_id,
    tc.title AS test_case_title,
    tc.created_by AS test_case_created_by,
    tc.created_at AS raw_test_case_created_at, -- Original date (optional)
    strftime('%d-%m-%Y', tc.created_at) AS formatted_test_case_created_at, -- Renamed alias
    tc.tags AS test_case_tags,
    tc.priority AS test_case_priority
FROM 
    groups g
JOIN 
    test_cases tc
ON 
    g.id = tc.group_id;


DROP VIEW IF EXISTS test_case_run_profile;
CREATE VIEW test_case_run_profile AS
SELECT 
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

DROP VIEW IF EXISTS test_case_run_profile_details;
CREATE VIEW test_case_run_profile_details AS
SELECT 
    json_extract(content, '$.test_case_fii') AS test_case_id,
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


DROP VIEW IF EXISTS test_case_data_body;
CREATE VIEW test_case_data_body AS
 WITH parsed_data AS (
    SELECT
        -- Extract JSON attributes
        json_extract(content_fm_body_attrs, '$.frontMatter') AS front_matter,
        json_extract(content_fm_body_attrs, '$.body') AS body,
        json_extract(content_fm_body_attrs, '$.attrs.FII') AS fii,
        json_extract(content_fm_body_attrs, '$.attrs.groupId') AS group_id,
        json_extract(content_fm_body_attrs, '$.attrs.title') AS title,
        json_extract(content_fm_body_attrs, '$.attrs.created_by') AS created_by,
        json_extract(content_fm_body_attrs, '$.attrs.created_at') AS created_at,
        json_extract(content_fm_body_attrs, '$.attrs.tags') AS tags,
        json_extract(content_fm_body_attrs, '$.attrs.priority') AS priority
    FROM uniform_resource 
    WHERE uri LIKE '%.case.md'
),
parsed_body AS (
    SELECT
        *,
        -- Extract the 'Description' section
        TRIM(SUBSTR(
            body,
            INSTR(body, '### Description') + LENGTH('### Description'),
            INSTR(body, '### Steps') - INSTR(body, '### Description') - LENGTH('### Description')
        )) AS description,
        -- Extract the 'Steps' section
        TRIM(SUBSTR(
            body,
            INSTR(body, '### Steps') + LENGTH('### Steps'),
            INSTR(body, '### Expected Outcome') - INSTR(body, '### Steps') - LENGTH('### Steps')
        )) AS steps,
        -- Extract the 'Expected Outcome' section
        TRIM(SUBSTR(
            body,
            INSTR(body, '### Expected Outcome') + LENGTH('### Expected Outcome'),
            INSTR(body, '### Expected Results') - INSTR(body, '### Expected Outcome') - LENGTH('### Expected Outcome')
        )) AS expected_outcome,
        -- Extract the 'Expected Results' section
        TRIM(SUBSTR(
            body,
            INSTR(body, '### Expected Results') + LENGTH('### Expected Results'),
            LENGTH(body) - INSTR(body, '### Expected Results') - LENGTH('### Expected Results')
        )) AS expected_results
    FROM parsed_data
)
SELECT
    front_matter,
    fii,
    group_id,
    title,
    created_by,
    created_at,
    tags,
    priority,
    description,
    steps,
    expected_outcome,
    expected_results
FROM parsed_body;
   
DROP VIEW IF EXISTS test_case_md_body;
CREATE VIEW test_case_md_body AS
SELECT
    json_extract(content_fm_body_attrs, '$.frontMatter') AS front_matter,
    json_extract(content_fm_body_attrs, '$.body') AS body,
    json_extract(content_fm_body_attrs, '$.attrs.FII') AS test_case_id,
    json_extract(content_fm_body_attrs, '$.attrs.groupId') AS group_id,
    json_extract(content_fm_body_attrs, '$.attrs.title') AS title,
    json_extract(content_fm_body_attrs, '$.attrs.created_by') AS created_by,
    json_extract(content_fm_body_attrs, '$.attrs.created_at') AS created_at,
    json_extract(content_fm_body_attrs, '$.attrs.tags') AS tags,
    json_extract(content_fm_body_attrs, '$.attrs.priority') AS priority
FROM uniform_resource
WHERE uri LIKE '%.case.md';

DROP VIEW IF EXISTS test_suites_test_case_count;
CREATE VIEW test_suites_test_case_count AS
SELECT 
    g.name AS group_name,
    g.suite_id,
    g.id AS group_id,
    g.created_by,   
    strftime('%d-%m-%Y',  g.created_at) AS formatted_test_case_created_at,
    COUNT(tc.FII) AS test_case_count
FROM groups g
LEFT JOIN test_cases tc
    ON g.id = tc.group_id
GROUP BY g.name, g.id;

-- CREATE VIEW test_suites_test_case_count AS
-- SELECT 
-- count(*) as test_case_count,
-- gp.name AS group_name,
-- gp.suite_id,
-- gp.created_by,
-- gp.id AS group_id,
-- strftime('%d-%m-%Y',  g.created_at) AS formatted_test_case_created_at
-- FROM test_cases tc
-- INNER JOIN groups gp on gp.id=tc.group_id
-- INNER JOIN test_suites st on gp.suite_id=st.id;




