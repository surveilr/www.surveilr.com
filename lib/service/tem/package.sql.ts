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
        caption: "Attack Surface Mapping By Tenant",
        description:
            `This page provides a comprehensive view of the attack surface mapped for each tenant. It aggregates results from multiple reconnaissance and scanning tools, including HTTP/HTTPS endpoints, subdomains, open ports, and TLS/SSL information. Users can explore discovered hosts, services, protocols, and vulnerabilities, helping teams assess network exposure and prioritize security remediation for each tenant environment.`,
        siblingOrder: 1,
    })
    "tem/attack_surface_mapping_tenant.sql"() {
        return this.SQL`
        ${this.activePageTitle()}

        --- Dsply Page Title
        SELECT
            'title'   as component,
            'Attack Surface Mapping By Tenant' contents;

        SELECT
            'text'              as component,
            "Attack Surface Mapping is the process of identifying, collecting, and analyzing all potential points of entry an attacker could exploit within an organization's digital infrastructure. It involves using tools such as WhatWeb, Nmap, TLS/TLSX, Nuclei, DNSx, Dirsearch, Naabu, Subfinder, Katana, and HTTPX-Toolkit to enumerate exposed services, technologies, subdomains, directories, ports, TLS configurations, and vulnerabilities. This helps organizations gain a comprehensive view of their external and internal exposure, prioritize remediation efforts, and strengthen their security posture." as contents;

        SELECT
            'card' as component,
            4      as columns;
        SELECT tanent_name as title,
          ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || tenant_id as link
         FROM tem_tenant;
        `;
    }

    @temNav({
        caption: "Attack Surface Mapping By Session",
        description:
            `This data represents the information footprint of an application, domain, or infrastructure, typically gathered during reconnaissance, vulnerability assessment, or penetration testing.`,
        siblingOrder: 1,
    })
    "tem/attack_surface_mapping_session.sql"() {
        return this.SQL`
        ${this.activePageTitle()}

        --- Dsply Page Title
        SELECT
            'title'   as component,
            'Attack Surface Mapping By Session' contents;

        SELECT
            'text'              as component,
            "This page presents the attack surface data collected during a specific session. It consolidates results from scanning and reconnaissance tools, showing discovered hosts, services, protocols, and exposed endpoints. This allows users to analyze session-specific findings, track changes over time, and prioritize security actions based on session-based activities." as contents;

        SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search,
        'Session' as markdown;

        SELECT 
            '[' || session_name || ']('||${this.absoluteURL("/tem/session/finding.sql?session_id=")} || ur_ingest_session_id || ')' AS "Session",
            IFNULL(tools_count, '-') AS "Analysis Tools",
            IFNULL(ingest_started_at, '-') AS "Session Start Date",
            IFNULL(ingest_finished_at, '-') AS "Session End Date",
            IFNULL(agent, '-') AS "Agent",
            IFNULL(version, '-') AS "Version"
        FROM tem_session;
        `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/attack_surface_mapping_inner.sql"() {
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;

        SELECT tanent_name AS title,
            '#' AS link FROM tem_tenant WHERE tenant_id=$tenant_id;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'Assets' as contents;

        SELECT
          'text'              as component,
          'Collection of reconnaissance and security assessment tools used for subdomain discovery, port scanning, DNS probing, web technology fingerprinting, TLS analysis, and vulnerability detection.' as contents;
        

       SELECT
            'card' as component,
            4      as columns;
        SELECT
            "Assets"  as title,
            ${this.absoluteURL("/tem/tenant_asset.sql?tenant_id=")} || $tenant_id as link;

        SELECT "Findings" as title,
            ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id as link;
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant_asset.sql"() {
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
         SELECT tanent_name AS title,
            'tenant/attack_surface_mapping_inner.sql?tenant_id='|| $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
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
    "tem/session/finding.sql"() {
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
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT tanent_name AS title,
            'tenant/attack_surface_mapping_inner.sql?tenant_id='|| $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
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
             '[What web data]('||${this.absoluteURL("/tem/session/what_web.sql?session_id=")
            } || $session_id || ')' as Asset,
           (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
           (SELECT count(uniform_resource_id) FROM tem_what_web_result WHERE ur_ingest_session_id = $session_id) as "count";
        SELECT
           '[DNSX Scan Results]('||${this.absoluteURL("/tem/session/dnsx.sql?session_id=")
            } || $session_id || ')' as Asset,
           (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
           (SELECT count(uniform_resource_id) FROM tem_dnsx_result WHERE ur_ingest_session_id = $session_id) as "count";
        SELECT
           '[Nuclei Scan Findings]('||${this.absoluteURL("/tem/session/nuclei.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_nuclei_result WHERE ur_ingest_session_id = $session_id) as "count";
        SELECT
           '[Naabu Port Scan Results]('||${this.absoluteURL("/tem/session/naabu.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_naabu_result WHERE ur_ingest_session_id = $session_id) as "count";
        SELECT
           '[Subfinder Results]('||${this.absoluteURL("/tem/session/subfinder.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_subfinder WHERE ur_ingest_session_id = $session_id) as "count";
         SELECT
           '[HTTPX Toolkit Results]('||${this.absoluteURL("/tem/session/httpx-toolkit.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_httpx_result WHERE ur_ingest_session_id = $session_id) as "count";
         SELECT
           '[Nmap Scan Results]('||${this.absoluteURL("/tem/session/nmap.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_nmap WHERE ur_ingest_session_id = $session_id) as "count";
         SELECT
           '[Katana Scan Results]('||${this.absoluteURL("/tem/session/katana.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_katana WHERE ur_ingest_session_id = $session_id) as "count";
         SELECT
           '[TLS Certificate Results]('||${this.absoluteURL("/tem/session/tlsx_certificate.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_tlsx_certificate WHERE ur_ingest_session_id = $session_id) as "count";
         SELECT
           '[Dirsearch Web Path Enumeration Results]('||${this.absoluteURL("/tem/session/dirsearch.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_dirsearch WHERE ur_ingest_session_id = $session_id) as "count";
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/finding.sql"() {
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
         SELECT tanent_name AS title,
                ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
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
             '[What web data]('||${this.absoluteURL("/tem/tenant/what_web.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_what_web_result WHERE tenant_id = $tenant_id) as "count";
        SELECT
           '[DNSX Scan Results]('||${this.absoluteURL("/tem/tenant/dnsx.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_dnsx_result WHERE tenant_id = $tenant_id) as "count";
            
        SELECT
           '[Nuclei Scan Findings]('||${this.absoluteURL("/tem/tenant/nuclei.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_nuclei_result WHERE tenant_id = $tenant_id) as "count";
        SELECT
           '[Naabu Port Scan Results]('||${this.absoluteURL("/tem/tenant/naabu.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_naabu_result WHERE tenant_id = $tenant_id) as "count";
        SELECT
           '[Subfinder Results]('||${this.absoluteURL("/tem/tenant/subfinder.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_subfinder WHERE tenant_id = $tenant_id) as "count";
         SELECT
           '[HTTPX Toolkit Results]('||${this.absoluteURL("/tem/tenant/httpx-toolkit.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_httpx_result WHERE tenant_id = $tenant_id) as "count";
         SELECT
           '[Nmap Scan Results]('||${this.absoluteURL("/tem/tenant/nmap.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_nmap WHERE tenant_id = $tenant_id) as "count";
         SELECT
           '[Katana Scan Results]('||${this.absoluteURL("/tem/tenant/katana.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_katana WHERE tenant_id = $tenant_id) as "count";
         SELECT
           '[TLS Certificate Results]('||${this.absoluteURL("/tem/tenant/tlsx_certificate.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_tlsx_certificate WHERE tenant_id = $tenant_id) as "count";
         SELECT
           '[Dirsearch Web Path Enumeration Results]('||${this.absoluteURL("/tem/tenant/dirsearch.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_dirsearch WHERE tenant_id = $tenant_id) as "count";
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/what_web.sql"() {
        const viewName = `tem_what_web_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
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
                CASE
                    WHEN length(q.target_url) > 60 THEN substr(q.target_url, 1, 60) || '...'
                    ELSE q.target_url
                END AS "Target URL",
                CASE
                    WHEN q.http_status BETWEEN 200 AND 299 THEN '🟢 ' || q.http_status
                    WHEN q.http_status BETWEEN 300 AND 399 THEN '🟠 ' || q.http_status
                    WHEN q.http_status BETWEEN 400 AND 599 THEN '🔴 ' || q.http_status
                    ELSE CAST(q.http_status AS TEXT)
                END AS "HTTP Status",
                q.ip_address AS "IP Address",
                q.country AS "Country",
                q.http_server AS "Web Server",
                q.page_title AS "Detected Technologies",
                q.uncommon_headers AS "Key HTTP Headers"
            FROM (
                SELECT *
                FROM ${viewName}
                WHERE tenant_id = $tenant_id
            ) q
        ${pagination.renderSimpleMarkdown("tenant_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/what_web.sql"() {
        const viewName = `tem_what_web_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
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
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT 'Findings' AS title,
               ${this.absoluteURL("/tem/session/finding.sql?session_id=")}|| $session_id AS link;
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
                CASE
                    WHEN length(q.target_url) > 60 THEN substr(q.target_url, 1, 60) || '...'
                    ELSE q.target_url
                END AS "Target URL",
                q.tanent_name AS "Tenant",
                CASE
                    WHEN q.http_status BETWEEN 200 AND 299 THEN '🟢 ' || q.http_status
                    WHEN q.http_status BETWEEN 300 AND 399 THEN '🟠 ' || q.http_status
                    WHEN q.http_status BETWEEN 400 AND 599 THEN '🔴 ' || q.http_status
                    ELSE CAST(q.http_status AS TEXT)
                END AS "HTTP Status",
                q.ip_address AS "IP Address",
                q.country AS "Country",
                q.http_server AS "Web Server",
                q.page_title AS "Detected Technologies",
                q.uncommon_headers AS "Key HTTP Headers"
            FROM (
                SELECT *
                FROM ${viewName}
                WHERE ur_ingest_session_id = $session_id
            ) q
        ${pagination.renderSimpleMarkdown("session_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/dnsx.sql"() {
        const viewName = `tem_dnsx_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
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
        FROM ${viewName} WHERE tenant_id = $tenant_id;
        ${pagination.renderSimpleMarkdown("tenant_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/dnsx.sql"() {
        const viewName = `tem_dnsx_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT 'Findings' AS title,
               ${this.absoluteURL("/tem/session/finding.sql?session_id=")}|| $session_id AS link;
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
            tanent_name AS "Tenant",
            host,
            ttl,
            resolver,
            ip_address as "ip address",
            status_code AS "status code",
            datetime(substr(timestamp, 1, 19), '-4 hours') AS time
        FROM ${viewName} WHERE ur_ingest_session_id = $session_id;
        ${pagination.renderSimpleMarkdown("session_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/nuclei.sql"() {
        const viewName = `tem_nuclei_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
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
        FROM ${viewName} WHERE tenant_id = $tenant_id;
        ${pagination.renderSimpleMarkdown("tenant_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/nuclei.sql"() {
        const viewName = `tem_nuclei_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
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
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT 'Findings' AS title,
               ${this.absoluteURL("/tem/session/finding.sql?session_id=")}|| $session_id AS link;
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
            tanent_name AS "Tenant",
            host,
            url,
            template_id AS "Template ID",
            name AS "Description",
            severity AS "Severity",
            ip AS "IP Address",
            matched_path  AS "Matched Path",
            datetime(substr(timestamp, 1, 19), '-4 hours') AS "Scan Time"
        FROM ${viewName} WHERE ur_ingest_session_id = $session_id;
        ${pagination.renderSimpleMarkdown("session_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/naabu.sql"() {
        const viewName = `tem_naabu_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
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
        FROM ${viewName} WHERE tenant_id = $tenant_id;
        ${pagination.renderSimpleMarkdown("tenant_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/naabu.sql"() {
        const viewName = `tem_naabu_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
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
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT 'Findings' AS title,
            ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
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
            tanent_name AS "Tenant",
            host,
            port,
            ip AS "IP Address",
            protocol,
            tls,
            datetime(substr(timestamp, 1, 19), '-4 hours') AS "Scan Time"
        FROM ${viewName} WHERE ur_ingest_session_id = $session_id;
        ${pagination.renderSimpleMarkdown("session_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/subfinder.sql"() {
        const viewName = `tem_subfinder`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
        SELECT 'Subfinder Results' AS title,
            '#' AS link;

        --- Display Page Title
        SELECT
          'title'   as component,
          'Subfinder Results' as contents;

        SELECT
          'text' as component,
          'This page displays results from the Subfinder tool. It shows discovered subdomains, their source, and ingestion metadata. This helps in expanding the attack surface by enumerating subdomains associated with target domains and providing visibility into where they were found.' as contents;

        SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search;

        ${pagination.init()} 
        SELECT
            domain                AS "Domain",
            raw_records           AS "Discovered Host",
            source                AS "Source",
            tool_name             AS "Tool"
        FROM ${viewName} WHERE tenant_id = $tenant_id;
        ${pagination.renderSimpleMarkdown("tenant_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/subfinder.sql"() {
        const viewName = `tem_subfinder`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
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
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT 'Findings' AS title,
            ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
        SELECT 'Subfinder Results' AS title,
            '#' AS link;

        --- Display Page Title
        SELECT
          'title'   as component,
          'Subfinder Results' as contents;

        SELECT
          'text' as component,
          'This page displays results from the Subfinder tool. It shows discovered subdomains, their source, and ingestion metadata. This helps in expanding the attack surface by enumerating subdomains associated with target domains and providing visibility into where they were found.' as contents;

        SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search;

        ${pagination.init()} 
        SELECT
            tanent_name           AS  "Tenant",
            domain                AS "Domain",
            raw_records           AS "Discovered Host",
            source                AS "Source",
            tool_name             AS "Tool"
        FROM ${viewName} WHERE ur_ingest_session_id = $session_id;
        ${pagination.renderSimpleMarkdown("session_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/httpx-toolkit.sql"() {
        const viewName = `tem_httpx_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
        SELECT 'HTTPX Toolkit Results' AS title,
            '#' AS link;

        --- Display Page Title
        SELECT
          'title'   as component,
          'HTTPX Toolkit Results' as contents;

        SELECT
          'text' as component,
          'This page displays results from the httpx-toolkit. It provides insights into HTTP/HTTPS endpoints, including status codes, response times, content type, IP resolution, and digests. This helps identify live services, exposed endpoints, and potential security issues.' as contents;

        SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search;

        ${pagination.init()} 
        SELECT
            domain             AS "Domain",
            url                AS "URL",
            scheme             AS "Scheme",
            port               AS "Port",
            (
                SELECT group_concat(value, ', ')
                FROM json_each(ip_addresses)
            )                 AS "IP Addresses",
            status_code        AS "Status Code",
            content_type       AS "Content Type",
            response_time      AS "Response Time",
            http_method        AS "HTTP Method",
            resolved_host      AS "Resolved Host",
            ingest_timestamp   AS "Ingested At"
        FROM ${viewName} WHERE tenant_id = $tenant_id;
        ${pagination.renderSimpleMarkdown("tenant_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/httpx-toolkit.sql"() {
        const viewName = `tem_httpx_result`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
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
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT 'Findings' AS title,
             ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
        SELECT 'HTTPX Toolkit Results' AS title,
            '#' AS link;

        --- Display Page Title
        SELECT
          'title'   as component,
          'HTTPX Toolkit Results' as contents;

        SELECT
          'text' as component,
          'This page displays results from the httpx-toolkit. It provides insights into HTTP/HTTPS endpoints, including status codes, response times, content type, IP resolution, and digests. This helps identify live services, exposed endpoints, and potential security issues.' as contents;

        SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search;

        ${pagination.init()} 
        SELECT
            tanent_name        AS  "Tenant",
            domain             AS "Domain",
            url                AS "URL",
            scheme             AS "Scheme",
            port               AS "Port",
            (
                SELECT group_concat(value, ', ')
                FROM json_each(ip_addresses)
            )                 AS "IP Addresses",
            status_code        AS "Status Code",
            content_type       AS "Content Type",
            response_time      AS "Response Time",
            http_method        AS "HTTP Method",
            resolved_host      AS "Resolved Host",
            ingest_timestamp   AS "Ingested At"
        FROM ${viewName} WHERE ur_ingest_session_id = $session_id;
        ${pagination.renderSimpleMarkdown("session_id")};`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/nmap.sql"() {
        const viewName = `tem_nmap`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
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
            SELECT 'Attack Surface Mapping By Tenant' AS title,
                ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
            SELECT tanent_name AS title,
                ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
            SELECT 'Findings' AS title,
                    ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
            SELECT 'Nmap Scan Results' AS title,
           '#' AS link;

        --- Display Page Title
        SELECT 'title' AS component,
            'Nmap Scan Results' AS contents;

        --- Page description
        SELECT 'text' AS component,
            'This page displays parsed Nmap scan results extracted from XML stored in uniform_resource.content. 
                It includes host IP, port, protocol, state, and detected service details to help assess open services and network exposure.' AS contents;

        --- Table setup
        SELECT 'table' AS component,
            TRUE AS sort,
            TRUE AS search;

        ${pagination.init()}
        SELECT
            host_ip           AS "Host IP",
            protocol          AS "Protocol",
            port              AS "Port",
            state             AS "State",
            service_name      AS "Service",
            service_product   AS "Product",
            service_version   AS "Version",
            service_extrainfo AS "Extra Info",
            tool_name         AS "Tool"
        FROM ${viewName} WHERE tenant_id = $tenant_id;;

        ${pagination.renderSimpleMarkdown("tenant_id")};
`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/nmap.sql"() {
        const viewName = `tem_nmap`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
        });
        return this.SQL`
        ${this.activePageTitle()}
        --- Display breadcrumb
        SELECT 'breadcrumb' AS component;
            SELECT
            'breadcrumb' AS component;
            SELECT
                'Home' AS title,
                ${this.absoluteURL("/")}    AS link;
            SELECT
                'Tem' AS title,
                ${this.absoluteURL("/tem/index.sql")} AS link;  
            SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
            SELECT 'Findings' AS title,
             ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
            SELECT 'Nmap Scan Results' AS title,
           '#' AS link;

        --- Display Page Title
        SELECT 'title' AS component,
            'Nmap Scan Results' AS contents;

        --- Page description
        SELECT 'text' AS component,
            'This page displays parsed Nmap scan results extracted from XML stored in uniform_resource.content. 
                It includes host IP, port, protocol, state, and detected service details to help assess open services and network exposure.' AS contents;

        --- Table setup
        SELECT 'table' AS component,
            TRUE AS sort,
            TRUE AS search;

        ${pagination.init()}
        SELECT
            tanent_name       AS  "Tenant",
            host_ip           AS "Host IP",
            protocol          AS "Protocol",
            port              AS "Port",
            state             AS "State",
            service_name      AS "Service",
            service_product   AS "Product",
            service_version   AS "Version",
            service_extrainfo AS "Extra Info",
            tool_name         AS "Tool"
        FROM ${viewName} WHERE ur_ingest_session_id = $session_id;;

        ${pagination.renderSimpleMarkdown("tenant_id")};
`;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/katana.sql"() {
        const viewName = `tem_katana`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
        });
        return this.SQL`
        ${this.activePageTitle()}

        --- Display breadcrumb
        SELECT 'breadcrumb' AS component;
            SELECT
                'Home' AS title,
                ${this.absoluteURL("/")} AS link;
            SELECT
                'Tem' AS title,
                ${this.absoluteURL("/tem/index.sql")} AS link;
            SELECT
                'Attack Surface Mapping By Tenant' AS title,
                ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
            SELECT tanent_name AS title,
                ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id
                AS link
            FROM tem_tenant WHERE tenant_id = $tenant_id;
            SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
            SELECT 'Katana Scan Results' AS title,
                '#' AS link;

        --- Page title
        SELECT 'title' AS component,
            'Katana Scan Results' AS contents;

        --- Page description
        SELECT 'text' AS component,
            'This page displays parsed Katana scan results extracted from JSONL stored in uniform_resource.content. 
            Each record includes the request method, endpoint, status code, and timestamp, 
            helping to analyze web exposure discovered during reconnaissance.' AS contents;

        --- Table setup
        SELECT 'table' AS component,
            TRUE AS sort,
            TRUE AS search;

        ${pagination.init()}
        SELECT
           strftime('%m-%d-%Y', timestamp) AS "Observed At",
            method        AS "Method",
            endpoint      AS "Endpoint",
            COALESCE(
                printf('%s', status_code),
                'N/A'
            )                               AS "Status Code"
        FROM ${viewName}
        WHERE tenant_id = $tenant_id;

        ${pagination.renderSimpleMarkdown("tenant_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/katana.sql"() {
        const viewName = `tem_katana`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
        });

        return this.SQL`
        ${this.activePageTitle()}

        --- Breadcrumb
        SELECT 'breadcrumb' AS component;
            SELECT 'Home' AS title,
                ${this.absoluteURL("/")} AS link;
            SELECT 'Tem' AS title,
                ${this.absoluteURL("/tem/index.sql")} AS link;  
            SELECT 'Attack Surface Mapping By Session' AS title,
                ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
            SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
            SELECT 'Katana Scan Results' AS title,
                '#' AS link;

        --- Page Title
        SELECT 'title' AS component,
            'Katana Scan Results' AS contents;

        --- Page Description
        SELECT 'text' AS component,
            'This page displays parsed Katana scan results extracted from JSONL stored in uniform_resource.content. 
             It includes request and response details such as method, endpoint, status code, and observed timestamps 
             to assist in analyzing web application surface mapping.' AS contents;

        --- Table Config
        SELECT 'table' AS component,
            TRUE AS sort,
            TRUE AS search;

        ${pagination.init()}
        SELECT
            tanent_name  AS "Tenant",
            strftime('%m-%d-%Y %H:%M:%S', timestamp) AS "Observed At",
            method       AS "Method",
            endpoint     AS "Endpoint",
            COALESCE(status_code, 'N/A') AS "Status Code"
        FROM ${viewName}
        WHERE ur_ingest_session_id = $session_id;

        ${pagination.renderSimpleMarkdown("session_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/tlsx_certificate.sql"() {
        const viewName = `tem_tlsx_certificate`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
        });
        return this.SQL`
        ${this.activePageTitle()}

        --- Breadcrumb setup
        SELECT 'breadcrumb' AS component;
            SELECT 'Home' AS title,
                ${this.absoluteURL("/")} AS link;
            SELECT 'Tem' AS title,
                ${this.absoluteURL("/tem/index.sql")} AS link;
            SELECT 'Attack Surface Mapping By Tenant' AS title,
                ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
            SELECT tanent_name AS title,
                ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link
            FROM tem_tenant WHERE tenant_id = $tenant_id;
            SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
            SELECT 'TLS Certificate Results' AS title,
                '#' AS link;

        --- Page title
        SELECT 'title' AS component,
            'TLS Certificate Results' AS contents;

        --- Page description
        SELECT 'text' AS component,
            'This page displays parsed TLS certificate scan results from tlsx JSONL data stored in uniform_resource.content.
            Each record includes host, IP, port, TLS version, cipher suite, subject/issuer details, fingerprints, and validity period.
            This helps assess TLS configuration, certificate trust, and potential misconfigurations.' AS contents;

        --- Table setup
        SELECT 'table' AS component,
            TRUE AS sort,
            TRUE AS search;

        ${pagination.init()}
        SELECT
            strftime('%m-%d-%Y', observed_at) AS "Observed At",
            host                              AS "Host",
            ip_address                        AS "IP Address",
            port                              AS "Port",
            probe_status                      AS "Probe Status",
            tls_version                       AS "TLS Version",
            is_self_signed                    AS "Self-Signed",
            is_mismatched                     AS "Mismatched",
            strftime('%m-%d-%Y', valid_from)  AS "Valid From",
            strftime('%m-%d-%Y', valid_until) AS "Valid Until",
            serial_number                     AS "Serial",
            issuer_dn                         AS "Issuer DN",
            issuer_cn                         AS "Issuer CN",
            tls_connection                    AS "TLS Connection",
            sni                               AS "SNI"
        FROM ${viewName}
        WHERE tenant_id = $tenant_id;

        ${pagination.renderSimpleMarkdown("tenant_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/tlsx_certificate.sql"() {
        const viewName = `tem_tlsx_certificate`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
        });
        return this.SQL`
        ${this.activePageTitle()}

        --- Breadcrumb setup
       SELECT 'breadcrumb' AS component;
            SELECT 'Home' AS title,
                ${this.absoluteURL("/")} AS link;
            SELECT 'Tem' AS title,
                ${this.absoluteURL("/tem/index.sql")} AS link;  
            SELECT 'Attack Surface Mapping By Session' AS title,
                ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
            SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
            SELECT 'TLS Certificate Results' AS title,
                '#' AS link;

        --- Page title
        SELECT 'title' AS component,
            'TLS Certificate Results' AS contents;

        --- Page description
        SELECT 'text' AS component,
            'This page displays parsed TLS certificate scan results from tlsx JSONL data stored in uniform_resource.content.
            Each record includes host, IP, port, TLS version, cipher suite, subject/issuer details, fingerprints, and validity period.
            This helps assess TLS configuration, certificate trust, and potential misconfigurations.' AS contents;

        --- Table setup
        SELECT 'table' AS component,
            TRUE AS sort,
            TRUE AS search;

        ${pagination.init()}
        SELECT
            tanent_name  AS "Tenant",
            strftime('%m-%d-%Y', observed_at) AS "Observed At",
            host                              AS "Host",
            ip_address                        AS "IP Address",
            port                              AS "Port",
            probe_status                      AS "Probe Status",
            tls_version                       AS "TLS Version",
            is_self_signed                    AS "Self-Signed",
            is_mismatched                     AS "Mismatched",
            strftime('%m-%d-%Y', valid_from)  AS "Valid From",
            strftime('%m-%d-%Y', valid_until) AS "Valid Until",
            serial_number                     AS "Serial",
            issuer_dn                         AS "Issuer DN",
            issuer_cn                         AS "Issuer CN",
            tls_connection                    AS "TLS Connection",
            sni                               AS "SNI"
        FROM ${viewName}
        WHERE ur_ingest_session_id = $session_id;

        ${pagination.renderSimpleMarkdown("session_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/dirsearch.sql"() {
        const viewName = `tem_dirsearch`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
        });
        return this.SQL`
      ${this.activePageTitle()}

      --- Breadcrumb setup
      SELECT 'breadcrumb' AS component;
          SELECT 'Home' AS title,
              ${this.absoluteURL("/")} AS link;
          SELECT 'Tem' AS title,
              ${this.absoluteURL("/tem/index.sql")} AS link;
          SELECT 'Attack Surface Mapping By Tenant' AS title,
              ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
          SELECT tanent_name AS title,
              ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link
          FROM tem_tenant WHERE tenant_id = $tenant_id;
          SELECT 'Findings' AS title,
              ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
          SELECT 'Dirsearch Web Path Enumeration Results' AS title,
              '#' AS link;

      --- Page title
      SELECT 'title' AS component,
          'Dirsearch Web Path Enumeration Results' AS contents;

      --- Page description
      SELECT 'text' AS component,
          'This page displays parsed results from the Dirsearch tool, which scans web applications to enumerate hidden files and directories. 
          Each entry shows the discovered URL, HTTP status code, content type, response length, and any redirect information.
          These insights help identify sensitive endpoints, misconfigurations, or exposed resources within a tenant’s web application footprint.' AS contents;

      --- Table setup
      SELECT 'table' AS component,
          TRUE AS sort,
          TRUE AS search;

      ${pagination.init()}
      SELECT
          observed_at AS "Observed At",
          discovered_url   AS "Discovered URL",
          status_code      AS "Status Code",
          content_type     AS "Content Type",
          content_length   AS "Content Length",
          redirect_url     AS "Redirect"
      FROM ${viewName}
      WHERE tenant_id = $tenant_id;

      ${pagination.renderSimpleMarkdown("tenant_id")};
  `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/dirsearch.sql"() {
        const viewName = `tem_dirsearch`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE ur_ingest_session_id = $session_id",
        });
        return this.SQL`
      ${this.activePageTitle()}

      --- Breadcrumb setup
        SELECT 'breadcrumb' AS component;
            SELECT 'Home' AS title,
                ${this.absoluteURL("/")} AS link;
            SELECT 'Tem' AS title,
                ${this.absoluteURL("/tem/index.sql")} AS link;  
            SELECT 'Attack Surface Mapping By Session' AS title,
                ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
            SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
          SELECT 'Dirsearch Web Path Enumeration Results' AS title,
              '#' AS link;

      --- Page title
      SELECT 'title' AS component,
          'Dirsearch Web Path Enumeration Results' AS contents;

      --- Page description
      SELECT 'text' AS component,
          'This page displays parsed results from the Dirsearch tool, which scans web applications to enumerate hidden files and directories. 
          Each entry shows the discovered URL, HTTP status code, content type, response length, and any redirect information.
          These insights help identify sensitive endpoints, misconfigurations, or exposed resources within a session’s web application footprint.' AS contents;

      --- Table setup
      SELECT 'table' AS component,
          TRUE AS sort,
          TRUE AS search;

      ${pagination.init()}
      SELECT
          tanent_name  AS "Tenant",
          observed_at AS "Observed At",
          discovered_url   AS "Discovered URL",
          status_code AS "Status Code",
          content_type     AS "Content Type",
          content_length   AS "Content Length",
          COALESCE(redirect_url, '-') AS "Redirect"
      FROM ${viewName}
      WHERE ur_ingest_session_id = $session_id;

      ${pagination.renderSimpleMarkdown("session_id")};
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
