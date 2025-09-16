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


