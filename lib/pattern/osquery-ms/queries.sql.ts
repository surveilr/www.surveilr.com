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
  targets: string[] = ["macos", "windows", "linux"],
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
    methodCtx.addInitializer(function () {
      this.migratableCells.set(String(methodCtx.name), dc);
    });
    // we're not modifying the DecoratedCell
    return dc;
  });
}

export class SurveilrOsqueryMsQueries extends cnb.TypicalCodeNotebook {
  readonly migratableCells: Map<string, cnb.DecoratedCell<"SQL">> = new Map();

  constructor() {
    super("rssd-init");
  }

  @osQueryMsCell({
    description: "Docker system information.",
  }, ["macos", "linux"])
  "Docker System Information"() {
    return `select * from docker_info;`;
  }

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
    return `SELECT * FROM processes WHERE name = 'dockerd';`;
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
  }, ["macos", "linux"])
  "Docker Version Information"() {
    return `select * from docker_version;`;
  }

  @osQueryMsCell({
    description: "Docker Container Ports.",
  }, ["macos", "linux"])
  "Docker Container Ports"() {
    return `select id,type,port,host_ip,host_port from docker_container_ports;`;
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
    return `SELECT * FROM file WHERE (path LIKE '/home/%/.ssh/%.pub' OR path LIKE '/home/%/.ssh/authorized_keys');`;
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
  pid,
  name,
  path,
  cmdline,
  state,
  uid,
  gid,
  euid,
  egid,
  parent,
  start_time AS timestamp
FROM
  processes
WHERE
  -- Filter for processes that started today
  strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) = strftime('%Y-%m-%d', 'now')
  AND 
  -- Exclude processes with the same `pid`, `uid`, and `name` already recorded today
  (pid, name) NOT IN (
    SELECT pid, name
    FROM processes
    WHERE strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) = strftime('%Y-%m-%d', 'now')
  )
  AND (uid, name) NOT IN (
    SELECT uid, name
    FROM processes
    WHERE strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) = strftime('%Y-%m-%d', 'now')
  );`;
  }

  @osQueryMsCell({
    description: "Osquery Authentication Log",
  }, ["linux"])
  "Osquery Authentication Log"() {
    return `SELECT username, tty, time, status, message FROM authentications;`;
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
