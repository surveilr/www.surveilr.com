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
    description: "Docker version information.",
  }, ["macos", "linux"])
  "Docker Version Information"() {
    return `select * from docker_version;`;
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
