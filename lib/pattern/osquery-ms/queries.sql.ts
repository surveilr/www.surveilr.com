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
    description: "listContainers.",
  }, ["linux"])
  "listContainers"() {
    return `SELECT id, name, image, status FROM docker_containers;`;
  }

 @osQueryMsCell({
    description: "listContainerImages.",
  }, ["linux"])
  "listContainerImages"() {
    return `SELECT * FROM docker_images;`;
  }

 @osQueryMsCell({
    description: "containerNetworkInformation.",
  }, ["linux"])
  "containerNetworkInformation"() {
    return `SELECT id, ip_address FROM docker_container_networks;`;
  }

 @osQueryMsCell({
    description: "listContainerVolumes.",
  }, ["linux"])
  "listContainerVolumes"() {
    return `SELECT mount_point, name FROM docker_volumes;`;
  }

  @osQueryMsCell({
    description: "containerDaemonInfo.",
  }, ["linux"])
  "containerDaemonInfo"() {
    return `SELECT * FROM processes WHERE name = 'dockerd';`;
  }

 @osQueryMsCell({
    description: "dockerhostInfo.",
  }, ["linux"])
  "dockerhostInfo"() {
    return `SELECT os, os_type, architecture, cpus, memory FROM docker_info;`;
  }

 @osQueryMsCell({
    description: "dockerImage.",
  }, ["linux"])
  "dockerImage"() {
    return `SELECT SUBSTR(id, 0, 8) AS id, strftime('%d-%m-%Y ', datetime(created, 'unixepoch')) AS created, size_bytes, tags FROM docker_images WHERE LENGTH(tags) < 20 AND tags <> '' AND tags != '<none>:<none>' LIMIT 5;`;
  }

 @osQueryMsCell({
    description: "dockerNetwork.",
  }, ["linux"])
  "dockerNetwork"() {
    return `SELECT SUBSTR(id, 0, 8) AS container, name, SUBSTR(network_id, 0, 8) AS network, gateway, ip_address FROM docker_container_networks WHERE name = 'appliance';`;
  }

  @osQueryMsCell({
    description: "Docker version information.",
  }, ["macos", "linux"])
  "Docker Version Information"() {
    return `select * from docker_version;`;
  }

  @osQueryMsCell({
    description: "osqueryMfaEnabled.",
  }, ["linux"])
  "osqueryMfaEnabled"() {
    return `SELECT  node, value, label, path FROM augeas WHERE path='/etc/pam.d/sshd' AND value like '%pam_google_authenticator.so%';`;
  }

 @osQueryMsCell({
    description: "osqueryDenyRootLogin.",
  }, ["linux"])
  "osqueryDenyRootLogin"() {
    return `SELECT node, value, label, path FROM augeas WHERE path='/etc/ssh/sshd_config' AND label like 'PermitRootLogin' AND value like 'no';`;
  }

 @osQueryMsCell({
    description: "osqueryRemovedUserAccounts.",
  }, ["linux"])
  "osqueryRemovedUserAccounts"() {
    return `SELECT * FROM users WHERE shell = 'disabled';`;
  }


 @osQueryMsCell({
    description: "osqueryEncryptedPasswords.",
  }, ["linux"])
  "osqueryEncryptedPasswords"() {
    return `SELECT md5, sha1, sha256 from hash where path = '/etc/passwd';`;
  }

 @osQueryMsCell({
    description: "osqueryAntivirusStatus.",
  }, ["linux"])
  "osqueryAntivirusStatus"() {
    return `SELECT score FROM (SELECT case when COUNT(*) = 2 then 1 ELSE 0 END AS score FROM processes WHERE (name = 'clamd') OR (name = 'freshclam')) WHERE score == 1;`;
  }
 
 @osQueryMsCell({
    description: "AsymmetricCryptography.",
  }, ["linux"])
  "AsymmetricCryptography"() {
    return `SELECT * FROM file WHERE (path LIKE '/home/%/.ssh/%.pub' OR path LIKE '/home/%/.ssh/authorized_keys');`;
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
