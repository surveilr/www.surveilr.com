DROP VIEW IF EXISTS url_data;
CREATE VIEW url_data AS
SELECT distinct uri FROM
 uniform_resource;

DROP VIEW IF EXISTS uniform_resource_summary;
CREATE VIEW uniform_resource_summary AS
SELECT
  COUNT(*) AS total_files_seen,
  COUNT(*) FILTER (WHERE content IS NOT NULL AND LENGTH(TRIM(content)) > 0) AS files_with_content,
  COUNT(*) FILTER (WHERE frontmatter IS NOT NULL AND LENGTH(TRIM(frontmatter)) > 0) AS files_with_frontmatter,
  MIN(last_modified_at) AS oldest_modified_at,
  MAX(last_modified_at) AS youngest_modified_at
FROM uniform_resource
WHERE uri IS NOT NULL;
