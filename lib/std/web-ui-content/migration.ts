import * as spn from "../notebook/sqlpage.ts";

export function migrationNav(
    route: Omit<spn.RouteConfig, "path" | "parentPath" | "namespace">,
  ) {
    return spn.navigationPrime({
      ...route,
      parentPath: "/migration",
    });
  }

  export class RssdMigrationSqlPages extends spn.TypicalSqlPageNotebook {
    navigationDML() {
        return this.SQL`
              ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
            `;
      }

      @spn.navigationPrime({
        caption: "Migrations",
        title: "RSSD Lifecycle (migrations)",
        description: "Explore RSSD Migrations to determine what was executed and not",
      })
      @spn.shell({ breadcrumbsFromNavStmts: "no" })
      "migration/index.sql"() {
        return this.SQL`
        WITH console_navigation_cte AS (
          SELECT title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = '/migration'
      )
      SELECT 'list' AS component, title, description
        FROM console_navigation_cte;
      SELECT caption as title, COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = '/migration'
       ORDER BY sibling_order;
    `;
      }

      @migrationNav({
        caption: "Notebook Versions",
        abbreviatedCaption: "Versions",
        description:
          "All cells and how many different versions of each cell are available",
        siblingOrder: 2,
      })
      "migration/versions.sql"() {
        return this.SQL`
          SELECT 'title' AS component, 'Code Notebook Cell Versions' AS contents;
          SELECT 'table' as component, 'Cell' as markdown, 1 as search, 1 as sort;
          SELECT 
              c.notebook_name, 
              c.cell_name,
              c.notebook_kernel_id,
              c.versions,
              c.code_notebook_cell_id
          FROM 
              code_notebook_cell_versions AS c
          ORDER BY 
              c.cell_name;
    `;
      }

      @migrationNav({
        caption: "Migratable Code Notebook Versions",
        abbreviatedCaption: "Migratable Cells",
        description:
          "All cells that are candidates for migration (including duplicates)",
        siblingOrder: 2,
      })
      "migration/migratable_cells.sql"() {
        return this.SQL`
          SELECT 'title' AS component, 'Code Notebook Cell Migratable Versions' AS contents;
          SELECT 'table' as component, 'Cell' as markdown, 1 as search, 1 as sort;
          SELECT 
              c.code_notebook_cell_id,
              c.notebook_name,
              c.cell_name,
              c.interpretable_code,
              c.interpretable_code_hash,
              c.is_idempotent,
              c.version_timestamp
          FROM 
              code_notebook_sql_cell_migratable_version AS c
          ORDER BY 
              c.cell_name;
    `;
      }

      @migrationNav({
        caption: "Latest Migratable Code Notebook",
        abbreviatedCaption: "Latest",
        description:
          "All cells that are candidates for migration (latest only)",
        siblingOrder: 2,
      })
      "migration/latest.sql"() {
        return this.SQL`
          SELECT 'title' AS component, 'Latest Migratable Cells' AS contents;
          SELECT 'table' as component, 'Cell' as markdown, 1 as search, 1 as sort;
          SELECT 
              c.code_notebook_cell_id,
              c.notebook_name,
              c.cell_name,
              c.interpretable_code,
              c.interpretable_code_hash,
              c.is_idempotent,
              c.version_timestamp
          FROM 
              code_notebook_sql_cell_migratable AS c
          ORDER BY 
              c.cell_name;
    `;
      }

      @migrationNav({
        caption: "Migration State",
        abbreviatedCaption: "State",
        description:
          "The state of cells that can be migrated (latest only)",
        siblingOrder: 2,
      })
      "migration/state.sql"() {
        return this.SQL`
          SELECT 'title' AS component, 'Migratable Cells State' AS contents;
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
    `;
      }

    @migrationNav({
        caption: "Unexcuted Migrations",
        abbreviatedCaption: "Pending",
        description:
          "All latest migratable cells that have not yet been executed",
        siblingOrder: 2,
      })
      "migration/pending.sql"() {
        return this.SQL`
          SELECT 'title' AS component, 'Pending Migrations' AS contents;
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
    `;
      }
  }