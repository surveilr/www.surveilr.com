#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { codeNB as cnb, RssdInitSqlNotebook } from "./deps.ts";

const osQueryMsNotebookName = "osQuery Management Server (Prime)" as const;
const osQueryMsCellGovernance = {
  "osquery-ms-interval": 60,
  "results-uniform-resource-store-jq-filters": [
    "del(.calendarTime, .unixTime, .action, .counter)",
  ],
  "results-uniform-resource-captured-jq-filters": [
    "{calendarTime, unixTime}",
  ],
};

function osQueryMsCell(
  init?: Omit<
    Parameters<typeof cnb.sqlCell>[0],
    "notebook_name" | "cell_governance"
  >,
  targets: string[] = ["darwin", "windows", "linux"],
  singleton: boolean = false,
  extraFilters: string[] = [],
) {
  const cellGovernance = JSON.stringify({
    ...osQueryMsCellGovernance,
    "results-uniform-resource-store-jq-filters": [
      ...osQueryMsCellGovernance["results-uniform-resource-store-jq-filters"],
      ...extraFilters,
    ],
    targets,
    singleton,
  });

  return cnb.sqlCell<RssdInitSqlNotebook>({
    ...init,
    notebook_name: osQueryMsNotebookName,
    cell_governance: cellGovernance,
  }, (dc, methodCtx) => {
    // Using arrow function to preserve context
    methodCtx.addInitializer(() => {
      // Get access to the instance via closure instead of thisValue
      // Store in a global registry that can be accessed later
      const methodName = String(methodCtx.name); // Explicit conversion to string

      // Access the instance using the global registry approach
      // This is a workaround since we can't directly access the instance
      if (globalRegistry.instance) {
        globalRegistry.instance.migratableCells.set(methodName, dc);
      } else {
        console.error(`Error: No instance available for ${methodName}`);
      }
    });
    // we're not modifying the DecoratedCell
    return dc;
  });
}

// Create a global registry to store the class instance
// This is a workaround for the decorator context limitations
const globalRegistry: {
  instance: SurveilrOsqueryMsQueries | null
} = {
  instance: null
};

export class SurveilrOsqueryMsQueries extends cnb.TypicalCodeNotebook {
  // Initialize this immediately to avoid undefined issues
  readonly migratableCells: Map<string, cnb.DecoratedCell<"SQL">> = new Map();

  constructor() {
    super("rssd-init");
    // Register this instance in the global registry
    globalRegistry.instance = this;
  }

  // @osQueryMsCell({
  //   description: "Docker system information.",
  // }, ["darwin", "linux"])
  // "Docker System Information"() {
  //   return `select * from docker_info;`;
  // }

  @osQueryMsCell({
    description: "List Containers.",
  }, ["linux"])
  "List Containers"() {
    return `SELECT id, name, image, image_id, status, state, created, pid FROM docker_containers;`;
  }

  @osQueryMsCell({
    description: "List Container Images.",
  }, ["linux"])
  "List Container Images"() {
    return `SELECT * FROM docker_images;`;
  }

  @osQueryMsCell({
    description: "Container Network Information.",
  }, ["linux"])
  "Container Network Information"() {
    return `SELECT id, ip_address FROM docker_container_networks;`;
  }

  @osQueryMsCell({
    description: "List Container Volumes.",
  }, ["linux"])
  "List Container Volumes"() {
    return `SELECT mount_point, name FROM docker_volumes;`;
  }

  @osQueryMsCell({
    description: "Container Daemon Info.",
  }, ["linux"])
  "Container Daemon Info"() {
    return `SELECT 
              cgroup_path,
              cmdline,
              cwd,
              disk_bytes_read,
              disk_bytes_written,
              egid,
              euid,
              gid,
              name,
              nice,
              on_disk,
              parent,
              path,
              pgroup,
              pid,
              root,
              sgid,
              strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) AS start_time,
              state,
              suid,
              threads,
              total_size,
              uid,
              wired_size
            FROM processes WHERE name = 'dockerd';`;
  }

  @osQueryMsCell({
    description: "Docker host Info.",
  }, ["linux"])
  "Docker host Info"() {
    return `SELECT os, os_type, architecture, cpus, memory FROM docker_info;`;
  }

  @osQueryMsCell({
    description: "Docker Image.",
  }, ["linux"])
  "Docker Image"() {
    return `SELECT SUBSTR(id, 0, 8) AS id, strftime('%d-%m-%Y ', datetime(created, 'unixepoch')) AS created, size_bytes, tags FROM docker_images WHERE LENGTH(tags) < 20 AND tags <> '' AND tags != '<none>:<none>' LIMIT 5;`;
  }

  @osQueryMsCell({
    description: "Docker Network.",
  }, ["linux"])
  "Docker Network"() {
    return `SELECT SUBSTR(id, 0, 8) AS container, name, SUBSTR(network_id, 0, 8) AS network, gateway, ip_address FROM docker_container_networks WHERE name = 'appliance';`;
  }

  @osQueryMsCell({
    description: "Docker version information.",
  }, ["darwin", "linux"])
  "Docker Version Information"() {
    return `select * from docker_version;`;
  }

  @osQueryMsCell({
    description: "Docker Container Ports.",
  }, ["darwin", "linux"])
  "Docker Container Ports"() {
    return `select id,type,port,host_ip,host_port from docker_container_ports WHERE host_ip != '::';`;
  }

  @osQueryMsCell({
    description: "Osquery Mfa Enabled.",
  }, ["linux"])
  "Osquery Mfa Enabled"() {
    return `SELECT  node, value, label, path FROM augeas WHERE path='/etc/pam.d/sshd' AND value like '%pam_google_authenticator.so%';`;
  }

  @osQueryMsCell({
    description: "Osquery Deny Root Login.",
  }, ["linux"])
  "Osquery Deny Root Login"() {
    return `SELECT node, value, label, path FROM augeas WHERE path='/etc/ssh/sshd_config' AND label like 'PermitRootLogin' AND value like 'no';`;
  }

  @osQueryMsCell({
    description: "Osquery Removed User Accounts.",
  }, ["linux"])
  "Osquery Removed User Accounts"() {
    return `SELECT * FROM users WHERE shell = 'disabled';`;
  }

  @osQueryMsCell({
    description: "Osquery Encrypted Passwords.",
  }, ["linux"])
  "Osquery Encrypted Passwords"() {
    return `SELECT md5, sha1, sha256 from hash where path = '/etc/passwd';`;
  }

  @osQueryMsCell({
    description: "Osquery Antivirus Status.",
  }, ["linux"])
  "Osquery Antivirus Status"() {
    return `SELECT score FROM (SELECT case when COUNT(*) = 2 then 1 ELSE 0 END AS score FROM processes WHERE (name = 'clamd') OR (name = 'freshclam')) WHERE score == 1;`;
  }

  @osQueryMsCell({
    description: "Asymmetric Cryptography.",
  }, ["linux"])
  "Asymmetric Cryptography"() {
    return `SELECT 
      path,
      directory,
      filename,
      inode,
      uid,
      gid,
      mode,
      device,
      size,
      block_size,
      atime,
      mtime,
      ctime,
      btime,
      hard_links,
      symlink,
      type
    FROM file WHERE (path LIKE '/home/%/.ssh/%.pub' OR path LIKE '/home/%/.ssh/authorized_keys');`;
  }

  @osQueryMsCell({
    description: "Osquery SystemInfo",
  }, ["linux"])
  "Osquery SystemInfo"() {
    return `SELECT *  from system_info;`;
  }

  @osQueryMsCell({
    description: "Osquery All Container Processes",
  }, ["linux"])
  "Osquery All Container Processes"() {
    return `SELECT
              name,
              path,
              state,
              strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) AS start_time
            FROM
              processes
            WHERE
              (strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')), name, path, start_time) IN (
                SELECT
                  strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) AS day,
                  name,
                  path,
                  MAX(start_time)
                FROM
                  processes
                GROUP BY
                  day, name, path
              );`;
  }

  @osQueryMsCell({
    description: "Osquery Authentication Log",
  }, ["linux"])
  "Osquery Authentication Log"() {
    return `SELECT username, tty, time, status, message FROM authentications;`;
  }

  @osQueryMsCell({
    description: "Osquery IDS Fail2ban Log",
  }, ["linux"])
  "Osquery IDS Fail2ban Log"() {
    return `SELECT name, type , notnull, dflt_value, pk  FROM file WHERE path LIKE '/var/log/fail2ban.log';`;
  }

  @osQueryMsCell({
    description: "Osquery IDS PSAD Log",
  }, ["linux"])
  "Osquery IDS PSAD Log"() {
    return `SELECT name, type , notnull, dflt_value, pk  FROM file WHERE path LIKE '/var/log/fail2ban.log';`;
  }

  @osQueryMsCell({
    description: "List services listening on port 443 (HTTPS)",
  }, ["linux"])
  "Osquery Listening Ports 443"() {
    return `SELECT port,protocol,family,address,fd,socket,path,net_namespace FROM listening_ports WHERE port = 443;`;
  }

  @osQueryMsCell({
    description: "Check for existence of SSL certificate and private key files",
  }, ["linux"])
  "Osquery SSL Cert Files"() {
    return `SELECT path,directory,filename,inode,uid,gid,mode,device,size,block_size,hard_links,type FROM file WHERE path LIKE '/etc/ssl/certs%' OR path LIKE '/etc/ssl/private%';`;
  }

  @osQueryMsCell({
    description: "Monitor SSL cert and key file modification times",
  }, ["linux"])
  "Osquery SSL Cert File MTIME"() {
    return `SELECT path, mtime FROM file WHERE path LIKE '/etc/ssl/certs%' OR path LIKE '/etc/ssl/private%';`;
  }

  @osQueryMsCell({
    description: "Check if common VPN service ports (443, 1194, 500, 4500) are listening",
  }, ["linux"])
  "Osquery VPN Listening Ports"() {
    return `SELECT port,protocol,family,address,fd,socket,path,net_namespace FROM listening_ports WHERE port IN (1194, 443, 500, 4500);`;
  }

  @osQueryMsCell({
    description: "Check for cron jobs related to backup tasks",
  }, ["linux"])
  "Osquery Cron Backup Jobs"() {
    return `SELECT event, minute, hour, day_of_month, month, day_of_week, command, path FROM crontab WHERE command LIKE '%backup%';`;
  }

  @osQueryMsCell({
    description: "Inventory: List MySQL database processes",
  }, ["linux"])
  "Osquery MySQL Process Inventory"() {
    return `SELECT name, pid, path FROM processes WHERE name LIKE 'mysqld%';`;
  }

  @osQueryMsCell({
    description: "Inventory: List PostgreSQL database processes",
  }, ["linux"])
  "Osquery PostgreSQL Process Inventory"() {
    return `SELECT name, pid, path FROM processes WHERE name LIKE 'postgres%';`;
  }

  @osQueryMsCell({
    description: "Inventory: List all cron jobs (Scheduled Tools and Tasks)",
  }, ["linux"])
  "Osquery Cron Job Inventory"() {
    return `SELECT event, minute, hour, day_of_month, month, day_of_week, command, path FROM crontab;`;
  }

  @osQueryMsCell({
    description: "Network Inventory: List all listening ports (in-scope services)",
  }, ["linux"])
  "Osquery Listening Ports Inventory"() {
    return `SELECT pid, port, protocol, family, address, path FROM listening_ports;`;
  }

  @osQueryMsCell({
    description: "Network Inventory: List of interface addresses",
  }, ["linux"])
  "Osquery Interface Addresses Inventory"() {
    return `SELECT interface,address,mask,broadcast,point_to_point,type FROM interface_addresses;`;
  }

  @osQueryMsCell({
    description: "Network Inventory: Detailed interface configuration",
  }, ["linux"])
  "Osquery Interface Details Inventory"() {
    return ` SELECT 
      interface, 
      mac, 
      type, 
      mtu, 
      metric, 
      flags, 
      ipackets, 
      opackets, 
      ibytes, 
      obytes, 
      ierrors, 
      oerrors, 
      idrops, 
      odrops, 
      collisions, 
      last_change, 
      link_speed, 
      pci_slot 
    FROM interface_details;`;
  }

  @osQueryMsCell({
    description: "User-Process Mapping: Get process info with associated user for OS, DB, App, and network services",
  }, ["linux"])
  "Osquery User List by IT Layer"() {
    return `
      SELECT 
        p.pid, 
        p.name, 
        u.username, 
        p.path, 
        p.cmdline 
      FROM processes p
      JOIN users u ON p.uid = u.uid
      WHERE 
        p.name LIKE '%nginx%' OR 
        p.name LIKE '%apache%' OR 
        p.name LIKE '%postgres%' OR 
        p.name LIKE '%mysqld%' OR 
        p.name LIKE '%ssh%' OR 
        p.name LIKE '%vpn%';
    `;
  }

  @osQueryMsCell({
    description: "Admin Processes: List processes for network services run by superusers",
  }, ["linux"])
  "Osquery Admin Network Services Processes"() {
    return `
      SELECT 
        p.pid, 
        p.name, 
        u.username, 
        p.path, 
        p.cmdline 
      FROM processes p
      JOIN users u ON p.uid = u.uid
      WHERE 
        (p.name LIKE 'nginx%' OR p.name LIKE 'apache%' OR p.name LIKE 'postgres%' OR p.name LIKE 'mysqld%')
        AND (u.username LIKE 'root%' OR u.username LIKE 'admin%' OR u.username LIKE '%sudo%');
    `;
  }

  @osQueryMsCell({
    description: "Admin Processes: Identify apps run by administrator-level users",
  }, ["linux"])
  "Osquery Admin Application Processes"() {
    return `
      SELECT 
        p.pid, 
        p.name, 
        u.username, 
        p.path 
      FROM processes p
      JOIN users u ON p.uid = u.uid
      WHERE 
        (p.name LIKE 'nginx%' OR p.name LIKE 'apache%' OR p.name LIKE 'postgres%' OR p.name LIKE 'mysqld%')
        AND (u.username LIKE 'root%' OR u.username LIKE 'admin%' OR u.username LIKE '%sudo%');
    `;
  }

  @osQueryMsCell({
    description: "Security Groups: Application-level access by admin or elevated users",
  }, ["linux"])
  "Osquery Application Access Rights"() {
    return `
      SELECT 
        p.pid, 
        p.name, 
        u.username, 
        p.path 
      FROM processes p
      JOIN users u ON p.uid = u.uid
      WHERE 
        (p.name LIKE 'nginx%' OR p.name LIKE 'apache%' OR p.name LIKE 'postgres%' OR p.name LIKE 'mysqld%')
        AND (u.username LIKE 'root%' OR u.username LIKE 'admin%' OR u.username LIKE '%sudo%');
    `;
  }

  @osQueryMsCell({
    description: "Security Groups: List admin users for operating system layer",
  }, ["linux"])
  "Osquery OS Admin Users"() {
    return `
      SELECT 
        username, 
        uid, 
        gid, 
        shell, 
        directory 
      FROM users 
      WHERE 
        username LIKE 'root%' OR 
        username LIKE 'admin%' OR 
        username LIKE '%sudo%';
    `;
  }
}



export async function SQL() {
  return await cnb.TypicalCodeNotebook.SQL(
    new SurveilrOsqueryMsQueries(),
  );
}

if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}