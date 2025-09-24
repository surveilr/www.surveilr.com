#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Drizzle-based Console SQLPages
 * 
 * Recreates the console web UI content using Drizzle decorators instead of SQLa
 */

import { DrizzleSqlPageNotebook, navigationPrimeDrizzle } from "../notebook-drizzle/drizzle-sqlpage.ts";
import { inlinedSQL, SQL } from "../../universal/sql-text.ts";

export class DrizzleConsoleSqlPages extends DrizzleSqlPageNotebook {
  constructor() {
    super("console");
  }

  // Auto-generation system using Drizzle patterns
  // Recreates the original infoSchemaContentDML() functionality
  autoGenerateTableViewBrowsers(): string {
    return inlinedSQL(SQL`
      -- Auto-generate table and view browser pages using Drizzle pattern
      -- Equivalent to original infoSchemaContentDML() method

      -- Delete existing auto-generated files
      DELETE FROM sqlpage_files WHERE path like 'console/content/table/%.auto.sql';
      DELETE FROM sqlpage_files WHERE path like 'console/content/view/%.auto.sql';

      -- Generate .auto.sql files for each table and view
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql',
            'SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

              SELECT ''breadcrumb'' AS component;
              SELECT ''Home'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
              SELECT ''Console'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console'' AS link;
              SELECT ''Content'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content'' AS link;
              SELECT ''' || tabular_name  || ' ' || tabular_nature || ''' as title, ''#'' AS link;

              SELECT ''title'' AS component, ''' || tabular_name || ' (' || tabular_nature || ') Content'' as contents;

              SET total_rows = (SELECT COUNT(*) FROM ' || tabular_name || ');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''text'' AS component, ''' || info_schema_link_full_md || ''' AS contents_md;
              SELECT ''text'' AS component,
                ''- Start Row: '' || $offset || ''\n'' ||
                ''- Rows per Page: '' || $limit || ''\n'' ||
                ''- Total Rows: '' || $total_rows || ''\n'' ||
                ''- Current Page: '' || $current_page || ''\n'' ||
                ''- Total Pages: '' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display table with pagination
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

      -- Generate redirect files (non-auto) that point to auto-generated ones
      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.sql',
            'SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;' || char(10) ||
            'SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;`);
  }

  // Console information schema views are now defined in ../../universal/views.ts using Drizzle query builder
  // This ensures consistency and type safety across the system
  infoSchemaDDL(): string {
    return inlinedSQL(SQL`-- Console information schema views are now defined in ../../universal/views.ts
-- Views will be created automatically by Drizzle ORM schema introspection
-- This ensures consistency between TypeScript definitions and SQL implementation

-- All console information schema views have been moved to ../../universal/views.ts:
-- - console_information_schema_table
-- - console_information_schema_view
-- - console_content_tabular
-- - console_information_schema_table_col_fkey
-- - console_information_schema_table_col_index
-- - rssd_statistics_overview
-- - rssd_table_statistic`);
  }

  @navigationPrimeDrizzle({
    caption: "Console", 
    description: "Administrative tools and system management",
    siblingOrder: 1,
  })
  "console/index.sql"() {
    return inlinedSQL(SQL`WITH console_navigation_cte AS (
        SELECT COALESCE(abbreviated_caption, caption) AS caption, 
               COALESCE(url, path) AS path, 
               description 
          FROM sqlpage_aide_navigation 
         WHERE namespace = 'prime' AND parent_path = 'console/index.sql' 
         ORDER BY sibling_order)
    
    SELECT 'list' AS component;
    SELECT caption as title, path as link, description
      FROM console_navigation_cte;`);
  }

  @navigationPrimeDrizzle({
    caption: "RSSD Information Schema",
    abbreviatedCaption: "Info Schema", 
    description: "Schema of database tables and views",
    siblingOrder: 10,
  })
  "console/info-schema/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Tables' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT table_name AS "Table", 
           '[Schema](' || info_schema_web_ui_path || ')' AS "Info Schema", 
           '[Content](' || content_web_ui_path || ')' AS "Content"
      FROM console_information_schema_table;

    SELECT 'title' AS component, 'Views' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT view_name AS "View", 
           '[Schema](' || info_schema_web_ui_path || ')' AS "Info Schema", 
           '[Content](' || content_web_ui_path || ')' AS "Content"
      FROM console_information_schema_view;`);
  }

  "console/info-schema/table.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Info Schema' as title, '/console/info-schema/index.sql' as link;
    SELECT ($name || ' Table') as title;

    SELECT 'title' AS component, ($name || ' Table Structure') as contents;
    SELECT 'table' AS component;
    SELECT column_name AS "Column", 
           data_type AS "Type",
           is_primary_key AS "Primary Key",
           is_not_null AS "Not Null",
           default_value AS "Default"
      FROM console_information_schema_table
     WHERE table_name = $name;

    SELECT 'title' AS component, 'Foreign Keys' as contents, 2 as level;
    SELECT 'table' AS component;
    SELECT column_name AS "Column", 
           foreign_key AS "References"
      FROM console_information_schema_table_col_fkey
     WHERE table_name = $name;

    SELECT 'title' AS component, 'Indexes' as contents, 2 as level;
    SELECT 'table' AS component;
    SELECT column_name AS "Column Name", 
           index_name AS "Index Name"
      FROM console_information_schema_table_col_index
     WHERE table_name = $name;

    SELECT 'title' AS component, 'SQL DDL' as contents, 2 as level;
    SELECT 'code' AS component;
    SELECT 'sql' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;`);
  }

  "console/info-schema/view.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Info Schema' as title, '/console/info-schema/index.sql' as link;
    SELECT ($name || ' View') as title;

    SELECT 'title' AS component, ($name || ' View Structure') as contents;
    SELECT 'table' AS component;
    SELECT column_name AS "Column", 
           data_type AS "Type"
      FROM console_information_schema_view
     WHERE view_name = $name;

    SELECT 'title' AS component, 'SQL DDL' as contents, 2 as level;
    SELECT 'code' AS component;
    SELECT 'sql' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;`);
  }

  @navigationPrimeDrizzle({
    caption: "SQLPage Files",
    description: "Web UI content management",
    siblingOrder: 20,
  })
  "console/sqlpage-files/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'SQLPage Files' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT path AS "Path", 
           caption AS "Caption",
           description AS "Description",
           '[View](' || path || ')' AS "File"
      FROM sqlpage_files
     ORDER BY path;`);
  }

  "console/sqlpage-files/sqlpage-file.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'SQLPage Files' as title, '/console/sqlpage-files/index.sql' as link;
    SELECT $path as title;

    SELECT 'title' AS component, 'SQLPage File Details' as contents;
    SELECT 'table' AS component;
    SELECT 'Path' AS "Field", path AS "Value" FROM sqlpage_files WHERE path = $path
    UNION ALL
    SELECT 'Caption' AS "Field", caption AS "Value" FROM sqlpage_files WHERE path = $path
    UNION ALL
    SELECT 'Description' AS "Field", description AS "Value" FROM sqlpage_files WHERE path = $path;

    SELECT 'title' AS component, 'File Content' as contents, 2 as level;
    SELECT 'code' AS component;
    SELECT 'sql' as language, contents as contents FROM sqlpage_files WHERE path = $path;`);
  }

  "console/sqlpage-files/content.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'All SQLPage File Contents' as contents;
    
    SELECT 'code' AS component;
    SELECT 'sql' as language, 
           GROUP_CONCAT(
             '-- File: ' || path || char(10) || 
             '-- Caption: ' || COALESCE(caption, 'N/A') || char(10) ||
             '-- Description: ' || COALESCE(description, 'N/A') || char(10) ||
             contents || char(10) || char(10), 
             char(10) || '-- ' || REPEAT('-', 50) || char(10) || char(10)
           ) as contents
    FROM sqlpage_files
    ORDER BY path;`);
  }

  @navigationPrimeDrizzle({
    caption: "SQLPage Navigation",
    description: "Web UI navigation structure",
    siblingOrder: 25,
  })
  "console/sqlpage-nav/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'SQLPage Navigation' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT namespace AS "Namespace",
           path AS "Path", 
           caption AS "Caption",
           description AS "Description",
           parent_path AS "Parent Path",
           sibling_order AS "Order"
      FROM sqlpage_aide_navigation
     ORDER BY namespace, parent_path, sibling_order;`);
  }

  @navigationPrimeDrizzle({
    caption: "Notebooks",
    description: "Code notebook management",
    siblingOrder: 30,
  })
  "console/notebooks/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Code Notebooks' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT notebook_name AS "Notebook",
           COUNT(*) AS "Cells",
           '[View](console/notebooks/notebook-cell.sql?notebook=' || notebook_name || ')' AS "Details"
      FROM code_notebook_cell
     GROUP BY notebook_name
     ORDER BY notebook_name;`);
  }

  "console/notebooks/notebook-cell.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Notebooks' as title, '/console/notebooks/index.sql' as link;
    SELECT $notebook as title;

    SELECT 'title' AS component, ('Notebook: ' || $notebook) as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT cell_name AS "Cell Name",
           kernel AS "Kernel",
           LEFT(interpretable_code, 100) || CASE WHEN LENGTH(interpretable_code) > 100 THEN '...' ELSE '' END AS "Code Preview",
           created_at AS "Created"
      FROM code_notebook_cell
     WHERE notebook_name = $notebook
     ORDER BY cell_name;

    SELECT 'title' AS component, 'Cell Details' as contents, 2 as level;
    SELECT 'table' AS component;
    SELECT cell_name AS "Cell",
           'code' AS component,
           'sql' as language,
           interpretable_code as contents
      FROM code_notebook_cell
     WHERE notebook_name = $notebook
     ORDER BY cell_name;`);
  }

  @navigationPrimeDrizzle({
    caption: "Migrations",
    description: "Database migration management",
    siblingOrder: 35,
  })
  "console/migrations/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Database Migrations' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT notebook_name AS "Migration Notebook",
           cell_name AS "Cell",
           '[View](console/migrations/notebook-cell.sql?notebook=' || notebook_name || '&cell=' || cell_name || ')' AS "Details"
      FROM code_notebook_sql_cell_migratable_version
     ORDER BY notebook_name, cell_name;`);
  }

  "console/migrations/notebook-cell.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Migrations' as title, '/console/migrations/index.sql' as link;
    SELECT ($notebook || '/' || $cell) as title;

    SELECT 'title' AS component, 'Migration Cell Details' as contents;
    SELECT 'code' AS component;
    SELECT 'sql' as language, interpretable_code as contents
      FROM code_notebook_sql_cell_migratable_version
     WHERE notebook_name = $notebook AND cell_name = $cell;`);
  }

  @navigationPrimeDrizzle({
    caption: "About",
    description: "System information and statistics",
    siblingOrder: 99,
  })
  "console/about.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'System Information' as contents;
    
    SELECT 'table' AS component;
    SELECT 'Database Size (MB)' AS "Metric", db_size_mb AS "Value" FROM rssd_statistics_overview
    UNION ALL
    SELECT 'Database Size (GB)' AS "Metric", db_size_gb AS "Value" FROM rssd_statistics_overview
    UNION ALL
    SELECT 'Total Tables' AS "Metric", total_tables AS "Value" FROM rssd_statistics_overview
    UNION ALL
    SELECT 'Total Views' AS "Metric", total_views AS "Value" FROM rssd_statistics_overview
    UNION ALL
    SELECT 'Total Indexes' AS "Metric", total_indexes AS "Value" FROM rssd_statistics_overview
    UNION ALL
    SELECT 'Total Triggers' AS "Metric", total_triggers AS "Value" FROM rssd_statistics_overview;

    SELECT 'title' AS component, 'Table Statistics' as contents, 2 as level;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT table_name AS "Table Name",
           total_columns AS "Columns",
           total_indexes AS "Indexes", 
           foreign_keys AS "Foreign Keys",
           table_size_mb AS "Size (MB)"
      FROM rssd_table_statistic
     ORDER BY table_size_mb DESC;`);
  }

  @navigationPrimeDrizzle({
    caption: "Statistics",
    description: "Database performance and usage statistics",
    siblingOrder: 40,
  })
  "console/statistics/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Database Statistics' as contents;
    
    SELECT 'table' AS component;
    SELECT table_name AS "Table",
           table_size_mb AS "Size (MB)"
      FROM rssd_table_statistic
     WHERE table_size_mb > 0
     ORDER BY table_size_mb DESC
     LIMIT 20;

    SELECT 'title' AS component, 'System Overview' as contents, 2 as level;
    SELECT 'table' AS component;
    SELECT 'Database Size (MB)' AS "Metric", db_size_mb AS "Value" FROM rssd_statistics_overview
    UNION ALL
    SELECT 'Total Tables' AS "Metric", total_tables AS "Value" FROM rssd_statistics_overview
    UNION ALL
    SELECT 'Total Views' AS "Metric", total_views AS "Value" FROM rssd_statistics_overview;`);
  }

  @navigationPrimeDrizzle({
    caption: "Behavior", 
    description: "System behavior and configuration",
    siblingOrder: 45,
  })
  "console/behavior/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'System Behavior Configuration' as contents;
    
    SELECT 'text' AS component, 
           'Monitor and configure system behaviors, policies, and rules.' AS contents_md;
    
    SELECT 'table' AS component;
    SELECT 'Feature' AS "Area",
           'Status' AS "Status",
           'Details' AS "Description"
    WHERE 1=0;  -- Placeholder for behavior data`);
  }

  "console/behavior/behavior-detail.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Behavior' as title, '/console/behavior/index.sql' as link;
    SELECT $behavior as title;

    SELECT 'title' AS component, 'Behavior Details' as contents;
    SELECT 'text' AS component, 
           'Detailed configuration for: ' || $behavior AS contents_md;`);
  }

  "console/content/action/regenerate-auto.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Regenerate Auto-generated Content' as contents;
    
    SELECT 'text' AS component,
           'This action will regenerate auto-generated database content.' AS contents_md;
    
    SELECT 'alert' AS component;
    SELECT 'This is a utility endpoint for regenerating content.' AS description;`);
  }

  // Table browser methods - specific table content pages
  "console/content/table/code_notebook_cell.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'code_notebook_cell table' as title;

    SELECT 'title' AS component, 'Code Notebook Cell Content' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT code_notebook_cell_id AS "ID",
           notebook_name AS "Notebook", 
           cell_name AS "Cell",
           kernel AS "Kernel",
           LEFT(interpretable_code, 100) || '...' AS "Code Preview",
           created_at AS "Created"
      FROM code_notebook_cell
     ORDER BY created_at DESC;`);
  }

  "console/content/table/sqlpage_files.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'sqlpage_files table' as title;

    SELECT 'title' AS component, 'SQLPage Files Content' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT path AS "Path",
           caption AS "Caption",
           description AS "Description", 
           LEFT(contents, 100) || '...' AS "Content Preview",
           last_modified AS "Modified"
      FROM sqlpage_files
     ORDER BY last_modified DESC;`);
  }

  "console/content/table/sqlpage_aide_navigation.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'sqlpage_aide_navigation table' as title;

    SELECT 'title' AS component, 'SQLPage Navigation Content' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT namespace AS "Namespace",
           path AS "Path",
           caption AS "Caption",
           parent_path AS "Parent Path",
           sibling_order AS "Order",
           description AS "Description"
      FROM sqlpage_aide_navigation
     ORDER BY namespace, parent_path, sibling_order;`);
  }

  "console/content/table/surveilr_function_doc.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'surveilr_function_doc table' as title;

    SELECT 'title' AS component, 'Surveilr Function Documentation' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT name AS "Function Name",
           version AS "Version",
           description AS "Description",
           return_type AS "Return Type"
      FROM surveilr_function_doc
     ORDER BY name;`);
  }

  "console/content/table/code_notebook_kernel.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'code_notebook_kernel table' as title;

    SELECT 'title' AS component, 'Code Notebook Kernels' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT code_notebook_kernel_id AS "ID",
           kernel_name AS "Kernel Name",
           description AS "Description",
           mime_type AS "MIME Type"
      FROM code_notebook_kernel
     ORDER BY kernel_name;`);
  }

  "console/content/table/code_notebook_state.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'code_notebook_state table' as title;

    SELECT 'title' AS component, 'Code Notebook State' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT code_notebook_state_id AS "ID",
           from_state AS "From State",
           to_state AS "To State",
           transition_reason AS "Reason",
           transitioned_at AS "Transitioned At"
      FROM code_notebook_state
     ORDER BY transitioned_at DESC;`);
  }

  // View browser methods - specific view content pages
  "console/content/view/code_notebook_cell_latest.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'code_notebook_cell_latest view' as title;

    SELECT 'title' AS component, 'Latest Code Notebook Cells' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT notebook_name AS "Notebook",
           cell_name AS "Cell Name", 
           LEFT(interpretable_code, 100) || '...' AS "Code Preview",
           created_at AS "Created"
      FROM code_notebook_cell_latest
     ORDER BY created_at DESC;`);
  }

  "console/content/view/code_notebook_sql_cell_migratable_version.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'code_notebook_sql_cell_migratable_version view' as title;

    SELECT 'title' AS component, 'Migratable SQL Cell Versions' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT notebook_name AS "Notebook",
           cell_name AS "Cell Name",
           interpretable_code_hash AS "Code Hash",
           is_idempotent AS "Idempotent",
           version_timestamp AS "Version"
      FROM code_notebook_sql_cell_migratable_version
     ORDER BY version_timestamp DESC;`);
  }

  "console/content/view/console_content_tabular.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Console' as title, '/console/index.sql' as link;
    SELECT 'Content' as title;
    SELECT 'console_content_tabular view' as title;

    SELECT 'title' AS component, 'Console Tabular Content Overview' as contents;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT tabular_nature AS "Type",
           tabular_name AS "Name",
           info_schema_link_abbrev_md AS "Schema",
           content_web_ui_link_abbrev_md AS "Content"
      FROM console_content_tabular
     ORDER BY tabular_nature, tabular_name;`);
  }
}