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

const WEB_UI_TITLE = "Tem";
const WE_UI_LOGO = "tem.png";
const WE_UI_FAV_ICON = "tem.ico";
const HIDE_HEADER_TITLE = true; // Hide header title text since logo contains "Tem" text


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
function temNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
    return spn.navigationPrime({
        ...route,
        parentPath: "tem/index.sql",
    });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */

export class TemSqlPages extends spn.TypicalSqlPageNotebook {
    // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
    // or `DDL` as general SQL before doing any upserts into sqlpage_files.
    navigationDML() {
        return this.SQL`
      -- delete all /tem-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE parent_path like ${this.constructHomePath("tem")
            };
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
    }

    @spn.navigationPrimeTopLevel({
        caption: "Tem",
        description:
            `Opsfolio TEM and Opsfolio EAA are part of the Opsfolio Suite, which underpins Opsfolio Compliance-as-a-Service (CaaS) offerings.`,
    })
    "tem/index.sql"() {
        return this.SQL`
    select
        'text'              as component,
        'Opsfolio Threat Exposure Management (TEM) transforms static penetration test reports into real-time, actionable dashboards and workflows. Powered by Opsfolio EAA, it streamlines vulnerability reporting, automates remediation tracking, and delivers compliance-ready evidence to keep your organization secure and audit-ready.' as contents;
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = ${this.constructHomePath("tem")
            }
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, ${this.absoluteURL("/")
            } || COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${this.constructHomePath("tem")
            }
       ORDER BY sibling_order;`;
    }

    @temNav({
        caption: "Attack Surface Mapping",
        description:
            `This data represents the information footprint of an application, domain, or infrastructure, typically gathered during reconnaissance, vulnerability assessment, or penetration testing.`,
        siblingOrder: 1,
    })
    "tem/attack_surface_mapping.sql"() {
        return this.SQL`
        ${this.activePageTitle()}

        --- Dsply Page Title
        SELECT
            'title'   as component,
            'Attack Surface Mapping ' contents;

        SELECT
            'text'              as component,
            "Attack Surface Mapping is the process of identifying, collecting, and analyzing all potential points of entry an attacker could exploit within an organization's digital infrastructure. It involves using tools such as WhatWeb, Nmap, TLS/TLSX, Nuclei, DNSx, Dirsearch, Naabu, Subfinder, Katana, and HTTPX-Toolkit to enumerate exposed services, technologies, subdomains, directories, ports, TLS configurations, and vulnerabilities. This helps organizations gain a comprehensive view of their external and internal exposure, prioritize remediation efforts, and strengthen their security posture." as contents;

        SELECT
            'card' as component,
            4      as columns;
        SELECT
            "Assets"  as title,
            ${this.absoluteURL("/tem/eaa_asset.sql")}  as link;

        SELECT "Findings" as title,
            ${this.absoluteURL("/tem/eaa_finding.sql")}  as link;
        `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/eaa_asset.sql"() {
        return this.SQL`
      ${this.activePageTitle()}
        --- Display breadcrumb
        SELECT
            'breadcrumb' AS component;
        SELECT
            'Home' AS title,
            ${this.absoluteURL("/")}    AS link;
        SELECT
            'Tem' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping.sql")} AS link;
        SELECT 'Assets' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'Assets' as contents;

        SELECT
          'text'              as component,
          'Collection of reconnaissance and security assessment tools used for subdomain discovery, port scanning, DNS probing, web technology fingerprinting, TLS analysis, and vulnerability detection.' as contents;
        

        SELECT 'table' AS component,
       TRUE AS sort,
       TRUE AS search;

        SELECT
            asset 
        FROM tem_eaa_asset_uri;
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/eaa_finding.sql"() {
        return this.SQL`
      ${this.activePageTitle()}
        --- Display breadcrumb
        SELECT
            'breadcrumb' AS component;
        SELECT
            'Home' AS title,
            ${this.absoluteURL("/")}    AS link;
        SELECT
            'Tem' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping.sql")} AS link;
        SELECT 'Findings' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'Findings' as contents;

        SELECT
          'text'              as component,
          'Detailed insights from each security tool, including scan results, fingerprints, DNS records, TLS details, subdomain enumeration, and vulnerability assessments, mapped per asset for better threat exposure analysis.' as contents;
        

        SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search,
        'Asset' as markdown;

        SELECT
             '[What web data]('||${this.absoluteURL("/tem/what_web.sql")
            }||')' as Asset;
        SELECT
           '[DNSX Scan Results]('||${this.absoluteURL("/tem/dnsx.sql")
            }||')' as Asset;
        SELECT
           '[Nuclei Scan Findings]('||${this.absoluteURL("/tem/nuclei.sql")
            }||')' as Asset;
        SELECT
           '[Naabu Port Scan Results]('||${this.absoluteURL("/tem/naabu.sql")
            }||')' as Asset;
    `;
    }



    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/what_web.sql"() {
        const viewName = `tem_what_web_result`;
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
            'Tem' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping.sql")} AS link;
        SELECT 'Web Technology Fingerprinting' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'Web Technology Fingerprinting' as contents;

        SELECT
          'text'              as component,
          'This page displays the results of automated web technology fingerprinting using WhatWeb. It includes details about detected servers, technologies, HTTP responses, geolocation, and key headers for each scanned endpoint.' as contents;
        

        SELECT 'table' AS component,
       TRUE AS sort,
       'http_status' AS markdown,
       TRUE AS search;
       
        ${pagination.init()} 
        SELECT
            target_url AS "Target URL",
        CASE
                WHEN http_status BETWEEN 200 AND 299 THEN '🟢 ' || http_status
                WHEN http_status BETWEEN 300 AND 399 THEN '🟠 ' || http_status
                WHEN http_status BETWEEN 400 AND 599 THEN '🔴 ' || http_status
            ELSE CAST(http_status AS TEXT)
            END AS "HTTP Status",
            ip_address AS "IP Address",
            country AS "Country",
            http_server AS "Web Server",
            page_title AS "Detected Technologies",
            uncommon_headers AS "Key HTTP Headers"
        FROM ${viewName};
        ${pagination.renderSimpleMarkdown()};
    `;
    }


    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/dnsx.sql"() {
        const viewName = `tem_dnsx_result`;
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
            'Tem' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping.sql")} AS link;
        SELECT 'DNS Enumeration Results' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'DNS Enumeration Results' as contents;

        SELECT
          'text'              as component,
          'This page lists the discovered DNS records using dnsx. It provides information about resolved subdomains, their IP addresses, DNS servers queried, response status, and timestamps for when the enumeration was performed.' as contents;
        

        SELECT 'table' AS component,
       TRUE AS sort,
       TRUE AS search;

        ${pagination.init()} 
        SELECT
            host,
            ttl,
            resolver,
            ip_address as "ip address",
            status_code AS "status code",
            datetime(substr(timestamp, 1, 19), '-4 hours') AS time
        FROM ${viewName};
        ${pagination.renderSimpleMarkdown()};`;
    }


    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/nuclei.sql"() {
        const viewName = `tem_nuclei_result`;
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
            'Tem' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping.sql")} AS link;
        SELECT 'Nuclei Scan Findings' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'Nuclei Scan Findings' as contents;

        SELECT
          'text'              as component,
          'Comprehensive overview of detected vulnerabilities and exposures from Nuclei scans. Displays host, URL, template details, severity levels, matched paths, and timestamps for quick analysis and remediation planning.' as contents;
        

        SELECT 'table' AS component,
       TRUE AS sort,
       TRUE AS search;

        ${pagination.init()} 
        SELECT
            host,
            url,
            template_id AS "Template ID",
            name AS "Description",
            severity AS "Severity",
            ip AS "IP Address",
            matched_path  AS "Matched Path",
            datetime(substr(timestamp, 1, 19), '-4 hours') AS "Scan Time"
        FROM ${viewName};
        ${pagination.renderSimpleMarkdown()};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/naabu.sql"() {
        const viewName = `tem_naabu_result`;
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
            'Tem' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping.sql")} AS link;
        SELECT 'Naabu Port Scan Results' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'Naabu Port Scan Results' as contents;

        SELECT
          'text'              as component,
          'This page displays the results from Naabu port scanning, showing open ports, associated hosts, and key network details. It helps in identifying exposed services and potential network entry points by providing real-time visibility into IPs, protocols, and TLS status discovered during the scan.' as contents;
        

        SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search;

        ${pagination.init()} 
        SELECT
            host,
            port,
            ip AS "IP Address",
            protocol,
            tls,
            datetime(substr(timestamp, 1, 19), '-4 hours') AS "Scan Time"
        FROM ${viewName};
        ${pagination.renderSimpleMarkdown()};`;
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
            async statelessfleetfolioSQL() {
                // read the file from either local or remote (depending on location of this file)
                return await spn.TypicalSqlPageNotebook.fetchText(
                    import.meta.resolve("./stateless.sql"),
                );
            }
        }(),
        new TemSqlPages(),
        new c.ConsoleSqlPages(),
        new d.DocsSqlPages(),
        new ur.UniformResourceSqlPages(),
        new orch.OrchestrationSqlPages(),
        new sh.ShellSqlPages(
            WEB_UI_TITLE,
            WE_UI_LOGO,
            WE_UI_FAV_ICON,
            HIDE_HEADER_TITLE,
        ),
    );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
    console.log((await SQL()).join("\n"));
}
