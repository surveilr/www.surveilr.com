import * as spn from "../notebook/sqlpage.ts";

export function msNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "ms/index.sql",
  });
}

export class OsqueryMsSqlPages extends spn.TypicalSqlPageNotebook {
  navigationDML() {
    return this.SQL`
          ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
        `;
  }

  surveilr_osquery_ms_node_process() {
    return this.SQL`
      DROP VIEW IF EXISTS surveilr_osquery_ms_node_process;
      CREATE VIEW surveilr_osquery_ms_node_process AS
      SELECT
          l.node_key,
          l.updated_at,
          json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
          json_extract(l.log_data, '$.columns.cgroup_path') AS cgroup_path,
          json_extract(l.log_data, '$.columns.cmdline') AS cmdline,
          json_extract(l.log_data, '$.columns.cwd') AS cwd,
          json_extract(l.log_data, '$.columns.disk_bytes_read') AS disk_bytes_read,
          json_extract(l.log_data, '$.columns.disk_bytes_written') AS disk_bytes_written,
          json_extract(l.log_data, '$.columns.egid') AS egid,
          json_extract(l.log_data, '$.columns.euid') AS euid,
          json_extract(l.log_data, '$.columns.gid') AS gid,
          json_extract(l.log_data, '$.columns.name') AS process_name,
          json_extract(l.log_data, '$.columns.nice') AS nice,
          json_extract(l.log_data, '$.columns.on_disk') AS on_disk,
          json_extract(l.log_data, '$.columns.parent') AS parent,
          json_extract(l.log_data, '$.columns.path') AS process_name,
          json_extract(l.log_data, '$.columns.pgroup') AS pgroup,
          json_extract(l.log_data, '$.columns.pid') AS pid,
          json_extract(l.log_data, '$.columns.resident_size') AS resident_size,
          json_extract(l.log_data, '$.columns.root') AS root,
          json_extract(l.log_data, '$.columns.sgid') AS sgid,
          json_extract(l.log_data, '$.columns.start_time') AS start_time,
          json_extract(l.log_data, '$.columns.state') AS state,
          json_extract(l.log_data, '$.columns.suid') AS suid,
          json_extract(l.log_data, '$.columns.system_time') AS system_time,
          json_extract(l.log_data, '$.columns.threads') AS threads,
          json_extract(l.log_data, '$.columns.total_size') AS total_size,
          json_extract(l.log_data, '$.columns.uid') AS uid,
          json_extract(l.log_data, '$.columns.user_time') AS user_time,
          json_extract(l.log_data, '$.columns.wired_size') AS wired_size
      FROM ur_ingest_session_osquery_ms_log AS l
      WHERE l.log_type = 'result'
          AND json_extract(l.log_data, '$.name') = 'All Processes';
    `;
  }

  surveilr_osquery_ms_node_interface_detail() {
    return this.SQL`
        DROP VIEW IF EXISTS surveilr_osquery_ms_node_interface_detail;
        CREATE VIEW surveilr_osquery_ms_node_interface_detail AS
        SELECT
            l.node_key,
            l.updated_at,
            json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
            json_extract(l.log_data, '$.columns.collisions') AS collisions,
            json_extract(l.log_data, '$.columns.flags') AS flags,
            json_extract(l.log_data, '$.columns.ibytes') AS ibytes,
            json_extract(l.log_data, '$.columns.idrops') AS idrops,
            json_extract(l.log_data, '$.columns.ierrors') AS ierrors,
            json_extract(l.log_data, '$.columns.interface') AS interface,
            json_extract(l.log_data, '$.columns.ipackets') AS ipackets,
            json_extract(l.log_data, '$.columns.last_change') AS last_change,
            json_extract(l.log_data, '$.columns.link_speed') AS link_speed,
            json_extract(l.log_data, '$.columns.mac') AS mac,
            json_extract(l.log_data, '$.columns.metric') AS metric,
            json_extract(l.log_data, '$.columns.mtu') AS mtu,
            json_extract(l.log_data, '$.columns.obytes') AS obytes,
            json_extract(l.log_data, '$.columns.odrops') AS odrops,
            json_extract(l.log_data, '$.columns.oerrors') AS oerrors,
            json_extract(l.log_data, '$.columns.opackets') AS opackets,
            json_extract(l.log_data, '$.columns.pci_slot') AS pci_slot,
            json_extract(l.log_data, '$.columns.type') AS type
        FROM ur_ingest_session_osquery_ms_log AS l
        WHERE l.log_type = 'result'
        AND json_extract(l.log_data, '$.name') = 'Interface Details';

    `;
  }

  surveilr_osquery_ms_node_listening_port() {
    return this.SQL`
      DROP VIEW IF EXISTS surveilr_osquery_ms_node_listening_port;
      CREATE VIEW surveilr_osquery_ms_node_listening_port AS
      SELECT
          l.node_key,
          l.updated_at,
          json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
          json_extract(l.log_data, '$.columns.family') AS family,
          json_extract(l.log_data, '$.columns.fd') AS fd,
          json_extract(l.log_data, '$.columns.address') AS address,
          json_extract(l.log_data, '$.columns.port') AS port,
          json_extract(l.log_data, '$.columns.net_namespace') AS net_namespace,
          json_extract(l.log_data, '$.columns.path') AS path,
          json_extract(l.log_data, '$.columns.pid') AS pid,
          json_extract(l.log_data, '$.columns.protocol') AS protocol,
          json_extract(l.log_data, '$.columns.socket') AS socket
      FROM ur_ingest_session_osquery_ms_log AS l
      WHERE l.log_type = 'result'
      AND json_extract(l.log_data, '$.name') = 'Listening Ports';
    `;
  }

  surveilr_osquery_ms_node_system_info() {
    return this.SQL`
      DROP VIEW IF EXISTS surveilr_osquery_ms_node_system_info;
      CREATE VIEW surveilr_osquery_ms_node_system_info AS
      SELECT
          l.node_key,
          l.updated_at,
          json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
          json_extract(l.log_data, '$.columns.board_model') AS board_model,
          json_extract(l.log_data, '$.columns.board_serial') AS board_serial,
          json_extract(l.log_data, '$.columns.board_vendor') AS board_vendor,
          json_extract(l.log_data, '$.columns.board_version') AS board_version,
          json_extract(l.log_data, '$.columns.computer_name') AS computer_name,
          json_extract(l.log_data, '$.columns.cpu_brand') AS cpu_brand,
          json_extract(l.log_data, '$.columns.cpu_logical_cores') AS cpu_logical_cores,
          json_extract(l.log_data, '$.columns.cpu_microcode') AS cpu_microcode,
          json_extract(l.log_data, '$.columns.cpu_physical_cores') AS cpu_physical_cores,
          json_extract(l.log_data, '$.columns.cpu_sockets') AS cpu_sockets,
          json_extract(l.log_data, '$.columns.cpu_subtype') AS cpu_subtype,
          json_extract(l.log_data, '$.columns.cpu_type') AS cpu_type,
          json_extract(l.log_data, '$.columns.hardware_model') AS hardware_model,
          json_extract(l.log_data, '$.columns.hardware_serial') AS hardware_serial,
          json_extract(l.log_data, '$.columns.hardware_vendor') AS hardware_vendor,
          json_extract(l.log_data, '$.columns.hardware_version') AS hardware_version,
          json_extract(l.log_data, '$.columns.hostname') AS hostname,
          json_extract(l.log_data, '$.columns.local_hostname') AS local_hostname,
          json_extract(l.log_data, '$.columns.physical_memory') AS physical_memory,
          json_extract(l.log_data, '$.columns.uuid') AS uuid
      FROM ur_ingest_session_osquery_ms_log AS l
      WHERE l.log_type = 'result'
      AND json_extract(l.log_data, '$.name') = 'System Information';
    `;
  }

  surveilr_osquery_ms_node_os_version() {
    return this.SQL`
      DROP VIEW IF EXISTS surveilr_osquery_ms_node_os_version;
      CREATE VIEW surveilr_osquery_ms_node_os_version AS
      SELECT
          l.node_key,
          l.updated_at,
          json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
          json_extract(l.log_data, '$.columns.name') AS name,
          json_extract(l.log_data, '$.columns.version') AS version,
          json_extract(l.log_data, '$.columns.major') AS major,
          json_extract(l.log_data, '$.columns.minor') AS minor,
          json_extract(l.log_data, '$.columns.patch') AS patch,
          json_extract(l.log_data, '$.columns.build') AS build,
          json_extract(l.log_data, '$.columns.platform') AS platform,
          json_extract(l.log_data, '$.columns.platform_like') AS platform_like,
          json_extract(l.log_data, '$.columns.codename') AS codename,
          json_extract(l.log_data, '$.columns.arch') AS arch
      FROM ur_ingest_session_osquery_ms_log AS l
      WHERE l.log_type = 'result'
      AND json_extract(l.log_data, '$.name') = 'OS Version';
    `;
  }

  surveilr_osquery_ms_node_interface_address() {
    return this.SQL`
        DROP VIEW IF EXISTS surveilr_osquery_ms_node_interface_address;
        CREATE VIEW surveilr_osquery_ms_node_interface_address AS
        SELECT
            l.node_key,
            l.updated_at,
            json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
            json_extract(l.log_data, '$.columns.address') AS address,
            json_extract(l.log_data, '$.columns.broadcast') AS broadcast,
            json_extract(l.log_data, '$.columns.interface') AS interface,
            json_extract(l.log_data, '$.columns.mask') AS mask,
            json_extract(l.log_data, '$.columns.point_to_point') AS point_to_point,
            json_extract(l.log_data, '$.columns.type') AS type
        FROM ur_ingest_session_osquery_ms_log AS l
        WHERE l.log_type = 'result'
        AND json_extract(l.log_data, '$.name') = 'Interface Addresses';
    `;
  }

  surveilr_osquery_ms_node_uptime() {
    return this.SQL`
      DROP VIEW IF EXISTS surveilr_osquery_ms_node_uptime;
      CREATE VIEW surveilr_osquery_ms_node_uptime AS
      SELECT
          l.node_key,
          l.updated_at,
          json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
          json_extract(l.log_data, '$.columns.days') AS days,
          json_extract(l.log_data, '$.columns.hours') AS hours,
          json_extract(l.log_data, '$.columns.minutes') AS minutes,
          json_extract(l.log_data, '$.columns.seconds') AS seconds,
          json_extract(l.log_data, '$.columns.total_seconds') AS total_seconds
      FROM ur_ingest_session_osquery_ms_log AS l
      WHERE l.log_type = 'result'
      AND json_extract(l.log_data, '$.name') = 'Server Uptime'
      ORDER BY l.created_at DESC
      LIMIT 1;
    `;
  }

  surveilr_osquery_ms_node_available_space() {
    return this.SQL`
      DROP VIEW IF EXISTS surveilr_osquery_ms_node_available_space;
      CREATE VIEW surveilr_osquery_ms_node_available_space AS
      SELECT
          l.node_key,
          l.updated_at,
          json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
          json_extract(l.log_data, '$.columns.available_space') AS available_space,
          json_extract(l.log_data, '$.columns.path') AS path
      FROM ur_ingest_session_osquery_ms_log AS l
      WHERE l.log_type = 'result'
      AND json_extract(l.log_data, '$.name') = 'Available Disk Space'
      ORDER BY l.created_at DESC
      LIMIT 1;
    `;
  }

  surveilr_osquery_ms_node_detail() {
    return this.SQL`
      DROP VIEW IF EXISTS surveilr_osquery_ms_node_detail;
      CREATE VIEW surveilr_osquery_ms_node_detail AS
      SELECT
          n.surveilr_osquery_ms_node_id,
          n.node_key,
          n.host_identifier,
          n.osquery_version,
          n.last_seen,
          n.created_at,
          i.updated_at,
          i.address AS ip_address,
          i.broadcast,
          i.mask,
          CASE 
            WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 60 THEN 
              (strftime('%s', 'now') - strftime('%s', n.created_at)) || ' seconds ago'
            WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 3600 THEN 
              ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 60) || ' minutes ago'
            WHEN (strftime('%s', 'now') - strftime('%s', n.created_at)) < 86400 THEN 
              ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 3600) || ' hours ago'
            ELSE 
              ((strftime('%s', 'now') - strftime('%s', n.created_at)) / 86400) || ' days ago'
          END AS added_to_surveilr_osquery_ms,
          o.name || ' ' || o.version AS operating_system,
          round(a.available_space, 2) || ' GB' AS available_space,
          CASE 
            WHEN (strftime('%s', 'now') - strftime('%s', last_seen)) < 60 THEN 'Online'
            ELSE 'Offline'
          END AS node_status,
          CASE 
            WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 60 THEN 
              (strftime('%s', 'now') - strftime('%s', n.last_seen)) || ' seconds ago'
            WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 3600 THEN 
              ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 60) || ' minutes ago'
            WHEN (strftime('%s', 'now') - strftime('%s', n.last_seen)) < 86400 THEN 
              ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 3600) || ' hours ago'
            ELSE 
              ((strftime('%s', 'now') - strftime('%s', n.last_seen)) / 86400) || ' days ago'
          END AS last_fetched,
          CASE
            WHEN CAST(u.days AS INTEGER) > 0 THEN 
                'about ' || u.days || ' day' || (CASE WHEN CAST(u.days AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
            WHEN CAST(u.hours AS INTEGER) > 0 THEN 
                'about ' || u.hours || ' hour' || (CASE WHEN CAST(u.hours AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
            WHEN CAST(u.minutes AS INTEGER) > 0 THEN 
                'about ' || u.minutes || ' minute' || (CASE WHEN CAST(u.minutes AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
            ELSE 
                'about ' || u.seconds || ' second' || (CASE WHEN CAST(u.seconds AS INTEGER) = 1 THEN '' ELSE 's' END) || ' ago'
          END AS last_restarted
      FROM surveilr_osquery_ms_node n
      LEFT JOIN surveilr_osquery_ms_node_available_space a
        ON n.node_key = a.node_key
      LEFT JOIN surveilr_osquery_ms_node_os_version o 
        ON n.node_key = o.node_key
      LEFT JOIN surveilr_osquery_ms_node_uptime u
        ON n.node_key = u.node_key
      LEFT JOIN surveilr_osquery_ms_node_interface_address i
        ON n.node_key = i.node_key
          AND i.interface = 'eth0'
          -- this only selects the IPv4 addresses for now
          AND i.address LIKE '%.%';
    `;
  }

  installed_software_view() {
    return this.SQL`
    DROP VIEW IF EXISTS surveilr_osquery_ms_node_installed_software;

    CREATE VIEW surveilr_osquery_ms_node_installed_software AS
    SELECT
        l.node_key,
        l.updated_at,
        json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
        json_extract(l.log_data, '$.columns.name') AS name,
        json_extract(l.log_data, '$.columns.source') AS source,
        json_extract(l.log_data, '$.columns.type') AS type,
        json_extract(l.log_data, '$.columns.version') AS version,
        CASE
            WHEN json_extract(l.log_data, '$.name') = 'Installed Linux software' THEN 'linux'
            WHEN json_extract(l.log_data, '$.name') = 'Installed Macos software' THEN 'macos'
            WHEN json_extract(l.log_data, '$.name') = 'Installed Windows software' THEN 'windows'
            ELSE 'unknown'
        END AS platform
    FROM ur_ingest_session_osquery_ms_log AS l
    WHERE l.log_type = 'result'
      AND (
          json_extract(l.log_data, '$.name') = 'Installed Linux software' OR
          json_extract(l.log_data, '$.name') = 'Installed Macos software' OR
          json_extract(l.log_data, '$.name') = 'Installed Windows software'
      );
    `;
  }

  surveilr_osquery_ms_node_executed_policy() {
    return this.SQL`
    DROP VIEW IF EXISTS surveilr_osquery_ms_node_executed_policy;
    CREATE VIEW surveilr_osquery_ms_node_executed_policy AS
    WITH ranked_policies AS (
        SELECT
            l.node_key,
            l.updated_at,
            json_extract(l.log_data, '$.hostIdentifier') AS host_identifier,
            json_extract(l.log_data, '$.name') AS policy_name,
            json_extract(l.log_data, '$.columns.policy_result') AS policy_result,
            ROW_NUMBER() OVER (PARTITION BY json_extract(l.log_data, '$.name') ORDER BY l.created_at DESC) AS row_num
        FROM ur_ingest_session_osquery_ms_log AS l
        WHERE l.log_type = 'result'
          AND json_extract(l.log_data, '$.name') IN (
              'SSH keys encrypted', 
              'Full disk encryption enabled (Linux)', 
              'Full disk encryption enabled (Windows)', 
              'Full disk encryption enabled (Macos)'
          )
    )
    SELECT
        ranked_policies.node_key,
        ranked_policies.updated_at,
        ranked_policies.host_identifier,
        ranked_policies.policy_name,
        CASE 
            WHEN ranked_policies.policy_result = 'true' THEN 'Pass'
            ELSE 'Fail'
        END AS policy_result,
        CASE 
            WHEN ranked_policies.policy_result = 'true' THEN '-'
            ELSE json_extract(c.cell_governance, '$.policy.resolution')
        END AS resolution
    FROM ranked_policies
    JOIN code_notebook_cell c
        ON ranked_policies.policy_name = c.cell_name
    WHERE ranked_policies.row_num = 1;  -- Only select the most recent entry for each policy
    `;
  }

  supportDDL() {
    return this.SQL`
      ${this.surveilr_osquery_ms_node_process()}
      ${this.surveilr_osquery_ms_node_interface_detail()}   
      ${this.surveilr_osquery_ms_node_listening_port()}
      ${this.surveilr_osquery_ms_node_system_info()}
      ${this.surveilr_osquery_ms_node_os_version()}
      ${this.surveilr_osquery_ms_node_interface_address()}
      ${this.surveilr_osquery_ms_node_uptime()}
      ${this.surveilr_osquery_ms_node_available_space()}
      ${this.surveilr_osquery_ms_node_detail()}
      ${this.installed_software_view()}
      ${this.surveilr_osquery_ms_node_executed_policy()}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "osQuery Management Server",
    description: "Explore details about all nodes",
  })
  "ms/index.sql"() {
    return this.SQL`
        SELECT 'title' AS component, 'All Registered Nodes' as contents;
        SELECT 'table' AS component,
            'Node' as markdown,
            TRUE as sort,
            TRUE as search;

        SELECT 
          '[' || host_identifier || '](node.sql?key=' || node_key || '&host_id=' || host_identifier || ')' AS "Node",
          node_status as "Status",
          0 as "Issues",
          available_space AS "Disk space available",
          operating_system AS "Operating Sytem",
          osquery_version AS "osQuery Version",
          ip_address AS "IP Address",
          last_fetched as "Last Fetched",
          last_restarted AS "Last Restarted"
        FROM surveilr_osquery_ms_node_detail;

        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ms/node.sql"() {
    const viewName = `surveilr_osquery_ms_node_installed_software`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "WHERE node_key = $key AND $tab = 'software'",
    });

    return this.SQL`
    ${this.activeBreadcrumbsSQL({ titleExpr: `$host_id || ' Node'` })}

    -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
    ${pagination.init()}

      SELECT 'title' as component, $host_id as contents, 2  as level;
      SELECT 'text' as component, 'Last fetched ' || "last_fetched" as contents, 1 as size FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;

      SELECT 'datagrid' as component;
      SELECT 'Status' as title, "node_status" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
      SELECT 'Issues' as title, "0" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
      SELECT 'Disk space' as title, "available_space" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
      SELECT 'Memory' as title, ROUND("physical_memory" / (1024 * 1024 * 1024), 2) || ' GB' AS description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
      SELECT 'Processor Type' as title, "cpu_type" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
      SELECT 'Operating system' as title, "operating_system" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
      SELECT 'osQuery' as title, "osquery_version" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;

      -- Define tabs
      SELECT 'tab' AS component, TRUE AS center;

      -- Tab 1: Details
      SELECT 'Details' AS title, '?tab=details&key=' || $key || '&host_id=' || $host_id AS link, $tab = 'details' AS active;

      -- Tab 2: Software
      SELECT 'Software' AS title, '?tab=software&key=' || $key || '&host_id=' || $host_id AS link, $tab = 'software' AS active;

      -- Tab 2: Software
      SELECT 'Policies' AS title, '?tab=policies&key=' || $key || '&host_id=' || $host_id AS link, $tab = 'policies' AS active;

      -- Tab specific content for Details
      select 'text' as component, 'About' as title, 2 as size WHERE $tab = 'details' OR $tab IS NULL;
      SELECT 'datagrid' as component WHERE $tab = 'details' OR $tab IS NULL;
      SELECT 'Added to surveilr' as title, "added_to_surveilr_osquery_ms" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key AND ($tab = 'details' OR $tab IS NULL);
      SELECT 'Last Restarted' as title, "last_restarted" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key AND ($tab = 'details' OR $tab IS NULL);
      SELECT 'Hardware Model' as title, "hardware_model" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key AND ($tab = 'details' OR $tab IS NULL);
      SELECT 'Serial Number' as title, "hardware_serial" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key AND ($tab = 'details' OR $tab IS NULL);
      SELECT 'IP Address' as title, "ip_address" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key AND ($tab = 'details' OR $tab IS NULL);

      -- Tab specific content for Software
      select 'text' as component, 'Software' as title WHERE $tab = 'software';

      SELECT 'table' AS component, TRUE as sort, TRUE as search WHERE $tab = 'software';
      SELECT name, version, type, platform, '-' AS "Vulnerabilities"
        FROM surveilr_osquery_ms_node_installed_software
        WHERE node_key = $key AND $tab = 'software'
        LIMIT $limit OFFSET $offset;

      ${pagination.renderSimpleMarkdown("key", "host_id", "tab")};
      
      -- Tab specific content for Policies
      select 'text' as component, 'Policies' as title WHERE $tab = 'software';
      SELECT 'table' AS component, TRUE as sort, TRUE as search WHERE $tab = 'policies';
      SELECT policy_name AS "Policy", policy_result as "Status", resolution
        FROM surveilr_osquery_ms_node_executed_policy
        WHERE node_key = $key AND $tab = 'policies';
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ms/process.sql"() {
    return this.SQL`
        ${this.activeBreadcrumbsSQL({ titleExpr: `$host_id || ' Processes'` })}
        SELECT 'title' AS component, 'All Running Processes on ' || $host_id as contents;
        SELECT 'table' AS component,
            TRUE as sort,
            TRUE as search;

        SELECT 
            node_key as "osQuery Node Key",
            host_identifier as "Host Identifier",
            updated_at as "Report Time",
            cgroup_path, cmdline, cwd,
            disk_bytes_read, disk_bytes_written, 
            egid, euid,
            gid, process_name, nice, on_disk,
            parent, process_name, pgroup, pid, 
            resident_size, root, 
            sgid, start_time, state, suid, system_time,
            threads, total_size,
            uid, user_time, wired_size
        FROM surveilr_osquery_ms_node_process WHERE node_key = $key;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ms/network.sql"() {
    return this.SQL`
        ${
      this.activeBreadcrumbsSQL({
        titleExpr: `$host_id || ' Interface Details'`,
      })
    }
        SELECT 'title' AS component, 'Interface Details' as contents;
        SELECT 'table' AS component,
            TRUE as sort,
            TRUE as search;

        SELECT 
            updated_at as "Report Time", 
            collisions, flags, type, ibytes, idrops, ierrors, ipackets, last_change
            collisions, interface, link_speed, type, metric, pci_slot, mac, mtu,
            obytes, odrops, oerrors, opackets
        FROM surveilr_osquery_ms_node_interface_detail WHERE node_key = $key;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ms/open-socket.sql"() {
    return this.SQL`
        ${
      this.activeBreadcrumbsSQL({ titleExpr: `$host_id || ' Listening Ports'` })
    }
        SELECT 'title' AS component, 'Listening Ports on ' || $host_id as contents;
        SELECT 'table' AS component,
            TRUE as sort,
            TRUE as search;

        SELECT 
            node_key as "osQuery Node Key",
            host_identifier as "Host Identifier",
            updated_at as "Report Time",
            family, fd, 
            address, port,
            net_namespace, path, pid, protocol, socket
        FROM surveilr_osquery_ms_node_listening_port WHERE node_key = $key;
        `;
  }
}
