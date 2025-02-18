#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
const SQE_TITLE = "LinkedIn explorer";
const SQE_LOGO = "linkedin-explorer-icon.png";
const SQE_FAV_ICON = "linkedin-explorer-favicon.ico";
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
function lieNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "lie/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class ContentAssemblerSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /lie-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE parent_path=${
      this.constructHomePath("lie")
    };
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "LinkedIn Explorer",
    description:
      `LinkedIn Explorer, will enable LinkedIn data integration into Surveilr. It includes manual data export, automated CSV ingestion, SQL Views for querying, and a Web UI for data analysis.`,
  })
  "lie/index.sql"() {
    return this.SQL`
    select
        'text'              as component,
        'LinkedIn Explorer, will enable LinkedIn data integration into Surveilr. It includes manual data export, automated CSV ingestion, SQL Views for querying, and a Web UI for data analysis.' as contents;
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = ${this.constructHomePath("lie")}
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, ${
      this.absoluteURL("/")
    } || COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${
      this.constructHomePath("lie")
    }
       ORDER BY sibling_order;`;
  }

  @lieNav({
    caption: "Profile",
    description:
      `The Source List page provides a streamlined view of all collected content sources. This page displays only the origins of the content, such as sender information for email sources, making it easy to see where each piece of content came from. Use this list to quickly review and identify the various sources contributing to the curated content collection.`,
    siblingOrder: 1,
  })
  "lie/profile.sql"() {
    return this.SQL`
        ${this.activePageTitle()}
        select
          'text'              as component,
          'The Source List page provides a streamlined view of all collected content sources. This page displays only the origins of the content, such as sender information for email sources, making it easy to see where each piece of content came from. Use this list to quickly review and identify the various sources contributing to the curated content collection.' as contents;

        select 
          'datagrid' as component;
        select 
            'Name' as title,
            full_name as description
         FROM linkedin_profile;
        select
            'Address' as title,
            address as description
        FROM linkedin_profile;
        select
            'Birth Date' as title,
            birth_date as description
        FROM linkedin_profile;
        
        -- Dashboard count
        select
          'card' as component,
          3      as columns;
        SELECT
            'Connection'  as title,
            '## '||connection_count||' ##' as description_md,
            TRUE                  as active,
            'home-link'       as icon,
            ${this.absoluteURL("/lie/connection.sql")} as link
        FROM linkedin_connection_count;

        SELECT
            'Skills'  as title,
            '## '||total_skills||' ##' as description_md,
            TRUE                  as active,
            'bulb'       as icon,
            ${this.absoluteURL("/lie/skills.sql")} as link
        FROM linkedin_top_skills_count;

        SELECT
            'Employment Timeline'  as title,
            '## '||time_line_count||' ##' as description_md,
            TRUE                  as active,
            'baseline-density-small'       as icon,
            ${this.absoluteURL("/lie/time_line.sql")} as link
        FROM linkedin_employment_timeline_count;

        select 
          'card' as component,
          2      as columns;
        select 
          'Learnings' as description_md,
          TRUE                  as active,
          'book'       as icon,
          ${this.absoluteURL("/lie/learning.sql")} as link;
        select
          'Company Follows' as description_md,
          TRUE                  as active,
          'building'       as icon,
          ${this.absoluteURL("/lie/company_follows.sql")} as link;

        select 
        'title'   as component,
        'Education' as contents;

        SELECT 'table' AS component;
        SELECT
         *
        FROM linkedin_profile_education;
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "lie/connection.sql"() {
    const viewName = `linkedin_connection_overview`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
    });
    return this.SQL`
      --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'LinkedIn Explorer' AS title,
        ${this.absoluteURL("/lie/index.sql")} AS link;
      SELECT
        'Profile' AS title,
        ${this.absoluteURL("/lie/profile.sql")} AS link;
      SELECT
        'Connection' AS title,
        ${this.absoluteURL("/lie/connection.sql")} AS link;
   -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
        ${pagination.init()}
  
         select
          'text'              as component,
          'The Source List page provides a streamlined view of all collected content sources. This page displays only the origins of the content, such as sender information for email sources, making it easy to see where each piece of content came from. Use this list to quickly review and identify the various sources contributing to the curated content collection.' as contents;

        -- Display uniform_resource table with pagination
        SELECT 'table' AS component,
              'subject' AS markdown,
              'Column Count' as align_right,
              TRUE as sort,
              TRUE as search;
  
         SELECT
            first_name,
            last_name,
            email
            FROM ${viewName}
            LIMIT $limit
          OFFSET $offset;
          ${pagination.renderSimpleMarkdown()}
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "lie/skills.sql"() {
    const viewName = `linkedin_top_skills`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
    });
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'LinkedIn Explorer' AS title,
        ${this.absoluteURL("/lie/index.sql")} AS link;
      SELECT
        'Profile' AS title,
        ${this.absoluteURL("/lie/profile.sql")} AS link;
      SELECT
        'Skills' AS title,
        ${this.absoluteURL("/lie/skills.sql")} AS link;
      
    --- Dsply Page Title
      SELECT
          'title'   as component,
          'Skills'  as contents;

     -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
        ${pagination.init()}
    select
    'text'              as component,
    'Ingest LinkedIn skills from CSV files into Resource Surveillance for seamless organization, querying, and analysis of skill data.' as contents;

     -- Display uniform_resource table with pagination
        SELECT 'table' AS component,
              'subject' AS markdown,
              'Column Count' as align_right,
              TRUE as sort,
              TRUE as search,
              'from' AS markdown;

         SELECT
            skills 
            FROM ${viewName}
            LIMIT $limit
          OFFSET $offset;
          ${pagination.renderSimpleMarkdown()}
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "lie/time_line.sql"() {
    const viewName = `linkedin_employment_timeline`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
    });
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Linkedin Explorer' AS title,
        ${this.absoluteURL("/lie/index.sql")} AS link;
      SELECT
        'Profile' AS title,
        ${this.absoluteURL("/lie/profile.sql")} AS link;
      SELECT
        'LinkedIn Employment Timeline' AS title,
        ${this.absoluteURL("/lie/time_line.sql")} AS link;
      
    --- Dsply Page Title
      SELECT
          'title'   as component,
          'LinkedIn Employment Timeline'  as contents;

     -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
        ${pagination.init()}
    select
    'text'              as component,
    'Ingest and organize employment data from LinkedIn positions to visualize career timelines and analyze professional history seamlessly.' as contents;

     -- Display uniform_resource table with pagination
        SELECT 'table' AS component,
              'subject' AS markdown,
              'Column Count' as align_right,
              TRUE as sort,
              TRUE as search,
              'from' AS markdown;

         SELECT
            * 
            FROM ${viewName}
            LIMIT $limit
          OFFSET $offset;
          ${pagination.renderSimpleMarkdown()}
        `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "lie/learning.sql"() {
    const viewName = `linkedin_learning`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
    });
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Linkedin Explorer' AS title,
        ${this.absoluteURL("/lie/index.sql")} AS link;
      SELECT
        'Profile' AS title,
        ${this.absoluteURL("/lie/profile.sql")} AS link;
      SELECT
        'Learning' AS title,
        ${this.absoluteURL("/lie/learning.sql")} AS link;
      
    --- Dsply Page Title
      SELECT
          'title'   as component,
          'Learning'  as contents;

     -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
        ${pagination.init()}
    select
    'text'              as component,
    'Enhance your professional profile by seamlessly listing your learnings and courses directly from LinkedIn.' as contents;

     -- Display uniform_resource table with pagination
        SELECT 'table' AS component,
              'subject' AS markdown,
              'Column Count' as align_right,
              TRUE as sort,
              TRUE as search,
              'from' AS markdown;

         SELECT
            * 
            FROM ${viewName}
            LIMIT $limit
          OFFSET $offset;
          ${pagination.renderSimpleMarkdown()}
        `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "lie/company_follows.sql"() {
    const viewName = `linkedin_company_follows`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
    });
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Linkedin Explorer' AS title,
        ${this.absoluteURL("/lie/index.sql")} AS link;
      SELECT
        'Profile' AS title,
        ${this.absoluteURL("/lie/profile.sql")} AS link;
      SELECT
        'Company Follows' AS title,
        ${this.absoluteURL("/lie/company_follows.sql")} AS link;
      
    --- Dsply Page Title
      SELECT
          'title'   as component,
          'Company Follows'  as contents;

     -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
        ${pagination.init()}
   SELECT
    'text' AS component,
    'This feature allows users to view a curated list of companies they follow on LinkedIn. 
    It provides insights into the user''s professional interests and industry preferences, 
    showcasing the organizations they engage with and stay updated on. 
    With a clear and interactive interface, this feature enhances the user''s profile by 
    highlighting their network and areas of interest.' AS contents;


     -- Display uniform_resource table with pagination
        SELECT 'table' AS component,
              'subject' AS markdown,
              'Column Count' as align_right,
              TRUE as sort,
              TRUE as search,
              'from' AS markdown;

         SELECT
            * 
            FROM ${viewName}
            LIMIT $limit
          OFFSET $offset;
          ${pagination.renderSimpleMarkdown()}
        `;
  }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelesslieSQL() {
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
    new ContentAssemblerSqlPages(),
  );
}

// // this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
