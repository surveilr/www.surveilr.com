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
      DELETE FROM sqlpage_aide_navigation WHERE path like 'ur%';
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
        WHERE ext_ur.nature = 'json' AND html_content NOT NULL`;
  }

  fsContentIngestSessionFilesStatsViewDDL() {
    // deno-fmt-ignore
    return this.viewDefn("ur_ingest_session_files_stats")/* sql */`
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
          file_extension;`;
  }

  fsContentIngestSessionFilesStatsLatestViewDDL() {
    // deno-fmt-ignore
    return this.viewDefn("ur_ingest_session_files_stats_latest")/* sql */`
      SELECT iss.*
        FROM ur_ingest_session_files_stats AS iss
        JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                  FROM ur_ingest_session
              ORDER BY ur_ingest_session.ingest_finished_at DESC
                 LIMIT 1) AS latest
          ON iss.ingest_session_id = latest.latest_session_id;`;
  }

  urIngestSessionTasksStatsViewDDL() {
    // deno-fmt-ignore
    return this.viewDefn("ur_ingest_session_tasks_stats")/* sql */`
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
          ur_status;`;
  }

  urIngestSessionTasksStatsLatestViewDDL() {
    // deno-fmt-ignore
    return this.viewDefn("ur_ingest_session_tasks_stats_latest")/* sql */`
        SELECT iss.*
          FROM ur_ingest_session_tasks_stats AS iss
          JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                    FROM ur_ingest_session
                ORDER BY ur_ingest_session.ingest_finished_at DESC
                   LIMIT 1) AS latest
            ON iss.ingest_session_id = latest.latest_session_id;`;
  }

  urIngestSessionFileIssueViewDDL() {
    // deno-fmt-ignore
    return this.viewDefn("ur_ingest_session_file_issue")/* sql */`
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
               ufs.ur_diagnostics;`
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
           WHERE namespace = 'prime' AND path =${this.constructHomePath('ur')}
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, COALESCE(REPLACE(url, 'ur/', ''), REPLACE(path, 'ur/', '')) as link, description
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
      '[' || table_name || '](' || ${this.absoluteURL('/console/info-schema/table.sql?name=')} || table_name || ')' AS "Name",
        COUNT(column_name) AS "Column Count"
      FROM console_information_schema_table
      WHERE table_name = 'uniform_resource' OR table_name like 'ur_%'
      GROUP BY table_name

      UNION ALL

    SELECT
    'View' as "Type",
      '[' || view_name || '](' || ${this.absoluteURL('/console/info-schema/view.sql?name=')} || view_name || ')' AS "Name",
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
    description:
      "Easily access and view your emails with our Uniform Resource (IMAP) system. Ingested from various mail sources, this feature organizes and displays your messages directly in the Web UI, ensuring all your communications are available in one convenient place.",
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
    '[' || email || '](' || ${this.absoluteURL('/ur/uniform-resource-imap-folder.sql?imap_account_id=')} || ur_ingest_session_imap_account_id || ')' AS "email"
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
       ${this.absoluteURL('/')} as link;
    SELECT
      'Uniform Resource' as title,
      ${this.absoluteURL('/ur/index.sql')} as link;
    SELECT
      'Uniform Resources (IMAP)' as title,
      ${this.absoluteURL('/ur/uniform-resource-imap-account.sql')} as link;
    SELECT
      'Folder' as title,
      ${this.absoluteURL('/ur/uniform-resource-imap-folder.sql?imap_account_id=')} || $imap_account_id:: TEXT as link;
    SELECT
      'title' as component,
      (SELECT email FROM ${viewName} WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT) as contents;

    --Display uniform_resource table with pagination
      SELECT 'table' AS component,
      'Uniform Resources' AS title,
        "Size (bytes)" as align_right,
        TRUE AS sort,
          TRUE AS search,
            TRUE AS hover,
              TRUE AS striped_rows,
                TRUE AS small,
                  'folder' AS markdown;
      SELECT '[' || folder_name || '](' || ${this.absoluteURL('/ur/uniform-resource-imap-mail-list.sql?folder_id=')} || ur_ingest_session_imap_acct_folder_id || ')' AS "folder"
        FROM ${viewName}
        WHERE ur_ingest_session_imap_account_id = $imap_account_id:: TEXT
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
      ${this.absoluteURL('/')}
    SELECT
      'Uniform Resource' AS title,
      ${this.absoluteURL('/ur/index.sql')} as link;
    SELECT
      'Uniform Resources (IMAP)' AS title,
      ${this.absoluteURL('/ur/uniform-resource-imap-account.sql')} AS link;
    SELECT
      'Folder' AS title,
      ${this.absoluteURL('/ur/uniform-resource-imap-folder.sql?imap_account_id=')}|| ur_ingest_session_imap_account_id AS link
      FROM ${viewName}
      WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

    SELECT
      folder_name AS title,
      ${this.absoluteURL('/ur/uniform-resource-imap-mail-list.sql?folder_id=')} || ur_ingest_session_imap_acct_folder_id AS link
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
                TRUE AS small,
                  'subject' AS markdown;;
    SELECT
    '[' || subject || '](uniform-resource-imap-mail-detail.sql?resource_id=' || uniform_resource_id || ')' AS "subject"
      , "from",
      CASE
          WHEN ROUND(julianday('now') - julianday(date)) = 0 THEN 'Today'
          WHEN ROUND(julianday('now') - julianday(date)) = 1 THEN '1 day ago'
          WHEN ROUND(julianday('now') - julianday(date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday('now') - julianday(date)) AS INT) || ' days ago'
          WHEN ROUND(julianday('now') - julianday(date)) < 30 THEN CAST(ROUND(julianday('now') - julianday(date)) AS INT) || ' days ago'
          WHEN ROUND(julianday('now') - julianday(date)) < 365 THEN CAST(ROUND((julianday('now') - julianday(date)) / 30) AS INT) || ' months ago'
          ELSE CAST(ROUND((julianday('now') - julianday(date)) / 365) AS INT) || ' years ago'
      END AS "Relative Time",
      strftime('%Y-%m-%d', substr(date, 1, 19)) as date
      FROM ${viewName}
      WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
      ORDER BY uniform_resource_id
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown("folder_id")}
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ur/uniform-resource-imap-mail-detail.sql"() {
    const viewName = `uniform_resource_imap`;
    return this.SQL`
    SELECT
    'breadcrumb' AS component;
    SELECT
    'Home' AS title,
      ${this.absoluteURL('/')}    AS link;
    SELECT
     'Uniform Resource' AS title,
      ${this.absoluteURL('/ur/index.sql')} AS link;
    SELECT
      'Uniform Resources (IMAP)' AS title,
      ${this.absoluteURL('/ur/uniform-resource-imap-account.sql')} AS link;
    SELECT
    'Folder' AS title,
      ${this.absoluteURL('/ur/uniform-resource-imap-folder.sql?imap_account_id=')} || ur_ingest_session_imap_account_id AS link
      FROM ${viewName}
      WHERE uniform_resource_id = $resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

    SELECT
       folder_name AS title,
      ${this.absoluteURL('/ur/uniform-resource-imap-mail-list.sql?folder_id=')} || ur_ingest_session_imap_acct_folder_id AS link
      FROM ${viewName}
      WHERE uniform_resource_id=$resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

    SELECT
       subject AS title,
      ${this.absoluteURL('/ur/uniform-resource-imap-mail-detail.sql?resource_id=')} || uniform_resource_id AS link
      FROM ${viewName}
      WHERE uniform_resource_id = $resource_id:: TEXT;

    --Breadcrumb ends-- -

      --- back button-- -
        select 'button' as component;
    select
    "<< Back" as title,
      ${this.absoluteURL('/ur/uniform-resource-imap-mail-list.sql?folder_id=')} || ur_ingest_session_imap_acct_folder_id as link
      FROM ${viewName}
      WHERE uniform_resource_id = $resource_id:: TEXT;

    --Display uniform_resource table with pagination
      SELECT
    'datagrid' as component;
    SELECT
    'From' as title,
      "from" as "description" FROM ${viewName} where uniform_resource_id=$resource_id::TEXT;
    SELECT
    'To' as title,
      email as "description" FROM ${viewName} where uniform_resource_id=$resource_id::TEXT;
    SELECT
    'Subject' as title,
      subject as "description" FROM ${viewName} where uniform_resource_id=$resource_id::TEXT;

      SELECT 'html' AS component;
      SELECT html_content AS html FROM uniform_resource_imap_content WHERE uniform_resource_id=$resource_id::TEXT ;
    `;
  }
}
