import * as spn from "../notebook/sqlpage.ts";

// custom decorator that makes navigation for this notebook type-safe
export function urNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "/ur",
  });
}

export class UniformResourceSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /fhir-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like '/fhir%';
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  // any SQL such as views or tables needed to support the SQLPage content;
  // SQL views are required to support pagination, grids, tables, etc.
  supportDDL() {
    return this.SQL`
      DROP VIEW IF EXISTS uniform_resource_file;
      CREATE VIEW uniform_resource_file AS
        SELECT ur.uniform_resource_id,
               ur.nature,
               p.root_path AS source_path,
               pe.file_path_rel,
               ur.size_bytes
        FROM uniform_resource ur
        LEFT JOIN ur_ingest_session_fs_path p ON ur.ingest_fs_path_id = p.ur_ingest_session_fs_path_id
        LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id
        WHERE ur.ingest_fs_path_id IS NOT NULL;

        DROP VIEW IF EXISTS uniform_resource_imap;
        CREATE VIEW uniform_resource_imap AS
        SELECT ur.uniform_resource_id,
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
              ur.nature
        FROM uniform_resource ur
        LEFT JOIN ur_ingest_session_imap_acct_folder iaf ON ur.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
        LEFT JOIN ur_ingest_session_imap_account iac ON iac.ur_ingest_session_imap_account_id = iaf.ingest_account_id
        LEFT JOIN ur_ingest_session_imap_acct_folder_message iacm ON iacm.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
        WHERE ur.ingest_imap_acct_folder_id IS NOT NULL;
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Uniform Resource",
    description: "Explore ingested resources",
  })
  "ur/index.sql"() {
    return this.SQL`
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = '/ur'
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = '/ur'
       ORDER BY sibling_order;`;
  }

  @urNav({
    caption: "Uniform Resource Tables and Views",
    description:
      "Information Schema documentation for ingested Uniform Resource database objects",
    siblingOrder: 99,
  })
  "ur/info-schema.sql"() {
    return this.SQL`
      SELECT 'title' AS component, 'Uniform Resource Tables and Views' as contents;
      SELECT 'table' AS component,
            'Name' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;

      SELECT
          'Table' as "Type",
          '[' || table_name || '](/console/info-schema/table.sql?name=' || table_name || ')' AS "Name",
          COUNT(column_name) AS "Column Count"
      FROM console_information_schema_table
      WHERE table_name = 'uniform_resource' OR table_name like 'ur_%'
      GROUP BY table_name

      UNION ALL

      SELECT
          'View' as "Type",
          '[' || view_name || '](/console/info-schema/view.sql?name=' || view_name || ')' AS "Name",
          COUNT(column_name) AS "Column Count"
      FROM console_information_schema_view
      WHERE view_name like 'ur_%'
      GROUP BY view_name;
    `;
  }

  @urNav({
    caption: "Uniform Resources (Files)",
    description: "Files ingested into the `uniform_resource` table",
    siblingOrder: 1,
  })
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ur/uniform-resource-files.sql"() {
    const viewName = `uniform_resource_file`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
      ${this.activePageTitle()}

      -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
      ${pagination.init()}

      -- Display uniform_resource table with pagination
      SELECT 'table' AS component,
            'Uniform Resources' AS title,
            "Size (bytes)" as align_right,
            TRUE AS sort,
            TRUE AS search,
            TRUE AS hover,
            TRUE AS striped_rows,
            TRUE AS small;
      SELECT * FROM ${viewName} ORDER BY uniform_resource_id
       LIMIT $limit
      OFFSET $offset;

      ${pagination.renderSimpleMarkdown()}
    `;
  }

  @urNav({
    caption: "Uniform Resources (IMAP)",
    description: "Files ingested into the `uniform_resource` table",
    siblingOrder: 1,
  })
  @spn.shell({})
  "ur/uniform-resource-imap-account.sql"() {
    const viewName = `uniform_resource_imap`;
    return this.SQL`
      ${this.activePageTitle()}

      select
          'title'   as component,
          'Mailbox' as contents;
      -- Display uniform_resource table with pagination
      SELECT 'table' AS component,
            'Uniform Resources' AS title,
            "Size (bytes)" as align_right,
            TRUE AS sort,
            TRUE AS search,
            TRUE AS hover,
            TRUE AS striped_rows,
            TRUE AS small,
            'email' AS markdown;
      SELECT
        '[' || email || '](/ur/uniform-resource-imap-folder.sql?imap_account_id=' || ur_ingest_session_imap_account_id || ')' AS "email"
          FROM ${viewName}
          GROUP BY ur_ingest_session_imap_account_id
          ORDER BY uniform_resource_id;

    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ur/uniform-resource-imap-folder.sql"() {
    const viewName = `uniform_resource_imap`;
    return this.SQL`
      SELECT 'breadcrumb' as component;
      SELECT
          'Home' as title,
          '/'    as link;
      SELECT
          'Uniform Resource' as title,
          '/ur' as link;
      SELECT
          'Uniform Resources (IMAP)' as title,
          '/ur/uniform-resource-imap-account.sql' as link;
      SELECT
          'Folder' as title,
          '/ur/uniform-resource-imap-folder.sql?imap_account_id=' || $imap_account_id::TEXT as link;

      SELECT
          'title'   as component,
          (SELECT email FROM ${viewName} WHERE ur_ingest_session_imap_account_id=$imap_account_id::TEXT) as contents;

      -- Display uniform_resource table with pagination
      SELECT 'table' AS component,
            'Uniform Resources' AS title,
            "Size (bytes)" as align_right,
            TRUE AS sort,
            TRUE AS search,
            TRUE AS hover,
            TRUE AS striped_rows,
            TRUE AS small,
            'folder' AS markdown;
      SELECT '[' || folder_name || '](/ur/uniform-resource-imap-mail-list.sql?folder_id=' || ur_ingest_session_imap_acct_folder_id || ')' AS "folder"
        FROM ${viewName}
        WHERE ur_ingest_session_imap_account_id=$imap_account_id::TEXT
        GROUP BY ur_ingest_session_imap_acct_folder_id
        ORDER BY uniform_resource_id;
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ur/uniform-resource-imap-mail-list.sql"() {
    const viewName = `uniform_resource_imap`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
      SELECT
      'breadcrumb' AS component;
      SELECT
          'Home' AS title,
          '/'    AS link;
      SELECT
          'Uniform Resource' AS title,
          '/ur' AS link;
      SELECT
          'Uniform Resources (IMAP)' AS title,
          '/ur/uniform-resource-imap-account.sql' AS link;
      SELECT
       'Folder' AS title,
       "uniform-resource-imap-folder.sql?imap_account_id="|| ur_ingest_session_imap_account_id AS link
      FROM ${viewName}
      WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

      SELECT
       folder_name AS title,
       "uniform-resource-imap-mail-list.sql?folder_id="|| ur_ingest_session_imap_acct_folder_id AS link
      FROM ${viewName}
      WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

       SELECT
          'title'   as component,
          (SELECT email || ' (' || folder_name || ')'  FROM ${viewName} WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT) as contents;

      -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
      ${pagination.init()}

      -- Display uniform_resource table with pagination
      SELECT 'table' AS component,
            'Uniform Resources' AS title,
            "Size (bytes)" as align_right,
            TRUE AS sort,
            TRUE AS search,
            TRUE AS hover,
            TRUE AS striped_rows,
            TRUE AS small;
      SELECT subject,"from",strftime('%Y-%m-%d %H:%M:%S', substr(date, 1, 19)) as date
      FROM ${viewName}
      WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
      ORDER BY uniform_resource_id
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()}
    `;
  }
}
