#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  docs as d,
  orchestration as orch,
  //shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
import * as sh from "./custom_shell.ts";

const WEB_UI_TITLE = "fleetfolio";
const WE_UI_LOGO = "fleetfolio-logo.png";
const WE_UI_FAV_ICON = "fleetfolio-favicon.ico";

/**
 * These pages depend on ../../std/package.sql.ts being loaded into RSSD (for nav).
 *
 * TODO: in TypicalSqlPageNotebook.SQL() call at the bottom of this code it
 * probably makese sense to just add all dependent notebooks into the sources
 * list like so:
 *
 *   TypicalSqlPageNotebook.SQL(new X(), new Y(), ..., new FhirSqlPages())
 *
 * where X, Y, etc. are in lib/std/content/mod.ts
 */

// custom decorator that makes navigation for this notebook type-safe
function fleetfolioNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "fleetfolio/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class FleetFolioSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /fleetfolio-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE parent_path like ${this.constructHomePath("fleetfolio")
      };
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "FleetFolio",
    description:
      `FleetFolio is a powerful infrastructure assurance platform built on surveilr that helps organizations achieve continuous compliance, security, and operational reliability. Unlike traditional asset management tools that simply list discovered assets, FleetFolio takes a proactive approach by defining expected infrastructure assets and verifying them against actual assets found using osQuery Management Server (MS).`,
  })
  "fleetfolio/index.sql"() {
    return this.SQL`
    select
        'text'              as component,
        'FleetFolio is a powerful infrastructure assurance platform built on surveilr that helps organizations achieve continuous compliance, security, and operational reliability. Unlike traditional asset management tools that simply list discovered assets, FleetFolio takes a proactive approach by defining expected infrastructure assets and verifying them against actual assets found using osQuery Management Server (MS).' as contents;
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = ${this.constructHomePath("fleetfolio")
      }
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, ${this.absoluteURL("/")
      } || COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${this.constructHomePath("fleetfolio")
      }
       ORDER BY sibling_order;`;
  }

  @fleetfolioNav({
    caption: "Parent Boundary",
    description:
      `The Server (Host) List ingested via osQuery provides real-time visibility into all discovered infrastructure assets.`,
    siblingOrder: 1,
  })
  "fleetfolio/parent_boundary.sql"() {
    return this.SQL`
        ${this.activePageTitle()}
  
        -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
          --- Dsply Page Title
      SELECT
          'title'   as component,
          'Boundary ' contents;
  
         select
          'text'              as component,
          'A boundary refers to a defined collection of servers and assets that work together to provide a specific function or service. It typically represents a perimeter or a framework within which resources are organized, managed, and controlled. Within this boundary, servers and assets are interconnected, often with defined roles and responsibilities, ensuring that operations are executed smoothly and securely. This concept is widely used in IT infrastructure and network management to segment and protect different environments or resources.' as contents;
  
        -- Dashboard count
        select
            'card' as component,
            4      as columns;
        select
            name  as title,
            ${this.absoluteURL("/fleetfolio/boundary.sql?boundary_id=")
      } || boundary_id as link
        FROM parent_boundary;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/boundary.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
        --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'FleetFolio' AS title,
        ${this.absoluteURL("/fleetfolio/index.sql")} AS link;  
      SELECT
        'Parent Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/parent_boundary.sql")} AS link; 
      SELECT
        'Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/boundary.sql?boundary_id=")} || $boundary_id  AS link;
        
      --- Dsply Page Title
      SELECT
          'title'   as component,
          'Boundary ' contents;
  
         select
          'text'              as component,
          'A boundary refers to a defined collection of servers and assets that work together to provide a specific function or service. It typically represents a perimeter or a framework within which resources are organized, managed, and controlled. Within this boundary, servers and assets are interconnected, often with defined roles and responsibilities, ensuring that operations are executed smoothly and securely. This concept is widely used in IT infrastructure and network management to segment and protect different environments or resources.' as contents;
  
        -- Dashboard count
        select
            'card' as component,
            4      as columns;
        select
            name  as title,
            ${this.absoluteURL("/fleetfolio/asset.sql?boundary_id=")
      } || boundary_id as link
        FROM boundary_list WHERE parent_boundary_id=$boundary_id::TEXT;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/asset.sql"() {
    return this.SQL`
        ${this.activePageTitle()}

        --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'FleetFolio' AS title,
        ${this.absoluteURL("/fleetfolio/index.sql")} AS link;
      SELECT
        'Parent Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/parent_boundary.sql")} AS link; 
      SELECT
        'Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/boundary.sql?boundary_id=")} || (SELECT parent_boundary_id FROM boundary_list WHERE boundary_id=$boundary_id::TEXT)  AS link;
      SELECT
        (SELECT name FROM boundary_list WHERE boundary_id=$boundary_id::TEXT) AS title,
        ${this.absoluteURL("/fleetfolio/asset.sql?boundary_id=")} || $boundary_id  AS link;
     
        
          --- Dsply Page Title
      SELECT
          'title'   as component,
          'Boundary' contents;

         select
          'text'              as component,
          'Servers under a boundary are individual computing resources that are part of the collection of assets within that defined perimeter. These servers typically perform specific tasks or functions such as hosting applications, managing databases, or handling network traffic. Within the boundary, servers are organized and managed to ensure efficient resource allocation, security, and performance. They work together to deliver the services and processes defined by the boundary, with clear roles and interconnections to maintain the integrity and smooth operation of the overall system.' as contents;

        -- Dashboard count
        select
            'table' as component,
           'assets' AS markdown;
        select '[' || name || '](' || ${this.absoluteURL("/fleetfolio/asset_detail.sql?link=")} || name || ')' as 'assets'
        FROM active_asset_list WHERE boundary_id=$boundary_id::TEXT;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/asset_detail.sql"() {
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Server' AS title,
        ${this.absoluteURL("/fleetfolio/index.sql")} AS link;
      SELECT
        host_identifier as title
      FROM
        surveilr_osquery_ms_node_detail 
      WHERE
       host_identifier = $link::TEXT;

       --- Dsply Page Title
      SELECT
       'title' as component,
        host_identifier as contents
      FROM
        surveilr_osquery_ms_node_detail
      WHERE
        host_identifier = $link::TEXT;

     select 
    'datagrid' as component;
    select 
          'Host identifier' as title,
          host_identifier   as description FROM surveilr_osquery_ms_node_system_info WHERE host_identifier = $link::TEXT;
    select 
          'Model' as title,
          board_model   as description FROM surveilr_osquery_ms_node_system_info WHERE host_identifier = $link::TEXT;  
    select 
          'Serial No' as title,
          board_serial   as description FROM surveilr_osquery_ms_node_system_info WHERE host_identifier = $link::TEXT;  
    select 
          'Vendor' as title,
          board_vendor   as description FROM surveilr_osquery_ms_node_system_info WHERE host_identifier = $link::TEXT;  
    select 
          'Version' as title,
          board_version   as description FROM surveilr_osquery_ms_node_system_info WHERE host_identifier = $link::TEXT; 
    select 
          'CPU brand' as title,
          cpu_brand   as description FROM surveilr_osquery_ms_node_system_info WHERE host_identifier = $link::TEXT;  
    select 
          'CPU brand' as title,
          cpu_brand   as description FROM surveilr_osquery_ms_node_system_info WHERE host_identifier = $link::TEXT; 

     select
          'table' as component,
          'Process' AS markdown;
      select 
       CASE
        WHEN name = 'All Processes'
        THEN
          '[' || name || '](' || ${this.absoluteURL("/fleetfolio/all_process.sql?host_identifier=")} || hostIdentifier || ')'
        ELSE name 
      END AS  process,
      count
      FROM system_detail_group WHERE hostIdentifier = $link::TEXT
          `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/all_process.sql"() {
    const viewName = `system_detail_all_processes`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "WHERE host_identifier=$host_identifier",
    });
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Server' AS title,
        ${this.absoluteURL("/fleetfolio/index.sql")} AS link;
        
      SELECT
        $host_identifier AS title,
        ${this.absoluteURL("/fleetfolio/host_detail.sql?link=")
      } || $host_identifier AS link;
      
      SELECT
        "Detail" AS title,
        '#' AS link;
      

       --- Dsply Page Title
      SELECT
       'title' as component,
        host_identifier as contents
      FROM
        surveilr_osquery_ms_node_detail
      WHERE
        host_identifier = $host_identifier::TEXT;
       ${pagination.init()}
      select 
          'table'           as component,
          TRUE              as sort,
          'hostIdentifier',
          'cgroup_path',
          'cmdline',
          'cwd',
          'disk_bytes_read',
          'disk_bytes_written',
          'egid',
          'euid',
          'gid',
          'system_name',
          'nice',
          'on_disk',
          'parent',
          'path',
          'pgroup',
          'pid',
          'resident_size',
          'root',
          'sgid',
          'start_time',
          'state',
          'suid',
          'system_time',
          'threads',
          'total_size',
          'uid',
          'user_time',
          'wired_size',
          'updated_at';
      SELECT 
        host_identifier,
        cgroup_path,
        cmdline,
        cwd,
        disk_bytes_read,
        disk_bytes_written,
        egid,
        euid,
        gid,
        system_name,
        nice,
        on_disk,
        parent,
        path,
        pgroup,
        pid,
        resident_size,
        root,
        sgid,
        start_time,
        state,
        suid,
        system_time,
        threads,
        total_size,
        uid,
        user_time,
        wired_size,
        updated_at FROM ${viewName} WHERE host_identifier = $host_identifier::TEXT LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown("host_identifier")};`;
  }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statefulfleetfolioSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
      async statelessfleetfolioSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new FleetFolioSqlPages(),
    new c.ConsoleSqlPages(),
    new d.DocsSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new sh.ShellSqlPages(WEB_UI_TITLE, WE_UI_LOGO, WE_UI_FAV_ICON),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
