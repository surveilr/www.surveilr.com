-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- database: ./resource-surveillance.sqlite.db

-- Drop and create view for uniform_resource summary
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_summary;
CREATE VIEW ai_ctxe_uniform_resource_summary AS
SELECT
  COUNT(*) AS total_files_seen, -- Total files seen
  COUNT(*) FILTER (WHERE content IS NOT NULL AND LENGTH(TRIM(content)) > 0) AS files_with_content, -- Files with content
  COUNT(*) FILTER (WHERE frontmatter IS NOT NULL AND LENGTH(TRIM(frontmatter)) > 0) AS files_with_frontmatter, -- Files with frontmatter
  MIN(last_modified_at) AS oldest_modified_at, -- Oldest modified date
  MAX(last_modified_at) AS youngest_modified_at -- Youngest modified date
FROM uniform_resource
WHERE uri IS NOT NULL;


-- Drop and create view for uniform_resource prompts
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_prompts;
CREATE VIEW ai_ctxe_uniform_resource_prompts AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    
    -- Extract filename from file_path_rel
    CASE 
        WHEN urf.file_path_rel LIKE '%/%' THEN 
            substr(urf.file_path_rel, length(rtrim(urf.file_path_rel, replace(urf.file_path_rel, '/', ''))) + 1)
        ELSE 
            urf.file_path_rel
    END AS filename,
    
    ur.created_at,
    ur.created_by,
    ur.content,
    ur.frontmatter,
    
    -- Extract title and summary from frontmatter JSON
    json_extract(ur.frontmatter, '$.title') AS title,
    json_extract(ur.frontmatter, '$.summary') AS summary,
    json_extract(ur.frontmatter, '$.merge-group') AS merge_group,
  COALESCE(json_extract(ur.frontmatter, '$.order'), 999999) AS ord,

    -- content with frontmatter stripped
    TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text,

    -- Additional useful fields from uniform_resource_file
    urf.nature,
    urf.source_path,
    urf.file_path_rel,
    urf.size_bytes

FROM uniform_resource ur
INNER JOIN uniform_resource_file urf 
    ON ur.uniform_resource_id = urf.uniform_resource_id
INNER JOIN   ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id AND fs.uniform_resource_id=urf.uniform_resource_id
WHERE ur.deleted_at IS NULL AND 
  (fs.file_basename LIKE '%.prompt.md' OR fs.file_basename LIKE '%.prompt-snippet.md'
  OR fs.file_basename LIKE '%-prompt-meta.md');

-- Drop and create view for uniform_resource frontmatter
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_frontmatter_view;
CREATE VIEW ai_ctxe_uniform_resource_frontmatter_view AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    -- Extracting only important keys from the frontmatter column
    json_extract(frontmatter, '$.id') AS frontmatter_id,
   COALESCE(
    json_extract(frontmatter, '$.title'),
    ur.filename
) AS title,
    json_extract(frontmatter, '$.summary') AS frontmatter_summary,
  json_extract(frontmatter, '$.merge-group') AS frontmatter_merge_group,
    json_extract(frontmatter, '$.artifact-nature') AS frontmatter_artifact_nature,
   
    json_extract(frontmatter, '$.lifecycle') AS frontmatter_lifecycle,
    json_extract(frontmatter, '$.visibility') AS frontmatter_visibility,
    json_extract(frontmatter, '$.audience') AS frontmatter_audience,
    json_extract(frontmatter, '$.function') AS frontmatter_function,
    json_extract(frontmatter, '$.product.name') AS frontmatter_product_name,
    
    -- Extracting features dynamically (up to the first 5 features)
    trim(
        json_extract(frontmatter, '$.product.features[0]') || ',' ||
        json_extract(frontmatter, '$.product.features[1]') || ',' ||
        json_extract(frontmatter, '$.product.features[2]') || ',' ||
        json_extract(frontmatter, '$.product.features[3]') || ',' ||
        json_extract(frontmatter, '$.product.features[4]')
    ) AS frontmatter_product_features,
    
    json_extract(frontmatter, '$.provenance.source-uri') AS frontmatter_provenance_source_uri,
    json_extract(frontmatter, '$.provenance.dependencies') AS frontmatter_provenance_dependencies,

    -- Extracting reviewers dynamically (up to the first 5 reviewers)
    trim(
        json_extract(frontmatter, '$.provenance.reviewers[0]') || ',' ||
        json_extract(frontmatter, '$.provenance.reviewers[1]')
    ) AS frontmatter_reviewers,
      json_extract(urt.elaboration, '$.validation.status') AS validation_status,
      json_extract(urt.elaboration, '$.warnings[0]') AS elaboration_warning

FROM ai_ctxe_uniform_resource_prompts ur
LEFT JOIN uniform_resource_transform urt
  ON ur.uniform_resource_id = urt.uniform_resource_id
  ;
    

-- Drop and create view for files with content
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_with_content;

CREATE VIEW IF NOT EXISTS ai_ctxe_uniform_resource_with_content AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    
    -- Extract filename from file_path_rel
    CASE 
        WHEN urf.file_path_rel LIKE '%/%' THEN 
            substr(urf.file_path_rel, length(rtrim(urf.file_path_rel, replace(urf.file_path_rel, '/', ''))) + 1)
        ELSE 
            urf.file_path_rel
    END AS filename,
    
    ur.created_at,
    ur.created_by,
    ur.content,
    ur.frontmatter,
    
    -- Extract title and summary from frontmatter JSON
    json_extract(ur.frontmatter, '$.title') AS title,
    json_extract(ur.frontmatter, '$.summary') AS summary,

    -- content with frontmatter stripped
    TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text,

    -- Additional useful fields from uniform_resource_file
    urf.nature,
    urf.source_path,
    urf.file_path_rel,
    urf.size_bytes

FROM uniform_resource ur
LEFT JOIN uniform_resource_file urf 
    ON ur.uniform_resource_id = urf.uniform_resource_id
WHERE ur.content IS NOT NULL AND deleted_at IS NULL AND LENGTH(TRIM(ur.content)) > 0;

-- Drop and create view for files with frontmatter
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_with_frontmatter;

CREATE VIEW IF NOT EXISTS ai_ctxe_uniform_resource_with_frontmatter AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
   
    
    -- Extract filename from file_path_rel
    CASE 
        WHEN urf.file_path_rel LIKE '%/%' THEN 
            substr(urf.file_path_rel, length(rtrim(urf.file_path_rel, replace(urf.file_path_rel, '/', ''))) + 1)
        ELSE 
            urf.file_path_rel
    END AS filename,
    
    ur.created_at,
    ur.created_by,
    ur.content,
    ur.frontmatter,
    
    -- Extract title and summary from frontmatter JSON
    json_extract(ur.frontmatter, '$.title') AS title,
    json_extract(ur.frontmatter, '$.summary') AS summary,

    -- content with frontmatter stripped
    TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text,

    -- Additional useful fields from uniform_resource_file
    urf.nature,
    urf.source_path,
    urf.file_path_rel,
    urf.size_bytes

FROM uniform_resource ur
LEFT JOIN uniform_resource_file urf 
    ON ur.uniform_resource_id = urf.uniform_resource_id
WHERE deleted_at IS NULL
        AND frontmatter IS NOT NULL AND LENGTH(TRIM(frontmatter)) > 0;

-- Drop and create view for all files
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_all_files;

CREATE VIEW  ai_ctxe_uniform_resource_all_files AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    
   fs.file_basename AS filename,
    ur.nature,
    
    ur.created_at,
    ur.created_by,
    ur.content,
    ur.frontmatter,
    
    -- Extract title and summary from frontmatter JSON
    json_extract(ur.frontmatter, '$.title') AS title,
    json_extract(ur.frontmatter, '$.summary') AS summary,

    -- content with frontmatter stripped
    TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text

FROM uniform_resource ur
LEFT JOIN
  ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id
WHERE ur.deleted_at IS NULL;

-- Drop and create view for risk panel
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_risk_view;
CREATE VIEW ai_ctxe_uniform_resource_risk_view AS
SELECT
    -- Count of resources with null or empty frontmatter
    (
        SELECT COUNT(*)
        FROM uniform_resource
        WHERE deleted_at IS NULL
          AND (frontmatter IS NULL OR LENGTH(TRIM(frontmatter)) = 0)
    ) AS count_empty_frontmatter,

    -- Count of grouped resources where order is null or count > 1
    (
        SELECT COUNT(*)
        FROM (
            SELECT 
                json_extract(frontmatter, '$.merge-group') AS mg,
                json_extract(frontmatter, '$.order') AS ord,
                COUNT(*) AS ct
            FROM uniform_resource
            WHERE deleted_at IS NULL
              AND frontmatter IS NOT NULL
              AND json_extract(frontmatter, '$.merge-group') IS NOT NULL
            GROUP BY mg, ord
            HAVING ord IS NULL OR ct > 1
        ) AS grouped_resources
    ) AS count_grouped_resources,

    -- Count of files over 1MB linked to non-deleted resources
    (
        SELECT COUNT(*)
        FROM uniform_resource_file urf
        JOIN uniform_resource ur ON urf.uniform_resource_id = ur.uniform_resource_id
        WHERE ur.deleted_at IS NULL
          AND urf.size_bytes > 1048576
    ) AS count_large_files;


-- Drop and create view for files without frontmatter
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_without_frontmatter;

CREATE VIEW IF NOT EXISTS ai_ctxe_uniform_resource_without_frontmatter AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    
    ur.created_at,
  
    ur.content,
    ur.uri,
    ur.nature,
    fs.file_basename as filename
FROM uniform_resource ur
JOIN
  ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id
WHERE ur.deleted_at IS NULL
        AND (frontmatter IS NULL OR LENGTH(TRIM(frontmatter)) = 0);


-- Drop and create view for oversized files
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_oversized_list;

CREATE VIEW IF NOT EXISTS ai_ctxe_uniform_resource_oversized_list AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    
    ur.created_at,
  
    ur.content,
    ur.uri,
    ur.nature,
    fs.file_basename as filename
FROM uniform_resource ur
JOIN
  ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id
WHERE ur.deleted_at IS NULL
        AND ur.size_bytes > 1048576;


-- Drop and create view for merge group risks
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_merge_group_risks;

CREATE VIEW IF NOT EXISTS ai_ctxe_uniform_resource_merge_group_risks AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    ur.created_at,
    TRIM(
        CASE
            WHEN instr(ur.content, '---') = 1 THEN substr(
                ur.content,
                instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
            )
            ELSE ur.content
        END
    ) AS body_text,
    ur.nature,
    json_extract(ur.frontmatter, '$.merge-group') AS merge_group,
    json_extract(ur.frontmatter, '$.order') AS merge_order,
    fs.file_basename AS filename
FROM uniform_resource ur
JOIN ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id
WHERE ur.deleted_at IS NULL
  AND (
        json_extract(ur.frontmatter, '$.merge-group') IS NULL
     OR (
        json_extract(ur.frontmatter, '$.merge-group') IS NOT NULL
        AND json_extract(ur.frontmatter, '$.order') IS NULL
     )
  );


--- === frontmatter validation ===
---DROP VIEW IF EXISTS opsfolio_frontmatter_validation;
---CREATE VIEW IF NOT EXISTS opsfolio_invalid_frontmatter AS
-- SELECT 
--     ur.uniform_resource_id,
--     ur.uri,
--     ur.created_at,
--     ur.content,
--     ur.nature,
--     ur.frontmatter,
--     fs.file_basename as filename
-- FROM 
--     uniform_resource ur
-- JOIN
--     ur_ingest_session_fs_path_entry fs ON fs.uniform_resource_id = ur.uniform_resource_id
-- WHERE
--     ur.deleted_at IS NULL
--     AND ur.frontmatter IS NOT NULL
--     AND json_schema_valid(
--         '{
--             "type": "object",
--             "properties": {
--                 "id": { "type": "string" },
--                 "title": { "type": "string" },
--                 "summary": { "type": "string" },
--                 "artifact-nature": { "type": "string" },
--                 "function": { "type": "string" },
--                 "audience": { "type": "string" },
--                 "visibility": { "type": "string" },
--                 "tenancy": { "type": "string" },
--                 "product": {
--                     "type": "object",
--                     "properties": {
--                         "name": { "type": "string" },
--                         "version": { "type": "string" },
--                         "features": {
--                             "type": "array",
--                             "items": { "type": "string" }
--                         }
--                     },
--                     "required": ["name", "version", "features"]
--                 },
--                 "provenance": {
--                     "type": "object",
--                     "properties": {
--                         "source-uri": { "type": "string" },
--                         "reviewers": {
--                             "type": "array",
--                             "items": { "type": "string" }
--                         },
--                         "dependencies": {
--                             "type": "array",
--                             "items": { "type": "string" }
--                         }
--                     },
--                     "required": ["source-uri", "reviewers", "dependencies"]
--                 },
--                 "merge-group": { "type": "string" },
--                 "order": { "type": "number" }
--             },
--             "required": [
--                 "id", "title", "summary", "artifact-nature", "function", "audience", 
--                 "visibility", "tenancy", "product", "provenance", "merge-group", "order"
--             ]
--         }', 
--         ur.frontmatter
--     ) = 0;-- 

-- Drop and create view for anythingllm
DROP VIEW IF EXISTS uniform_resource_build_anythingllm;
CREATE VIEW uniform_resource_build_anythingllm AS
SELECT DISTINCT
 ur.uniform_resource_id,
    ur.uri,
    
    -- Extract filename from file_path_rel
    CASE 
        WHEN urf.file_path_rel LIKE '%/%' THEN 
            substr(urf.file_path_rel, length(rtrim(urf.file_path_rel, replace(urf.file_path_rel, '/', ''))) + 1)
        ELSE 
            urf.file_path_rel
    END AS filename,
    
    ur.created_at,
    ur.created_by,
    ur.content,
    ur.frontmatter,
    
    -- Extract title and summary from frontmatter JSON
    json_extract(ur.frontmatter, '$.title') AS title,
    json_extract(ur.frontmatter, '$.summary') AS summary,

    -- content with frontmatter stripped
    TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text,

    -- Additional useful fields from uniform_resource_file
    urf.nature,
    urf.source_path,
    urf.file_path_rel,
    urf.size_bytes

FROM uniform_resource ur
LEFT JOIN uniform_resource_file urf 
    ON ur.uniform_resource_id = urf.uniform_resource_id
LEFT JOIN   ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id AND fs.uniform_resource_id=urf.uniform_resource_id
WHERE ur.deleted_at IS NULL
AND ur.uri LIKE '%.build/anythingllm%';

-- Drop and create view for anythingllm frontmatter
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_frontmatter_view_anythingllm;
CREATE VIEW ai_ctxe_uniform_resource_frontmatter_view_anythingllm AS

SELECT DISTINCT
    uniform_resource_id,
    uri,
    -- Extracting only important keys from the frontmatter column
    json_extract(frontmatter, '$.id') AS frontmatter_id,
    json_extract(frontmatter, '$.title') AS title,
    json_extract(frontmatter, '$.summary') AS frontmatter_summary,
  json_extract(frontmatter, '$.merge-group') AS frontmatter_merge_group,
    json_extract(frontmatter, '$.artifact-nature') AS frontmatter_artifact_nature,
   
    json_extract(frontmatter, '$.lifecycle') AS frontmatter_lifecycle,
    json_extract(frontmatter, '$.visibility') AS frontmatter_visibility,
    json_extract(frontmatter, '$.audience') AS frontmatter_audience,
    json_extract(frontmatter, '$.function') AS frontmatter_function,
    json_extract(frontmatter, '$.product.name') AS frontmatter_product_name,
    
    -- Extracting features dynamically (up to the first 5 features)
    trim(
        json_extract(frontmatter, '$.product.features[0]') || ',' ||
        json_extract(frontmatter, '$.product.features[1]') || ',' ||
        json_extract(frontmatter, '$.product.features[2]') || ',' ||
        json_extract(frontmatter, '$.product.features[3]') || ',' ||
        json_extract(frontmatter, '$.product.features[4]')
    ) AS frontmatter_product_features,
    
    json_extract(frontmatter, '$.provenance.source-uri') AS frontmatter_provenance_source_uri,
    json_extract(frontmatter, '$.provenance.dependencies') AS frontmatter_provenance_dependencies,

    -- Extracting reviewers dynamically (up to the first 5 reviewers)
    trim(
        json_extract(frontmatter, '$.provenance.reviewers[0]') || ',' ||
        json_extract(frontmatter, '$.provenance.reviewers[1]')
    ) AS frontmatter_reviewers
    
FROM uniform_resource_build_anythingllm;

-- Drop and create view for transformed resources cleaned
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_transformed_resources_cleaned;
CREATE VIEW IF NOT EXISTS ai_ctxe_uniform_resource_transformed_resources_cleaned AS
SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    ur.nature,
     fs.file_basename as filename,
    -- Remove frontmatter from content
    TRIM(
        CASE
            WHEN instr(urt.content, '---') = 1 THEN substr(
                urt.content,
                instr(ur.content, '---') + 3 + instr(substr(urt.content, instr(urt.content, '---') + 3), '---') + 3
            )
            ELSE urt.content
        END
    ) AS body_content,
    json_extract(urt.elaboration, '$.validation.status') AS validation_status,
    json_extract(urt.elaboration, '$.warnings') AS warnings
FROM uniform_resource ur
LEFT JOIN uniform_resource_transform urt
  ON ur.uniform_resource_id = urt.uniform_resource_id
  LEFT JOIN
  ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id AND fs.uniform_resource_id=urt.uniform_resource_id
WHERE ur.deleted_at IS NULL
  AND (
      json_extract(urt.elaboration, '$.validation.status') IS NULL
      OR json_extract(urt.elaboration, '$.validation.status') != 'success'
  );

-- Drop and create view for transformed resources valid
DROP VIEW IF EXISTS ai_ctxe_uniform_resource_transformed_resources_valid;
CREATE VIEW IF NOT EXISTS ai_ctxe_uniform_resource_transformed_resources_valid AS
SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,
    ur.nature,
    ur.created_at,
     fs.file_basename as filename,
    -- Remove frontmatter from content
    TRIM(
        CASE
            WHEN instr(urt.content, '---') = 1 THEN substr(
                urt.content,
                instr(ur.content, '---') + 3 + instr(substr(urt.content, instr(urt.content, '---') + 3), '---') + 3
            )
            ELSE urt.content
        END
    ) AS body_content,
    json_extract(urt.elaboration, '$.validation.status') AS validation_status,
    json_extract(urt.elaboration, '$.warnings') AS warnings
FROM uniform_resource ur
JOIN uniform_resource_transform urt
  ON ur.uniform_resource_id = urt.uniform_resource_id
  JOIN
  ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id AND fs.uniform_resource_id=urt.uniform_resource_id
WHERE ur.deleted_at IS NULL
  AND (
    
      json_extract(urt.elaboration, '$.validation.status') = 'success'
  );


DROP VIEW IF EXISTS ai_ctxe_view_uniform_resource_complaince;
CREATE VIEW ai_ctxe_view_uniform_resource_complaince AS

SELECT DISTINCT
    ur.uniform_resource_id,
    ur.uri,

    -- Extract regime from URI
    CASE
        WHEN ur.uri LIKE '%/regime/hipaa/%' THEN 'HIPAA'
        WHEN ur.uri LIKE '%/regime/soc2/%' THEN 'SOC2'
        WHEN ur.uri LIKE '%/regime/nist/%' THEN 'NIST'
        ELSE 'Other'
    END AS regime,

    -- Extract filename from file_path_rel
    CASE 
        WHEN urf.file_path_rel LIKE '%/%' THEN 
            substr(urf.file_path_rel, length(rtrim(urf.file_path_rel, replace(urf.file_path_rel, '/', ''))) + 1)
        ELSE 
            urf.file_path_rel
    END AS filename,

    ur.created_at,
    ur.created_by,
    ur.content,
    ur.frontmatter,

    -- Extract title and summary from frontmatter JSON
    json_extract(ur.frontmatter, '$.title') AS title,
    json_extract(ur.frontmatter, '$.description') AS summary,
    json_extract(ur.frontmatter, '$.merge-group') AS merge_group,
    COALESCE(json_extract(ur.frontmatter, '$.order'), 999999) AS ord,

    -- content with frontmatter stripped
    TRIM(
        CASE
            WHEN instr(ur.content, '---') = 1
                THEN substr(
                    ur.content,
                    instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
                )
            ELSE ur.content
        END
    ) AS body_text,

    -- Additional useful fields from uniform_resource_file
    urf.nature,
    urf.source_path,
    urf.file_path_rel,
    urf.size_bytes,
    json_extract(frontmatter, '$.id') AS frontmatter_id,
    json_extract(frontmatter, '$.title') AS title,
    json_extract(frontmatter, '$.description') AS frontmatter_summary,
    json_extract(frontmatter, '$.merge-group') AS frontmatter_merge_group,
    json_extract(frontmatter, '$.control-question') AS frontmatter_control_question,
    json_extract(frontmatter, '$.control-id') AS frontmatter_control_id,
    json_extract(frontmatter, '$.control-domain') AS frontmatter_control_domain,
    json_extract(frontmatter, '$.SCF-control') AS SCF_control,
    json_extract(frontmatter, '$.publishDate') AS publishDate,
    json_extract(frontmatter, '$.provenance.dependencies') AS frontmatter_provenance_dependencies,

    json_extract(frontmatter, '$.id') AS frontmatter_id,
   trim(
        json_extract(frontmatter, '$.category[0]') || ',' ||
        json_extract(frontmatter, '$.category[1]') || ',' ||
        json_extract(frontmatter, '$.category[2]') || ',' ||
        json_extract(frontmatter, '$.category[3]') || ',' ||
        json_extract(frontmatter, '$.category[4]')
    ) AS frontmatter_category,
    
    -- Extracting features dynamically (up to the first 5 features)
    trim(
        json_extract(frontmatter, '$.satisfies[0]') || ',' ||
        json_extract(frontmatter, '$.satisfies[1]') || ',' ||
        json_extract(frontmatter, '$.satisfies[2]') || ',' ||
        json_extract(frontmatter, '$.satisfies[3]') || ',' ||
        json_extract(frontmatter, '$.satisfies[4]')
    ) AS frontmatter_satisfies
    


FROM uniform_resource ur
LEFT JOIN uniform_resource_file urf 
    ON ur.uniform_resource_id = urf.uniform_resource_id
LEFT JOIN ur_ingest_session_fs_path_entry fs
    ON fs.uniform_resource_id = ur.uniform_resource_id AND fs.uniform_resource_id = urf.uniform_resource_id
WHERE ur.deleted_at IS NULL
  AND (
    ur.uri LIKE '%/regime/hipaa/%'
    OR ur.uri LIKE '%/regime/soc2/%'
    OR ur.uri LIKE '%/regime/nist/%'
  )
  AND (fs.file_basename LIKE '%.prompt.md' OR fs.file_basename LIKE '%.prompt-snippet.md' OR fs.file_basename LIKE '%-prompt-meta.md');




/* 'orchestrateStatefulSQL' in '[object Object]' returned type undefined instead of string | string[] | SQLa.SqlTextSupplier */
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
DELETE FROM sqlpage_aide_navigation WHERE parent_path='ai-context-engineering'||'/index.sql';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'ai-context-engineering/index.sql', 'ai-context-engineering/index.sql', 'AI Context Engineering Overview', NULL, NULL, 'Explore and query AI-generated and RSSD ingested context data.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "AI Context Middleware Explorer",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/favicon.ico",
  "image": "https://www.surveilr.com/assets/brand/surveilr-icon.png",
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
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT ''shell'' AS component,
       ''AI Context Middleware Explorer'' AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/favicon.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/surveilr-icon.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
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
       ''Surveilr ''|| (SELECT json_extract(session_agent, ''$.version'') AS version FROM ur_ingest_session LIMIT 1) || '' Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), LENGTH(sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'')) + 2 ) || '')'' as footer;',
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
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
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
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&folder_id='' || replace($folder_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&folder_id='' || replace($folder_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
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
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
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
      'ai-context-engineering/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ai-context-engineering/index.sql''
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
''card'' as component,
2 as columns;
select
''## Opsfolio'' as description_md,
''white'' as background_color,
     
''12'' as width,
''pink'' as color,
''timeline-event'' as icon,
''background-color: #FFFFFF'' as style,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/opsfolio.sql'' as link
;

select
''## Compliance Explorer'' as description_md,
''white'' as background_color,
''12'' as width,
''pink'' as color,
''timeline-event'' as icon,
''background-color: #FFFFFF'' as style,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/compliance.sql'' as link;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/opsfolio.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                  select
    ''breadcrumb'' as component;
   
    select
    ''Home'' as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
   
    select
    ''AI Context Engineering Overview'' as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
    select
    ''Opsfolio'' as title,
    ''#'' as link;
   
   

   
   select
    ''card'' as component,
    4 as columns;
   
    select
    ''## Total Counts of Prompt Module'' as description_md,
    ''white'' as background_color,
    ''## '' || count(DISTINCT uri) as description_md,
    ''12'' as width,
    ''pink'' as color,
    ''timeline-event'' as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts.sql'' as link
    FROM ai_ctxe_uniform_resource_prompts WHERE uri NOT LIKE ''%/.build/anythingllm/%''
AND uri NOT LIKE ''%/regime/hipaa/%''
AND uri NOT LIKE ''%/regime/soc2/%''
AND uri NOT LIKE ''%/regime/nist/%'';
   
    select
    ''## Total counts of Merge Group'' as description_md,
    ''white'' as background_color,
    ''## '' || count(DISTINCT merge_group) as description_md,
    ''12'' as width,
    ''pink'' as color,
    ''timeline-event'' as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group.sql'' as link
    FROM ai_ctxe_uniform_resource_prompts;
   
    select
    ''## Ingest Health'' as description_md,
    ''white'' as background_color,
    ''12'' as width,
    ''green'' as color,
    ''file-plus'' as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
   
    select
    ''## Risk/QA Panel'' as description_md,
    ''white'' as background_color,
    ''12'' as width,
    ''red'' as color,
    ''alert-circle'' as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/risk.sql'' as link;
 
    select
    ''card'' as component,
    4 as columns;
   
    select
    ''## Total Count of Prompts fed into AnythingLLM'' as description_md,
    ''white'' as background_color,
    ''## '' || count(DISTINCT uri) as description_md,
    ''12'' as width,
    ''pink'' as color,
    ''timeline-event'' as icon,
    ''background-color: #FFFFFF'' as style,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-anythingllm.sql'' as link
    FROM uniform_resource_build_anythingllm;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/compliance.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
     
select
''Home'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
select
''AI Context Engineering Overview'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
select
''card'' as component,
3 as columns;

select
''## Total Counts of HIPAA Prompt Modules'' as description_md,
''white'' as background_color,
''## '' || count(DISTINCT uniform_resource_id) as description_md,
''12'' as width,
''pink'' as color,
''timeline-event'' as icon,
''background-color: #FFFFFF'' as style,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-hipaa.sql'' as link
FROM ai_ctxe_view_uniform_resource_complaince where regime=''HIPAA'';

select
''## Total Counts of SOC2 Prompt Modules'' as description_md,
''white'' as background_color,
''## '' || count(DISTINCT uniform_resource_id) as description_md,
''12'' as width,
''pink'' as color,
''timeline-event'' as icon,
''background-color: #FFFFFF'' as style,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-soc.sql'' as link
FROM ai_ctxe_view_uniform_resource_complaince where regime=''SOC2'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/merge-group.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Merge Groups'' as title;
       SELECT ''title''AS component, 
     ''Merge group'' as contents;
      SELECT ''text'' as component,
''This page displays all defined merge groups for AI context engineering prompts. Each group represents a collection of related prompts that can be explored further by clicking on the group name.'' as contents;

     
      SELECT
      ''table'' as component,
      TRUE AS sort,
      TRUE AS search,
      ''merge_group'' as markdown;
     
      SELECT
      ''[''||merge_group||''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql''||''?uniform_resource_id=''||uniform_resource_id||'')'' as merge_group,
      title as ''title'',
      uri as ''uri''
     
      FROM ai_ctxe_uniform_resource_prompts
      WHERE merge_group IS NOT NULL
     AND uri NOT LIKE ''%/.build/anythingllm/%''
     ORDER BY merge_group;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/ingest-health.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Ingest Health'' as title;
     
      select ''title'' AS component, ''Ingest Health Overview'' AS contents;
      SELECT ''text'' as component,
''This dashboard provides visibility into the health of the AI context ingestion pipeline. Use the metrics below to monitor the number of files ingested, processed for content, and validated for frontmatter. You can also filter recent ingests by time range.'' as contents;

     
      -- === FILES SEEN ===
      select
      ''big_number'' as component,
      4 as columns,
      ''colorfull_dashboard'' as id;
     
      select
      ''Files Seen'' AS title,
      (SELECT COUNT(*)
      FROM uniform_resource
      WHERE deleted_at IS NULL
      ) as value,
      ''green'' as color,
      ''/ai-context-engineering/file-list.sql'' as value_link,
      TRUE as value_link_new_tab;
     
      -- === FILE WITH CONTENT ===
      SELECT
      ''Files with Content'' AS title,
      (
      SELECT COUNT(*)
      FROM ai_ctxe_uniform_resource_with_content
      ) AS value,
      ''blue'' AS color,
      ''/ai-context-engineering/file-with-content-list.sql'' as value_link,
      TRUE as value_link_new_tab;
     
      -- === FILES WITH FRONTMATTER ===
      SELECT
      ''Files with Frontmatter'' AS title,
      (
      SELECT COUNT(*)
      FROM ai_ctxe_uniform_resource_with_frontmatter
      ) AS value,
      ''orange'' AS color,
      ''/ai-context-engineering/file-with-frontmatter-list.sql'' as value_link;
 
      -- === FILES WITH VALID FRONTMATTER ===
      SELECT
      ''Files with valid Frontmatter'' AS title,
      (
      SELECT COUNT(*)
      FROM ai_ctxe_uniform_resource_transformed_resources_valid
      ) AS value,
      ''green'' AS color,
      ''/ai-context-engineering/file-with-valid-frontmatter-list.sql'' as value_link;
     
      -- === TIME RANGE SELECTION ===
      -- 1. Define the form
      SELECT ''form'' AS component, TRUE AS auto_submit;
     
      SELECT
      ''select'' AS type,
      ''time_range'' AS name,
      ''Select time range'' AS label,
      ''Select time range'' AS empty_option,
      ''[{"label": "Today", "value": "0"}, {"label": "7 day", "value": "1"}, {"label": "30 day", "value": "2"}]'' AS options,
      :time_range AS value;
     
      -- 2. Define the table
      SELECT ''table'' AS component,
      TRUE AS sort,
      TRUE AS search,
      ''filename'' AS markdown;
     
      -- 3. Query the filtered data
      SELECT
      ''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/time-range-file-detail.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' AS "filename",
      uri AS "uri",
      nature AS "Nature",
      created_at AS "Created At"
      FROM ai_ctxe_uniform_resource_all_files
      WHERE
      :time_range IS NOT NULL
      AND :time_range != ''''
      AND CASE
      WHEN :time_range = ''0'' THEN DATE(created_at) = DATE(''now'')
      WHEN :time_range = ''1'' THEN DATE(created_at) >= DATE(''now'', ''-7 days'')
      WHEN :time_range = ''2'' THEN DATE(created_at) >= DATE(''now'', ''-30 days'')
      ELSE 0 = 1
      END
      ORDER BY created_at DESC;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/merge-group-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Merge Groups'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group.sql'' as link;
     
      select
      "frontmatter_merge_group" as title,
      "#" as link from ai_ctxe_uniform_resource_frontmatter_view where uniform_resource_id = $uniform_resource_id;
;
SELECT ''title'' AS component, ''Merge Group Details'' AS contents;
 SELECT ''text'' as component,
''This page provides a detailed view of a specific merge group in the AI Context Engineering system. It structured frontmatter details (title, summary, lifecycle, product metadata, provenance, reviewers, and features), and the list of prompts associated with the selected resource.'' as contents;

      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
       ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
 
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' as component, 1 as columns;
     
      SELECT
     
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_prompts p
     
      WHERE p.uniform_resource_id = $uniform_resource_id
    GROUP BY p.uniform_resource_id
      ORDER BY p.ord, p.uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompts.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Prompt'' as title;
      SELECT ''title''AS component, 
     ''Prompt'' as contents; 
       SELECT ''text'' as component,
''This page provides an overview of AI context engineering prompts, including their purpose, target audience, and validation status. Use the table below to explore and evaluate individual prompts and their associated metadata.'' as contents;

   
     
-- Add CSS styling for validation status colors
SELECT ''html'' as component,
''<style>
  /* Target the validation status column specifically */
  ._col_validation_status a {
    text-decoration: none;
  }
 
  /* Success styling for validation status column */
  .rowClass-success ._col_validation_status a {
    color: #28a745 !important;
    font-weight: bold;
  }
 
  /* Failure styling for validation status column */
  .rowClass-failure ._col_validation_status a {
    color: #dc3545 !important;
    font-weight: bold;
  }
</style>'' as html;
 
SELECT
  ''table'' as component,
  TRUE AS sort,
  TRUE AS search,
  "title" as markdown,
  "validation status" as markdown;
     
SELECT
  ''['' || title || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompt-detail.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "title",
  CASE
    WHEN validation_status = ''success'' THEN
      ''[success]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/validation-detail.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')''
    WHEN validation_status IN (''failure'', ''failed'') THEN
      ''[failure]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/validation-detail.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')''
    ELSE
      ''['' || validation_status || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/validation-detail.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')''
  END as "validation status",
 
  frontmatter_artifact_nature as "Artifact nature",
  frontmatter_function as "Function",
  frontmatter_audience as "Audience",
  frontmatter_summary as "Summary",
  uri as "URI",
 
  -- Add CSS class based on validation status
  CASE
    WHEN validation_status = ''success'' THEN ''rowClass-success''
    WHEN validation_status IN (''failure'', ''failed'') THEN ''rowClass-failure''
    ELSE NULL
  END as _sqlpage_css_class
 
FROM ai_ctxe_uniform_resource_frontmatter_view WHERE uri NOT LIKE ''%/.build/anythingllm/%''
  AND uri NOT LIKE ''%/regime/hipaa/%''
  AND uri NOT LIKE ''%/regime/soc2/%''
  AND uri NOT LIKE ''%/regime/nist/%''
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompts-complaince-hipaa.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Prompt'' as title;
      SELECT ''title''AS component, 
     ''Prompt'' as contents; 
       SELECT ''text'' as component,
''This page provides an overview of compliance-focused AI context engineering prompts, including those related to US HIPAA Controls prompts. Use the table below to review individual prompts along with their summaries and source details.'' as contents;

   
     

 
SELECT
  ''table'' as component,
  TRUE AS sort,
  TRUE AS search,
  "title" as markdown
 ;
     
SELECT
  ''['' || title || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompt-detail-complaince-hipaa.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "title",
  

  frontmatter_summary as "Summary",
  uri as "URI"

 
FROM ai_ctxe_view_uniform_resource_complaince where regime=''HIPAA''
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompt-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Prompt'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts.sql'' as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''Prompt Details'' AS contents;
      SELECT ''text'' as component,
     ''This page displays comprehensive details about the selected AI Context Engineering prompt, including its frontmatter metadata (such as title, summary, lifecycle, and provenance), reviewers, product features, and the full prompt content. Use the sections below to explore the prompt’s information and related resources.'' as contents;

      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
       ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
 
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,

       ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_prompts p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
     
select
''Home'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
select
''AI Context Engineering Overview'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
select
''Ingest Health'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
select ''Files'' as title;
     
select
''table'' as component,
TRUE AS sort,
TRUE AS search,
''filename'' as markdown;
     
select
''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompt-detail-all.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "filename",
created_at as "Created At"
from ai_ctxe_uniform_resource_prompts;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-with-content-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
     
select
''Home'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
select
''AI Context Engineering Overview'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
select
''Ingest Health'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
select ''Files'' as title;
     
select
''table'' as component,
TRUE AS sort,
TRUE AS search,
''filename'' as markdown;
     
select
''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-detail-all.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "filename",
created_at as "Created At"
from ai_ctxe_uniform_resource_with_content;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompt-detail-all.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Ingest Health'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
      select ''Files'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-list.sql'' as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''File Details'' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
      ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_prompts p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-detail-all.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Ingest Health'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
      select ''Files'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-list.sql'' as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_with_content
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''File Details'' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
     ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_with_content p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-with-frontmatter-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
     
select
''Home'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
select
''AI Context Engineering Overview'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
select
''Ingest Health'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
select ''Files'' as title;
     
select
''table'' as component,
TRUE AS sort,
TRUE AS search,
''filename'' as markdown;
     
select
''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-detail-all-frontmatter.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "filename",
created_at as "Created At"
from ai_ctxe_uniform_resource_with_frontmatter;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-detail-all-frontmatter.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Ingest Health'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
      select ''Files'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-list.sql'' as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_with_content
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''File Details'' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
      ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_with_frontmatter p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/risk.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Risk'' as title;
     
      -- QA Risk Panel Card
      SELECT ''card'' AS component, ''Risk / QA Panel'' AS title;
     SELECT ''text'' as component,
''This page highlights potential risks and quality issues within the AI context ingestion pipeline. Review invalid frontmatter, duplicate or unordered merge groups, and oversized files to ensure prompt quality and system reliability.'' as contents;

      -- Risk summary table
      select
      ''big_number'' as component,
      3 as columns,
      ''colorfull_dashboard'' as id;
     
      select
      ''Invalid Frontmatter'' AS title,
      (SELECT count_empty_frontmatter
      FROM ai_ctxe_uniform_resource_risk_view
      ) as value,
      ''red'' as color,
      ''/ai-context-engineering/file-without-frontmatter.sql'' as value_link,
      TRUE as value_link_new_tab;
     
      -- === Duplicate merge group ===
      SELECT
      ''Duplicate or Missing Order in Merge Groups'' AS title,
      (
      SELECT count_grouped_resources
      FROM ai_ctxe_uniform_resource_risk_view
      ) AS value,
      ''red'' AS color,
      ''/ai-context-engineering/file-with-merge-group-risk-list.sql'' as value_link,
      TRUE as value_link_new_tab;
     
      -- === FILES OVERSIZED ===
      SELECT
      ''Oversized Files (> 1MB)'' AS title,
      (
      SELECT count_large_files
      FROM ai_ctxe_uniform_resource_risk_view
      ) AS value,
      ''orange'' AS color,
      ''/ai-context-engineering/file-oversized-list.sql'' as value_link;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/time-range-file-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Ingest Health'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
      select ''Files'' as title, ''#'' as link;
     
      SELECT ''title'' AS component, ''File Details'' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
      ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
 **Merge group** : '' || a.frontmatter_merge_group AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_all_files p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-without-frontmatter.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Risk'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/risk.sql'' as link;
     
      Select ''Files'' as title, ''#'' as link;
      SELECT ''text'' as component,
''This page lists ingested files that are missing frontmatter metadata. These files may require manual inspection or correction to be fully processed and included in the AI context engineering pipeline.'' as contents;

     
      select
      ''table'' as component,
      TRUE AS sort,
      TRUE AS search,
      ''filename'' as markdown;
     
      select
      ''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-detail-without-frontmatter.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "filename",
      uri as "URI",
      nature as "Nature"
      from ai_ctxe_uniform_resource_transformed_resources_cleaned;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-detail-without-frontmatter.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Risk'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/risk.sql'' as link;
     
      Select ''Files'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-without-frontmatter.sql'' as link;
     
      select filename as title,
      ''#'' as link
      from ai_ctxe_uniform_resource_transformed_resources_cleaned
      where uniform_resource_id = $uniform_resource_id;
     
       -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
       ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
 
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
 
     
      SELECT ''card'' as component, 1 as columns;
     
      SELECT
      ''
'' || p.body_content AS description_md
      FROM ai_ctxe_uniform_resource_transformed_resources_cleaned p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-oversized-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
     
select
''Home'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
select
''AI Context Engineering Overview'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
select
''Risk'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/risk.sql'' as link;
     
Select ''Files'' as title, ''#'' as link;
     
select
''table'' as component,
TRUE AS sort,
TRUE AS search,
''filename'' as markdown;
     
select
''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-detail-oversize.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "filename",
uri as "URI",
nature as "Nature"
from ai_ctxe_uniform_resource_oversized_list;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-detail-oversize.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Risk'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/risk.sql'' as link;
     
      Select ''Files'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-oversized-list.sql'' as link;
     
      select filename as title,
      ''#'' as link
      from ai_ctxe_uniform_resource_oversized_list
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''File Details'' AS contents;
     
      SELECT ''card'' as component, 1 as columns;
     
      SELECT
      ''
'' || p.content AS description_md
      FROM ai_ctxe_uniform_resource_oversized_list p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-with-merge-group-risk-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Risk'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/risk.sql'' as link;
     
      Select ''Files'' as title, ''#'' as link;
     
       SELECT ''title''AS component, 
     ''Missing Order'' as contents;
      SELECT ''text'' as component,
''This page lists files with merge group configuration issues, such as duplicate entries or missing order values. These risks may affect the correct merging and sequencing of prompts within the AI context pipeline.'' as contents;


     
      select
      ''table'' as component,
      TRUE AS sort,
      TRUE AS search,
      ''filename'' as markdown;
     
      select
      ''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-detail-merge-group-risk.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "filename",
      uri as "URI",
      nature as "Nature"
      from ai_ctxe_uniform_resource_merge_group_risks;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-detail-merge-group-risk.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Risk'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/risk.sql'' as link;
     
      Select ''Files'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-with-merge-group-risk-list.sql'' as link;
     
      select filename as title,
      ''#'' as link
      from ai_ctxe_uniform_resource_merge_group_risks
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''File Details'' AS contents;
 
      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
       ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
 
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' as component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_merge_group_risks p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompts-anythingllm.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Prompt'' as title;
      SELECT ''title''AS component, 
     ''Prompt'' as contents;

      SELECT ''text'' as component,
''This page lists AI context engineering prompts designed for use with AnythingLLM. Each entry includes metadata such as function, audience, and summary to help evaluate its suitability for specific LLM use cases.'' as contents;

     
      SELECT
      ''table'' as component,
      TRUE AS sort,
      TRUE AS search,
      "title" as markdown;
     
      SELECT
      ''['' || title || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompt-detail-anythingllm.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "title",
      frontmatter_artifact_nature as "Artifact nature",
      frontmatter_function as "Function",
      frontmatter_audience as "Audience",
      frontmatter_summary as "Summary",
      uri as "URI"
      from ai_ctxe_uniform_resource_frontmatter_view_anythingllm;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompt-detail-anythingllm.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Prompt'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-anythingllm.sql'' as link;
     
      select
      "title" as title,
      "#" as link
      from uniform_resource_build_anythingllm
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''Prompt Details'' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
       ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
 
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view_anythingllm a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM uniform_resource_build_anythingllm p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-with-valid-frontmatter-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
     
select
''Home'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
select
''AI Context Engineering Overview'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
select
''Ingest Health'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
select ''Files'' as title;
     
select
''table'' as component,
TRUE AS sort,
TRUE AS search,
''filename'' as markdown;
     
select
''['' || filename || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-detail-all-frontmatter-valid.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "filename",
created_at as "Created At"
from ai_ctxe_uniform_resource_transformed_resources_valid;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/file-detail-all-frontmatter-valid.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Ingest Health'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/ingest-health.sql'' as link;
     
      select ''Files'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/file-with-valid-frontmatter-list.sql'' as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_with_content
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''File Details'' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **Lifecycle** : '' || a.frontmatter_lifecycle AS description_md,
      ''
 **Product name** : '' || a.frontmatter_product_name AS description_md,
      ''
 **Provenance source uri** : '' || a.frontmatter_provenance_source_uri AS description_md,
     ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,
      ''
 **Reviewers** : '' || a.frontmatter_reviewers AS description_md,
      ''
 **Product features** : '' || a.frontmatter_product_features AS description_md,
      ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_with_frontmatter p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompts-complaince-soc.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              select
''breadcrumb'' as component;
     
select
''Home'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
select
''AI Context Engineering Overview'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
select
''SOC2 Type I'' as title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-soc.sql'' as link;
select
''card'' as component,
3 as columns;

select
''## Total Counts of SOC2 Type I Prompt Modules'' as description_md,
''white'' as background_color,
''## '' || count(DISTINCT uniform_resource_id) as description_md,
''12'' as width,
''pink'' as color,
''timeline-event'' as icon,
''background-color: #FFFFFF'' as style,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-soc2-typeI.sql'' as link
FROM ai_ctxe_view_uniform_resource_complaince where regime=''SOC2'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompts-complaince-soc2-typeI.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
      select
      ''SOC2 Type I'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-soc.sql'' as link;
     
      select
      ''Prompt'' as title,
      ''#'' as link;
      SELECT ''title''AS component, 
     ''Prompt'' as contents; 
       SELECT ''text'' as component,
''This page provides an overview of SOC2 Type I compliance-focused AI context engineering prompts. It includes a summary of each prompt, and a searchable, sortable table with links to detailed prompt pages. Each entry highlights the prompt’s title, a short description, and its source URI, enabling quick access to compliance-related resources.'' as contents;

   
     

 
SELECT
  ''table'' as component,
  TRUE AS sort,
  TRUE AS search,
  "title" as markdown
 ;
     
SELECT
  ''['' || title || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompt-detail-complaince-soc2I.sql'' || ''?uniform_resource_id='' || uniform_resource_id || '')'' as "title",
  

  frontmatter_summary as "Summary",
  uri as "URI"

 
FROM ai_ctxe_view_uniform_resource_complaince where regime=''SOC2''
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/validation-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Prompt'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts.sql'' as link;
     
      select
      "Validation" as title,
      "#" as link
      from ai_ctxe_uniform_resource_frontmatter_view
      where uniform_resource_id = $uniform_resource_id;
       select
      ''card'' as component,
      1 as columns;
     SELECT
      ''
'' || p.elaboration_warning AS description_md
      
      from ai_ctxe_uniform_resource_frontmatter_view p
      where p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompt-detail-complaince-hipaa.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
     
      select
      ''Complaince Prompt'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-hipaa.sql'' as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''Prompt Details'' AS contents;
      SELECT ''text'' as component,
     ''This page provides detailed compliance prompt information from AI Context Engineering. 
 It displays the selected prompt’s metadata (including title, control question, control ID, 
 domain, SCF mapping, summary, publish date, category, satisfies frameworks, and provenance dependencies), 
 along with its merge group reference and full prompt content.'' as contents;

      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
       ''
 **Control question** : '' || a.frontmatter_control_question AS description_md,
       ''
 **Control id** : '' || a.frontmatter_control_id AS description_md,
         ''
 **Control domain** : '' || a.frontmatter_control_domain AS description_md,
           ''
 **SCF control** : '' || a.SCF_control AS description_md,

      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **publishDate** : '' || a.publishDate AS description_md,
      ''
 **category** : '' || a.frontmatter_category AS description_md,
      ''
 **Satisfies** : '' || a.frontmatter_satisfies AS description_md,
       ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,

        ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ai-context-engineering/prompt-detail-complaince-soc2I.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      select
      ''breadcrumb'' as component;
     
      select
      ''Home'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
     
      select
      ''AI Context Engineering Overview'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/index.sql'' as link;
      select
      ''SOC2 Type I'' as title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-soc.sql'' as link;
     
      select
      ''Prompt'' as title,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/prompts-complaince-soc2-typeI.sql'' as link;

     

     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT ''title'' AS component, ''Prompt Details'' AS contents;
      SELECT ''text'' as component,
     ''This page provides detailed SOC2 TypeI compliance prompt information from AI Context Engineering. 
 It displays the selected prompt’s metadata (including title, control question, control ID, 
 domain, SCF mapping, summary, publish date, category, satisfies frameworks, and provenance dependencies), 
 along with its merge group reference and full prompt content.'' as contents;

      -- First card for accordion (frontmatter details)
      SELECT ''html'' AS component,
      ''<details open>
      <summary>Frontmatter details</summary>
      <div>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
 **Title** : '' || a.title AS description_md,
       ''
 **Control question** : '' || a.frontmatter_control_question AS description_md,
       ''
 **Control id** : '' || a.frontmatter_control_id AS description_md,
         ''
 **Control domain** : '' || a.frontmatter_control_domain AS description_md,
           ''
 **SCF control** : '' || a.SCF_control AS description_md,

      ''
 **Summary** : '' || a.frontmatter_summary AS description_md,
      ''
 **publishDate** : '' || a.publishDate AS description_md,
      ''
 **category** : '' || a.frontmatter_category AS description_md,
      ''
 **Satisfies** : '' || a.frontmatter_satisfies AS description_md,
       ''
**Provenance dependencies**:
'' ||
  ifnull((
    SELECT group_concat(''- '' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), ''None'')
  AS description_md,

        ''
Merge group: ['' || a.frontmatter_merge_group || '']('' || 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ai-context-engineering/merge-group-detail.sql'' || 
  ''?uniform_resource_id='' || uniform_resource_id || '')'' 
  AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT ''html'' AS component, ''</div></details>'' AS html;
     
      SELECT ''card'' AS component, 1 as columns;
     
      SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince p
      WHERE p.uniform_resource_id = $uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
