#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

const SQE_TITLE = "osQuery Management Server";
const SQE_LOGO = "osquery-ms.png";
const SQE_FAV_ICON = "osquery-ms.ico";

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

  @spn.navigationPrimeTopLevel({
    caption: "osQuery Management Server",
    description: "Explore details about all nodes",
  })
  "ms/index.sql"() {
    return this.SQL`
          SELECT 'title' AS component, 'All Registered Nodes' as contents;
          SELECT 'table' AS component,
              'Node' as markdown,
              'Issues' as markdown,
              TRUE as sort,
              TRUE as search;
  
         SELECT 
            '[' || host_identifier || '](node.sql?key=' || node_key || '&host_id=' || host_identifier || ')' AS "Node",
            node_status AS "Status",
            CONCAT('[', issues, '](node.sql?key=', node_key, '&host_id=', host_identifier, '&tab=policies)') AS "Issues",
            available_space AS "Disk space available",
            operating_system AS "Operating System",
            osquery_version AS "osQuery Version",
            ip_address AS "IP Address",
            boundary AS "Boundary",
            '-' AS "Team",
            last_fetched AS "Last Fetched",
            last_restarted AS "Last Restarted"
        FROM surveilr_osquery_ms_node_detail;
  
         WITH navigation_cte AS (
                  SELECT COALESCE(title, caption) as title, description
                      FROM sqlpage_aide_navigation
                  WHERE namespace = 'prime' AND path = ${this.constructHomePath("ms")
      }
                  )
                  SELECT 'list' AS component, title, description
                      FROM navigation_cte;
                  SELECT caption as title, ${this.absoluteURL("/")
      } || COALESCE(url, path) as link, description
                      FROM sqlpage_aide_navigation
                  WHERE namespace = 'prime' AND parent_path =  ${this.constructHomePath("ms")
      }
                  ORDER BY sibling_order;
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
        SELECT 'Issues' as title, "issues" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
        SELECT 'Disk space' as title, "available_space" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
        SELECT 'Memory' as title, ROUND("physical_memory" / (1024 * 1024 * 1024), 2) || ' GB' AS description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
        SELECT 'Processor Type' as title, "cpu_type" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
        SELECT 'Operating system' as title, "operating_system" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
        SELECT 'osQuery' as title, "osquery_version" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
        SELECT 'Boundary' as title, "boundary" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
  
        SELECT 'datagrid' as component;
        SELECT 'Added to surveilr' as title, "added_to_surveilr_osquery_ms" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
        SELECT 'Last Restarted' as title, "last_restarted" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
        SELECT 'Hardware Model' as title, "hardware_model" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
        SELECT 'Serial Number' as title, "hardware_serial" as description FROM surveilr_osquery_ms_node_system_info WHERE node_key = $key;
        SELECT 'IP Address' as title, "ip_address" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
        SELECT 'Team' as title, "-" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key;
    
        -- Define tabs
        SELECT 'tab' AS component, TRUE AS center;
  
        -- Tab 1: Software
        SELECT 'Software' AS title, '?tab=software&key=' || $key || '&host_id=' || $host_id AS link, $tab = 'software' AS active;
  
        -- Tab 2: Software
        SELECT 'Policies' AS title, '?tab=policies&key=' || $key || '&host_id=' || $host_id AS link, $tab = 'policies' AS active;
  
       
        -- SELECT 'IP Address' as title, "ip_address" as description FROM surveilr_osquery_ms_node_detail WHERE node_key = $key AND ($tab = 'details' OR $tab IS NULL);
  
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

  @msNav({
    caption: "Policies",
    description:
      "Quickly monitor your nodes by asking yes or no questions about them.",
    siblingOrder: 99,
  })
  "ms/policies.sql"() {
    return this.SQL`
          SELECT 'title' AS component, 'Policies' as contents;
          SELECT 'table' AS component,
              'Policy Name' as markdown,
              TRUE as sort,
              TRUE as search;
  
          SELECT '[' || policy_name || '](policy.sql?policy_id=' || osquery_policy_id || ')' AS "Policy Name" FROM osquery_policy;    
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ms/policy.sql"() {
    return this.SQL`
        ${this.activeBreadcrumbsSQL()}
        SELECT 'title' as component, "policy_name" as contents, 1 as level FROM osquery_policy where osquery_policy_id = $policy_id;
        SELECT 'text' as component, "policy_description" as contents FROM osquery_policy where osquery_policy_id = $policy_id;
        SELECT 'title' as component, 'Resolution:' as contents, 4 as level;
        SELECT 'text' as component, "policy_fail_remarks" as contents FROM osquery_policy where osquery_policy_id = $policy_id;
        SELECT 'code' as component;
        SELECT 'Query:' as title, 'sql' as language, "osquery_code" as contents FROM osquery_policy where osquery_policy_id = $policy_id;
        SELECT 'title' as component, 'Compatible with:' as contents, 4 as level;
        SELECT 'text' AS component, value AS contents FROM osquery_policy, json_each(osquery_policy.osquery_platforms) WHERE osquery_policy_id = $policy_id;
      `;
  }

  @spn.shell({ eliminate: true })
  "add_policy_to_code_notebook.sql"() {
    return this.SQL`
        DELETE FROM code_notebook_cell WHERE cell_name = '' AND notebook_name 'osQuery Management Server (Policy)';
  
      `;
  }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statefulSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
      async statelessSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new sh.ShellSqlPages(SQE_TITLE, SQE_LOGO, SQE_FAV_ICON),
    new ur.UniformResourceSqlPages(),
    new c.ConsoleSqlPages(),
    new orch.OrchestrationSqlPages(),
    new OsqueryMsSqlPages(),
  );
}

// // this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
