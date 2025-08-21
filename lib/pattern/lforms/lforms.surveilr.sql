-- =====================================================================
-- View: uniform_resource_lform_item
--
-- Purpose:
--   Flattens top-level "items" (LHC-Forms) or "item" (FHIR Questionnaire)
--   arrays from JSON form definitions stored in the uniform_resource table.
--   Each row represents a single form item (e.g., question or section),
--   including nested items at any depth.
--
-- Changes in this version:
--   - Recursion now handles BOTH "item" (FHIR) and "items" (LHC-Forms)
--     at any nesting level.
-- =====================================================================

DROP VIEW IF EXISTS uniform_resource_lform_item;

CREATE VIEW uniform_resource_lform_item AS
WITH RECURSIVE
-- Step 1: Start with file metadata + root JSON
base AS (
  SELECT
    uf.uniform_resource_id,
    uf.nature,
    uf.source_path,
    uf.file_path_rel,
    uf.size_bytes,
    ur.uri,
    CAST(ur.content AS TEXT) AS content_json
  FROM uniform_resource_file uf
  JOIN uniform_resource ur
    ON ur.uniform_resource_id = uf.uniform_resource_id
),
-- Step 2: Seed recursion with top-level item arrays from LHC-Forms and FHIR
items_recursive AS (
  -- Root-level LHC-Forms items
  SELECT
    b.uniform_resource_id,
    b.nature,
    b.source_path,
    b.file_path_rel,
    b.size_bytes,
    b.uri,
    b.content_json,
    je.value AS item_obj
  FROM base b
  JOIN json_each(b.content_json, '$.items') AS je
  WHERE json_type(je.value) = 'object'

  UNION ALL

  -- Root-level FHIR Questionnaire items
  SELECT
    b.uniform_resource_id,
    b.nature,
    b.source_path,
    b.file_path_rel,
    b.size_bytes,
    b.uri,
    b.content_json,
    je.value AS item_obj
  FROM base b
  JOIN json_each(b.content_json, '$.item') AS je
  WHERE json_type(je.value) = 'object'

  UNION ALL

  -- Step 3a: Recursively extract nested FHIR-style "item"
  SELECT
    ir.uniform_resource_id,
    ir.nature,
    ir.source_path,
    ir.file_path_rel,
    ir.size_bytes,
    ir.uri,
    ir.content_json,
    je.value AS item_obj
  FROM items_recursive ir
  JOIN json_each(ir.item_obj, '$.item') AS je
  WHERE json_type(je.value) = 'object'

  UNION ALL

  -- Step 3b: Recursively extract nested LHC-Forms-style "items"
  SELECT
    ir.uniform_resource_id,
    ir.nature,
    ir.source_path,
    ir.file_path_rel,
    ir.size_bytes,
    ir.uri,
    ir.content_json,
    je.value AS item_obj
  FROM items_recursive ir
  JOIN json_each(ir.item_obj, '$.items') AS je
  WHERE json_type(je.value) = 'object'
)
-- Step 4: Extract metadata from every item found
SELECT
  uniform_resource_id,
  file_path_rel,
  /* Form name/title from the root JSON */
  COALESCE(
    json_extract(content_json, '$.name'),
    json_extract(content_json, '$.title'),
    json_extract(content_json, '$.id'),
    json_extract(content_json, '$.code.text'),
    json_extract(content_json, '$.code')
  ) AS lform_name,
  /* Top-level or nested item identifier */
  COALESCE(
    json_extract(item_obj, '$.questionCode'),
    json_extract(item_obj, '$.linkId')
  ) AS item_id,
  json_extract(item_obj, '$.dataType') AS data_type,
  json_extract(item_obj, '$.name') AS item_name,
  json_extract(item_obj, '$.code') AS item_code,
  json_extract(item_obj, '$.question') AS item_question,
  json_extract(item_obj, '$.label') AS item_label,
  json_extract(item_obj, '$.text') AS item_text,
  json_extract(item_obj, '$.value') AS item_value,
  json_extract(item_obj, '$.responseAEI.evaluation.criteria.nature') AS response_aei_nature,
  json_extract(item_obj, '$.responseAEI') AS response_aei
FROM items_recursive
WHERE item_id IS NOT NULL;

DROP VIEW IF EXISTS uniform_resource_lform_item_grouped;

CREATE VIEW uniform_resource_lform_item_grouped AS
WITH ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY item_id
      ORDER BY 
        CASE WHEN item_value IS NOT NULL THEN 0 ELSE 1 END,  -- Prefer item_value not null
        uniform_resource_id                                    -- Stable order
    ) AS rn
  FROM uniform_resource_lform_item
)
SELECT
  -- uniform_resource_id: from the preferred row (rn=1)
  (SELECT uniform_resource_id 
   FROM ranked r2 
   WHERE r2.item_id = r.item_id 
     AND r2.rn = 1) AS uniform_resource_id,

  -- lform_name: first non-null
  MAX(lform_name) AS lform_name,

  item_id,

  -- data_type: first non-null
  MAX(data_type) AS data_type,

  -- item_name
  MAX(item_name) AS item_name,

  -- item_code
  MAX(item_code) AS item_code,

  -- item_question: first non-null
  MAX(item_question) AS item_question,

  -- item_label
  MAX(item_label) AS item_label,

  -- item_text: first non-null
  MAX(item_text) AS item_text,

  -- item_value: first non-null
  MAX(item_value) AS item_value,

  -- response_aei_nature: first non-null
  MAX(response_aei_nature) AS response_aei_nature,

  -- response_aei: first non-null
  MAX(response_aei) AS response_aei

FROM ranked r
GROUP BY item_id;

