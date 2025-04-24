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
import * as osQueryMS from "../../pattern/osquery-ms/package.sql.ts"

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
    caption: "Boundary",
    description:
      `The Server (Host) List ingested via osQuery provides real-time visibility into all discovered infrastructure assets.`,
    siblingOrder: 1,
  })
  "fleetfolio/boundary.sql"() {
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
                boundary  as title,
                ${this.absoluteURL("/fleetfolio/host_list.sql?boundary_key=")
      } || boundary_key as link
            FROM boundary_list;

        -- AWS Trust Boundary
         select
            'card' as component,
             4      as columns;
         select
             "AWS Trust Boundary"  as title,
            ${this.absoluteURL("/fleetfolio/aws_trust_boundary_list.sql")
      } as link
         ;
            `;
  }


  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/host_list.sql"() {
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
        SELECT 'Boundary' AS title,
            ${this.absoluteURL("/fleetfolio/boundary.sql")} AS link;
        SELECT boundary AS title,
            ${this.absoluteURL("/fleetfolio/host_list.sql?boundary_key=")
      } || boundary_key  AS link
          FROM host_list WHERE boundary_key=$boundary_key LIMIT 1;


      --- Dsply Page Title
      SELECT
          'title'   as component,
          boundary as contents FROM host_list WHERE boundary_key=$boundary_key LIMIT 1;

         select
          'text'              as component,
          'A boundary refers to a defined collection of servers and assets that work together to provide a specific function or service. It typically represents a perimeter or a framework within which resources are organized, managed, and controlled. Within this boundary, servers and assets are interconnected, often with defined roles and responsibilities, ensuring that operations are executed smoothly and securely. This concept is widely used in IT infrastructure and network management to segment and protect different environments or resources.' as contents;

       -- asset list
        SELECT 'table' AS component,
            'host' as markdown,
            TRUE as sort,
            TRUE as search;
        SELECT 
        '[' || host || '](' || ${this.absoluteURL("/fleetfolio/host_detail.sql?host_identifier=")
      } || host_identifier || ')' as host,
        boundary,
        CASE 
            WHEN status = 'Online' THEN '🟢 Online'
            WHEN status = 'Offline' THEN '🔴 Offline'
            ELSE '⚠️ Unknown'
        END AS "Status",
        osquery_version as "Os query version",
        available_space AS "Disk space available",
        operating_system AS "Operating System",
        osquery_version AS "osQuery Version",
        ip_address AS "IP Address",
        last_fetched AS "Last Fetched",
        last_restarted AS "Last Restarted"
        FROM host_list WHERE boundary_key=$boundary_key;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/host_detail.sql"() {
    const policyViewName = `asset_policy_list`;
    const policyPagination = this.pagination({
      tableOrViewName: policyViewName,
      whereSQL: "WHERE host_identifier=$host_identifier",
    });
    const softwareViewName = `asset_software_list`;
    const softwarePagination = this.pagination({
      tableOrViewName: softwareViewName,
      whereSQL: "WHERE host_identifier=$host_identifier",
    });
    const userListViewName = `asset_user_list`;
    const userListPagination = this.pagination({
      tableOrViewName: userListViewName,
      whereSQL: "WHERE host_identifier=$host_identifier",
    });
    const containerViewName = `list_docker_container`;
    const containerPagination = this.pagination({
      tableOrViewName: containerViewName,
      whereSQL: "WHERE host_identifier=$host_identifier",
    });
    const processViewName = `ur_transform_list_container_process`;
    const processPagination = this.pagination({
      tableOrViewName: processViewName,
      whereSQL: "WHERE host_identifier=$host_identifier",
    });
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
            'Boundary' AS title,
            ${this.absoluteURL("/fleetfolio/boundary.sql")} AS link; 
        SELECT boundary AS title,
            ${this.absoluteURL("/fleetfolio/host_list.sql?boundary_key=")
      } || boundary_key  AS link
            FROM host_list WHERE host_identifier=$host_identifier LIMIT 1;
        SELECT host AS title,
            ${this.absoluteURL("/fleetfolio/host_detail.sql?host_identifier=")
      } || host_identifier  AS link
            FROM host_list WHERE host_identifier=$host_identifier LIMIT 1;


        --- Dsply Page Title
        SELECT
            'title'   as component,
            host as contents FROM host_list WHERE host_identifier=$host_identifier;

        SELECT
            'text'              as component,
            description as contents FROM host_list WHERE host_identifier=$host_identifier;
        --- Display Asset (Host) Details first row
        SELECT 'datagrid' as component;
            -- SELECT 'Parent Boundary' as title, parent_boundary as description FROM host_list WHERE asset_id=$host_identifier;
            SELECT 'Boundary' as title, boundary as description FROM host_list WHERE host_identifier=$host_identifier;
            SELECT 'Status' as title,
            CASE 
                WHEN status = 'Online' THEN '🟢 Online'
                WHEN status = 'Offline' THEN '🔴 Offline'
                ELSE '⚠️ Unknown'
            END AS  description FROM host_list WHERE host_identifier=$host_identifier;
            SELECT 'Issues' as title, issues as description FROM host_list WHERE host_identifier=$host_identifier;
            SELECT 'Osquery version' as title, osquery_version as description FROM host_list WHERE host_identifier=$host_identifier;
            SELECT 'Operating system' as title, operating_system as description FROM host_list WHERE host_identifier=$host_identifier;

            select 
                'html' as component,
                '<div style="display: flex; gap: 20px; width: 100%;">
                    <!-- First Column -->
                    <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc;  border-radius: 4px; width: 33%; background-color: #ffffff;">
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Disk space</div>
                            <div>' || available_space || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Memory</div>
                            <div>' || ROUND(physical_memory / (1024 * 1024 * 1024), 2) || ' GB' || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Processor Type</div>
                            <div>' || cpu_type || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px;">
                            <div class="datagrid-title">Added to surveilr</div>
                            <div>' || added_to_surveilr_osquery_ms || '</div>
                        </div>
                    </div> 

                    <!-- Second Column -->
                    <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Hardware Model</div>
                            <div>' || hardware_model || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Board Model</div>
                            <div>' || board_model || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Serial Number</div>
                            <div>' || hardware_serial || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px;">
                            <div class="datagrid-title">Last restarted</div>
                            <div>' || last_restarted || '</div>
                        </div>
                    </div> 

                    <!-- Third Column -->
                    <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">IP Address</div>
                            <div>' || ip_address || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Mac Address</div>
                            <div>' || mac || '</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px;">
                            <div class="datagrid-title">Last Fetched</div>
                            <div>' || last_fetched || '</div>
                        </div>
                    </div>
                </div>

            ' as html FROM host_list WHERE host_identifier=$host_identifier;

        select 
        'divider' as component,
        'System Environment'   as contents;

        SELECT 'tab' AS component, TRUE AS center;
        SELECT 'Policies' AS title, '?tab=policies&host_identifier=' || $host_identifier AS link, ($tab = 'policies' OR $tab IS NULL) AS active;
        select 'Software' as title, '?tab=software&host_identifier=' || $host_identifier AS link, $tab = 'software' as active;
        select 'Users' as title, '?tab=users&host_identifier=' || $host_identifier AS link, $tab = 'users' as active;
        select 'Containers' as title, '?tab=container&host_identifier=' || $host_identifier AS link, $tab = 'container' as active;
        select 'All Process' as title, '?tab=all_process&host_identifier=' || $host_identifier AS link, $tab = 'all_process' as active;

        -- policy table and tab value Start here
        -- policy pagenation
        ${policyPagination.init()} 
        SELECT 'table' AS component, TRUE as sort, TRUE as search WHERE ($tab = 'policies' OR $tab IS NULL);
        SELECT 
        policy_name AS "Policy", policy_result as "Status", resolution
        FROM ${policyViewName}
        WHERE host_identifier = $host_identifier AND ($tab = 'policies' OR $tab IS NULL) LIMIT $limit
        OFFSET $offset;
        -- checking
        ${policyPagination.renderSimpleMarkdown(
        "tab",
        "host_identifier",
        "$tab='policies'",)};

        -- Software table and tab value Start here
       
        ${softwarePagination.init()} 
        SELECT 'table' AS component, TRUE as sort, TRUE as search WHERE $tab = 'software';
        SELECT name, version, type, platform, '-' AS "Vulnerabilities"
        FROM ${softwareViewName}
        WHERE host_identifier = $host_identifier AND $tab = 'software'
        LIMIT $limit OFFSET $offset;

        -- Software pagenation
        ${softwarePagination.renderSimpleMarkdown(
          "tab",
          "host_identifier",
          "$tab='software'",
        )
      };

        -- User table and tab value Start here
        ${userListPagination.init()} 
        SELECT 'table' AS component, TRUE as sort, TRUE as search WHERE $tab = 'users';
        SELECT user_name as "User Name", directory as "Directory"
        FROM ${userListViewName}
        WHERE host_identifier = $host_identifier AND $tab = 'users'
        LIMIT $limit OFFSET $offset;

        -- User pagenation
        ${userListPagination.renderSimpleMarkdown(
        "tab",
        "host_identifier",
        "$tab='users'",
      )
      };

      -- Container table and tab value Start here
      -- Container pagenation
      ${containerPagination.init()} 
        SELECT 'table' AS component, TRUE as sort, TRUE as search,TRUE    as hover
         WHERE $tab = 'container';
        SELECT LTRIM(container_name, '/') AS name, image,host_port AS "host Port",
        port, ip_address as "IP Address", owenrship, process, state, status,created_date as created
        FROM ${containerViewName}
        WHERE host_identifier = $host_identifier AND $tab = 'container'
        LIMIT $limit OFFSET $offset;
        ${containerPagination.renderSimpleMarkdown(
        "tab",
        "host_identifier",
        "$tab='container'",
      )
      };
      

        -- all_process table and tab value Start here
        -- all_process pagenation
        ${processPagination.init()} 
        SELECT 'table' AS component, TRUE as sort, TRUE as search WHERE $tab = 'all_process';
        SELECT process_name AS "process name"
        FROM ${processViewName}
        WHERE host_identifier = $host_identifier AND $tab = 'all_process'
        LIMIT $limit OFFSET $offset;
        ${processPagination.renderSimpleMarkdown(
        "tab",
        "host_identifier",
        "$tab='all_process'",
      )
      };
      `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/aws_trust_boundary_list.sql"() {
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
        'Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/boundary.sql")} AS link; 

      SELECT
        'AWS Trust Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/aws_trust_boundary_list.sql")} AS link; 

      --- Dsply Page Title
      SELECT
          'title'   as component,
          "AWS Trust Boundary" contents;

       -- Dashboard count
        select
            'card' as component,
            4      as columns;
        select
            "AWS EC2 instance "  as title,
            'square' as icon,
            'orange'                    as color,
            ${this.absoluteURL("/fleetfolio/aws_ec2_instance_list.sql")} as link;
        select
            "AWS S3 buckets"  as title,
            "bucket" as icon,
            'blue'                    as color,
            ${this.absoluteURL("/fleetfolio/aws_s3_bucket_list.sql")} as link;
        select
            "AWS VPC"  as title,
            "cloud" as icon,
            'black'                    as color,
            ${this.absoluteURL("/fleetfolio/aws_vpc_list.sql")} as link;

     `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/aws_ec2_instance_list.sql"() {
    const viewName = `list_aws_ec2_instance`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "",
    });
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
        'Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/boundary.sql")} AS link; 

      SELECT
        'AWS Trust Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/aws_trust_boundary_list.sql")} AS link; 

      SELECT
        'AWS EC2 instance' AS title,
        ${this.absoluteURL("/fleetfolio/aws_ec2_instance_list.sql")} AS link; 


      --- Dsply Page Title
      SELECT
          'title'   as component,
          "AWS EC2 instance" contents;

         select
          'text'              as component,
          'An EC2 instance represents a virtual server hosted on Amazon Web Services (AWS), used to run applications, services, or processes in a scalable and flexible cloud environment. Each instance is provisioned with a specific configuration—such as CPU, memory, storage, and networking capabilities—to meet the needs of the workload it supports. EC2 instances are a core component of cloud infrastructure, enabling users to deploy and manage computing resources without the need for physical hardware. They can be started, stopped, resized, or terminated as needed, offering full control over performance, cost, and security.' as contents;


      ${pagination.init()} 
     SELECT 'table' AS component,
            'host' as markdown,
            TRUE as sort,
            TRUE as search,
            'title' as markdown;
        SELECT 
        '[' || title || '](' || ${this.absoluteURL("/fleetfolio/aws_ec2_instance_detail.sql?instance_id=")
      } || instance_id || ')' as title,
        architecture,
        platform_details AS platform, 
        root_device_name as "root device name",
        state,
        instance_type as "instance type",
        datetime(substr(launch_time, 1, 19)) as "launch time"
        FROM ${viewName};
         ${pagination.renderSimpleMarkdown()};`;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/aws_ec2_instance_detail.sql"() {
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
        'Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/boundary.sql")} AS link; 
      SELECT
        'AWS Trust Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/aws_trust_boundary_list.sql")} AS link; 

      SELECT
        'AWS EC2 instance' AS title,
        ${this.absoluteURL("/fleetfolio/list_aws_ec2_instance.sql")} AS link; 
      SELECT
        title,
        ${this.absoluteURL("/fleetfolio/aws_ec2_instance_detail.sql?instance_id=")
      } || instance_id AS link FROM list_aws_ec2_instance WHERE instance_id=$instance_id; 

      --- Dsply Page Title
        SELECT
          'title'   as component,
          title as contents FROM list_aws_ec2_instance WHERE instance_id=$instance_id;

        select
          'text'              as component,
          'An EC2 instance represents a virtual server hosted on Amazon Web Services (AWS), used to run applications, services, or processes in a scalable and flexible cloud environment. Each instance is provisioned with a specific configuration—such as CPU, memory, storage, and networking capabilities—to meet the needs of the workload it supports. EC2 instances are a core component of cloud infrastructure, enabling users to deploy and manage computing resources without the need for physical hardware. They can be started, stopped, resized, or terminated as needed, offering full control over performance, cost, and security.' as contents;

         select 
                'html' as component,
                '<div style="display: flex; gap: 20px; width: 100%;">
                    <!-- First Column -->
                    <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc;  border-radius: 4px; width: 33%; background-color: #ffffff;">
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Architecture</div>
                            <div>'|| architecture ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Platform</div>
                            <div>'|| platform_details ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Root Device Name</div>
                            <div>'|| root_device_name ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px;">
                            <div class="datagrid-title">Type </div>
                            <div>'|| instance_type ||'</div>
                        </div>
                    </div> 

                    <!-- Second Column -->
                    <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">state</div>
                            <div>'|| state ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Cpu options core count</div>
                            <div>'|| cpu_options_core_count ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Availability Zone</div>
                            <div>'|| az ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px;">
                            <div class="datagrid-title">Launch Time</div>
                            <div>'|| datetime(substr(launch_time, 1, 19)) ||'</div>
                        </div>
                    </div> 

                    <!-- Third Column -->
                    <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Private IP Address</div>
                            <div>'|| private_ip_address ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Mac Address</div>
                            <div>'|| mac_address ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">Public IP Address</div>
                            <div>'|| COALESCE(public_ip_address, 'No IP address') ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px;">
                            <div class="datagrid-title">Status</div>
                            <div>'|| status ||'</div>
                        </div>
                    </div>
                     <!-- Fourth Column -->
                    <div style="display: flex; flex-direction: column; gap: 8px; padding: 12px; border: .5px solid #ccc; border-radius: 4px; width: 33%; background-color: #ffffff;">
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">VPC</div>
                            <div>'|| vpc_name ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px; border-bottom: 1px solid #eee;">
                            <div class="datagrid-title">VPC State</div>
                            <div>'|| vpc_state ||'</div>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding: 4px;">
                            <div class="datagrid-title">Last Fetched</div>
                            <div>Value</div>
                        </div>
                    </div>
                </div>

            ' as html FROM list_aws_ec2_instance WHERE instance_id=$instance_id
     `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/aws_s3_bucket_list.sql"() {
    const viewName = `list_aws_s3_bucket`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "",
    });
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
        'Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/boundary.sql")} AS link; 

      SELECT
        'AWS Trust Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/aws_trust_boundary_list.sql")} AS link; 

      SELECT
        'AWS S3 buckets' AS title,
        ${this.absoluteURL("/fleetfolio/list_aws_ec2_instance.sql")} AS link; 


      --- Dsply Page Title
      SELECT
          'title'   as component,
          "AWS S3 buckets" contents;

         select
          'text'              as component,
          'AWS S3 Bucket is a scalable storage container in Amazon Simple Storage Service (S3) used to store and organize objects (such as files, images, backups, and data). Each bucket has a globally unique name and supports features like versioning, access control, encryption, and lifecycle policies.' as contents;


      ${pagination.init()} 
     SELECT 'table' AS component,
            'host' as markdown,
            TRUE as sort,
            TRUE as search,
            'title' as markdown;
        SELECT 
        name,
        region,
        datetime(substr(creation_date, 1, 19)) as "Creation date"
        FROM ${viewName};
         ${pagination.renderSimpleMarkdown()};`;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "fleetfolio/aws_vpc_list.sql"() {
    const viewName = `list_aws_vpc`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "",
    });
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
        'Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/boundary.sql")} AS link; 

      SELECT
        'AWS Trust Boundary' AS title,
        ${this.absoluteURL("/fleetfolio/aws_trust_boundary_list.sql")} AS link; 

      SELECT
        'AWS VPC' AS title,
        ${this.absoluteURL("/fleetfolio/aws_vpc_list.sql")} AS link; 


      --- Dsply Page Title
      SELECT
          'title'   as component,
          "AWS VPC" contents;

         select
          'text'              as component,
          'Amazon Virtual Private Cloud (VPC) is a logically isolated section of the AWS Cloud where you can launch and manage AWS resources in a custom-defined network. You control key networking aspects like IP address ranges, subnets, route tables, internet gateways, and security settings.' as contents;


      ${pagination.init()} 
     SELECT 'table' AS component,
            'host' as markdown,
            TRUE as sort,
            TRUE as search;
        SELECT 
        vpc_name as name,
        account,
        owner,
        region,
        state,
        cidr_block as 'cidr block',
        dhcp_options_id as 'DHCP Options ID',
        is_default as "is default",
        partition
        FROM ${viewName};
         ${pagination.renderSimpleMarkdown()
      };`;
  }

  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
    pageTitleFromNavStmts: "no",
  })
  "sqlpage/templates/shell-custom.handlebars"() {
    return this.SQL`<!DOCTYPE html>
      <html lang="{{language}}" style="font-size: {{default font_size 18}}px" {{#if class}}class="{{class}}" {{/if}}>
      <head>
          <meta charset="utf-8" />

          <!-- Base CSS -->
          <link rel="stylesheet" href="{{static_path 'sqlpage.css'}}">
          {{#each (to_array css)}}
              {{#if this}}
                  <link rel="stylesheet" href="{{this}}">
              {{/if}}
          {{/each}}

          <!-- Font Setup -->
          {{#if font}}
              {{#if (starts_with font "/")}}
                  <style>
                      @font-face {
                          font-family: 'LocalFont';
                          src: url('{{font}}') format('woff2');
                          font-weight: normal;
                          font-style: normal;
                      }
                      :root {
                          --tblr-font-sans-serif: 'LocalFont', Arial, sans-serif;
                      }
                  </style>
              {{else}}
                  <link rel="preconnect" href="https://fonts.googleapis.com">
                  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family={{font}}&display=fallback">
                  <style>
                      :root {
                          --tblr-font-sans-serif: '{{font}}', Arial, sans-serif;
                      }
                  </style>
              {{/if}}
          {{/if}}

          <!-- JavaScript -->
          <script src="{{static_path 'sqlpage.js'}}" defer nonce="{{@csp_nonce}}"></script>
          {{#each (to_array javascript)}}
              {{#if this}}
                  <script src="{{this}}" defer nonce="{{@../csp_nonce}}"></script>
              {{/if}}
          {{/each}}
          {{#each (to_array javascript_module)}}
              {{#if this}}
                  <script src="{{this}}" type="module" defer nonce="{{@../csp_nonce}}"></script>
              {{/if}}
          {{/each}}
      </head>

      <body class="layout-{{#if sidebar}}fluid{{else}}{{default layout 'boxed'}}{{/if}}" {{#if theme}}data-bs-theme="{{theme}}" {{/if}}>
          <div class="page">
              <!-- Header -->
              <!-- Page Wrapper -->
              <div class="page-wrapper">
                  <main class="page-body w-full flex-grow-1 px-0" id="sqlpage_main_wrapper">
                      {{~#each_row~}}{{~/each_row~}}
                  </main>
              </div>
          </div>
      </body>
      </html>
`;
  }
}

export async function SQL() {

  return await spn.TypicalSqlPageNotebook.SQL(

    new class extends spn.TypicalSqlPageNotebook {

      async statefulOsQeryMSSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("../../pattern/osquery-ms/stateful.sql"),
        );
      }

      async statelessOsQeryMSSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("../../pattern/osquery-ms/stateless.sql"),
        );
      }

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
