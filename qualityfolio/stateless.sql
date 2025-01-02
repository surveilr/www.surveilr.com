DROP VIEW IF EXISTS projects;
CREATE view projects AS
SELECT DISTINCT 
    project,
    REPLACE(
        UPPER(SUBSTR(substring_text, 1, 1)) || 
        LOWER(SUBSTR(substring_text, 2, INSTR(substring_text, '-') - 1)) || 
        UPPER(SUBSTR(substring_text, INSTR(substring_text, '-') + 1, 1)) || 
        LOWER(SUBSTR(substring_text, INSTR(substring_text, '-') + 2)),
        '-', ' '
    ) AS project_name
FROM (
    SELECT 
     SUBSTR(
        uri, 
        INSTR(uri, 'qualityfolio-service-content/') + LENGTH('qualityfolio-service-content/'), 
        INSTR(SUBSTR(uri, INSTR(uri, 'qualityfolio-service-content/') + LENGTH('qualityfolio-service-content/')), '/') - 1
    ) AS project,
        SUBSTR(
            uri, 
            INSTR(uri, 'qualityfolio-service-content/') + LENGTH('qualityfolio-service-content/'), 
            INSTR(SUBSTR(uri, INSTR(uri, 'qualityfolio-service-content/') + LENGTH('qualityfolio-service-content/')), '/') - 1
        ) AS substring_text
    FROM uniform_resource
    WHERE uri LIKE '%qualityfolio-service-content/%'
) AS subquery;

DROP VIEW IF EXISTS test_cases;
CREATE VIEW test_cases AS
SELECT 
uri,
substr(
        uri, 
        instr(uri, 'qualityfolio-service-watchtower-content/') + length('qualityfolio-service-watchtower-content/'), 
        instr(
            substr(uri, instr(uri, 'qualityfolio-service-watchtower-content/') + length('qualityfolio-service-watchtower-content/')), 
            '/'
        ) - 1
    ) AS folder_name,
 substr(
        uri,
        length(uri) - length(substr(uri, instr(uri, 'qualityfolio-service-watchtower-content'))) + instr(substr(uri, instr(uri, 'qualityfolio-service-watchtower-content')), '/') + 1
    ) AS file_name,
      substr(
        uri,
        length(uri) - length(substr(uri, instr(uri, 'qualityfolio-service-watchtower-content'))) + instr(substr(uri, instr(uri, 'qualityfolio-service-watchtower-content')), '/') + 
        instr(substr(uri, instr(uri, 'qualityfolio-service-watchtower-content/') + length('qualityfolio-service-watchtower-content/')), '.') + 1
    ) AS file_extension,
  json_extract(frontmatter, '$.test_case_id') AS test_case_id,
    json_extract(frontmatter, '$.title') AS title,
    json_extract(frontmatter, '$.description') AS description,
    json_extract(frontmatter, '$.priority') AS priority,
    json_extract(frontmatter, '$.status') AS status,
    json_extract(frontmatter, '$.created_by') AS created_by,
    json_extract(frontmatter, '$.created_date') AS created_date,
    json_extract(frontmatter, '$.suite_id') AS suite_id
       
from 
uniform_resource ur

GROUP BY 
    uri;