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

        DROP VIEW IF EXISTS surveilr_osquery_ms_node_detail;
        CREATE VIEW surveilr_osquery_ms_node_detail AS
        SELECT
            n.surveilr_osquery_ms_node_id,
            n.node_key,
            n.host_identifier,
            n.tls_cert_subject,
            n.os_version,
            n.platform,
            n.last_seen,
            n.status,
            n.device_id,
            n.behavior_id,
            i.updated_at,
            i.address AS ip_address,
            i.broadcast,
            i.mask,
            i.point_to_point,
            i.type
        FROM surveilr_osquery_ms_node n
        LEFT JOIN surveilr_osquery_ms_node_interface_address i
        ON n.node_key = i.node_key
            AND i.interface = 'eth0'
            -- this only selects the IPv4 addresses for now
            AND i.address LIKE '%.%';

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
            'osQuery Node Key' as markdown,
            TRUE as sort,
            TRUE as search;

        SELECT 
            '[' || node_key || '](node.sql?key=' || node_key || '&host_id=' || host_identifier || ')' as "osQuery Node Key",
            host_identifier as "Host Identifier",
            platform as "OS",
            os_version as "OS Version",
            last_seen as 'Last Seen',
            status as status,
            ip_address, mask
        FROM surveilr_osquery_ms_node_detail;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ms/node.sql"() {
    return this.SQL`
            ${this.activeBreadcrumbsSQL({ titleExpr: `$host_id || ' Node'` })}
            
            SELECT 'datagrid' as component;
            SELECT 'Computer Name' as title, "computer_name" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
            SELECT 'Cpu Brand' as title, "cpu_brand" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
            SELECT 'cpu_type' as title, "cpu_type" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
            SELECT 'cpu_logical_cores' as title, "cpu_logical_cores" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
            SELECT 'physical_memory' as title, ROUND("physical_memory" / (1024 * 1024 * 1024), 2) || ' GB' AS description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;

            SELECT 'list' as component;
            SELECT 
                'Processes' as title, 
                'Identify what processes are running (helpful to see if unauthorized processes are active).' as description,
                'process.sql?key=' || $key || '&host_id=' || $host_id as link;

            SELECT 
                'Interface Details' as title, 
                'Detailed information and stats of network interfaces for ' || $host_id as description,
                'network.sql?key=' || $key || '&host_id=' || $host_id as link;

             SELECT 
                'Listening Ports' as title, 
                'Processes with listening (bound) network sockets/ports on ' || $host_id as description,
                'open-socket.sql?key=' || $key || '&host_id=' || $host_id as link;
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
