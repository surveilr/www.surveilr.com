CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
    "key" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL
);
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('SQL', 'SQLite SQL Statements', NULL, 'application/sql', '.sql', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JFC1V424TVCAS90SZQK2HE0T', 'SQL', 'osquery', 'infoSchemaOsQueryATCs', NULL, 'WITH table_columns AS (
    SELECT m.tbl_name AS table_name,
           group_concat(c.name) AS column_names_for_select,
           json_group_array(c.name) AS column_names_for_atc_json
      FROM sqlite_master m,
           pragma_table_info(m.tbl_name) c
     WHERE m.type = ''table''
  GROUP BY m.tbl_name
),
target AS (
  -- set SQLite parameter :osquery_atc_path to assign a different path
  SELECT COALESCE(SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''infoSchemaOsQueryATCs_path'';, ''No infoSchemaOsQueryATCs_path argument supplied in session_state_ephemeral'') AS path
),
table_query AS (
    SELECT table_name,
           ''SELECT '' || column_names_for_select || '' FROM '' || table_name AS query,
           column_names_for_atc_json
      FROM table_columns
)
SELECT json_object(''auto_table_construction'',
          json_group_object(
              table_name,
              json_object(
                  ''query'', query,
                  ''columns'', json(column_names_for_atc_json),
                  ''path'', path
              )
          )
       ) AS osquery_auto_table_construction
  FROM table_query, target;', 'dd4945f0479dd77d540c64f2e745d139cb1a3a06', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
