-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
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
    ('prime', 'console/index.sql', 2, 'console/about.sql', 'console/about.sql', 'Resource Surveillance Details', 'About', NULL, 'Detailed information about the underlying surveilr binary', NULL)
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
-- delete all /drh-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE parent_path="drh/index.sql";
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'drh/index.sql', 'drh/index.sql', 'DRH Edge UI Home', NULL, NULL, 'Welcome to Diabetes Research Hub Edge UI', NULL),
    ('prime', 'drh/index.sql', 4, 'drh/researcher-related-data/index.sql', 'drh/researcher-related-data/index.sql', 'Researcher And Associated Information', 'Researcher And Associated Information', NULL, 'Researcher And Associated Information', NULL),
    ('prime', 'drh/index.sql', 5, 'drh/study/index.sql', 'drh/study/index.sql', 'Study and Participant Information', 'Study and Participant Information', NULL, 'Study and Participant Information', NULL),
    ('prime', 'drh/index.sql', 5, 'drh/study-related-data/index.sql', 'drh/study-related-data/index.sql', 'Study and Participant Information', 'Study and Participant Information', NULL, 'Study and Participant Information', NULL),
    ('prime', 'drh/index.sql', 6, 'drh/uniform-resource-participant.sql', 'drh/uniform-resource-participant.sql', 'Uniform Resource Participant', NULL, NULL, 'Participant demographics with pagination', NULL),
    ('prime', 'drh/index.sql', 7, 'drh/author-pub-data/index.sql', 'drh/author-pub-data/index.sql', 'Author Publication Information', 'Author Publication Information', NULL, 'Author Publication Information', NULL),
    ('prime', 'drh/index.sql', 8, 'drh/deidentification-log/index.sql', 'drh/deidentification-log/index.sql', 'PHI DeIdentification Results', 'PHI DeIdentification Results', NULL, 'PHI DeIdentification Results', NULL),
    ('prime', 'drh/index.sql', 21, 'drh/cgm-combined-data/index.sql', 'drh/cgm-combined-data/index.sql', 'Combined CGM Tracing', 'Combined CGM Tracing', NULL, 'Combined CGM Tracing', NULL),
    ('prime', 'drh/index.sql', 9, 'drh/cgm-associated-data/index.sql', 'drh/cgm-associated-data/index.sql', 'CGM File MetaData Information', 'CGM File MetaData Information', NULL, 'CGM File MetaData Information', NULL),
    ('prime', 'drh/index.sql', 10, 'drh/cgm-data/index.sql', 'drh/cgm-data/index.sql', 'Raw CGM Data', 'Raw CGM Data', NULL, 'Raw CGM Data', NULL),
    ('prime', 'drh/index.sql', 11, 'drh/ingestion-log/index.sql', 'drh/ingestion-log/index.sql', 'Study Files', 'Study Files', NULL, 'Study Files', NULL),
    ('prime', 'drh/index.sql', 20, 'drh/participant-info/index.sql', 'drh/participant-info/index.sql', 'Participant Information', 'Participant Information', NULL, 'The Participants Detail page is a comprehensive report that includes glucose statistics, such as the Ambulatory Glucose Profile (AGP), Glycemia Risk Index (GRI), Daily Glucose Profile, and all other metrics data.', NULL),
    ('prime', 'drh/index.sql', 12, 'drh/study-participant-dashboard/index.sql', 'drh/study-participant-dashboard/index.sql', 'Study Participant Dashboard', 'Study Participant Dashboard', NULL, 'Study Participant Dashboard', NULL),
    ('prime', 'drh/index.sql', 13, 'drh/verification-validation-log/index.sql', 'drh/verification-validation-log/index.sql', 'Verfication And Validation Results', 'Verfication And Validation Results', NULL, 'Verfication And Validation Results', NULL),
    ('prime', 'drh/index.sql', 19, 'drh/participant-related-data/index.sql', 'drh/participant-related-data/index.sql', 'Participant Information', 'Participant Information', NULL, NULL, NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Diabetes Research Hub Edge",
  "icon": "",
  "favicon": "https://drh.diabetestechnology.org/_astro/favicon.CcrFY5y9.ico",
  "image": "https://drh.diabetestechnology.org/images/diabetic-research-hub-logo.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "/",
  "menu_item": [
    {
      "link": "/",
      "title": "Home"
    }
  ],
  "javascript": [
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js",
    "https://app.devl.drh.diabetestechnology.org/js/d3-aide.js",
    "/js/chart-component.js"
  ],
  "javascript_module": [
    "https://app.devl.drh.diabetestechnology.org/js/wc/d3/stacked-bar-chart.js",
    "https://app.devl.drh.diabetestechnology.org/js/wc/d3/gri-chart.js",
    "https://app.devl.drh.diabetestechnology.org/js/wc/d3/dgp-chart.js",
    "https://app.devl.drh.diabetestechnology.org/js/wc/d3/agp-chart.js",
    "https://app.devl.drh.diabetestechnology.org/js/wc/formula-component.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT ''shell'' AS component,
       ''Diabetes Research Hub Edge'' AS title,
       NULL AS icon,
       ''https://drh.diabetestechnology.org/_astro/favicon.CcrFY5y9.ico'' AS favicon,
       ''https://drh.diabetestechnology.org/images/diabetic-research-hub-logo.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''/'' AS link,
       ''{"link":"/","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       ''https://app.devl.drh.diabetestechnology.org/js/d3-aide.js'' AS javascript,
       ''/js/chart-component.js'' AS javascript,
       json_object(
            ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''ur'',
            ''title'', ''Uniform Resource'',      
            ''target'', '''',      
            ''submenu'', (
                SELECT json_group_array(
                    json_object(
                        ''title'', title,
                        ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                        ''description'', description,
                        ''target'', target                      
                    )
                )
                FROM (
                    SELECT
                        COALESCE(abbreviated_caption, caption) as title,
                        COALESCE(url, path) as link,
                        description,
                        elaboration as target
                    FROM sqlpage_aide_navigation
                    WHERE namespace = ''prime'' AND parent_path = ''ur/index.sql''
                    ORDER BY sibling_order
                )
            )
        ) as menu_item,
       json_object(
            ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''console'',
            ''title'', ''Console'',      
            ''target'', '''',      
            ''submenu'', (
                SELECT json_group_array(
                    json_object(
                        ''title'', title,
                        ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                        ''description'', description,
                        ''target'', target                      
                    )
                )
                FROM (
                    SELECT
                        COALESCE(abbreviated_caption, caption) as title,
                        COALESCE(url, path) as link,
                        description,
                        elaboration as target
                    FROM sqlpage_aide_navigation
                    WHERE namespace = ''prime'' AND parent_path = ''console/index.sql''
                    ORDER BY sibling_order
                )
            )
        ) as menu_item,
       json_object(
            ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''orchestration'',
            ''title'', ''Orchestration'',      
            ''target'', '''',      
            ''submenu'', (
                SELECT json_group_array(
                    json_object(
                        ''title'', title,
                        ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                        ''description'', description,
                        ''target'', target                      
                    )
                )
                FROM (
                    SELECT
                        COALESCE(abbreviated_caption, caption) as title,
                        COALESCE(url, path) as link,
                        description,
                        elaboration as target
                    FROM sqlpage_aide_navigation
                    WHERE namespace = ''prime'' AND parent_path = ''orchestration/index.sql''
                    ORDER BY sibling_order
                )
            )
        ) as menu_item,
       json_object(
            ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''https://drh.diabetestechnology.org/'',
            ''title'', ''DRH Home'',      
            ''target'', ''__blank'',      
            ''submenu'', (
                SELECT json_group_array(
                    json_object(
                        ''title'', title,
                        ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                        ''description'', description,
                        ''target'', target                      
                    )
                )
                FROM (
                    SELECT
                        COALESCE(abbreviated_caption, caption) as title,
                        COALESCE(url, path) as link,
                        description,
                        elaboration as target
                    FROM sqlpage_aide_navigation
                    WHERE namespace = ''prime'' AND parent_path = ''https://drh.diabetestechnology.org//index.sql''
                    ORDER BY sibling_order
                )
            )
        ) as menu_item,
       json_object(
            ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''https://www.diabetestechnology.org/'',
            ''title'', ''DTS Home'',      
            ''target'', ''__blank'',      
            ''submenu'', (
                SELECT json_group_array(
                    json_object(
                        ''title'', title,
                        ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                        ''description'', description,
                        ''target'', target                      
                    )
                )
                FROM (
                    SELECT
                        COALESCE(abbreviated_caption, caption) as title,
                        COALESCE(url, path) as link,
                        description,
                        elaboration as target
                    FROM sqlpage_aide_navigation
                    WHERE namespace = ''prime'' AND parent_path = ''https://www.diabetestechnology.org//index.sql''
                    ORDER BY sibling_order
                )
            )
        ) as menu_item,
       ''https://app.devl.drh.diabetestechnology.org/js/wc/d3/stacked-bar-chart.js'' AS javascript_module,
       ''https://app.devl.drh.diabetestechnology.org/js/wc/d3/gri-chart.js'' AS javascript_module,
       ''https://app.devl.drh.diabetestechnology.org/js/wc/d3/dgp-chart.js'' AS javascript_module,
       ''https://app.devl.drh.diabetestechnology.org/js/wc/d3/agp-chart.js'' AS javascript_module,
       ''https://app.devl.drh.diabetestechnology.org/js/wc/formula-component.js'' AS javascript_module,
       ''Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), 2) || '')'' as footer;',
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
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
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
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&folder_id='' || $folder_id ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&folder_id='' || $folder_id ||  '')'' ELSE '''' END)
    AS contents_md;
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
      'drh/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/index.sql''
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
      ''card''                      as component,
      ''Welcome to the Diabetes Research Hub Edge UI'' as title,
      1                           as columns;

SELECT
      ''About'' as title,
      ''green''                        as color,
      ''white''                  as background_color,
      ''The Diabetes Research Hub (DRH) addresses a growing need for a centralized platform to manage and analyze continuous glucose monitor (CGM) data.Our primary focus is to collect data from studies conducted by various researchers. Initially, we are concentrating on gathering CGM data, with plans to collect additional types of data in the future.'' as description,
      ''home''                 as icon;

SELECT
      ''card''                  as component,
      ''Files Log'' as title,
      1                     as columns;


SELECT
    ''Study Files Log''  as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/ingestion-log/index.sql'' as link,
    ''This section provides an overview of the files that have been accepted and converted into database format for research purposes'' as description,
    ''book''                as icon,
    ''red''                    as color;

;

SELECT
      ''card''                  as component,
      ''File Verification Results'' as title,
      1                     as columns;

SELECT
    ''Verification Log'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/verification-validation-log/index.sql'' AS link,
    ''Use this section to review the issues identified in the file content and take appropriate corrective actions.'' AS description,
    ''table'' AS icon,
    ''red'' AS color;



SELECT
      ''card''                  as component,
      ''Features '' as title,
      9                     as columns;


SELECT
    ''Study Participant Dashboard''  as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/study-participant-dashboard/index.sql'' as link,
    ''The dashboard presents key study details and participant-specific metrics in a clear, organized table format'' as description,
    ''table''                as icon,
    ''red''                    as color;
;




SELECT
    ''Researcher and Associated Information''  as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/researcher-related-data/index.sql'' as link,
    ''This section provides detailed information about the individuals , institutions and labs involved in the research study.'' as description,
    ''book''                as icon,
    ''red''                    as color;
;

SELECT
    ''Study ResearchSite Details''  as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/study-related-data/index.sql'' as link,
    ''This section provides detailed information about the study , and sites involved in the research study.'' as description,
    ''book''                as icon,
    ''red''                    as color;
;

SELECT
    ''Participant Demographics''  as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/participant-related-data/index.sql'' as link,
    ''This section provides detailed information about the the participants involved in the research study.'' as description,
    ''book''                as icon,
    ''red''                    as color;
;

SELECT
    ''Author and Publication Details''  as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/author-pub-data/index.sql'' as link,
    ''Information about research publications and the authors involved in the studies are also collected, contributing to the broader understanding and dissemination of research findings.'' as description,
     ''book'' AS icon,
    ''red''                    as color;
;



SELECT
    ''CGM Meta Data and Associated information''  as title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/cgm-associated-data/index.sql'' as link,
    ''This section provides detailed information about the CGM device used, the relationship between the participant''''s raw CGM tracing file and related metadata, and other pertinent information.'' as description,
    ''book''                as icon,
    ''red''                    as color;

;


SELECT
    ''Raw CGM Data Description'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/cgm-data/index.sql'' AS link,
    ''Explore detailed information about glucose levels over time, including timestamp, and glucose value.'' AS description,
    ''book''                as icon,
    ''red''                    as color;                

SELECT
    ''Combined CGM Tracing'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/cgm-combined-data/index.sql'' AS link,
    ''Explore the comprehensive CGM dataset, integrating glucose monitoring data from all participants for in-depth analysis of glycemic patterns and trends across the study.'' AS description,
    ''book''                as icon,
    ''red''                    as color;         


SELECT
    ''PHI De-Identification Results'' AS title,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/deidentification-log/index.sql'' AS link,
    ''Explore the results of PHI de-identification and review which columns have been modified.'' AS description,
    ''book''                as icon,
    ''red''                    as color;
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/researcher-related-data/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/researcher-related-data/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/researcher-related-data/index.sql/index.sql'') as contents;
    ;

SELECT
  ''text'' as component,
  ''The Diabetes Research Hub collaborates with a diverse group of researchers or investigators dedicated to advancing diabetes research. This section provides detailed information about the individuals and institutions involved in the research studies.'' as contents;


SELECT
  ''text'' as component,
  ''Researcher / Investigator '' as title;
SELECT
  ''These are scientific professionals and medical experts who design and conduct studies related to diabetes management and treatment. Their expertise ranges from clinical research to data analysis, and they are crucial in interpreting results and guiding future research directions.Principal investigators lead the research projects, overseeing the study design, implementation, and data collection. They ensure the research adheres to ethical standards and provides valuable insights into diabetes management.'' as contents;
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from drh_investigator;

SELECT
  ''text'' as component,
  ''Institution'' as title;
SELECT
  ''The researchers and investigators are associated with various institutions, including universities, research institutes, and hospitals. These institutions provide the necessary resources, facilities, and support for conducting high-quality research. Each institution brings its unique strengths and expertise to the collaborative research efforts.'' as contents;
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from drh_institution;


SELECT
  ''text'' as component,
  ''Lab'' as title;
SELECT
  ''Within these institutions, specialized labs are equipped with state-of-the-art technology to conduct diabetes research. These labs focus on different aspects of diabetes studies, such as glucose monitoring, metabolic analysis, and data processing. They play a critical role in executing experiments, analyzing samples, and generating data that drive research conclusions.'' as contents;
SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT * from drh_lab;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/study/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/study/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/study/index.sql/index.sql'') as contents;
    ;
  SELECT
''text'' as component,
  ''
  In Continuous Glucose Monitoring (CGM) research, studies are designed to evaluate the effectiveness, accuracy, and impact of CGM systems on diabetes management. Each study aims to gather comprehensive data on glucose levels, treatment efficacy, and patient outcomes to advance our understanding of diabetes care.

  ### Study Details

  - **Study ID**: A unique identifier assigned to each study.
  - **Study Name**: The name or title of the study.
  - **Start Date**: The date when the study begins.
  - **End Date**: The date when the study concludes.
  - **Treatment Modalities**: Different treatment methods or interventions used in the study.
  - **Funding Source**: The source(s) of financial support for the study.
  - **NCT Number**: ClinicalTrials.gov identifier for the study.
  - **Study Description**: A description of the study’s objectives, methodology, and scope.

  '' as contents_md;

  SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows,''study_id'' as markdown;
  SELECT 
    format(''[%s](/drh/study-participant-dashboard/index.sql?study_id=%s)'',study_id, study_id) as study_id,      
    study_name,
    start_date,
    end_date,
    treatment_modalities,
    funding_source,
    nct_number,
    study_description  
  from drh_study;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/study-related-data/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/study-related-data/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/study-related-data/index.sql/index.sql'') as contents;
    ;
    SELECT
  ''text'' as component,
  ''
  In Continuous Glucose Monitoring (CGM) research, studies are designed to evaluate the effectiveness, accuracy, and impact of CGM systems on diabetes management. Each study aims to gather comprehensive data on glucose levels, treatment efficacy, and patient outcomes to advance our understanding of diabetes care.

  ### Study Details

  - **Study ID**: A unique identifier assigned to each study.
  - **Study Name**: The name or title of the study.
  - **Start Date**: The date when the study begins.
  - **End Date**: The date when the study concludes.
  - **Treatment Modalities**: Different treatment methods or interventions used in the study.
  - **Funding Source**: The source(s) of financial support for the study.
  - **NCT Number**: ClinicalTrials.gov identifier for the study.
  - **Study Description**: A description of the study’s objectives, methodology, and scope.

  '' as contents_md;

  SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT * from drh_study;


      SELECT
          ''text'' as component,
          ''

## Site Information

Research sites are locations where the studies are conducted. They include clinical settings where participants are recruited, monitored, and data is collected.

### Site Details

  - **Study ID**: A unique identifier for the study associated with the site.
  - **Site ID**: A unique identifier for each research site.
  - **Site Name**: The name of the institution or facility where the research is carried out.
  - **Site Type**: The type or category of the site (e.g., hospital, clinic).

      '' as contents_md;

      SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
      SELECT * from drh_site;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/uniform-resource-participant.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/uniform-resource-participant.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/uniform-resource-participant.sql/index.sql'') as contents;
    ;


SET total_rows = (SELECT COUNT(*) FROM drh_participant );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
      TRUE AS sort,
      TRUE AS search;
SELECT * FROM drh_participant
 LIMIT $limit
OFFSET $offset;

SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/author-pub-data/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/author-pub-data/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/author-pub-data/index.sql/index.sql'') as contents;
    ;

  SELECT
  ''text'' as component,
  ''

## Authors

This section contains information about the authors involved in study publications. Each author plays a crucial role in contributing to the research, and their details are important for recognizing their contributions.

### Author Details

- **Author ID**: A unique identifier for the author.
- **Name**: The full name of the author.
- **Email**: The email address of the author.
- **Investigator ID**: A unique identifier for the investigator the author is associated with.
- **Study ID**: A unique identifier for the study associated with the author.


      '' as contents_md;

  SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT * from drh_author;
  SELECT
  ''text'' as component,
  ''
## Publications Overview

This section provides information about the publications resulting from a study. Publications are essential for sharing research findings with the broader scientific community.

### Publication Details

- **Publication ID**: A unique identifier for the publication.
- **Publication Title**: The title of the publication.
- **Digital Object Identifier (DOI)**: Identifier for the digital object associated with the publication.
- **Publication Site**: The site or journal where the publication was released.
- **Study ID**: A unique identifier for the study associated with the publication.


  '' as contents_md;

  SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT * from drh_publication;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/deidentification-log/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/deidentification-log/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/deidentification-log/index.sql/index.sql'') as contents;
    ;

/*
SELECT
''breadcrumb'' as component;
SELECT
    ''Home'' as title,
    ''index.sql''    as link;
SELECT
    ''DeIdentificationResults'' as title;
    */

SELECT
  ''text'' as component,
  ''DeIdentification Results'' as title;
 SELECT
  ''The DeIdentification Results section provides a view of the outcomes from the de-identification process '' as contents;


SELECT ''table'' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
SELECT input_text as "deidentified column", orch_started_at,orch_finished_at ,diagnostics_md from drh_vw_orchestration_deidentify;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/cgm-combined-data/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/cgm-combined-data/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/cgm-combined-data/index.sql/index.sql'') as contents;
    ;


    SELECT
''text'' as component,
''

The **Combined CGM Tracing** refers to a consolidated dataset of continuous glucose monitoring (CGM) data, collected from multiple participants in a research study. CGM devices track glucose levels at regular intervals throughout the day, providing detailed insights into the participants'''' glycemic control over time.

In a research study, this combined dataset is crucial for analyzing glucose trends across different participants and understanding overall patterns in response to interventions or treatments. The **Combined CGM Tracing** dataset typically includes:
- **Participant ID**: A unique identifier for each participant, ensuring the data is de-identified while allowing for tracking individual responses.
- **Date_Time**: The timestamp for each CGM reading, formatted uniformly to allow accurate time-based analysis.(YYYY-MM-DD HH:MM:SS)
- **CGM_Value**: The recorded glucose level at each time point, often converted to a standard unit (e.g., mg/dL or mmol/L) and stored as a real number for precise calculations.

This combined view enables researchers to perform comparative analyses, evaluate glycemic variability, and assess overall glycemic control across participants, which is essential for understanding the efficacy of treatments or interventions in the study. By aggregating data from multiple sources, researchers can identify population-level trends while maintaining the integrity of individual data. 

'' as contents_md;

SET total_rows = (SELECT COUNT(*) FROM combined_cgm_tracing );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;
SELECT * FROM combined_cgm_tracing 
LIMIT $limit
OFFSET $offset;

SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/cgm-associated-data/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/cgm-associated-data/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/cgm-associated-data/index.sql/index.sql'') as contents;
    ;

      /*SELECT
  ''breadcrumb'' as component;
  SELECT
      ''Home'' as title,
      ''index.sql''    as link;
  SELECT
      ''CGM File Meta Data'' as title;
      */



    SELECT
''text'' as component,
''

CGM file metadata provides essential information about the Continuous Glucose Monitoring (CGM) data files used in research studies. This metadata is crucial for understanding the context and quality of the data collected.

### Metadata Details

- **Metadata ID**: A unique identifier for the metadata record.
- **Device Name**: The name of the CGM device used to collect the data.
- **Device ID**: A unique identifier for the CGM device.
- **Source Platform**: The platform or system from which the CGM data originated.
- **Patient ID**: A unique identifier for the patient from whom the data was collected.
- **File Name**: The name of the uploaded CGM data file.
- **File Format**: The format of the uploaded file (e.g., CSV, Excel).
- **File Upload Date**: The date when the file was uploaded to the system.
- **Data Start Date**: The start date of the data period covered by the file.
- **Data End Date**: The end date of the data period covered by the file.
- **Study ID**: A unique identifier for the study associated with the CGM data.


'' as contents_md;

SET total_rows = (SELECT COUNT(*) FROM drh_cgmfilemetadata_view );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;
SELECT * FROM drh_cgmfilemetadata_view
LIMIT $limit
OFFSET $offset;

SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/cgm-data/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/cgm-data/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/cgm-data/index.sql/index.sql'') as contents;
    ;

SELECT
''text'' as component,
''
The raw CGM data includes the following key elements.

- **Date_Time**:
The exact date and time when the glucose level was recorded. This is crucial for tracking glucose trends and patterns over time. The timestamp is usually formatted as YYYY-MM-DD HH:MM:SS.
- **CGM_Value**:
The measured glucose level at the given timestamp. This value is typically recorded in milligrams per deciliter (mg/dL) or millimoles per liter (mmol/L) and provides insight into the participant''''s glucose fluctuations throughout the day.'' as contents_md;

SELECT ''table'' AS component,
        ''Table'' AS markdown,
        ''Column Count'' as align_right,
        TRUE as sort,
        TRUE as search;
SELECT ''['' || table_name || ''](raw-cgm/'' || table_name || ''.sql)'' AS "Table"
FROM drh_raw_cgm_table_lst;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/cgm-data/data.sql',
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
    WHERE namespace = ''prime'' AND path=''drh/cgm-data/index.sql''
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

-- Initialize pagination
SET total_rows = (SELECT COUNT(*) FROM $name );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display table with pagination
SELECT ''table'' AS component,
      TRUE AS sort,
      TRUE AS search;
SELECT * FROM $name
LIMIT $limit
OFFSET $offset;

SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/ingestion-log/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/ingestion-log/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/ingestion-log/index.sql/index.sql'') as contents;
    ;

SELECT
  ''text'' as component,
  ''Study Files'' as title;
 SELECT
  ''
  This section provides an overview of the files that have been accepted and converted into database format for research purposes. The conversion process ensures that data from various sources is standardized, making it easier for researchers to analyze and draw meaningful insights.
  Additionally, the corresponding database table names generated from these files are listed for reference.'' as contents;

 SET total_rows = (SELECT COUNT(*) FROM drh_study_files_table_info );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

  SELECT ''table'' AS component,
  TRUE AS sort,
  TRUE AS search;
  SELECT file_name,file_format, table_name FROM drh_study_files_table_info
  LIMIT $limit
  OFFSET $offset;

  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/participant-info/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/participant-info/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/participant-info/index.sql/index.sql'') as contents;
    ;

    SELECT
     ''card''     as component,
     '''' as title,
      1         as columns;
    SELECT 
     ''The Participants Detail page is a comprehensive report that includes glucose statistics, such as the Ambulatory Glucose Profile (AGP), Glycemia Risk Index (GRI), Daily Glucose Profile, and all other metrics data.'' as description;
  
     

    SELECT 
        ''form''            as component,
        ''Filter by Date Range''   as title,
        ''Submit'' as validate,    
        ''Clear''           as reset;
    SELECT 
        ''start_date'' as name,
        ''Start Date'' as label,
         strftime(''%Y-%m-%d'', MIN(Date_Time))  as value, 
        ''date''       as type,
        6            as width,
        ''mt-1'' as class
    FROM     
        combined_cgm_tracing        
    WHERE 
        participant_id = $participant_id;  
    SELECT 
        ''end_date'' as name,
        ''End Date'' as label,
         strftime(''%Y-%m-%d'', MAX(Date_Time))  as value, 
        ''date''       as type,
         6             as width,
         ''mt-1'' as class
    FROM     
        combined_cgm_tracing        
    WHERE 
        participant_id = $participant_id; 



  SELECT
    ''datagrid'' AS component;
  SELECT
      ''MRN: '' || participant_id || '''' AS title,
      '' '' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      ''Study: '' || study_arm || '''' AS title,
      '' '' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  
  SELECT
      ''Age: ''|| age || '' Years'' AS title,
      '' '' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      ''hba1c: '' || baseline_hba1c || '''' AS title,
      '' '' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      ''BMI: ''|| bmi || '''' AS title,
      '' '' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      ''Diabetes Type: ''|| diabetes_type || ''''  AS title,
      '' '' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      strftime(''Generated: %Y-%m-%d %H:%M:%S'', ''now'') AS title,
      '' '' AS description
 
  SELECT    
    ''html'' as component,
      ''<input type="hidden" name="participant_id" class="participant_id" value="''|| $participant_id ||''">'' as html;      
      
    SELECT 
    ''card'' as component,    
    2      as columns;
SELECT 
    '''' AS title,
    ''white'' As background_color,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/glucose-statistics-and-targets/index.sql?_sqlpage_embed&participant_id='' || $participant_id ||
    ''&start_date='' || COALESCE($start_date, participant_cgm_dates.cgm_start_date) ||
    ''&end_date='' || COALESCE($end_date, participant_cgm_dates.cgm_end_date) AS embed
FROM 
    (SELECT participant_id, 
            MIN(Date_Time) AS cgm_start_date, 
            MAX(Date_Time) AS cgm_end_date
     FROM combined_cgm_tracing
     GROUP BY participant_id) AS participant_cgm_dates
WHERE 
    participant_cgm_dates.participant_id = $participant_id;  

         
SELECT 
    '''' as title,
    ''white'' As background_color,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/goals-for-type-1-and-type-2-diabetes/index.sql?_sqlpage_embed&participant_id='' || $participant_id ||
    ''&start_date='' || COALESCE($start_date, participant_cgm_dates.cgm_start_date) ||
    ''&end_date='' || COALESCE($end_date, participant_cgm_dates.cgm_end_date) AS embed
FROM 
    (SELECT participant_id, 
            MIN(Date_Time) AS cgm_start_date, 
            MAX(Date_Time) AS cgm_end_date
     FROM combined_cgm_tracing
     GROUP BY participant_id) AS participant_cgm_dates
WHERE 
    participant_cgm_dates.participant_id = $participant_id;  

SELECT 
    '''' as title,
    ''white'' As background_color,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/ambulatory-glucose-profile/index.sql?_sqlpage_embed&participant_id='' || $participant_id as embed;  
SELECT 
    '''' as title,
    ''white'' As background_color,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/daily-gluecose-profile/index.sql?_sqlpage_embed&participant_id='' || $participant_id as embed;  
SELECT 
    '''' as title,
    ''white'' As background_color,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/glycemic_risk_indicator/index.sql?_sqlpage_embed&participant_id='' || $participant_id as embed;  
  SELECT 
    '''' as title,
    ''white'' As background_color,
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/advanced_metrics/index.sql?_sqlpage_embed&participant_id='' || $participant_id  || 
    ''&start_date='' || COALESCE($start_date, participant_cgm_dates.cgm_start_date) ||
    ''&end_date='' || COALESCE($end_date, participant_cgm_dates.cgm_end_date) AS embed 
    FROM 
        (SELECT participant_id, 
                MIN(Date_Time) AS cgm_start_date, 
                MAX(Date_Time) AS cgm_end_date
        FROM combined_cgm_tracing
        GROUP BY participant_id) AS participant_cgm_dates
    WHERE 
        participant_cgm_dates.participant_id = $participant_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/glucose-statistics-and-targets/index.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
 SELECT  
''html'' as component;
SELECT ''<div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black;">GLUCOSE STATISTICS AND TARGETS</div><div class="px-4">'' as html;
SELECT  
  ''<div class="card-content my-1">''|| strftime(''%Y-%m-%d'', MIN(Date_Time)) || '' - '' ||  strftime(''%Y-%m-%d'', MAX(Date_Time)) || '' <span style="float: right;">''|| CAST(julianday(MAX(Date_Time)) - julianday(MIN(Date_Time)) AS INTEGER) ||'' days</span></div>'' as html
FROM  
    combined_cgm_tracing
WHERE 
    participant_id = $participant_id
 AND Date_Time BETWEEN $start_date AND $end_date;   

SELECT  
  ''<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Time CGM Active</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>'' || ROUND(
    (COUNT(DISTINCT DATE(Date_Time)) / 
    ROUND((julianday(MAX(Date_Time)) - julianday(MIN(Date_Time)) + 1))
    ) * 100, 2) || ''</b> % <formula-component content="This metric calculates the percentage of time during a specific period (e.g., a day, week, or month) that the CGM device is actively collecting data. It takes into account the total duration of the monitoring period and compares it to the duration during which the device was operational and recording glucose readings."></formula-component></div></div></div>'' as html
FROM
  combined_cgm_tracing  
WHERE 
  participant_id = $participant_id
AND Date_Time BETWEEN $start_date AND $end_date;    

SELECT  
  ''<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Number of Days CGM Worn</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>''|| COUNT(DISTINCT DATE(Date_Time)) ||''</b> days<formula-component content="This metric represents the total number of days the CGM device was worn by the user over a monitoring period. It helps in assessing the adherence to wearing the device as prescribed."></formula-component></div></div></div>'' as html
FROM
    combined_cgm_tracing  
WHERE 
    participant_id = $participant_id
AND Date_Time BETWEEN $start_date AND $end_date;

SELECT  
  ''<div class="card-body" style="background-color: #E3E3E2;border: 1px solid black;">
                  <div class="table-responsive">
                    <table class="table">                           
                       <tbody class="table-tbody list">
                       <tr>
                            <th colspan="2" style="text-align: center;">
                              Ranges And Targets For Type 1 or Type 2 Diabetes
                            </th>
                          </tr>
                          <tr> 
                            <th>
                              Glucose Ranges
                            </th>
                            <th>
                              Targets % of Readings (Time/Day)
                            </th>
                          </tr>
                          <tr>
                            <td>Target Range 70-180 mg/dL</td>
                            <td>Greater than 70% (16h 48min)</td>
                          </tr>
                          <tr>
                            <td>Below 70 mg/dL</td>
                            <td>Less than 4% (58min)</td>
                          </tr>
                          <tr>
                            <td>Below 54 mg/dL</td>
                            <td>Less than 1% (14min)</td>
                          </tr>
                          <tr>
                            <td>Above 180 mg/dL</td>
                            <td>Less than 25% (6h)</td>
                          </tr>
                          <tr>
                            <td>Above 250 mg/dL</td>
                            <td>Less than 5% (1h 12min)</td>
                          </tr>
                          <tr>
                            <td colspan="2">Each 5% increase in time in range (70-180 mg/dL) is clinically beneficial.</td>                                
                          </tr>
                       </tbody>
                    </table>
                  </div>
                </div>'' as html; 

SELECT  
  ''<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Mean Glucose</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>''|| ROUND(AVG(CGM_Value), 2) ||''</b> mg/dL<formula-component content="Mean glucose reflects the average glucose level over the monitoring period, serving as an indicator of overall glucose control. It is a simple yet powerful measure in glucose management."></formula-component></div></div></div>'' as html
FROM
  combined_cgm_tracing  
WHERE 
  participant_id = $participant_id
AND Date_Time BETWEEN $start_date AND $end_date;

SELECT  
  ''<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Glucose Management Indicator (GMI)</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>''|| ROUND(AVG(CGM_Value) * 0.155 + 95, 2) ||''</b> %<formula-component content="GMI provides an estimated A1C level based on mean glucose, which can be used as an indicator of long-term glucose control. GMI helps in setting and assessing long-term glucose goals."></formula-component></div></div></div>'' as html
FROM
  combined_cgm_tracing  
WHERE 
  participant_id = $participant_id
AND Date_Time BETWEEN $start_date AND $end_date;
  
SELECT  
  ''<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Glucose Variability</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>''|| ROUND((SQRT(AVG(CGM_Value * CGM_Value) - AVG(CGM_Value) * AVG(CGM_Value)) / AVG(CGM_Value)) * 100, 2) ||''</b> %<formula-component content="Glucose variability measures fluctuations in glucose levels over time, calculated as the coefficient of variation (%CV). A lower %CV indicates more stable glucose control."></formula-component></div></div></div>'' as html   
FROM
  combined_cgm_tracing  
WHERE 
  participant_id = $participant_id
AND Date_Time BETWEEN $start_date AND $end_date;  
  
SELECT  
  ''<div class="card-content my-1">Defined as percent coefficient of variation (%CV); target ≤36%</div></div>'' as html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'js/chart-component.js',
      'async function initializeAgpChart(participant_id, start_date, end_date) {
  const margin = { top: 20, right: 30, bottom: 40, left: 60 };
  const width = 800 - margin.left - margin.right;
  const height = 500 - margin.top - margin.bottom;

  const response = await fetch(
    `/drh/api/ambulatory-glucose-profile/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();
  const agpChart = document.querySelector(''agp-chart'');
  if (
    result.ambulatoryGlucoseProfile &&
    Object.keys(result.ambulatoryGlucoseProfile).length > 0
  ) {
    const data = result.ambulatoryGlucoseProfile;

    agpChart.data = data;
    agpChart.width = width;
    agpChart.height = height;
  } else {
    agpChart.noDataFound = true;
  }
}

async function initializeStackedBarChart(participant_id, start_date, end_date) {
  const response = await fetch(
    `/drh/api/time_range_stacked_metrics/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();
  const timeMetrics = result.timeMetrics;

  const chartHeight = 400;
  const chartWidth = 700;

  const chartdata = [
    {
      category: "Very Low",
      value: timeMetrics.timeBelowRangeVeryLow,
      goal: "<1%",
      color: "#A93226",
    },
    {
      category: "Low",
      value: timeMetrics.timeBelowRangeLow,
      goal: "<4%",
      color: "#E74C3C",
    },
    {
      category: "Target",
      value: timeMetrics.timeInRange,
      goal: "≥70%",
      color: "#27AE60",
    },
    {
      category: "High",
      value: timeMetrics.timeAboveRangeHigh,
      goal: "<25%",
      color: "#F39C12",
    },
    {
      category: "Very High",
      value: timeMetrics.timeAboveRangeVeryHigh,
      goal: "<5%",
      color: "#D35400",
    },
  ];

  const barChart = document.querySelector(''stacked-bar-chart'');
  if(timeMetrics.participant_id) {
    barChart.data = chartdata;
    barChart.chartWidth = chartWidth;
    barChart.chartHeight = chartHeight;
  } else {
    barChart.noDataFound = true;
  }
  
}



async function initializeDgpChart(participant_id, start_date, end_date) {
  await new Promise((resolve) => setTimeout(resolve, 3000)); // Add a 3-second delay

  const response = await fetch(
    `/drh/api/daily-glcuose-profile/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();
  const dgpChart = document.querySelector(''dgp-chart'');

  if (result.daily_glucose_profile.length > 0) {
    dgpChart.result = result.daily_glucose_profile;
  } else {
    dgpChart.noDataFound = true;
  }
}

async function initializeDriChart(participant_id, start_date, end_date) {
  const response = await fetch(
    `/drh/api/glycemic_risk_indicator/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();
  const griData = result.glycemicRiskIndicator;


  const griChart = document.querySelector(''gri-chart'');
  if(griData.GRI) {
    griChart.data = griData;
  } else {
    griChart.noDataFound = true;
  }
  

  assignValues(document.getElementsByClassName("TIR"), griData.time_in_range_percentage);
  assignValues(document.getElementsByClassName("TAR_VH"), griData.time_above_VH_percentage);
  assignValues(document.getElementsByClassName("TAR_H"), griData.time_above_H_percentage);
  assignValues(document.getElementsByClassName("TBR_L"), griData.time_below_low_percentage);
  assignValues(document.getElementsByClassName("TBR_VL"), griData.time_below_VL_percentage);
  assignValues(document.getElementsByClassName("GRI"), griData.GRI);

}

async function initializeAdvanceMetrics(participant_id, start_date, end_date) {
  const response = await fetch(
    `/drh/api/advanced_metrics/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();

  const griData = result.advancedMetrics;
  assignValues(document.getElementsByClassName("timeInTightRangeCdata"), griData.time_in_tight_range_percentage);

}

function assignValues(containers, value) {
  for (const container of containers) {
    container.innerHTML = value;
  }
}

function getValue(containers) {
  for (const container of containers) {
    return container.value;
  }
}

document.addEventListener("DOMContentLoaded", function () {
  for (const container of document.getElementsByClassName("participant_id")) {
    const participant_id = container.value;
    const start_date = getValue(document.getElementsByClassName("start_date"));
    const end_date = getValue(document.getElementsByClassName("end_date"));
    initializeStackedBarChart(participant_id, start_date, end_date);
    initializeAgpChart(participant_id, start_date, end_date);
    initializeDgpChart(participant_id, start_date, end_date);
    initializeDriChart(participant_id, start_date, end_date);
    initializeAdvanceMetrics(participant_id, start_date, end_date);
  }
});
',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/api/time_range_stacked_metrics/index.sql',
      '          -- not including shell
          -- not including breadcrumbs from sqlpage_aide_navigation
          -- not including page title from sqlpage_aide_navigation
          

          SELECT ''json'' AS component, 
JSON_OBJECT(
    ''timeMetrics'', (
        SELECT 
            JSON_OBJECT(
                ''participant_id'', participant_id, 
                ''timeBelowRangeLow'', CAST(COALESCE(SUM(CASE WHEN CGM_Value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                ''timeBelowRangeVeryLow'', CAST(COALESCE(SUM(CASE WHEN CGM_Value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                ''timeInRange'', CAST(COALESCE(SUM(CASE WHEN CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                ''timeAboveRangeVeryHigh'', CAST(COALESCE(SUM(CASE WHEN CGM_Value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                ''timeAboveRangeHigh'', CAST(COALESCE(SUM(CASE WHEN CGM_Value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER) 
            )
        FROM 
            combined_cgm_tracing
        WHERE 
            participant_id = $participant_id    
        AND Date_Time BETWEEN $start_date AND $end_date
    )
) AS contents;
        ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/goals-for-type-1-and-type-2-diabetes/index.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''html'' as component,
''<input type="hidden" name="start_date" class="start_date" value="''|| $start_date ||''">
<input type="hidden" name="end_date" class="end_date" value="''|| $end_date ||''">
<div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">Goals for Type 1 and Type 2 Diabetes <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="Goals for Type 1 and Type 2 Diabetes Chart provides a comprehensive view of a participant&#39;s glucose readings categorized into different ranges over a specified period."></formula-component></div></div>
<stacked-bar-chart class="p-5"></stacked-bar-chart>
'' as html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/api/ambulatory-glucose-profile/index.sql',
      '          -- not including shell
          -- not including breadcrumbs from sqlpage_aide_navigation
          -- not including page title from sqlpage_aide_navigation
          

          SELECT ''json'' AS component, 
JSON_OBJECT(
    ''ambulatoryGlucoseProfile'', (
                WITH glucose_data AS (
      SELECT
          participant_id,
          strftime(''%H'', Date_Time) AS hourValue,
          CGM_Value AS glucose_level
      FROM
          combined_cgm_tracing
      WHERE
          participant_id = $participant_id
      AND Date_Time BETWEEN $start_date AND $end_date
  ),
  percentiles AS (
      SELECT
          participant_id,
          hourValue AS hour,
          MAX(CASE WHEN row_num = CAST(0.05 * total_count AS INT) THEN glucose_level END) AS p5,
          MAX(CASE WHEN row_num = CAST(0.25 * total_count AS INT) THEN glucose_level END) AS p25,
          MAX(CASE WHEN row_num = CAST(0.50 * total_count AS INT) THEN glucose_level END) AS p50,
          MAX(CASE WHEN row_num = CAST(0.75 * total_count AS INT) THEN glucose_level END) AS p75,
          MAX(CASE WHEN row_num = CAST(0.95 * total_count AS INT) THEN glucose_level END) AS p95
      FROM (
          SELECT
              participant_id,
              hourValue,
              glucose_level,
              ROW_NUMBER() OVER (PARTITION BY participant_id, hourValue ORDER BY glucose_level) AS row_num,
              COUNT(*) OVER (PARTITION BY participant_id, hourValue) AS total_count
          FROM
              glucose_data
      ) ranked_data
      GROUP BY
          participant_id, hourValue
  )
  SELECT JSON_GROUP_ARRAY(
            JSON_OBJECT(
                ''participant_id'', participant_id,
                ''hour'', hour,
                ''p5'', COALESCE(p5, 0),
                ''p25'', COALESCE(p25, 0),
                ''p50'', COALESCE(p50, 0),
                ''p75'', COALESCE(p75, 0),
                ''p95'', COALESCE(p95, 0)
            )
        ) AS result
  FROM
      percentiles
  GROUP BY
      participant_id
   

    )
) AS contents;
        ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/ambulatory-glucose-profile/index.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''html'' as component,
''<style>
    .text-\[11px\] { 
        font-size: 11px;  
    }
</style>
<div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">AMBULATORY GLUCOSE PROFILE (AGP) <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="The Ambulatory Glucose Profile (AGP) summarizes glucose monitoring data over a specified period, typically 14 to 90 days. It provides a visual representation of glucose levels, helping to identify patterns and variability in glucose management."></formula-component></div></div>
<agp-chart class="p-5"></agp-chart>
'' as html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/api/daily-glcuose-profile/index.sql',
      '          -- not including shell
          -- not including breadcrumbs from sqlpage_aide_navigation
          -- not including page title from sqlpage_aide_navigation
          

          SELECT ''json'' AS component, 
JSON_OBJECT(
    ''daily_glucose_profile'', (
        SELECT JSON_GROUP_ARRAY(
            JSON_OBJECT(
                ''date_time'', Date_Time, 
                ''date'', strftime(''%Y-%m-%d'', Date_Time), 
                ''hour'', strftime(''%H'', Date_Time),                        
                ''glucose'', CGM_Value                     
            )
        ) 
          FROM
            combined_cgm_tracing
          WHERE
            participant_id = $participant_id
          AND Date_Time BETWEEN $start_date AND $end_date
    )
) AS contents;
        ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/daily-gluecose-profile/index.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    SELECT ''html'' as component,
        ''<style>
    .line {
        fill: none;
        stroke: lightgrey;
        stroke-width: 1px;
    }

    .highlight-area {
        fill: lightgreen;
        opacity: 1;
    }

    .highlight-line {
        fill: none;
        stroke: green;
        stroke-width: 1px;
    }

    .highlight-glucose-h-line {
        fill: none;
        stroke: orange;
        stroke-width: 1px;
    }

    .highlight-glucose-l-line {
        fill: none;
        stroke: red;
        stroke-width: 1px;
    }

    .reference-line {
        stroke: black;
        stroke-width: 1px;
    }

    .vertical-line {
        stroke: rgb(223, 223, 223);
        stroke-width: 1px;
    }

    .day-label {
        font-size: 10px;
        fill: #000;
    }

    .day-label-top {
        font-size: 12px;
        text-anchor: middle;
        fill: #000;
    }

    .axis path,
    .axis line {
        fill: none;
        shape-rendering: crispEdges;
    }

    .mg-dl-label {
        font-size: 14px;
        font-weight: bold;
        text-anchor: middle;
        fill: #000;
        transform: rotate(-90deg);
        transform-origin: left center;
    }

    .horizontal-line {
        stroke: rgb(223, 223, 223);
        stroke-width: 1px;
    }
</style> 
        <div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">DAILY GLUCOSE PROFILE <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="The Ambulatory Glucose Profile (AGP) summarizes glucose monitoring data over a specified period, typically 14 to 90 days. It provides a visual representation of glucose levels, helping to identify patterns and variability in glucose management."></formula-component></div></div>
        <dgp-chart></dgp-chart>
        <p class="py-2 px-4 text-gray-800 font-normal text-xs hidden" id="dgp-note"><b>NOTE:</b> The Daily Glucose
            Profile
            plots the glucose levels of the last 14 days.</p>
    '' as html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/api/glycemic_risk_indicator/index.sql',
      '          -- not including shell
          -- not including breadcrumbs from sqlpage_aide_navigation
          -- not including page title from sqlpage_aide_navigation
          

          SELECT ''json'' AS component, 
JSON_OBJECT(
    ''glycemicRiskIndicator'', (
        SELECT JSON_OBJECT(
                ''time_above_VH_percentage'', ROUND(COALESCE((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                ''time_above_H_percentage'', ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                ''time_in_range_percentage'', ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                ''time_below_low_percentage'', ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                ''time_below_VL_percentage'', ROUND(COALESCE((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                ''Hypoglycemia_Component'', ROUND(COALESCE((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                                      (0.8 * (SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))), 0), 2),
                ''Hyperglycemia_Component'', ROUND(COALESCE((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                                          (0.5 * (SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))), 0), 2),
                ''GRI'', ROUND(COALESCE((3.0 * ((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                            (0.8 * (SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))) + 
                                (1.6 * ((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                        (0.5 * (SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))), 0), 2)
        ) 
          FROM
            combined_cgm_tracing
          WHERE
            participant_id = $participant_id 
          AND Date_Time BETWEEN $start_date AND $end_date
    )
) AS contents;
        ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/glycemic_risk_indicator/index.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''html'' as component,
    ''<style>
    svg {
      display: block;
      margin: auto;
    }
  </style>        
    <div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">Glycemia Risk Index <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="Hypoglycemia Component = VLow + (0.8 × Low)
                    Hyperglycemia Component = VHigh + (0.5 × High)
                    GRI = (3.0 × Hypoglycemia Component) + (1.6 × Hyperglycemia Component)
                    Equivalently,
                    GRI = (3.0 × VLow) + (2.4 × Low) + (1.6 × VHigh) + (0.8 × High)"></formula-component></div></div>
    <div class="px-4 pb-4">
    <gri-chart></gri-chart>'' as html; 
  SELECT ''
    <table class="w-full text-center border">
    <thead>
      <tr class="bg-gray-900">
        <th >TIR</th>
        <th >TAR(VH)</th>
        <th >TAR(H)</th>
        <th >TBR(L)</th>
        <th >TBR(VL)</th>
        <th >TITR</th>
        <th >GRI</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="TIR"></td>
        <td class="TAR_VH"></td>
        <td class="TAR_H"></td>
        <td class="TBR_L"></td>
        <td class="TBR_VL"></td>
        <td class="timeInTightRangeCdata"></td>
        <td class="GRI"></td>
      </tr>
    </tbody> 
  </table>
  </div>
'' as html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/api/advanced_metrics/index.sql',
      '          -- not including shell
          -- not including breadcrumbs from sqlpage_aide_navigation
          -- not including page title from sqlpage_aide_navigation
          

          SELECT ''json'' AS component, 
JSON_OBJECT(
    ''advancedMetrics'', (
        SELECT JSON_OBJECT(
                ''time_in_tight_range_percentage'', round(time_in_tight_range_percentage,3) 
        ) 
          FROM 
            drh_advanced_metrics
          WHERE
            participant_id = $participant_id 
    )
) AS contents;
        ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/advanced_metrics/index.sql',
      '              -- not including shell
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

               SELECT  
''html'' as component;
SELECT
  ''<div class="px-4">'' as html;
SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Liability Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| ROUND(CAST((SUM(CASE WHEN CGM_Value < 70 THEN 1 ELSE 0 END) + SUM(CASE WHEN CGM_Value > 180 THEN 1 ELSE 0 END)) AS REAL) / COUNT(*), 2) ||'' mg/dL<formula-component content="The Liability Index quantifies the risk associated with glucose variability, measured in mg/dL."></formula-component></div></div></div>
  <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Hypoglycemic Episodes <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| SUM(CASE WHEN CGM_Value < 70 THEN 1 ELSE 0 END) ||''<formula-component content="This metric counts the number of occurrences when glucose levels drop below a specified hypoglycemic threshold, indicating potentially dangerous low blood sugar events."></formula-component></div></div></div>
  <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Euglycemic Episodes <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| SUM(CASE WHEN CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) ||''<formula-component content="This metric counts the number of instances where glucose levels remain within the target range, indicating stable and healthy glucose control."></formula-component></div></div></div>
  <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Hyperglycemic Episodes <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| SUM(CASE WHEN CGM_Value > 180 THEN 1 ELSE 0 END) ||''<formula-component content="This metric counts the number of instances where glucose levels exceed a certain hyperglycemic threshold, indicating potentially harmful high blood sugar events."></formula-component></div></div></div>'' as html 
  FROM combined_cgm_tracing 
                WHERE participant_id = $participant_id AND Date(Date_Time) BETWEEN $start_date AND $end_date
                GROUP BY participant_id;
 SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">M Value <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| round((MAX(CGM_Value) - MIN(CGM_Value)) / 
((strftime(''%s'', MAX(DATETIME(Date_Time))) - strftime(''%s'', MIN(DATETIME(Date_Time)))) / 60.0),3) ||'' mg/dL<formula-component content="The M Value provides a measure of glucose variability, calculated from the mean of the absolute differences between consecutive CGM values over a specified period."></formula-component></div></div></div>'' as html   
  FROM combined_cgm_tracing 
                WHERE participant_id = $participant_id AND Date(Date_Time) BETWEEN $start_date AND $end_date
                GROUP BY participant_id;
  SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Mean Amplitude <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| round(AVG(amplitude),3) ||''<formula-component content="Mean Amplitude quantifies the average degree of fluctuation in glucose levels over a given time frame, giving insight into glucose stability."></formula-component></div></div></div>'' as html  
  FROM (SELECT ABS(MAX(CGM_Value) - MIN(CGM_Value)) AS amplitude   
  FROM combined_cgm_tracing  WHERE participant_id = $participant_id AND Date(Date_Time) BETWEEN $start_date AND $end_date   
  GROUP BY DATE(Date_Time) 
  );      

  CREATE TEMPORARY TABLE DailyRisk AS 
  SELECT 
      participant_id, 
      DATE(date_time) AS day, 
      MAX(CGM_Value) - MIN(CGM_Value) AS daily_range 
  FROM 
      combined_cgm_tracing cct 
  WHERE 
      participant_id = $participant_id
      AND DATE(date_time) BETWEEN DATE($start_date) AND DATE($end_date) 
  GROUP BY 
      participant_id, 
      DATE(date_time);

  CREATE TEMPORARY TABLE AverageDailyRisk AS 
  SELECT 
      participant_id, 
      AVG(daily_range) AS average_daily_risk 
  FROM 
      DailyRisk 
  WHERE 
      participant_id = $participant_id
  GROUP BY 
      participant_id;    

  SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Average Daily Risk Range <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| round(average_daily_risk,3) ||'' mg/dL<formula-component content="This metric assesses the average risk associated with daily glucose variations, expressed in mg/dL."></formula-component></div></div></div>'' as html  
  FROM 
      AverageDailyRisk 
  WHERE 
       participant_id = $participant_id;

  DROP TABLE IF EXISTS DailyRisk;
  DROP TABLE IF EXISTS AverageDailyRisk;

  CREATE TEMPORARY TABLE glucose_stats AS 
  SELECT
      participant_id,
      AVG(CGM_Value) AS mean_glucose,
      (AVG(CGM_Value * CGM_Value) - AVG(CGM_Value) * AVG(CGM_Value)) AS variance_glucose
  FROM
      combined_cgm_tracing
  WHERE
      participant_id = $participant_id
      AND DATE(Date_Time) BETWEEN DATE($start_date) AND DATE($end_date) 
  GROUP BY
      participant_id;

  SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">J Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| ROUND(0.001 * (mean_glucose + SQRT(variance_glucose)) * (mean_glucose + SQRT(variance_glucose)), 2) ||'' mg/dL<formula-component content="The J Index calculates glycemic variability using both high and low glucose readings, offering a comprehensive view of glucose fluctuations."></formula-component></div></div></div>'' as html  
  FROM
    glucose_stats;
  DROP TABLE IF EXISTS glucose_stats;

SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Low Blood Glucose Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| ROUND(SUM(CASE WHEN (CGM_Value - 2.5) / 2.5 > 0 
               THEN ((CGM_Value - 2.5) / 2.5) * ((CGM_Value - 2.5) / 2.5) 
               ELSE 0 
          END) * 5, 2) ||''<formula-component content="This metric quantifies the risk associated with low blood glucose levels over a specified period, measured in mg/dL."></formula-component></div></div></div>
  <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">High Blood Glucose Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| ROUND(SUM(CASE WHEN (CGM_Value - 9.5) / 9.5 > 0 
               THEN ((CGM_Value - 9.5) / 9.5) * ((CGM_Value - 9.5) / 9.5) 
               ELSE 0 
          END) * 5, 2) ||''<formula-component content="This metric quantifies the risk associated with high blood glucose levels over a specified period, measured in mg/dL."></formula-component></div></div></div>'' as html  
  FROM 
      combined_cgm_tracing
  WHERE 
      participant_id = $participant_id
      AND DATE(Date_Time) BETWEEN $start_date AND $end_date;   

  SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Glycaemic Risk Assessment Diabetes Equation (GRADE) <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| round(AVG(CASE
        WHEN CGM_Value < 90 THEN 10 * (5 - (CGM_Value / 18.0)) * (5 - (CGM_Value / 18.0))
        WHEN CGM_Value > 180 THEN 10 * ((CGM_Value / 18.0) - 10) * ((CGM_Value / 18.0) - 10)
        ELSE 0
    END),3) ||''<formula-component content="GRADE is a metric that combines various glucose metrics to assess overall glycemic risk in individuals with diabetes, calculated using multiple input parameters."></formula-component></div></div></div>'' as html
  FROM 
      combined_cgm_tracing
  WHERE 
      participant_id = $participant_id
      AND DATE(Date_Time) BETWEEN $start_date AND $end_date;


  CREATE TEMPORARY TABLE lag_values AS 
  SELECT 
      participant_id,
      Date_Time,
      CGM_Value,
      LAG(CGM_Value) OVER (PARTITION BY participant_id ORDER BY Date_Time) AS lag_CGM_Value
  FROM 
      combined_cgm_tracing
  WHERE
     participant_id = $participant_id
      AND DATE(Date_Time) BETWEEN $start_date AND $end_date;

  CREATE TEMPORARY TABLE conga_hourly AS 
  SELECT 
      participant_id,
      SQRT(
          AVG(
              (CGM_Value - lag_CGM_Value) * (CGM_Value - lag_CGM_Value)
          ) OVER (PARTITION BY participant_id ORDER BY Date_Time)
      ) AS conga_hourly
  FROM 
      lag_values
  WHERE 
      lag_CGM_Value IS NOT NULL;    

  SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Continuous Overall Net Glycemic Action (CONGA) <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| round(AVG(conga_hourly),3) ||''<formula-component content="CONGA quantifies the net glycemic effect over time by evaluating the differences between CGM values at specified intervals."></formula-component></div></div></div>'' as html
  FROM 
    conga_hourly;

    DROP TABLE IF EXISTS lag_values;
    DROP TABLE IF EXISTS conga_hourly;

  SELECT  
  ''<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Mean of Daily Differences <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">''|| round(AVG(daily_diff),3) ||''<formula-component content="This metric calculates the average of the absolute differences between daily CGM readings, giving insight into daily glucose variability."></formula-component></div></div></div>'' as html  
  FROM (
      SELECT
          participant_id,
          CGM_Value - LAG(CGM_Value) OVER (PARTITION BY participant_id ORDER BY DATE(Date_Time)) AS daily_diff
      FROM
          combined_cgm_tracing
      WHERE 
          participant_id = $participant_id
      AND DATE(Date_Time) BETWEEN $start_date AND $end_date
  ) AS daily_diffs
  WHERE
      daily_diff IS NOT NULL;                          
  SELECT
  ''</div>'' as html;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/study-participant-dashboard/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/study-participant-dashboard/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/study-participant-dashboard/index.sql/index.sql'') as contents;
    ;


SELECT
''datagrid'' AS component; 

SELECT
    ''Study Name'' AS title,
    '''' || study_name || '''' AS description
FROM
    drh_study_vanity_metrics_details;

SELECT
    ''Start Date'' AS title,
    '''' || start_date || '''' AS description
FROM
    drh_study_vanity_metrics_details;

SELECT
    ''End Date'' AS title,
    '''' || end_date || '''' AS description
FROM
    drh_study_vanity_metrics_details;

SELECT
    ''NCT Number'' AS title,
    '''' || nct_number || '''' AS description
FROM
    drh_study_vanity_metrics_details;




SELECT
   ''card''     as component,
   '''' as title,
    4         as columns;

SELECT
   ''Total Number Of Participants'' AS title,
   '''' || total_number_of_participants || '''' AS description
FROM
    drh_study_vanity_metrics_details;

SELECT

    ''Total CGM Files'' AS title,
   '''' || number_of_cgm_raw_files || '''' AS description
FROM
  drh_number_cgm_count;



SELECT
   ''% Female'' AS title,
   '''' || percentage_of_females || '''' AS description
FROM
    drh_study_vanity_metrics_details;


SELECT
   ''Average Age'' AS title,
   '''' || average_age || '''' AS description
FROM
    drh_study_vanity_metrics_details;




SELECT
''datagrid'' AS component;


SELECT
    ''Study Description'' AS title,
    '''' || study_description || '''' AS description
FROM
    drh_study_vanity_metrics_details;

    SELECT
    ''Study Team'' AS title,
    '''' || investigators || '''' AS description
FROM
    drh_study_vanity_metrics_details;


    SELECT
   ''card''     as component,
   '''' as title,
    1         as columns;

    SELECT
    ''Device Wise Raw CGM File Count'' AS title,
    GROUP_CONCAT('' '' || devicename || '': '' || number_of_files || '''') AS description
    FROM
        drh_device_file_count_view;

        SELECT
''text'' as component,
''# Participant Dashboard'' as contents_md;

    SET total_rows = (SELECT COUNT(*) FROM participant_dashboard_cached );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

  -- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
        ''participant_id'' as markdown,
        TRUE AS sort,
        TRUE AS search;        
  SELECT tenant_id,format(''[%s](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/drh/participant-info/index.sql?participant_id=''||''%s)'',participant_id, participant_id) as participant_id,gender,age,study_arm,baseline_hba1c,cgm_devices,cgm_files,tir,tar_vh,tar_h,tbr_l,tbr_vl,tar,tbr,gmi,percent_gv,gri,days_of_wear,data_start_date,data_end_date FROM participant_dashboard_cached
  LIMIT $limit
  OFFSET $offset;

  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/verification-validation-log/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/verification-validation-log/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/verification-validation-log/index.sql/index.sql'') as contents;
    ;

  SELECT
    ''text'' as component,
    ''
    Validation is a detailed process where we assess if the data within the files conforms to expecuted rules or constraints. This step ensures that the content of the files is both correct and meaningful before they are utilized for further processing.'' as contents;



SELECT
  ''steps'' AS component,
  TRUE AS counter,
  ''green'' AS color;


SELECT
  ''Check the Validation Log'' AS title,
  ''file'' AS icon,
  ''#'' AS link,
  ''If the log is empty, no action is required. Your files are good to go! If the log has entries, follow the steps below to fix any issues.'' AS description;


SELECT
  ''Note the Issues'' AS title,
  ''note'' AS icon,
  ''#'' AS link,
  ''Review the log to see what needs fixing for each file. Note them down to make a note on what needs to be changed in each file.'' AS description;


SELECT
  ''Stop the Edge UI'' AS title,
  ''square-rounded-x'' AS icon,
  ''#'' AS link,
  ''Make sure to stop the UI (press CTRL+C in the terminal).'' AS description;


SELECT
  ''Make Corrections in Files'' AS title,
  ''edit'' AS icon,
  ''#'' AS link,
  ''Edit the files according to the instructions provided in the log. For example, if a file is empty, fill it with the correct data.'' AS description;


SELECT
  ''Copy the modified Files to the folder'' AS title,
  ''copy'' AS icon,
  ''#'' AS link,
  ''Once you’ve made the necessary changes, replace the old files with the updated ones in the folder.'' AS description;


SELECT
  ''Execute the automated script again'' AS title,
  ''retry'' AS icon,
  ''#'' AS link,
  ''Run the command again to perform file conversion.'' AS description;


SELECT
  ''Repeat the steps until issues are resolved'' AS title,
  ''refresh'' AS icon,
  ''#'' AS link,
  ''Continue this process until the log is empty and all issues are resolved'' AS description;


SELECT
    ''text'' as component,
    ''
    Reminder: Keep updating and re-running the process until you see no entries in the log below.'' as contents;


    SET total_rows = (SELECT COUNT(*) FROM drh_vandv_orch_issues );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

    SELECT ''table'' AS component,
    TRUE AS sort,
    TRUE AS search;
    SELECT * FROM drh_vandv_orch_issues
    LIMIT $limit
    OFFSET $offset;

    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'drh/participant-related-data/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''drh/participant-related-data/index.sql''
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
   WHERE namespace = ''prime'' AND path = ''drh/participant-related-data/index.sql/index.sql'') as contents;
    ;

  SELECT
      ''text'' as component,
      ''
## Participant Information

Participants are individuals who volunteer to take part in CGM research studies. Their data is crucial for evaluating the performance of CGM systems and their impact on diabetes management.

### Participant Details

  - **Participant ID**: A unique identifier assigned to each participant.
  - **Study ID**: A unique identifier for the study in which the participant is involved.
  - **Site ID**: The identifier for the site where the participant is enrolled.
  - **Diagnosis ICD**: The diagnosis code based on the International Classification of Diseases (ICD) system.
  - **Med RxNorm**: The medication code based on the RxNorm system.
  - **Treatment Modality**: The type of treatment or intervention administered to the participant.
  - **Gender**: The gender of the participant.
  - **Race Ethnicity**: The race and ethnicity of the participant.
  - **Age**: The age of the participant.
  - **BMI**: The Body Mass Index (BMI) of the participant.
  - **Baseline HbA1c**: The baseline Hemoglobin A1c level of the participant.
  - **Diabetes Type**: The type of diabetes diagnosed for the participant.
  - **Study Arm**: The study arm or group to which the participant is assigned.


      '' as contents_md;

      SET total_rows = (SELECT COUNT(*) FROM drh_participant );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

    -- Display uniform_resource table with pagination
    SELECT ''table'' AS component,
          TRUE AS sort,
          TRUE AS search;
    SELECT * FROM drh_participant
     LIMIT $limit
    OFFSET $offset; 

    SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
