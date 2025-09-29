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
    caption: "Threat Exposure Management",
    description: `Opsfolio Threat Exposure Management (TEM) and Opsfolio EAA are part of the Opsfolio Suite, which underpins Opsfolio Compliance-as-a-Service (CaaS) offerings.`,
    })
    "tem/index.sql"() {
    const taskView = "tem_task_summary"; 
    const pagination = this.pagination({
        tableOrViewName: taskView,
        whereSQL: "WHERE uri LIKE '%task%'",
    });

    return this.SQL`
        -- Intro text
        SELECT
            'text' AS component,
            'Opsfolio Threat Exposure Management (TEM) transforms static penetration test reports into real-time, actionable dashboards and workflows. Powered by Opsfolio EAA, it streamlines vulnerability reporting, automates remediation tracking, and delivers compliance-ready evidence to keep your organization secure and audit-ready.' AS contents;

        -- Navigation list
        WITH navigation_cte AS (
            SELECT COALESCE(title, caption) AS title, description
            FROM sqlpage_aide_navigation
            WHERE namespace = 'prime' AND path = ${this.constructHomePath("tem")}
        )
        SELECT 'list' AS component, title, description
        FROM navigation_cte;

        SELECT caption AS title, ${this.absoluteURL("/")} || COALESCE(url, path) AS link, description
        FROM sqlpage_aide_navigation
        WHERE namespace = 'prime' AND parent_path = ${this.constructHomePath("tem")}
        ORDER BY sibling_order;

        --- Page Title for Tasks Section
        SELECT 'title' AS component, 'Tasks Overview' AS contents;

        --- Small description above the table
        SELECT 'text' AS component,
        'This table lists all tasks detected in the system, including their status and title. Click on a Task ID to view detailed content.' AS contents;

        --- Tasks Table
        SELECT 'table' AS component, TRUE AS sort, TRUE AS search, 'Title' AS markdown;

        ${pagination.init()}
        SELECT
        '[' || title || '](' || ${this.absoluteURL("/tem/task_detail.sql?task_id=")} || uniform_resource_id || ')' AS "Title",
        task_id AS "Task ID",
        status AS "Status"
        FROM ${taskView};

        ${pagination.renderSimpleMarkdown()};
    `;
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
         SELECT
           '[TestSSL Report]('||${this.absoluteURL("/tem/session/tssl_certificate.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Session Name",
            (SELECT count(uniform_resource_id) FROM tem_testssl_general WHERE ur_ingest_session_id = $session_id) as "count";
         SELECT
           '[SSL/TLS Certificate Metadata]('||${this.absoluteURL("/tem/session/openssl.sql?session_id=")
            } || $session_id || ')' as Asset,
            (SELECT session_name FROM tem_session WHERE ur_ingest_session_id = $session_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_openssl WHERE ur_ingest_session_id = $session_id) as "count";
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
            'Threat Exposure Management' AS title,
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
         SELECT
           '[TestSSL Report]('||${this.absoluteURL("/tem/tenant/tssl_certificate.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_testssl_general WHERE tenant_id = $tenant_id) as "count";
         SELECT
           '[SSL/TLS Certificate Metadata]('||${this.absoluteURL("/tem/tenant/openssl.sql?tenant_id=")
            } || $tenant_id || ')' as Asset,
            (SELECT tanent_name FROM tem_tenant WHERE tenant_id = $tenant_id) AS "Tenant Name",
            (SELECT count(uniform_resource_id) FROM tem_openssl WHERE tenant_id = $tenant_id) as "count";
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
            'Threat Exposure Management' AS title,
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
                'Threat Exposure Management' AS title,
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
                'Threat Exposure Management' AS title,
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
                'Threat Exposure Management' AS title,
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
            SELECT 'Threat Exposure Management' AS title,
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
            SELECT 'Threat Exposure Management' AS title,
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
            SELECT 'Threat Exposure Management' AS title,
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
          SELECT 'Threat Exposure Management' AS title,
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
            SELECT 'Threat Exposure Management' AS title,
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

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/tssl_certificate.sql"() {
        const viewName = `tem_testssl_general`;
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
            'Threat Exposure Management' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
        SELECT 'TestSSL Report' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'TestSSL Report' as contents;

        SELECT
          'text'              as component,
          'The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.' as contents;
        
         SELECT 'table' AS component,
          TRUE AS sort,
          TRUE AS search,
          'Host' as markdown;

      ${pagination.init()}
      SELECT
           '[' || host || '](' || ${this.absoluteURL("/tem/tenant/tssl_certificate_inner.sql?component=tab&tab=pretests&uniform_resource_id=")
            } || uniform_resource_id ||'&tenant_id='||$tenant_id||')' as Host,
          datetime(start_time, 'unixepoch') AS "start time",
          ip,
          port,
          rdns
      FROM ${viewName}
      WHERE tenant_id = $tenant_id;

      ${pagination.renderSimpleMarkdown("tenant_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/tssl_certificate_inner.sql"() {
        const viewName = `tem_testssl_general`;
        const pretestViewName = `tem_testssl_pretest`;
        const pretestPagination = this.pagination({
            tableOrViewName: pretestViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const protocolsViewName = `tem_testssl_protocols`;
        const protocolsPagination = this.pagination({
            tableOrViewName: protocolsViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const ciphersViewName = `tem_testssl_ciphers`;
        const ciphersPagination = this.pagination({
            tableOrViewName: ciphersViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const serverReferencesViewName = `tem_testssl_server_references`;
        const serverReferencesPagination = this.pagination({
            tableOrViewName: serverReferencesViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const fsViewName = `tem_testssl_fs`;
        const fsPagination = this.pagination({
            tableOrViewName: fsViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const serverDefaultsViewName = `tem_testssl_server_default`;
        const serverDefaultsPagination = this.pagination({
            tableOrViewName: serverDefaultsViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const headerResponseViewName = `tem_testssl_header_response`;
        const headerResponsePagination = this.pagination({
            tableOrViewName: headerResponseViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const vulnerabilitieViewName = `tem_testssl_vulnerabilitie`;
        const vulnerabilitiePagination = this.pagination({
            tableOrViewName: vulnerabilitieViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const browserSimulationViewName = `tem_testssl_browser_simulation`;
        const browserSimulationPagination = this.pagination({
            tableOrViewName: browserSimulationViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
        });
        const ratingViewName = `tem_testssl_rating`;
        const ratingPagination = this.pagination({
            tableOrViewName: ratingViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND tenant_id = $tenant_id",
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
            'Threat Exposure Management' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping By Tenant' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
        SELECT tanent_name AS title,
            ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link FROM tem_tenant WHERE tenant_id=$tenant_id;
        SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
        SELECT 'TestSSL Report' AS title,
            ${this.absoluteURL("/tem/tenant/tssl_certificate.sql?tenant_id=")} || $tenant_id AS link;
        SELECT host AS title,
            '#' AS link
        FROM ${viewName}
        WHERE tenant_id = $tenant_id;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'TestSSL Report' as contents;

        SELECT
          'text'              as component,
          'The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.' as contents;
        


        select 
        'table' as component,
        TRUE    as freeze_columns,
        TRUE    as freeze_headers,
        TRUE    as border;  
           
            select 
                'Invocation' as 'General Info',
                invocation as 'Value'
                FROM tem_testssl_general WHERE tenant_id=$tenant_id
            union all
            select 
                'Open SSL' as 'General Info',
                openssl as 'Value'
                FROM tem_testssl_general WHERE tenant_id=$tenant_id
            union all
            select 
                'Version' as 'General Info',
                version as 'Value'
                FROM tem_testssl_general WHERE tenant_id=$tenant_id
            union all
            select 
                'Host' as 'General Info',
                host as 'Value'
                FROM tem_testssl_general WHERE tenant_id=$tenant_id
            union all
            select 
                'ip' as 'General Info',
                ip as 'Value'
                FROM tem_testssl_general WHERE tenant_id=$tenant_id
            union all
            select 
                'port' as 'General Info',
                port as 'Value'
                FROM tem_testssl_general WHERE tenant_id=$tenant_id
            union all
            select 
                'service' as 'General Info',
                service as 'Value'
                FROM tem_testssl_general WHERE tenant_id=$tenant_id

       select 
            'tab' as component;
        -- Pretests tab (active only if tab=pretests) 
        select 
            'Pretests' as title,
            (coalesce($tab, 'pretests') = 'pretests') as active,
            '?component=tab&tab=pretests&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- Protocols tab (active only if tab=protocols) 
        select 
            'Protocols' as title,
            ($tab = 'protocols') as active,
            '?component=tab&tab=protocols&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

         -- Ciphers tab (active only if tab=ciphers)
        select 
            'Ciphers' as title,
            ($tab = 'ciphers') as active,
            '?component=tab&tab=ciphers&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- Server Preferences tab (active only if tab=server-preferences)
        select 
            'Server Preferences' as title,
            ($tab = 'server-preferences') as active,
            '?component=tab&tab=server-preferences&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- Forward Secrecy (active only if tab=forward-secrecy)
        select 
            'Forward Secrecy' as title,
            ($tab = 'forward-secrecy') as active,
            '?component=tab&tab=forward-secrecy&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- Server Defaults / Certificates (active only if tab=protocols)
        select 
            'Server Defaults / Certificates' as title,
            ($tab = 'server-defaults') as active,
            '?component=tab&tab=server-defaults&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- HTTP Response Headers (active only if tab=http-response-header)
        select 
            'HTTP Response Headers' as title,
            ($tab = 'http-response-header') as active,
            '?component=tab&tab=http-response-header&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- Vulnerabilities (active only if tab=http-response-header)
        select 
            'Vulnerabilities' as title,
            ($tab = 'vulnerabilitie') as active,
            '?component=tab&tab=vulnerabilitie&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- Browser Simulations (active only if tab=browser-simulations)
        select 
            'Browser Simulations' as title,
            ($tab = 'browser-simulations') as active,
            '?component=tab&tab=browser-simulations&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

        -- Rating (active only if tab=rating)
        select 
            'Rating' as title,
            ($tab = 'rating') as active,
            '?component=tab&tab=rating&uniform_resource_id='||$uniform_resource_id||'&tenant_id='||$tenant_id as link;

            -- Pretests tab
            ${pretestPagination.init()}
            SELECT
            'title'   as component,
            'Pretests' as contents WHERE $tab = 'pretests';
            SELECT
            'text'              as component,
            'Quick preliminary checks performed before the detailed scan. These verify basic connectivity, service availability, and whether the host can be tested reliably.' as contents
            WHERE $tab = 'pretests';
        
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'pretests';
            select id,severity,finding from ${pretestViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'pretests';
            ${pretestPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='pretests'")};

            -- Protocols tab
            ${protocolsPagination.init()}
            SELECT
            'title'   as component,
            'Protocols' as contents WHERE $tab = 'protocols';
            SELECT
            'text'              as component,
            'Lists the supported SSL/TLS protocol versions (e.g., TLS 1.0, 1.2, 1.3). Helps identify if older, insecure protocols are enabled or only modern secure ones are accepted.' as contents
            WHERE $tab = 'protocols';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'protocols';
            select id,severity,finding from ${protocolsViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'protocols';
            ${protocolsPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='protocols'")};

            -- Ciphers tab
            ${ciphersPagination.init()}
            SELECT
            'title'   as component,
            'Ciphers' as contents WHERE $tab = 'ciphers';
            SELECT
            'text'              as component,
            'Shows the encryption algorithms (ciphers) supported by the server. Weak or outdated ciphers (like CBC-based ones) are flagged, while strong ciphers are marked safe.' as contents
            WHERE $tab = 'ciphers';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'ciphers';
            select id,severity,finding from ${ciphersViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'ciphers';
            ${ciphersPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='ciphers'")};

            -- Server Preferences tab
            ${serverReferencesPagination.init()}
            SELECT
            'title'   as component,
            'Server Preferences' as contents WHERE $tab = 'server-preferences';
            SELECT
            'text'              as component,
            'Describes how the server prioritizes protocols and ciphers. For example, whether the server enforces its own cipher order or allows clients to choose.' as contents
            WHERE $tab = 'server-preferences';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'server-preferences';
            select id,severity,finding from ${serverReferencesViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'server-preferences';
            ${serverReferencesPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='server-preferences'")};

            -- Forward Secrecy (FS) tab
            ${fsPagination.init()}
            SELECT
            'title'   as component,
            'Forward Secrecy (FS)' as contents WHERE $tab = 'forward-secrecy';
            SELECT
            'text'              as component,
            'Checks whether the server supports forward secrecy using key exchange methods (e.g., ECDHE). FS ensures that past communications remain secure even if the server’s private key is compromised later.' as contents
            WHERE $tab = 'forward-secrecy';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'forward-secrecy';
            select id,severity,finding from ${fsViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'forward-secrecy';
            ${fsPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='forward-secrecy'")};

            -- Server Defaults / Certificates tab
            ${serverDefaultsPagination.init()}
            SELECT
            'title'   as component,
            'Server Defaults / Certificates' as contents WHERE $tab = 'server-defaults';
            SELECT
            'text'              as component,
            'Displays SSL/TLS certificate information such as common name, issuer, validity, and other defaults. This helps verify domain ownership, certificate authority, and expiration.' as contents
            WHERE $tab = 'server-defaults';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'server-defaults';
            select id,severity,finding from ${serverDefaultsViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'server-defaults';
            ${serverDefaultsPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='server-defaults'")};

            -- HTTP Response Headers tab
            ${headerResponsePagination.init()}
            SELECT
            'title'   as component,
            'HTTP Response Headers' as contents WHERE $tab = 'http-response-header';
            SELECT
            'text'              as component,
            'Lists security-related HTTP headers (e.g., HSTS, X-Frame-Options, CSP). These help protect against attacks like clickjacking, XSS, or protocol downgrade.' as contents
            WHERE $tab = 'http-response-header';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'http-response-header';
            select header_response_id as "header response id",severity,finding from ${headerResponseViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'http-response-header';
            ${headerResponsePagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='http-response-header'")};

            -- Vulnerabilities tab
            ${vulnerabilitiePagination.init()}
            SELECT
            'title'   as component,
            'Vulnerabilities' as contents WHERE $tab = 'vulnerabilitie';
            SELECT
            'text'              as component,
            'Tests the server against known SSL/TLS vulnerabilities (e.g., Heartbleed, POODLE, LUCKY13). Any positive finding here indicates a serious risk.' as contents
            WHERE $tab = 'vulnerabilitie';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'vulnerabilitie';
            select vulnerability_id as "vulnerability id",severity,finding from ${vulnerabilitieViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'vulnerabilitie';
            ${vulnerabilitiePagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='vulnerabilitie'")};

            -- Browser Simulations tab
            ${browserSimulationPagination.init()}
            SELECT
            'title'   as component,
            'Browser Simulations' as contents WHERE $tab = 'browser-simulations';
            SELECT
            'text'              as component,
            'Simulates how different browsers and versions connect to the server. This helps verify compatibility and whether old browsers are blocked from insecure connections.' as contents
            WHERE $tab = 'browser-simulations';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'browser-simulations';
            select simulation_id as "simulation id",severity,finding from ${browserSimulationViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'browser-simulations';
            ${browserSimulationPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='browser-simulations'")};

           -- Rating Simulations tab
            ${ratingPagination.init()}
             SELECT
            'title'   as component,
            'Rating' as contents WHERE $tab = 'rating';
            SELECT
            'text'              as component,
            'Provides an overall grade (A, B, etc.) summarizing the server’s SSL/TLS configuration strength. This is often based on industry benchmarks like SSL Labs grading.' as contents
            WHERE $tab = 'rating';
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'rating';
            select rating_id as "rating id",severity,finding from ${ratingViewName} where uniform_resource_id= $uniform_resource_id AND tenant_id=$tenant_id AND $tab = 'rating';
            ${ratingPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "tenant_id", "$tab='rating'")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/tssl_certificate.sql"() {
        const viewName = `tem_testssl_general`;
        const pagination = this.pagination({
            tableOrViewName: viewName,
            whereSQL: "WHERE tenant_id = $tenant_id",
        });
        return this.SQL`
      ${this.activePageTitle()}
        --- Display breadcrumb
         SELECT 'breadcrumb' AS component;
            SELECT 'Home' AS title,
                ${this.absoluteURL("/")} AS link;
            SELECT 'Threat Exposure Management' AS title,
                ${this.absoluteURL("/tem/index.sql")} AS link;  
            SELECT 'Attack Surface Mapping By Session' AS title,
                ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
            SELECT 'Findings' AS title,
                ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
        SELECT 'TestSSL Report' AS title,
            '#' AS link;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'TestSSL Report' as contents;

        SELECT
          'text'              as component,
          'The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.' as contents;
        
         SELECT 'table' AS component,
          TRUE AS sort,
          TRUE AS search,
          'Host' as markdown;

      ${pagination.init()}
      SELECT
           '[' || host || '](' || ${this.absoluteURL("/tem/session/tssl_certificate_inner.sql?component=tab&tab=pretests&uniform_resource_id=")
            } || uniform_resource_id ||'&session_id='||$session_id||')' as Host,
          datetime(start_time, 'unixepoch') AS "start time",
          ip,
          port,
          rdns,
          tanent_name  AS "Tenant"
      FROM ${viewName}
      WHERE ur_ingest_session_id = $session_id;

      ${pagination.renderSimpleMarkdown("session_id")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/tssl_certificate_inner.sql"() {
        const viewName = `tem_testssl_general`;
        const pretestViewName = `tem_testssl_pretest`;
        const pretestPagination = this.pagination({
            tableOrViewName: pretestViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const protocolsViewName = `tem_testssl_protocols`;
        const protocolsPagination = this.pagination({
            tableOrViewName: protocolsViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const ciphersViewName = `tem_testssl_ciphers`;
        const ciphersPagination = this.pagination({
            tableOrViewName: ciphersViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const serverReferencesViewName = `tem_testssl_server_references`;
        const serverReferencesPagination = this.pagination({
            tableOrViewName: serverReferencesViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const fsViewName = `tem_testssl_fs`;
        const fsPagination = this.pagination({
            tableOrViewName: fsViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const serverDefaultsViewName = `tem_testssl_server_default`;
        const serverDefaultsPagination = this.pagination({
            tableOrViewName: serverDefaultsViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const headerResponseViewName = `tem_testssl_header_response`;
        const headerResponsePagination = this.pagination({
            tableOrViewName: headerResponseViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const vulnerabilitieViewName = `tem_testssl_vulnerabilitie`;
        const vulnerabilitiePagination = this.pagination({
            tableOrViewName: vulnerabilitieViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const browserSimulationViewName = `tem_testssl_browser_simulation`;
        const browserSimulationPagination = this.pagination({
            tableOrViewName: browserSimulationViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        const ratingViewName = `tem_testssl_rating`;
        const ratingPagination = this.pagination({
            tableOrViewName: ratingViewName,
            whereSQL: "WHERE uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id = $session_id",
        });
        return this.SQL`
      ${this.activePageTitle()}
        --- Display breadcrumb
        SELECT 'breadcrumb' AS component;
        SELECT 'Home' AS title,
            ${this.absoluteURL("/")} AS link;
        SELECT 'Threat Exposure Management' AS title,
            ${this.absoluteURL("/tem/index.sql")} AS link;  
        SELECT 'Attack Surface Mapping By Session' AS title,
            ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
        SELECT 'Findings' AS title,
            ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
        SELECT 'TestSSL Report' AS title,
            ${this.absoluteURL("/tem/session/tssl_certificate.sql?session_id=")} || $session_id AS link;
        SELECT host AS title,
            '#' AS link
        FROM ${viewName}
        WHERE ur_ingest_session_id = $session_id;

        --- Dsply Page Title
        SELECT
          'title'   as component,
          'TestSSL Report' as contents;

        SELECT
          'text'              as component,
          'The TestSSL Report provides a comprehensive overview of the SSL/TLS security posture of scanned hosts. It consolidates findings from server configurations, supported protocols, cipher suites, forward secrecy settings, HTTP headers, browser simulations, vulnerabilities, and overall ratings into a structured and easily interpretable format. Each entry includes a unique identifier, severity level, and descriptive details, allowing security teams to quickly identify and prioritize issues. The report helps organizations assess compliance with best practices, track security improvements over time, and make informed decisions to strengthen their SSL/TLS configurations, ensuring robust protection for web applications and client connections.' as contents;
        


        select 
        'table' as component,
        TRUE    as freeze_columns,
        TRUE    as freeze_headers,
        TRUE    as border;  
           select 
                'Tenant' as 'General Info',
                tanent_name as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
            union all
            select 
                'Invocation' as 'General Info',
                invocation as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
            union all
            select 
                'Open SSL' as 'General Info',
                openssl as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
            union all
            select 
                'Version' as 'General Info',
                version as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
            union all
            select 
                'Host' as 'General Info',
                host as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
            union all
            select 
                'ip' as 'General Info',
                ip as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
            union all
            select 
                'port' as 'General Info',
                port as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id
            union all
            select 
                'service' as 'General Info',
                service as 'Value'
                FROM tem_testssl_general WHERE ur_ingest_session_id=$session_id

       select 
            'tab' as component;
        -- Pretests tab (active only if tab=pretests) 
        select 
            'Pretests' as title,
            (coalesce($tab, 'pretests') = 'pretests') as active,
            '?component=tab&tab=pretests&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- Protocols tab (active only if tab=protocols) 
        select 
            'Protocols' as title,
            ($tab = 'protocols') as active,
            '?component=tab&tab=protocols&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

         -- Ciphers tab (active only if tab=ciphers)
        select 
            'Ciphers' as title,
            ($tab = 'ciphers') as active,
            '?component=tab&tab=ciphers&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- Server Preferences tab (active only if tab=server-preferences)
        select 
            'Server Preferences' as title,
            ($tab = 'server-preferences') as active,
            '?component=tab&tab=server-preferences&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- Forward Secrecy (active only if tab=forward-secrecy)
        select 
            'Forward Secrecy' as title,
            ($tab = 'forward-secrecy') as active,
            '?component=tab&tab=forward-secrecy&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- Server Defaults / Certificates (active only if tab=protocols)
        select 
            'Server Defaults / Certificates' as title,
            ($tab = 'server-defaults') as active,
            '?component=tab&tab=server-defaults&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- HTTP Response Headers (active only if tab=http-response-header)
        select 
            'HTTP Response Headers' as title,
            ($tab = 'http-response-header') as active,
            '?component=tab&tab=http-response-header&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- Vulnerabilities (active only if tab=http-response-header)
        select 
            'Vulnerabilities' as title,
            ($tab = 'vulnerabilitie') as active,
            '?component=tab&tab=vulnerabilitie&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- Browser Simulations (active only if tab=browser-simulations)
        select 
            'Browser Simulations' as title,
            ($tab = 'browser-simulations') as active,
            '?component=tab&tab=browser-simulations&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

        -- Rating (active only if tab=rating)
        select 
            'Rating' as title,
            ($tab = 'rating') as active,
            '?component=tab&tab=rating&uniform_resource_id='||$uniform_resource_id||'&session_id='||$session_id as link;

            -- Pretests tab
            ${pretestPagination.init()}
            SELECT
            'title'   as component,
            'Pretests' as contents
            WHERE $tab = 'pretests';
            SELECT
            'text'              as component,
            'Quick preliminary checks performed before the detailed scan. These verify basic connectivity, service availability, and whether the host can be tested reliably.' as contents
            WHERE $tab = 'pretests';
        
            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'pretests';
            select id,severity,finding from ${pretestViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'pretests';
            ${pretestPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='pretests'")};

            -- Protocols tab
            ${protocolsPagination.init()}
            SELECT
                'title'   as component,
                'Protocols' as contents WHERE $tab = 'protocols';
            SELECT
                'text'              as component,
                'Lists the supported SSL/TLS protocol versions (e.g., TLS 1.0, 1.2, 1.3). Helps identify if older, insecure protocols are enabled or only modern secure ones are accepted.' as contents
            WHERE $tab = 'protocols';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'protocols';
            select id,severity,finding from ${protocolsViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'protocols';
            ${protocolsPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='protocols'")};

            -- Ciphers tab
            ${ciphersPagination.init()}
            SELECT
                'title'   as component,
                'Ciphers' as contents WHERE $tab = 'ciphers';
            SELECT
                'text'              as component,
                'Shows the encryption algorithms (ciphers) supported by the server. Weak or outdated ciphers (like CBC-based ones) are flagged, while strong ciphers are marked safe.' as contents
            WHERE $tab = 'ciphers';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'ciphers';
            select id,severity,finding from ${ciphersViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'ciphers';
            ${ciphersPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='ciphers'")};

            -- Server Preferences tab
            ${serverReferencesPagination.init()}
            SELECT
                'title'   as component,
                'Server Preferences' as contents WHERE $tab = 'server-preferences';
            SELECT
                'text'              as component,
                'Describes how the server prioritizes protocols and ciphers. For example, whether the server enforces its own cipher order or allows clients to choose.' as contents
            WHERE $tab = 'server-preferences';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'server-preferences';
            select id,severity,finding from ${serverReferencesViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'server-preferences';
            ${serverReferencesPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='server-preferences'")};

            -- Forward Secrecy (FS) tab
            ${fsPagination.init()}
            SELECT
                'title'   as component,
                'Forward Secrecy (FS)' as contents WHERE $tab = 'forward-secrecy';
            SELECT
                'text'              as component,
                'Checks whether the server supports forward secrecy using key exchange methods (e.g., ECDHE). FS ensures that past communications remain secure even if the server’s private key is compromised later.' as contents
            WHERE $tab = 'forward-secrecy';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'forward-secrecy';
            select id,severity,finding from ${fsViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'forward-secrecy';
            ${fsPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='forward-secrecy'")};

            -- Server Defaults / Certificates tab
            ${serverDefaultsPagination.init()}
            SELECT
                'title'   as component,
                'Server Defaults / Certificates' as contents WHERE $tab = 'server-defaults';
            SELECT
                'text'              as component,
                'Displays SSL/TLS certificate information such as common name, issuer, validity, and other defaults. This helps verify domain ownership, certificate authority, and expiration.' as contents
            WHERE $tab = 'server-defaults';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'server-defaults';
            select id,severity,finding from ${serverDefaultsViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'server-defaults';
            ${serverDefaultsPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='server-defaults'")};

            -- HTTP Response Headers tab
            ${headerResponsePagination.init()}
            SELECT
                'title'   as component,
                'HTTP Response Headers' as contents WHERE $tab = 'http-response-header';
            SELECT
                'text'              as component,
                'Lists security-related HTTP headers (e.g., HSTS, X-Frame-Options, CSP). These help protect against attacks like clickjacking, XSS, or protocol downgrade.' as contents
            WHERE $tab = 'http-response-header';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'http-response-header';
            select header_response_id as "header response id",severity,finding from ${headerResponseViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'http-response-header';
            ${headerResponsePagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='http-response-header'")};

            -- Vulnerabilities tab
            ${vulnerabilitiePagination.init()}
            SELECT
                'title'   as component,
                'Vulnerabilities' as contents WHERE $tab = 'vulnerabilitie';
            SELECT
                'text'              as component,
                'Tests the server against known SSL/TLS vulnerabilities (e.g., Heartbleed, POODLE, LUCKY13). Any positive finding here indicates a serious risk.' as contents
            WHERE $tab = 'vulnerabilitie';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'vulnerabilitie';
            select vulnerability_id as "vulnerability id",severity,finding from ${vulnerabilitieViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'vulnerabilitie';
            ${vulnerabilitiePagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='vulnerabilitie'")};

            -- Browser Simulations tab
            ${browserSimulationPagination.init()}
             SELECT
                'title'   as component,
                'Browser Simulations' as contents WHERE $tab = 'browser-simulations';
            SELECT
                'text'              as component,
                'Simulates how different browsers and versions connect to the server. This helps verify compatibility and whether old browsers are blocked from insecure connections.' as contents
            WHERE $tab = 'browser-simulations';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'browser-simulations';
            select simulation_id as "simulation id",severity,finding from ${browserSimulationViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'browser-simulations';
            ${browserSimulationPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='browser-simulations'")};

           -- Rating Simulations tab
            ${ratingPagination.init()}
             SELECT
                'title'   as component,
                'Rating' as contents WHERE $tab = 'rating';
            SELECT
                'text'              as component,
                'Provides an overall grade (A, B, etc.) summarizing the server’s SSL/TLS configuration strength. This is often based on industry benchmarks like SSL Labs grading.' as contents
            WHERE $tab = 'rating';

            SELECT 'table' AS component,
                TRUE AS sort,
                TRUE AS search,
                'Host' as markdown where $tab = 'rating';
            select rating_id as "rating id",severity,finding from ${ratingViewName} where uniform_resource_id= $uniform_resource_id AND ur_ingest_session_id=$session_id AND $tab = 'rating';
            ${ratingPagination.renderSimpleMarkdown("component", "tab", "uniform_resource_id", "session_id", "$tab='rating'")};
    `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/tenant/openssl.sql"() {
        const viewName = `tem_openssl`;
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
          SELECT 'Threat Exposure Management' AS title,
              ${this.absoluteURL("/tem/index.sql")} AS link;
          SELECT 'Attack Surface Mapping By Tenant' AS title,
              ${this.absoluteURL("/tem/attack_surface_mapping_tenant.sql")} AS link;
          SELECT tanent_name AS title,
              ${this.absoluteURL("/tem/tenant/attack_surface_mapping_inner.sql?tenant_id=")} || $tenant_id AS link
          FROM tem_tenant WHERE tenant_id = $tenant_id;
          SELECT 'Findings' AS title,
              ${this.absoluteURL("/tem/tenant/finding.sql?tenant_id=")} || $tenant_id AS link;
          SELECT 'SSL/TLS Certificate Metadata' AS title,
              '#' AS link;

      --- Page title
      SELECT 'title' AS component,
          'SSL/TLS Certificate Metadata' AS contents;

      --- Page description
      SELECT 'text' AS component,
          'This page displays structured SSL/TLS certificate details extracted from OpenSSL output. 
          Each row represents a certificate discovered within the tenant’s infrastructure, showing subject details, issuer information, and validity periods. 
          These insights help assess certificate ownership, identify expired or weakly issued certificates, and strengthen the tenant’s security posture.' AS contents;

      --- Table setup
      SELECT 'table' AS component,
          TRUE AS sort,
          TRUE AS search;

      ${pagination.init()}
     SELECT
        CASE WHEN common_name IS NULL OR trim(common_name) = '' THEN '-' ELSE common_name END AS "Common Name",
        CASE WHEN subject_organization IS NULL OR trim(subject_organization) = '' THEN '-' ELSE subject_organization END AS "Subject Organization",
        CASE WHEN issuer_common_name IS NULL OR trim(issuer_common_name) = '' THEN '-' ELSE issuer_common_name END AS "Issuer CN",
        CASE WHEN issuer_organization IS NULL OR trim(issuer_organization) = '' THEN '-' ELSE issuer_organization END AS "Issuer Organization",
        CASE WHEN issuer_country IS NULL OR trim(issuer_country) = '' THEN '-' ELSE issuer_country END AS "Issuer Country",

        -- Issued Date
        CASE
            WHEN issued_date IS NULL OR trim(issued_date) = '' THEN '-'
            ELSE printf(
                    '%s %s %s',
                    trim(substr(replace(replace(issued_date, '  ', ' '), '  ', ' '), 1, 3)),
                    trim(substr(replace(replace(issued_date, '  ', ' '), '  ', ' '), 5, 2)),
                    trim(substr(replace(replace(issued_date, '  ', ' '), '  ', ' '), -9, 4))
                )
        END AS "Issued Date",

        -- Expires Date
        CASE
            WHEN expires_date IS NULL OR trim(expires_date) = '' THEN '-'
            ELSE printf(
                    '%s %s %s',
                    trim(substr(replace(replace(expires_date, '  ', ' '), '  ', ' '), 1, 3)),
                    trim(substr(replace(replace(expires_date, '  ', ' '), '  ', ' '), 5, 2)),
                    trim(substr(replace(replace(expires_date, '  ', ' '), '  ', ' '), -9, 4))
                )
        END AS "Expires Date"

    FROM ${viewName}
    WHERE tenant_id = $tenant_id;

      ${pagination.renderSimpleMarkdown("tenant_id")};
  `;
    }

    @spn.shell({ breadcrumbsFromNavStmts: "no" })
    "tem/session/openssl.sql"() {
        const viewName = `tem_openssl`;
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
                SELECT 'Threat Exposure Management' AS title,
                    ${this.absoluteURL("/tem/index.sql")} AS link;  
                SELECT 'Attack Surface Mapping By Session' AS title,
                    ${this.absoluteURL("/tem/attack_surface_mapping_session.sql")} AS link;
                SELECT 'Findings' AS title,
                    ${this.absoluteURL("/tem/session/finding.sql?session_id=")} || $session_id AS link;
                SELECT 'SSL/TLS Certificate Metadata' AS title,
                    '#' AS link;

        --- Page title
        SELECT 'title' AS component,
            'SSL/TLS Certificate Metadata' AS contents;

        --- Page description
        SELECT 'text' AS component,
            'This page displays structured SSL/TLS certificate details extracted from OpenSSL output for a given session. 
            Each row represents a certificate discovered within the session’s infrastructure, showing subject details, issuer information, and validity periods. 
            These insights help assess certificate ownership, identify expired or weakly issued certificates, and strengthen the session’s security posture.' AS contents;

        --- Table setup
        SELECT 'table' AS component,
            TRUE AS sort,
            TRUE AS search;

        ${pagination.init()}
        SELECT
            CASE WHEN tanent_name IS NULL OR trim(tanent_name) = '' THEN '-' ELSE tanent_name END AS "Tenant",
            CASE WHEN common_name IS NULL OR trim(common_name) = '' THEN '-' ELSE common_name END AS "Common Name",
            CASE WHEN subject_organization IS NULL OR trim(subject_organization) = '' THEN '-' ELSE subject_organization END AS "Subject Organization",
            CASE WHEN issuer_common_name IS NULL OR trim(issuer_common_name) = '' THEN '-' ELSE issuer_common_name END AS "Issuer CN",
            CASE WHEN issuer_organization IS NULL OR trim(issuer_organization) = '' THEN '-' ELSE issuer_organization END AS "Issuer Organization",
            CASE WHEN issuer_country IS NULL OR trim(issuer_country) = '' THEN '-' ELSE issuer_country END AS "Issuer Country",

            -- Issued Date
            CASE
                WHEN issued_date IS NULL OR trim(issued_date) = '' THEN '-'
                ELSE printf(
                        '%s %s %s',
                        trim(substr(replace(replace(issued_date, '  ', ' '), '  ', ' '), 1, 3)),
                        trim(substr(replace(replace(issued_date, '  ', ' '), '  ', ' '), 5, 2)),
                        trim(substr(replace(replace(issued_date, '  ', ' '), '  ', ' '), -9, 4))
                    )
            END AS "Issued Date",

            -- Expires Date
            CASE
                WHEN expires_date IS NULL OR trim(expires_date) = '' THEN '-'
                ELSE printf(
                        '%s %s %s',
                        trim(substr(replace(replace(expires_date, '  ', ' '), '  ', ' '), 1, 3)),
                        trim(substr(replace(replace(expires_date, '  ', ' '), '  ', ' '), 5, 2)),
                        trim(substr(replace(replace(expires_date, '  ', ' '), '  ', ' '), -9, 4))
                    )
            END AS "Expires Date"

        FROM ${viewName}
        WHERE ur_ingest_session_id = $session_id;

        ${pagination.renderSimpleMarkdown("session_id")};
        `;
    }


    @spn.shell({
        breadcrumbsFromNavStmts: "no",
        shellStmts: "do-not-include",
        pageTitleFromNavStmts: "no",
    })
    "sqlpage/templates/shell-custom.handlebars"() {
        return this.SQL`<!DOCTYPE html>
          <html lang="{{language}}" style="font-size: {{default font_size 18}}px" {{#if class}} class="{{class}}" {{/if}}>
            <head>
            <meta charset="utf-8" />
    
              <!--Base CSS-->
                <link rel="stylesheet" href="{{static_path 'sqlpage.css'}}">
                  {{#each (to_array css)}}
                  {{#if this}}
    <link rel="stylesheet" href="{{this}}">
      {{/if}}
    {{/each}}
    
    <!--Font Setup-->
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
    
    <!--JavaScript-->
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
    
      <body class="layout-{{#if sidebar}}fluid{{else}}{{default layout 'boxed'}}{{/if}}" {{#if theme}} data-bs-theme="{{theme}}" {{/if}}>
        <div class="page">
          <!--Header-->
    
    
            <!--Page Wrapper-->
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
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "tem/task_detail.sql"() {
    return this.SQL`
    ${this.activePageTitle()}

    --- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home' AS title, ${this.absoluteURL("/")} AS link;
    SELECT 'Tem' AS title, ${this.absoluteURL("/tem/index.sql")} AS link;
    SELECT 
      (SELECT title FROM tem_task_summary WHERE uniform_resource_id = $task_id) AS title,
      '#' AS link;

    --- Card Header with Task Title
    SELECT 'card' AS component,
           (SELECT title
            FROM tem_task_summary
            WHERE uniform_resource_id = $task_id) AS title,
           1 AS columns;

    --- Task Content Section (rendered nicely in Markdown)
    WITH RECURSIVE strip_comments(txt) AS (
    -- initial content (after frontmatter)
    SELECT ltrim(
             substr(
               content,
               instr(substr(content, instr(content, '---') + 3), '---') + instr(content, '---') + 5
             )
           )
    FROM tem_task_summary
    WHERE uniform_resource_id = $task_id

    UNION ALL

    -- remove first <!-- ... --> occurrence
    SELECT 
        substr(txt, 1, instr(txt, '<!--') - 1) || substr(txt, instr(txt, '-->') + 3)
    FROM strip_comments
    WHERE txt LIKE '%<!--%-->%'
    )
    SELECT txt AS description_md
    FROM strip_comments
    WHERE txt NOT LIKE '%<!--%-->%'
    LIMIT 1;
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
