#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-net
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

const SQE_TITLE = "Site Quality Explorer";
const SQE_LOGO = "site-quality-icon.png";
const SQE_FAV_ICON = "site-quality-favicon.ico";

// custom decorator that makes navigation for this notebook type-safe
function sqNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "sq/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class SiteQualitySqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /ip-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like '/ce%';
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Site Quality",
    description:
      `The Site Quality Explorer (SQE) is a surveilr pattern designed for conducting detailed and ongoing audits of website content quality. It helps analyze how web pages perform across several key SEO factors, providing actionable insights for improving search engine rankings. SQE integrates with surveilr, leveraging its robust ingestion framework to capture and store web content across multiple sources. It uses SQLite and Full Text Search(FTS) to perform efficient queries and generate important SEO metrics`,
  })
  "sq/index.sql"() {
    return this.SQL`
    SELECT
    'card' AS component,
    'Website Resources' AS title,  -- Section title for the card layout
    3 AS columns;  -- Number of columns, adjust based on desired layout

    -- Dynamically create a card for each entry in uniform_resource_website
    SELECT
      hostname AS title,
      ${
      this.absoluteURL("/sq/missing-meta-information.sql?hostname=")
    } || hostname AS link,
      'world' AS icon,
      'blue' AS color
    FROM
      uniform_resource_website
    WHERE
      hostname NOT LIKE '%www.%';`;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "sq/missing-meta-information.sql"() {
    return this.SQL`
    SELECT
      'breadcrumb' AS component;
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} as link;
    SELECT
      'Website Resources' AS title,
      ${this.absoluteURL("/sq")} as link;

    SELECT
    'title' AS component,
    'Social Media and SEO Metadata Analysis for: '||$hostname::TEXT ||'' as contents,
    3 AS level;

    SELECT
    'title' AS component,
    ''||name||': '||description||'' as contents,
    5 AS level
    FROM site_quality_control;

    SELECT
      'card' AS component,
      '' AS title,
      2 AS columns;

    SELECT
      'Open Graph Missing Properties Overview' AS title,
      GROUP_CONCAT(
        '**' || property_name || ' missing URLs:** ' ||
        ' [ ' || missing_count || ' ](' || ${
      this.absoluteURL("/sq/missing-meta-information/details.sql?hostname=")
    } || $hostname || '&property=' || property_name ||') ' || '  \n\n',
        ''
      ) AS description_md,
      'tag' AS icon,
      'green' AS color
    FROM (
      SELECT
        property_name,
        COUNT(*) AS missing_count
      FROM uniform_resource_uri_missing_open_graph
      WHERE uri LIKE '%' || $hostname::TEXT || '%'
      GROUP BY property_name
    );

    SELECT
      'HTML Meta Missing Properties Overview' AS title,
      GROUP_CONCAT(
        '**' || property_name || ' missing URLs:** ' ||
        ' [ ' || missing_count || ' ](' || ${
      this.absoluteURL("/sq/missing-meta-information/details.sql?hostname=")
    } || $hostname || '&property=' || property_name ||') ' || '  \n\n',
        ''
      ) AS description_md,
      'tag' AS icon,
      'orange' AS color
    FROM (
      SELECT
        property_name,
        COUNT(*) AS missing_count
      FROM uniform_resource_uri_missing_html_meta_data
      WHERE uri LIKE '%' || $hostname::TEXT || '%'
      GROUP BY property_name
    );

    SELECT
      'Twitter Card Missing Properties Overview' AS title,
      GROUP_CONCAT(
        '**' || property_name || ' missing URLs:** ' ||
        ' [ ' || missing_count || ' ](' || ${
      this.absoluteURL("/sq/missing-meta-information/details.sql?hostname=")
    } || $hostname || '&property=' || property_name ||') ' || '  \n\n',
        ''
      ) AS description_md,
      'tag' AS icon,
      'blue' AS color
    FROM (
      SELECT
        property_name,
        COUNT(*) AS missing_count
      FROM uniform_resource_uri_missing_twitter_card_cached
      WHERE uri LIKE '%' || $hostname::TEXT || '%'
      GROUP BY property_name
    );
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "sq/missing-meta-information/details.sql"() {
    const viewName = `uniform_resource_uri_missing_meta_info`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL:
        "WHERE property_name=$property::TEXT AND uri LIKE '%'||$hostname::TEXT||'%'",
    });
    return this.SQL`
    SELECT
      'breadcrumb' AS component;
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} as link;
    SELECT
      'Website Resources' AS title,
       ${this.absoluteURL("/sq")} as link;
    SELECT
      'Social Media and SEO Metadata Analysis' AS title,
      ${
      this.absoluteURL("/sq/missing-meta-information.sql?hostname=")
    }||$hostname::TEXT||'' AS link;
    ${pagination.init()}

    SELECT
      'text' AS component,
      '**Property Name:** ' || property_name || '  \n' ||
      '**Description:** ' || description || '  \n' ||
      '**Requirements:** ' || requirement || '  \n' ||
      '**Impact of Missing Property:** ' || impact || '  \n' ||
      '**Suggested Solution:** ' || suggested_solution || '  \n'
      AS contents_md
    FROM
      site_quality_policy
    WHERE
      property_name = $property::TEXT;

    SELECT
    'title' AS component,
    'URLs Missing the Property "'||$property::TEXT||'" for: '||$hostname::TEXT||'' as contents,
    3 AS level;

    SELECT
    'table' AS component,
    TRUE AS sort,
    TRUE AS search;
    SELECT
      ROW_NUMBER() OVER () AS "Sl.No",
      uri   AS "Website URL"
      FROM uniform_resource_uri_missing_meta_info WHERE property_name=$property::TEXT AND uri LIKE '%'||$hostname::TEXT||'%'
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()};
    `;
  }

  @sqNav({
    caption: "Mising Meta Data",
    description: "Mising Meta Data",
    siblingOrder: 4,
  })
  "sq/missing-meta-data.sql"() {
    return this.SQL`
    -- Define tabs
    SELECT
      'tab' AS component,
      TRUE AS center;

    -- Tab 1: Open Graph Missing URLs
    SELECT
      'Open Graph Missing URLs' AS title,
      ${
      this.absoluteURL("/sq/missing-meta-data.sql?hostname=")
    } || $hostname::TEXT || '&tab=open_graph' AS link,
      $tab = 'open_graph' AS active;

    -- Tab 2: Meta Tags Missing URLs
    SELECT
      'Meta Tags Missing URLs' AS title,
      ${
      this.absoluteURL("/sq/missing-meta-data.sql?hostname=")
    } || $hostname::TEXT || '&tab=html_meta_data' AS link,
      $tab = 'html_meta_data' AS active;

    -- Define component type based on active tab
    SELECT
      CASE
        WHEN $tab = 'open_graph' THEN 'table'
        WHEN $tab = 'html_meta_data' THEN 'table'
      END AS component,TRUE AS sort,TRUE AS search,'URL' AS align_left,'Property Name' AS align_left;

    -- Conditional content based on active tab
    -- Tab-specific content for "open_graph"
    SELECT
      property_name AS "Property Name",uri AS "URL"
    FROM uniform_resource_uri_missing_open_graph
    WHERE $tab = 'open_graph'
    AND uri LIKE '%' || $hostname::TEXT || '%';

    -- Tab-specific content for "html_meta_data"
    SELECT
      uri AS "URL", property_name AS "Property Name"
    FROM uniform_resource_uri_missing_html_meta_data
    WHERE $tab = 'html_meta_data'
    AND uri LIKE '%' || $hostname::TEXT || '%';
    `;
  }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT

export async function controlSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessControlSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }

      async orchestrateStatefulControlSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
    }(),
    new sh.ShellSqlPages(SQE_TITLE, SQE_LOGO, SQE_FAV_ICON),
    new ur.UniformResourceSqlPages(),
    new c.ConsoleSqlPages(),
    new orch.OrchestrationSqlPages(),
    new SiteQualitySqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await controlSQL()).join("\n"));
}
