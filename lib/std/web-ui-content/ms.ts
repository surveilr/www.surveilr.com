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

  supportDDL() {
    return this.SQL`
            DROP VIEW IF EXISTS surveilr_osquery_ms_processes;
            CREATE VIEW surveilr_osquery_ms_processes AS
            SELECT
                l.node_key,
                json_extract(j.value, '$.hostIdentifier') AS host_identifier,
                json_extract(j.value, '$.calendarTime') AS calendar_time,
                json_extract(j.value, '$.columns.cgroup_path') AS cgroup_path,
                json_extract(j.value, '$.columns.cmdline') AS cmdline,
                json_extract(j.value, '$.columns.cwd') AS cwd,
                json_extract(j.value, '$.columns.disk_bytes_read') AS disk_bytes_read,
                json_extract(j.value, '$.columns.disk_bytes_written') AS disk_bytes_written,
                json_extract(j.value, '$.columns.egid') AS egid,
                json_extract(j.value, '$.columns.euid') AS euid,
                json_extract(j.value, '$.columns.gid') AS gid,
                json_extract(j.value, '$.columns.name') AS process_name,
                json_extract(j.value, '$.columns.nice') AS nice,
                json_extract(j.value, '$.columns.on_disk') AS on_disk,
                json_extract(j.value, '$.columns.parent') AS parent,
                json_extract(j.value, '$.columns.path') AS process_name,
                json_extract(j.value, '$.columns.pgroup') AS pgroup,
                json_extract(j.value, '$.columns.pid') AS pid,
                json_extract(j.value, '$.columns.resident_size') AS resident_size,
                json_extract(j.value, '$.columns.root') AS root,
                json_extract(j.value, '$.columns.sgid') AS sgid,
                json_extract(j.value, '$.columns.start_time') AS start_time,
                json_extract(j.value, '$.columns.state') AS state,
                json_extract(j.value, '$.columns.suid') AS suid,
                json_extract(j.value, '$.columns.system_time') AS system_time,
                json_extract(j.value, '$.columns.threads') AS threads,
                json_extract(j.value, '$.columns.total_size') AS total_size,
                json_extract(j.value, '$.columns.uid') AS uid,
                json_extract(j.value, '$.columns.user_time') AS user_time,
                json_extract(j.value, '$.columns.wired_size') AS wired_size
            FROM ur_ingest_session_surveilr_osquery_ms_log AS l,
                json_each(l.log_data) AS j
            WHERE l.log_type = 'result'
                AND json_extract(j.value, '$.name') = 'tls_proc';


        DROP VIEW IF EXISTS surveilr_osquery_ms_interface_details;
        CREATE VIEW surveilr_osquery_ms_interface_details AS
        SELECT
            l.node_key,
            json_extract(j.value, '$.hostIdentifier') AS host_identifier,
            json_extract(j.value, '$.calendarTime') AS calendar_time,
            json_extract(j.value, '$.columns.collisions') AS collisions,
            json_extract(j.value, '$.columns.flags') AS flags,
            json_extract(j.value, '$.columns.ibytes') AS ibytes,
            json_extract(j.value, '$.columns.idrops') AS idrops,
            json_extract(j.value, '$.columns.ierrors') AS ierrors,
            json_extract(j.value, '$.columns.interface') AS interface,
            json_extract(j.value, '$.columns.ipackets') AS ipackets,
            json_extract(j.value, '$.columns.last_change') AS last_change,
            json_extract(j.value, '$.columns.link_speed') AS link_speed,
            json_extract(j.value, '$.columns.mac') AS mac,
            json_extract(j.value, '$.columns.metric') AS metric,
            json_extract(j.value, '$.columns.mtu') AS mtu,
            json_extract(j.value, '$.columns.obytes') AS obytes,
            json_extract(j.value, '$.columns.odrops') AS odrops,
            json_extract(j.value, '$.columns.oerrors') AS oerrors,
            json_extract(j.value, '$.columns.opackets') AS opackets,
            json_extract(j.value, '$.columns.pci_slot') AS pci_slot,
            json_extract(j.value, '$.columns.type') AS type
        FROM ur_ingest_session_surveilr_osquery_ms_log AS l,
            json_each(l.log_data) AS j
        WHERE l.log_type = 'result'
        AND json_extract(j.value, '$.name') = 'interface_details';

        DROP VIEW IF EXISTS surveilr_osquery_ms_open_sockets;
        CREATE VIEW surveilr_osquery_ms_open_sockets AS
        SELECT
            l.node_key,
            json_extract(j.value, '$.hostIdentifier') AS host_identifier,
            json_extract(j.value, '$.calendarTime') AS calendar_time,
            json_extract(j.value, '$.columns.family') AS family,
            json_extract(j.value, '$.columns.fd') AS fd,
            json_extract(j.value, '$.columns.local_address') AS local_address,
            json_extract(j.value, '$.columns.local_port') AS local_port,
            json_extract(j.value, '$.columns.net_namespace') AS net_namespace,
            json_extract(j.value, '$.columns.path') AS path,
            json_extract(j.value, '$.columns.pid') AS pid,
            json_extract(j.value, '$.columns.protocol') AS protocol,
            json_extract(j.value, '$.columns.remote_address') AS remote_address,
            json_extract(j.value, '$.columns.remote_port') AS remote_port,
            json_extract(j.value, '$.columns.socket') AS socket,
            json_extract(j.value, '$.columns.state') AS state
        FROM ur_ingest_session_surveilr_osquery_ms_log AS l,
            json_each(l.log_data) AS j
        WHERE l.log_type = 'result'
        AND json_extract(j.value, '$.name') = 'process_open_sockets';

        DROP VIEW IF EXISTS surveilr_osquery_ms_system_info;
        CREATE VIEW surveilr_osquery_ms_system_info AS
        SELECT
            l.node_key,
            json_extract(j.value, '$.hostIdentifier') AS host_identifier,
            json_extract(j.value, '$.calendarTime') AS calendar_time,
            json_extract(j.value, '$.columns.board_model') AS board_model,
            json_extract(j.value, '$.columns.board_serial') AS board_serial,
            json_extract(j.value, '$.columns.board_vendor') AS board_vendor,
            json_extract(j.value, '$.columns.board_version') AS board_version,
            json_extract(j.value, '$.columns.computer_name') AS computer_name,
            json_extract(j.value, '$.columns.cpu_brand') AS cpu_brand,
            json_extract(j.value, '$.columns.cpu_logical_cores') AS cpu_logical_cores,
            json_extract(j.value, '$.columns.cpu_microcode') AS cpu_microcode,
            json_extract(j.value, '$.columns.cpu_physical_cores') AS cpu_physical_cores,
            json_extract(j.value, '$.columns.cpu_sockets') AS cpu_sockets,
            json_extract(j.value, '$.columns.cpu_subtype') AS cpu_subtype,
            json_extract(j.value, '$.columns.cpu_type') AS cpu_type,
            json_extract(j.value, '$.columns.hardware_model') AS hardware_model,
            json_extract(j.value, '$.columns.hardware_serial') AS hardware_serial,
            json_extract(j.value, '$.columns.hardware_vendor') AS hardware_vendor,
            json_extract(j.value, '$.columns.hardware_version') AS hardware_version,
            json_extract(j.value, '$.columns.hostname') AS hostname,
            json_extract(j.value, '$.columns.local_hostname') AS local_hostname,
            json_extract(j.value, '$.columns.physical_memory') AS physical_memory,
            json_extract(j.value, '$.columns.uuid') AS uuid
        FROM ur_ingest_session_surveilr_osquery_ms_log AS l,
            json_each(l.log_data) AS j
        WHERE l.log_type = 'result'
        AND json_extract(j.value, '$.name') = 'system_info';

        `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Osquery Management Server Details",
    description: "Explore details about all nodes",
  })
  "ms/index.sql"() {
    return this.SQL`
              WITH navigation_cte AS (
              SELECT COALESCE(title, caption) as title, description
                  FROM sqlpage_aide_navigation
              WHERE namespace = 'prime' AND path = ${
      this.constructHomePath("ms")
    }
              )
              SELECT 'list' AS component, title, description
                  FROM navigation_cte;
              SELECT caption as title, ${
      this.absoluteURL("/")
    } || COALESCE(url, path) as link, description
                  FROM sqlpage_aide_navigation
              WHERE namespace = 'prime' AND parent_path =  ${
      this.constructHomePath("ms")
    }
              ORDER BY sibling_order;
          `;
  }

  @msNav({
    caption: "Nodes",
    description: "All Connected Machines",
    siblingOrder: 99,
  })
  "ms/nodes.sql"() {
    return this.SQL`
            SELECT 'title' AS component, 'Brief Details About Nodes' as contents;
             SELECT 'table' AS component,
                TRUE as sort,
                TRUE as search;

                SELECT 
                node_key as "Node Key",
                host_identifier as "Identifier",
                platform as "OS",
                os_version as "OS Version",
                last_seen as 'Last Seen',
                status as status
                FROM surveilr_osquery_ms_node;
        `;
  }

  @msNav({
    caption: "Processes",
    description:
      "Identify what processes are running (helpful to see if unauthorized processes are active).",
    siblingOrder: 99,
  })
  "ms/process.sql"() {
    return this.SQL`
            SELECT 'title' AS component, 'Running Processes' as contents;
             SELECT 'table' AS component,
                TRUE as sort,
                TRUE as search;

                SELECT 
                node_key as "Node Key",
                host_identifier as "Identifier",
                calendar_time as "Report Time",
                cgroup_path, cmdline, cwd,
                disk_bytes_read, disk_bytes_written, 
                egid, euid,
                gid, process_name, nice, on_disk,
                parent, process_name, pgroup, pid, 
                resident_size, root, 
                sgid, start_time, state, suid, system_time,
                threads, total_size,
                uid, user_time, wired_size
                FROM surveilr_osquery_ms_processes;
        `;
  }

  @msNav({
    caption: "Node Information",
    description: "Detailed System information",
    siblingOrder: 99,
  })
  "ms/info.sql"() {
    return this.SQL`
            SELECT 'title' AS component, 'Detailed Sytem Information' as contents;
             SELECT 'table' AS component,
                TRUE as sort,
                TRUE as search;

                SELECT 
                host_identifier as "Identifier",
                calendar_time,
                *
                FROM surveilr_osquery_ms_system_info;
        `;
  }

  //   @msNav({
  //     caption: "Node Operating Sytem",
  //     description: "Operating System version and details",
  //     siblingOrder: 99,
  //   })
  //   "ms/os.sql"() {
  //     return this.SQL`
  //         SELECT 'title' AS component, 'Bri' as contents;
  //          SELECT 'table' AS component,
  //             TRUE as sort,
  //             TRUE as search;

  //             SELECT
  //             node_key as "Node Key",
  //             host_identifier as "Identifier",
  //             platform as "OS",
  //             os_version as "OS Version",
  //             last_seen as 'Last Seen',
  //             status as status
  //             FROM surveilr_osquery_ms_node;
  //     `
  //   }

  //   @msNav({
  //     caption: "User Accounts",
  //     description: "Verify which user accounts exist and check for unexpected accounts.",
  //     siblingOrder: 99,
  //   })
  //   "ms/users.sql"() {
  //     return this.SQL`
  //         SELECT 'title' AS component, 'Brief Details About Nodes' as contents;
  //          SELECT 'table' AS component,
  //             TRUE as sort,
  //             TRUE as search;

  //             SELECT
  //             node_key as "Node Key",
  //             host_identifier as "Identifier",
  //             platform as "OS",
  //             os_version as "OS Version",
  //             last_seen as 'Last Seen',
  //             status as status
  //             FROM surveilr_osquery_ms_node;
  //     `
  //   }

  @msNav({
    caption: "Network Interface Details",
    description: "An audit of interfaces, IP addresses, and network masks.",
    siblingOrder: 99,
  })
  "ms/network.sql"() {
    return this.SQL`
            SELECT 'title' AS component, 'Network Interfaces' as contents;
             SELECT 'table' AS component,
                TRUE as sort,
                TRUE as search;

                SELECT 
                node_key as "Node Key",
                host_identifier as "Identifier",
                calendar_time as "Report Time", flags,
                collisions, interface, link_speed, type, metric, pci_slot, mac
                FROM surveilr_osquery_ms_interface_details;
        `;
  }

  //   @msNav({
  //     caption: "IP Configuration",
  //     description: "An audit of interfaces, IP addresses, and network masks.",
  //     siblingOrder: 99,
  //   })
  //   "ms/ip_config.sql"() {
  //     return this.SQL`
  //         SELECT 'title' AS component, 'Brief Details About Nodes' as contents;
  //          SELECT 'table' AS component,
  //             TRUE as sort,
  //             TRUE as search;

  //             SELECT
  //             node_key as "Node Key",
  //             host_identifier as "Identifier",
  //             platform as "OS",
  //             os_version as "OS Version",
  //             last_seen as 'Last Seen',
  //             status as status
  //             FROM surveilr_osquery_ms_node;
  //     `
  //   }

  @msNav({
    caption: "Process Open Sockets",
    description: "Verify network connections.",
    siblingOrder: 99,
  })
  "ms/open_socket.sql"() {
    return this.SQL`
            SELECT 'title' AS component, 'Sockets' as contents;
             SELECT 'table' AS component,
                TRUE as sort,
                TRUE as search;

                SELECT 
                node_key as "Node Key",
                host_identifier as "Identifier",
                calendar_time as "Report Time",
                family, fd, 
                local_address, local_port,
                net_namespace, path, pid, protocol,
                remote_address, remote_port,
                socket, state
                FROM surveilr_osquery_ms_open_sockets;
        `;
  }

  //   @msNav({
  //     caption: "Process Open File Descriptors",
  //     description: "View and verify open ports running.",
  //     siblingOrder: 99,
  //   })
  //   "ms/ports.sql"() {
  //     return this.SQL`
  //         SELECT 'title' AS component, 'Brief Details About Nodes' as contents;
  //          SELECT 'table' AS component,
  //             TRUE as sort,
  //             TRUE as search;

  //             SELECT
  //             node_key as "Node Key",
  //             host_identifier as "Identifier",
  //             platform as "OS",
  //             os_version as "OS Version",
  //             last_seen as 'Last Seen',
  //             status as status
  //             FROM surveilr_osquery_ms_node;
  //     `
  //   }
}
