#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

// custom decorator that makes navigation for this notebook type-safe
function iatNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "/opsfolio",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class iatSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /ip-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like '/opsfolio/info/assurance%';
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Opsfolio",
    description: "Opsfolio",
  })
  "opsfolio/index.sql"() {
    return this.SQL`
    select
     'card'             as component,
     3                 as columns;
      SELECT caption as title, COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = '/opsfolio' AND sibling_order = 2
       ORDER BY sibling_order;`;
  }
  @iatNav({
    caption: "Information Assurance",
    description:
      `A threat model is a structured framework used to identify, assess, and prioritize potential security threats to a system, application, or network to mitigate risks effectively.`,
    siblingOrder: 2,
  })
  "opsfolio/info/assurance/threat_model.sql"() {
    return this.SQL`
    SELECT
      'card' AS component,
      4 AS columns
     SELECT
      'Threat Model Analysis Report' AS title,
      'arrow-big-right' AS icon,
      '/opsfolio/info/assurance/threat_model/threat_model_analysis_report.sql' AS link
      SELECT
      'Web Application' AS title,
      'arrow-big-right' AS icon,
      '/opsfolio/info/assurance/threat_model/web_application.sql' AS link
      SELECT
      'Managed Application' AS title,
      'arrow-big-right' AS icon,
      '/opsfolio/info/assurance/threat_model/managed_application.sql' AS link
      SELECT
      'SQL Database' AS title,
      'arrow-big-right' AS icon,
      '/opsfolio/info/assurance/threat_model/sql_database.sql' AS link
      SELECT
      'Boundaries' AS title,
      'arrow-big-right' AS icon,
      '/opsfolio/info/assurance/threat_model/boundaries.sql' AS link
  `;
  }

  @iatNav({
    caption: "Threat Model Analysis Report",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/assurance/threat_model/threat_model_analysis_report.sql"() {
    const viewName = `threat_model`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
    ${this.activePageTitle()}
     ${pagination.init()}
    SELECT 'table' AS component,
    'Title' as markdown
      SELECT
    '[' || title || '](/opsfolio/info/assurance/threat_model/threat_model_analysis_report/detail.sql?id=' || id || ')' AS "Title",
      category,
      interaction,
      priority,
      "state"
    FROM threat_model
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()}
  `;
  }

  @iatNav({
    caption: "Web Application",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/assurance/threat_model/web_application.sql"() {
    const viewName = `web_application`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
     ${pagination.init()}
    ${this.activePageTitle()}
    SELECT 'list' as component
    SELECT
     Title as title
    FROM web_application
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()}
  `;
  }

  @iatNav({
    caption: "Managed Application",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/assurance/threat_model/managed_application.sql"() {
    const viewName = `managed_application`;
    const pagination = this.pagination({ tableOrViewName: viewName });

    return this.SQL`
    ${this.activePageTitle()}
    ${pagination.init()}
    SELECT 'list' as component
    SELECT
     Title as title
    FROM managed_application
       LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()}
  `;
  }

  @iatNav({
    caption: "SQL Database",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/assurance/threat_model/sql_database.sql"() {
    const viewName = `sql_database`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
    ${pagination.init()}
    ${this.activePageTitle()}
    SELECT 'list' AS component
    SELECT
     Title as title
    FROM sql_database
     LIMIT $limit
      OFFSET $offset;

      ${pagination.renderSimpleMarkdown()}
  `;
  }

  @iatNav({
    caption: "Boundaries",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/assurance/threat_model/boundaries.sql"() {
    const viewName = `boundaries`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
     ${pagination.init()}
    ${this.activePageTitle()}
    SELECT 'list' AS component
    SELECT
     boundary as title
    FROM boundaries
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()}
  `;
  }

  @iatNav({
    caption: "Threat Model Report Analysis",
    description: ``,
    siblingOrder: 4,
  })
  "opsfolio/info/assurance/threat_model/threat_model_analysis_report/detail.sql"() {
    return this.SQL`
    ${this.activePageTitle()}

    -- Component definition

    SELECT
        'card' AS component,
        2 AS columns;

    -- Title section
    SELECT
        'Title' AS title,
        title AS description
    FROM
        threat_model
    WHERE
        id = $id::TEXT;

    -- Category section
    SELECT
        'Category' AS title,
        title AS description
    FROM
        threat_model
    WHERE
        id = $id::TEXT;

    -- Short description section
    SELECT
        'card' AS component,
        1 AS columns;
    SELECT
        'Short Description' AS title,
        short_description AS description
    FROM
        threat_model
    WHERE
        id = $id::TEXT;

    -- Full description section
    SELECT
        'Description' AS title,
        description AS description
    FROM
        threat_model
    WHERE
        id = $id::TEXT;

    -- Priority and State sections
    SELECT
        'card' AS component,
        2 AS columns;

    SELECT
        'Priority' AS title,
        priority AS description
    FROM
        threat_model
    WHERE
        id = $id::TEXT;

    SELECT
        'State' AS title,
        state AS description
    FROM
        threat_model
    WHERE
        id = $id::TEXT;
  `;
  }
}

export async function infoAssuranceSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessDmsSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new sh.ShellSqlPages(),
    new ur.UniformResourceSqlPages(),
    new c.ConsoleSqlPages(),
    new orch.OrchestrationSqlPages(),
    new iatSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await infoAssuranceSQL()).join("\n"));
}
