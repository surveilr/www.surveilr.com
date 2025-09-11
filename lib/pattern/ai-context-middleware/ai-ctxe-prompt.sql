DROP VIEW IF EXISTS ai_ctxe_prompt;
CREATE VIEW ai_ctxe_prompt AS
SELECT
  ur.uniform_resource_id,
  json_extract(ur.frontmatter, '$.merge-group') AS merge_group,
  COALESCE(json_extract(ur.frontmatter, '$.order'), 999999) AS ord,
ur.content  AS body_text
FROM
  uniform_resource ur
JOIN
  ur_ingest_session_fs_path_entry fs
  ON fs.uniform_resource_id = ur.uniform_resource_id
WHERE
  (fs.file_basename LIKE '%.prompt.md' OR fs.file_basename LIKE '%.prompt-snippet.md');