import { ws } from "../deps.ts";
import * as spn from "../notebook/sqlpage.ts";

// custom decorator that makes navigation for this notebook type-safe
export function consoleNav(
  route: Omit<spn.RouteConfig, "path" | "parentPath" | "namespace">,
) {
  return spn.navigationPrime({
    ...route,
    parentPath: "console/index.sql",
  });
}

export class ConsoleSqlPages extends spn.TypicalSqlPageNotebook {
  infoSchemaDDL() {

    // deno-fmt-ignore
    return this.SQL`
      -- ${this.tsProvenanceComment(import.meta.url)}

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
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}

      INSERT OR REPLACE INTO code_notebook_cell (notebook_kernel_id, code_notebook_cell_id, notebook_name, cell_name, interpretable_code, interpretable_code_hash, description) VALUES (
        'SQL',
        'web-ui.auto_generate_console_content_tabular_sqlpage_files',
        'Web UI',
        'auto_generate_console_content_tabular_sqlpage_files',
        ${this.emitCtx.sqlTextEmitOptions.quotedLiteral(this.infoSchemaContentDML())[1]},
        'TODO',
        'A series of idempotent INSERT statements which will auto-generate "default" content for all tables and views'
      );`;
  }

  /**
   * A SQLite "procedure" (SQL code block) which is always run when console UX is loaded
   * and may be run "manually" via web UI upon request. Treat this SQL block as a procedure
   * because it may be inserted into SQLPage as "commands", too.
   *
   * - Deletes `sqlpage_files` rows where `path` is 'console/content/%/%.auto.sql'.
   * - Generate default "content" pages in `sqlpage_files` for each table and view in the database.
   * - If no default 'console/content/<table|view>/<table-or-view-name>.sql exists, setup redirect to the auto-generated default content page.
   *   - if a page is inserted by another utility (custom page by an app/service) it's not replaced
   * @returns
   */
  infoSchemaContentDML() {
    // NOTE: we're not using this.SQL`` on purpose since it seems to be mangling SQL
    //       when it's "included" (injected) into SQLPage /action/ pages.
    // TODO: add this same SQL block into a code_notebook_cell row too
    // deno-fmt-ignore
    return ws.unindentWhitespace(`
      -- ${this.tsProvenanceComment(import.meta.url)}

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
                ''- Start Row: '' || $offset || ''\n'' ||
                ''- Rows per Page: '' || $limit || ''\n'' ||
                ''- Total Rows: '' || $total_rows || ''\n'' ||
                ''- Current Page: '' || $current_page || ''\n'' ||
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
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;\n' ||
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add \${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows`);
  }

  @spn.navigationPrime({
    caption: "Home",
    title: "Resource Surveillance State Database (RSSD)",
    description: "Welcome to Resource Surveillance State Database (RSSD)",
  })
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "index.sql"() {
    return this.SQL`
      SELECT 'list' AS component;
      SELECT caption as title, COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = 'index.sql'
       ORDER BY sibling_order;`;
  }

  @spn.navigationPrimeTopLevel({
    caption: "RSSD Console",
    abbreviatedCaption: "Console",
    title: "Resource Surveillance State Database (RSSD) Console",
    description:
      "Explore RSSD information schema, code notebooks, and SQLPage files",
    siblingOrder: 999,
  })
  "console/index.sql"() {
    return this.SQL`
      WITH console_navigation_cte AS (
          SELECT title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path =${this.constructHomePath("console")
      }
      )
      SELECT 'list' AS component, title, description
        FROM console_navigation_cte;
      SELECT caption as title, ${this.absoluteURL('/')} || COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${this.constructHomePath("console")}
       ORDER BY sibling_order;`;
  }

  @consoleNav({
    caption: "RSSD Information Schema",
    abbreviatedCaption: "Info Schema",
    description:
      "Explore RSSD tables, columns, views, and other information schema documentation",
    siblingOrder: 1,
  })
  "console/info-schema/index.sql"() {
    return this.SQL`
      SELECT 'title' AS component, 'Tables' as contents;
      SELECT 'table' AS component,
            'Table' AS markdown,
            'Column Count' as align_right,
            'Content' as markdown,
            TRUE as sort,
            TRUE as search;
      SELECT
          '[' || table_name || '](table.sql?name=' || table_name || ')' AS "Table",
          COUNT(column_name) AS "Column Count",
          REPLACE(content_web_ui_link_abbrev_md,'$SITE_PREFIX_URL',${this.absoluteURL('')}) as "Content"
      FROM console_information_schema_table
      GROUP BY table_name;

      SELECT 'title' AS component, 'Views' as contents;
      SELECT 'table' AS component,
            'View' AS markdown,
            'Column Count' as align_right,
            'Content' as markdown,
            TRUE as sort,
            TRUE as search;
      SELECT
          '[' || view_name || '](view.sql?name=' || view_name || ')' AS "View",
          COUNT(column_name) AS "Column Count",
          REPLACE(content_web_ui_link_abbrev_md,'$SITE_PREFIX_URL',${this.absoluteURL('')}) as "Content"
      FROM console_information_schema_view
      GROUP BY view_name;

      SELECT 'title' AS component, 'Migrations' as contents;
      SELECT 'table' AS component,
            'Table' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;
      SELECT from_state, to_state, transition_reason, transitioned_at
      FROM code_notebook_state
      ORDER BY transitioned_at;`;
  }

  // no @consoleNav since this is a "utility" page (not navigable)
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "console/info-schema/table.sql"() {
    return this.SQL`
      ${this.activeBreadcrumbsSQL({ titleExpr: `$name || ' Table'` })}

      SELECT 'title' AS component, $name AS contents;
      SELECT 'table' AS component;
      SELECT
          column_name AS "Column",
          data_type AS "Type",
          is_primary_key AS "PK",
          is_not_null AS "Required",
          default_value AS "Default"
      FROM console_information_schema_table
      WHERE table_name = $name;

      SELECT 'title' AS component, 'Foreign Keys' as contents, 2 as level;
      SELECT 'table' AS component;
      SELECT
          column_name AS "Column Name",
          foreign_key AS "Foreign Key"
      FROM console_information_schema_table_col_fkey
      WHERE table_name = $name;

      SELECT 'title' AS component, 'Indexes' as contents, 2 as level;
      SELECT 'table' AS component;
      SELECT
          column_name AS "Column Name",
          index_name AS "Index Name"
      FROM console_information_schema_table_col_index
      WHERE table_name = $name;

      SELECT 'title' AS component, 'SQL DDL' as contents, 2 as level;
      SELECT 'code' AS component;
      SELECT 'sql' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;`;
  }

  // no @consoleNav since this is a "utility" page (not navigable)
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "console/info-schema/view.sql"() {
    return this.SQL`
      ${this.activeBreadcrumbsSQL({ titleExpr: `$name || ' View'` })}

      SELECT 'title' AS component, $name AS contents;
      SELECT 'table' AS component;
      SELECT
          column_name AS "Column",
          data_type AS "Type"
      FROM console_information_schema_view
      WHERE view_name = $name;

      SELECT 'title' AS component, 'SQL DDL' as contents, 2 as level;
      SELECT 'code' AS component;
      SELECT 'sql' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;`;
  }

  @consoleNav({
    caption: "RSSD SQLPage Files",
    abbreviatedCaption: "SQLPage Files",
    description:
      "Explore RSSD SQLPage Files which govern the content of the web-UI",
    siblingOrder: 3,
  })
  "console/sqlpage-files/index.sql"() {
    return this.SQL`
      SELECT 'title' AS component, 'SQLPage pages in sqlpage_files table' AS contents;
      SELECT 'table' AS component,
            'Path' as markdown,
            'Size' as align_right,
            TRUE as sort,
            TRUE as search;     
         SELECT
        '[🚀](' || ${this.absoluteURL("/")
      } || path || ') [📄 ' || path || '](sqlpage-file.sql?path=' || path || ')' AS "Path",
         LENGTH(contents) as "Size", last_modified
      FROM sqlpage_files
      ORDER BY path;`;
  }

  // no @consoleNav since this is a "utility" page (not navigable)
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "console/sqlpage-files/sqlpage-file.sql"() {
    return this.SQL`
      ${this.activeBreadcrumbsSQL({ titleExpr: `$path || ' Path'` })}

      SELECT 'title' AS component, $path AS contents;
      SELECT 'text' AS component,
             '\`\`\`sql\n' || (select contents FROM sqlpage_files where path = $path) || '\n\`\`\`' as contents_md;`;
  }

  @consoleNav({
    caption: "RSSD Data Tables Content SQLPage Files",
    abbreviatedCaption: "Content SQLPage Files",
    description:
      "Explore auto-generated RSSD SQLPage Files which display content within tables",
    siblingOrder: 3,
  })
  "console/sqlpage-files/content.sql"() {
    return this.SQL`
      SELECT 'title' AS component, 'SQLPage pages generated from tables and views' AS contents;
      SELECT 'text' AS component, '
        - \`*.auto.sql\` pages are auto-generated "default" content pages for each table and view defined in the database.
        - The \`*.sql\` companions may be auto-generated redirects to their \`*.auto.sql\` pair or an app/service might override the \`*.sql\` to not redirect and supply custom content for any table or view.
        - [View regenerate-auto.sql](' || ${this.absoluteURL(
      '/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql',
    )
      } || ')
        ' AS contents_md;

      SELECT 'button' AS component, 'center' AS justify;
      SELECT ${this.absoluteURL('/console/content/action/regenerate-auto.sql')
      } AS link, 'info' AS color, 'Regenerate all "default" table/view content pages' AS title;

      SELECT 'title' AS component, 'Redirected or overriden content pages' as contents;
      SELECT 'table' AS component,
            'Path' as markdown,
            'Size' as align_right,
            TRUE as sort,
            TRUE as search;  
            SELECT
        '[🚀](' || ${this.absoluteURL("/")} || path || ')[📄 ' || path || '](sqlpage-file.sql?path=' || path || ')' AS "Path",
      
        LENGTH(contents) as "Size", last_modified
      FROM sqlpage_files
      WHERE path like 'console/content/%'
            AND NOT(path like 'console/content/%.auto.sql')
            AND NOT(path like 'console/content/action%')
      ORDER BY path;

      SELECT 'title' AS component, 'Auto-generated "default" content pages' as contents;
      SELECT 'table' AS component,
            'Path' as markdown,
            'Size' as align_right,
            TRUE as sort,
            TRUE as search;
          SELECT
            '[🚀](' || ${this.absoluteURL("/")
      } || path || ') [📄 ' || path || '](sqlpage-file.sql?path=' || path || ')' AS "Path",
        
        LENGTH(contents) as "Size", last_modified
      FROM sqlpage_files
      WHERE path like 'console/content/%.auto.sql'
      ORDER BY path;
      `;
  }

  @spn.shell({ eliminate: true })
  "console/content/action/regenerate-auto.sql"() {
    return this.SQL`
      ${this.infoSchemaContentDML()}

      -- ${this.tsProvenanceComment(import.meta.url)}
      SELECT 'redirect' AS component, sqlpage.environment_variable('SQLPAGE_SITE_PREFIX') || '/console/sqlpage-files/content.sql' as link WHERE $redirect is NULL;
      SELECT 'redirect' AS component, sqlpage.environment_variable('SQLPAGE_SITE_PREFIX') || $redirect as link WHERE $redirect is NOT NULL;
    `;
  }

  @consoleNav({
    caption: "RSSD SQLPage Navigation",
    abbreviatedCaption: "SQLPage Navigation",
    description:
      "See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table",
    siblingOrder: 3,
  })
  "console/sqlpage-nav/index.sql"() {
    return this.SQL`
      SELECT 'title' AS component, 'SQLPage navigation in sqlpage_aide_navigation table' AS contents;
      SELECT 'table' AS component, TRUE as sort, TRUE as search;
      SELECT path, caption, description FROM sqlpage_aide_navigation ORDER BY namespace, parent_path, path, sibling_order;`;
  }

  @consoleNav({
    caption: "RSSD Code Notebooks",
    abbreviatedCaption: "Code Notebooks",
    description:
      "Explore RSSD Code Notebooks which contain reusable SQL and other code blocks",
    siblingOrder: 2,
  })
  "console/notebooks/index.sql"() {
    return this.SQL`
      SELECT 'title' AS component, 'Code Notebooks' AS contents;
      SELECT 'table' as component, 'Cell' as markdown, 1 as search, 1 as sort;
      SELECT c.notebook_name,
          '[' || c.cell_name || '](' ||
          ${this.absoluteURL("/console/notebooks/notebook-cell.sql?notebook=")
      } || 
          replace(c.notebook_name, ' ', '%20') || 
          '&cell=' || 
          replace(c.cell_name, ' ', '%20') || 
          ')' AS "Cell",      
           c.description,
             k.kernel_name as kernel
        FROM code_notebook_kernel k, code_notebook_cell c
       WHERE k.code_notebook_kernel_id = c.notebook_kernel_id;`;
  }

  // no @consoleNav since this is a "utility" page (not navigable)
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "console/notebooks/notebook-cell.sql"() {
    // deno-fmt-ignore
    return this.SQL`
      ${this.activeBreadcrumbsSQL({ titleExpr: `'Notebook ' || $notebook || ' Cell' || $cell` })}

      SELECT 'code' as component;
      SELECT $notebook || '.' || $cell || ' (' || k.kernel_name ||')' as title,
             COALESCE(c.cell_governance -> '$.language', 'sql') as language,
             c.interpretable_code as contents
        FROM code_notebook_kernel k, code_notebook_cell c
       WHERE c.notebook_name = $notebook
         AND c.cell_name = $cell
         AND k.code_notebook_kernel_id = c.notebook_kernel_id;`;
  }

  migrationDocumentation() {
    return `
This document provides an organized and comprehensive overview of \`\`surveilr\`\`''s RSSD migration process starting from \`\`v 1.0.0\`\`, breaking down each component and the steps followed to ensure smooth and efficient migrations. It covers the creation of key tables and views, the handling of migration cells, and the sequence for executing migration scripts.

---

## Session and State Initialization

To manage temporary session data and track user state, we use the \`\`session_state_ephemeral\`\` table, which stores essential session information like the current user. This table is temporary, meaning it only persists data for the duration of the session, and it''s especially useful for identifying the user responsible for specific actions during the migration.

Each time the migration process runs, we initialize session data in this table, ensuring all necessary information is available without affecting the core database tables. This initialization prepares the system for more advanced operations that rely on knowing the user executing each action.

---

## Assurance Schema Table

The \`\`assurance_schema\`\` table is designed to store various schema-related details, including the type of schema assurance, associated codes, and related governance data. This table is central to defining the structure of assurance records, which are useful for validating data, tracking governance requirements, and recording creation timestamps. All updates to the schema are logged to track when they were last modified and by whom.

---

## Code Notebook Kernel, Cell, and State Tables

\`\`surveilr\`\` uses a structured system of code notebooks to store and execute SQL commands. These commands, or “cells,” are grouped into notebooks, and each notebook is associated with a kernel, which provides metadata about the notebook''s language and structure. The main tables involved here are:

- **\`\`code_notebook_kernel\`\`**: Stores information about different kernels, each representing a unique execution environment or language.
- **\`\`code_notebook_cell\`\`**: Holds individual code cells within each notebook, along with their associated metadata and execution history.
- **\`\`code_notebook_state\`\`**: Tracks each cell''s state changes, such as when it was last executed and any errors encountered.

By organizing migration scripts into cells and notebooks, \`\`surveilr\`\` can maintain detailed control over execution order and track the state of each cell individually. This tracking is essential for handling updates, as it allows us to execute migrations only when necessary.

---

## Views for Managing Cell Versions and Migrations

Several views are defined to simplify and organize the migration process by managing different versions of code cells and identifying migration candidates. These views help filter, sort, and retrieve the cells that need execution.

### Key Views

- **\`\`code_notebook_cell_versions\`\`**: Lists all available versions of each cell, allowing the migration tool to retrieve older versions if needed for rollback or auditing.
- **\`\`code_notebook_cell_latest\`\`**: Shows only the latest version of each cell, simplifying the migration by focusing on the most recent updates.
- **\`\`code_notebook_sql_cell_migratable\`\`**: Filters cells to include only those that are eligible for migration, ensuring that non-executable cells are ignored.

---

## Migration-Oriented Views and Dynamic Migration Scripts

To streamline the migration process, several migration-oriented views organize the data by listing cells that require execution or are ready for re-execution. By grouping these cells in specific views, \`\`surveilr\`\` dynamically generates a script that executes only the necessary cells.

### Key Views

- **\`\`code_notebook_sql_cell_migratable_not_executed\`\`**: Lists migratable cells that haven’t yet been executed.
- **\`\`code_notebook_sql_cell_migratable_state\`\`**: Shows the latest migratable cells, along with their current state transitions.

---

## How Migrations Are Executed

When it''s time to apply changes to the database, this section explains the process in detail, focusing on how \`\`surveilr\`\` prepares the environment, identifies which cells to migrate, executes the appropriate SQL code, and ensures data integrity throughout.

---

### 1. Initialization

The first step in the migration process involves setting up the essential database tables and seeding initial values. This lays the foundation for the migration process, making sure that all tables, views, and temporary values needed are in place.

- **Check for Core Tables**: \`\`surveilr\`\` first verifies whether the required tables, such as \`\`code_notebook_cell\`\`, \`\`code_notebook_state\`\`, and others starting with \`\`code_notebook%\`\`, are already set up in the database. 
- **Setup**: If these tables do not yet exist, \`\`surveilr\`\` automatically initiates the setup by running the initial SQL script, known as \`\`bootstrap.sql\`\`. This script contains SQL commands that create all the essential tables and views discussed in previous sections. 
- **Seeding**: During the execution of \`\`bootstrap.sql\`\`, essential data, such as temporary values in the \`\`session_state_ephemeral\`\` table (e.g., information about the current user), is also added to ensure that the migration session has the data it needs to proceed smoothly.

---

### 2. Migration Preparation and Identification of Cells to Execute

Once the environment is ready, \`\`surveilr\`\` examines which specific cells (code blocks in the migration notebook) need to be executed to bring the database up to the latest version.

- **Listing Eligible Cells**: \`\`surveilr\`\` begins by consulting views such as \`\`code_notebook_sql_cell_migratable_not_executed\`\`. This view is a pre-filtered list of cells that are eligible for migration but haven’t yet been executed.
- **Idempotent vs. Non-Idempotent Cells**: \`\`surveilr\`\` then checks whether each cell is marked as “idempotent” or “non-idempotent.” 
   - **Idempotent Cells** can be executed multiple times without adverse effects. If they have been run before, they can safely be run again without impacting data integrity.
   - **Non-Idempotent Cells**, identified by names containing \`\`_once_\`\`, should only be executed once. If these cells have been executed previously, they are skipped in the migration process to prevent unintentional re-runs.

---

### 3. Dynamic Script Generation and Execution

\`\`surveilr\`\` then assembles a custom SQL script that includes only the cells identified as eligible for execution. This script is crafted carefully to ensure each cell''s SQL code is executed in the correct order and with the right contextual information.

- **Script Creation**: We start by generating a dynamic script in a single transaction block. Transactions are a way of grouping a series of commands so that they are either all applied or none are, which protects data integrity.
- **Inclusion of Cells Based on Eligibility**:
   - For each cell, \`\`surveilr\`\` checks its eligibility status. If it''s non-idempotent and already executed, it''s marked with a comment noting that it''s excluded from the script due to previous execution.
   - If the cell is idempotent or eligible for re-execution, its SQL code is added to the script, along with additional details such as comments about the cell''s last execution date.
- **State Transition Records**: After each cell''s SQL code, additional commands are added to record the cell''s transition state. This step inserts information into \`\`code_notebook_state\`\`, logging details such as the cell ID, transition state (from “Pending” to “Executed”), and the reason for the transition (“Migration” or “Reapplication”). These logs are invaluable for auditing purposes.

---

### 4. Execution in a Transactional Block

With the script prepared, \`\`surveilr\`\` then executes the entire batch of SQL commands within a transactional block.

- **BEGIN TRANSACTION**: The script begins with a transaction, ensuring that all changes are applied as a single, atomic unit.
- **Running Cell Code**: Within this transaction, each cell''s SQL code is executed in the order it appears in the script.
- **Error Handling**: If any step in the transaction fails, all changes are rolled back. This prevents partial updates from occurring, ensuring that the database remains in a consistent state.
- **COMMIT**: If the script executes successfully without errors, the transaction is committed, finalizing the changes. The \`\`COMMIT\`\` command signifies the end of the migration session, making all updates permanent.

---

### 5. Finalizing Migration and Recording Results

After a successful migration session, \`\`surveilr\`\` concludes by recording details about the migration process.

- **Final Updates to \`\`code_notebook_state\`\`**: Any cells marked as “Executed” are updated in \`\`code_notebook_state\`\` with the latest timestamp, indicating their successful migration.
- **Logging Completion**: Activity logs are updated with relevant details, ensuring a clear record of the migration.
- **Cleanup of Temporary Data**: Finally, temporary data is cleared, such as entries in \`\`session_state_ephemeral\`\`, since these values were only needed during the migration process.
    `;
  }

  @consoleNav({
    caption: "RSSD Lifecycle (migrations)",
    abbreviatedCaption: "Migrations",
    description:
      "Explore RSSD Migrations to determine what was executed and not",
    siblingOrder: 2,
  })
  "console/migrations/index.sql"() {
    return this.SQL`
      SELECT 
          'foldable' as component;
      SELECT 
          'RSSD Lifecycle(Migration) Documentation' as title,
          '${this.migrationDocumentation()}' as description_md;


      SELECT 'title' AS component, 'Pending Migrations' AS contents;
      SELECT 'text' AS component, 'code_notebook_sql_cell_migratable_not_executed lists all cells eligible for migration but not yet executed. 
          If migrations have been completed successfully, this list will be empty, 
          indicating that all migratable cells have been processed and marked as executed.' as contents;

      SELECT 'table' as component, 'Cell' as markdown, 1 as search, 1 as sort;
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
      SELECT 'title' AS component, 'State of Executed Migrations' AS contents;
      SELECT 'text' AS component, 'code_notebook_sql_cell_migratable_state displays all cells that have been successfully executed as part of the migration process, 
          showing the latest version of each migratable cell. 
          For each cell, it provides details on its transition states, 
          the reason and result of the migration, and the timestamp of when the migration occurred.' as contents;

      SELECT 'table' as component, 'Cell' as markdown, 1 as search, 1 as sort;
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
      SELECT 'title' AS component, 'Executable Migrations' AS contents;
      SELECT 'text' AS component, 'All cells that are candidates for migration (including duplicates)' as contents;
      SELECT 'table' as component, 'Cell' as markdown, 1 as search, 1 as sort;
      SELECT 
              c.code_notebook_cell_id,
              c.notebook_name,
              c.cell_name,
              '[' || c.cell_name || ']('||${this.absoluteURL("/console/notebooks/notebook-cell.sql?notebook=")
      } || replace(c.notebook_name, ' ', '%20') || '&cell=' || replace(c.cell_name, ' ', '%20') || ')' as Cell,
              c.interpretable_code_hash,
              c.is_idempotent,
              c.version_timestamp
          FROM 
              code_notebook_sql_cell_migratable_version AS c
          ORDER BY 
              c.cell_name;
      
      -- All Migrations
      SELECT 'button' as component;
      SELECT 
          ${this.absoluteURL("/console/notebooks")} as link,
          'See all notebook entries' as title;
      `;
  }

  // no @consoleNav since this is a "utility" page (not navigable)
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "console/migrations/notebook-cell.sql"() {
    // deno-fmt-ignore
    return this.SQL`
      ${this.activeBreadcrumbsSQL({ titleExpr: `'Notebook ' || $notebook || ' Cell' || $cell` })}

      SELECT 'code' as component;
      SELECT $notebook || '.' || $cell || ' (' || k.kernel_name ||')' as title,
             COALESCE(c.cell_governance -> '$.language', 'sql') as language,
             c.interpretable_code as contents
        FROM code_notebook_kernel k, code_notebook_cell c
       WHERE c.notebook_name = $notebook
         AND c.cell_name = $cell
         AND k.code_notebook_kernel_id = c.notebook_kernel_id;`;
  }
}
