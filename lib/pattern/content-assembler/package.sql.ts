#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
const SQE_TITLE = "Content Assembler";
const SQE_LOGO = "content-assembler.png";
const SQE_FAV_ICON = "content-assembler.ico";
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
function cakNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "cak/index.sql",
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
      -- delete all /cak-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE parent_path=${this.constructHomePath("cak")
      };
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Content Assembler",
    description: `The Content Assembler
    harnesses pre-curated content from influencers, curators,
     and authoritative sources, collecting, de-duplicating, and
     scoring valuable links shared across platforms like email,
      Twitter, and LinkedIn for reuse in B2B and community channels in Surveilr.`,
  })
  "cak/index.sql"() {
    return this.SQL`
    select
        'text'              as component,
        'The Content Assembler provides access to a centralized repository of content across various platforms, such as email and Twitter. The "Periodicals" link navigates to a section where all content subjects, including periodical updates, can be viewed and managed.' as contents;
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = ${this.constructHomePath("cak")}
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, ${this.absoluteURL("/")
      } || COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${this.constructHomePath("cak")
      }
       ORDER BY sibling_order;`;
  }

  @cakNav({
    caption: "Periodicals",
    description:
      `The Source List page provides a streamlined view of all collected content sources. This page displays only the origins of the content, such as sender information for email sources, making it easy to see where each piece of content came from. Use this list to quickly review and identify the various sources contributing to the curated content collection.`,
    siblingOrder: 1,
  })
  "cak/periodicals.sql"() {
    const viewName = `periodicals_from`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
    });
    return this.SQL`
      ${this.activePageTitle()}

      -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
      ${pagination.init()}

       select
        'text'              as component,
        'The Source List page provides a streamlined view of all collected content sources. This page displays only the origins of the content, such as sender information for email sources, making it easy to see where each piece of content came from. Use this list to quickly review and identify the various sources contributing to the curated content collection.' as contents;

      -- Dashboard count
      select
          'card' as component,
          4      as columns;
      select
          'Total Mail Inbox'  as title,
          '## '||dashboard_from_count||' ##' as description_md,
          TRUE                  as active,
          'mail-pin'       as icon
      FROM periodicals_from_count;
      select
          'Filtered periodicals'  as title,
          '## '||dashboard_periodical_filtered_count||' ##' as description_md,
          TRUE                  as active,
          'filter'       as icon,
          'green'           as color
      FROM periodical_filtered_count;
      select
          'Removed Anchors'  as title,
          '## '||dashboard_anchor_removed_count||' ##' as description_md,
          TRUE                  as active,
          'trash-x'       as icon,
          'danger'           as color
      FROM anchor_removed_count;
      select
          'Total Anchors'  as title,
          '## '||dashboard_anchor_total_count||' ##' as description_md,
          TRUE                  as active,
          'link'       as icon,
          'warning'           as color
      FROM anchor_total_count;

      select
          'Error Anchors'  as title,
          '## '||error_count||' ##' as description_md,
          TRUE                  as active,
          'exclamation-circle'       as icon,
          'danger'           as color,
          ${this.absoluteURL("/cak/error_periodicals.sql")} as link
      FROM error_link_count;

      -- Display uniform_resource table with pagination
      SELECT 'table' AS component,
            'subject' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search,
            'from' AS markdown;

       SELECT
          '[' || message_from || ']('|| ${this.absoluteURL("/cak/periodicals_subject.sql?message_from=")
      } || message_from || ')' AS "from",
          subject_count as "subject count",
          periodical_count as "periodical count"
          FROM ${viewName}
          LIMIT $limit
        OFFSET $offset;
        ${pagination.renderSimpleMarkdown()}
      `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/periodicals_subject.sql"() {
    const viewName = `periodicals_subject`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "WHERE message_from=$message_from",
    });
    return this.SQL`
    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Content Assembler' AS title,
        ${this.absoluteURL("/cak/index.sql")} AS link;
      SELECT
        'Periodicals' AS title,
        ${this.absoluteURL("/cak/periodicals.sql")} AS link;
      SELECT $message_from AS title, ${this.absoluteURL("/cak/periodicals_subject.sql?message_from=")
      }|| $message_from  AS link;

      --- Dsply Page Title
      SELECT
          'title'   as component,
          'Periodicals From ' || $message_from as contents;

      --- Dsply Page Description
       SELECT
    'text' AS component,
    'The Source Details page offers an in-depth view of content collected from a specific sender. Here, you''ll find a list of messages from this source, including each message''s subject, sender, recipient, and send date. This organized layout helps you explore all communications from this source in one place, making it easy to review and track relevant content by date and topic.' AS contents;

       -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
      ${pagination.init()}

      -- Display uniform_resource table with pagination
      SELECT 'table' AS component,
          'Column Count' as align_right,
          TRUE as sort,
          TRUE as search,
          'subject' AS markdown,
          'removed links' AS markdown;

      SELECT
        '[' || message_subject || ']('|| ${this.absoluteURL(
        "/cak/periodical_anchor.sql?periodical_uniform_resource_id=",
      )
      }  || periodical_uniform_resource_id || ')' AS "subject",
        '[ View]('|| ${this.absoluteURL(
        "/cak/periodical_removed_anchor.sql?periodical_uniform_resource_id=",
      )
      } || periodical_uniform_resource_id || ') (' ||
          (SELECT
            count(anchor)
          FROM
            removed_anchor_list
          WHERE
            uniform_resource_id = periodical_uniform_resource_id) || ')'
          as "removed links",
        message_from as "from",
        message_to as "to",
         CASE
          WHEN ROUND(julianday('now') - julianday(message_date)) = 0 THEN 'Today'
          WHEN ROUND(julianday('now') - julianday(message_date)) = 1 THEN '1 day ago'
          WHEN ROUND(julianday('now') - julianday(message_date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday('now') - julianday(message_date)) AS INT) || ' days ago'
          WHEN ROUND(julianday('now') - julianday(message_date)) < 30 THEN CAST(ROUND(julianday('now') - julianday(message_date)) AS INT) || ' days ago'
          WHEN ROUND(julianday('now') - julianday(message_date)) < 365 THEN CAST(ROUND((julianday('now') - julianday(message_date)) / 30) AS INT) || ' months ago'
          ELSE CAST(ROUND((julianday('now') - julianday(message_date)) / 365) AS INT) || ' years ago'
      END AS "Relative Time"
      FROM ${viewName}
      WHERE message_from=$message_from::TEXT
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()};
      `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/periodical_anchor.sql"() {
    const viewName = `periodical_anchor`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "WHERE uniform_resource_id=$periodical_uniform_resource_id",
    });
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Content Assembler' AS title,
        ${this.absoluteURL("/cak/index.sql")} AS link;
      SELECT
        'Periodicals' AS title,
        ${this.absoluteURL("/cak/periodicals.sql")} AS link;
      SELECT message_from AS title, ${this.absoluteURL("/cak/periodicals_subject.sql?message_from=")
      }|| message_from  AS link FROM periodicals_subject WHERE periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

      SELECT
        message_subject as title,
         ${this.absoluteURL(
        "/cak/periodical_anchor.sql?periodical_uniform_resource_id=",
      )
      }|| periodical_uniform_resource_id AS link
      FROM
        periodicals_subject
      WHERE
        periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

    --- Dsply Page Title
      SELECT
        'title' as component,
        message_subject as contents
      FROM
        periodicals_subject
      WHERE
        periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;


    select
    'text'              as component,
    'The Newsletter Link Details page provides a comprehensive list of URLs shared within a specific newsletter. For each entry, you’ll find the original URL as it appeared in the newsletter, the link text, and the canonical URL (standardized for consistent reference). This page also includes key metadata for each link, such as title, description, and any additional structured data, allowing for an in-depth look at the content and context of each link. This organized view makes it easy to analyze and manage all linked resources from the newsletter.' as contents;
     -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
      ${pagination.init()}
     SELECT 'table' AS component,
          'Column Count' as align_right,
          TRUE as sort,
          TRUE as search,
          'canonical link' AS markdown,
          'meta data' AS markdown,
          'original link url' AS markdown;
      SELECT
        '[' || url_text || ']('|| orginal_url ||')'   AS "original link url",
        canonical_link as 'canonical link',
        '[ Meta Data ]('|| ${this.absoluteURL("/cak/periodicals_meta.sql?url=")
      } || orginal_url || ')' AS "meta data"
      FROM
        ${viewName}
      WHERE
        uniform_resource_id = $periodical_uniform_resource_id::TEXT
       LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown("periodical_uniform_resource_id")};
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/periodicals_meta.sql"() {
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Content Assembler' AS title,
        ${this.absoluteURL("/cak/index.sql")} AS link;
      SELECT
        'Periodicals' AS title,
        ${this.absoluteURL("/cak/periodicals.sql")} AS link;
      SELECT
            ps.message_from AS title,
            ${this.absoluteURL("/cak/periodicals_subject.sql?message_from=")
      }|| ps.message_from AS link
            FROM
              periodicals_subject ps
            INNER JOIN periodical_anchor pa ON pa.uniform_resource_id = ps.periodical_uniform_resource_id
            WHERE
              pa.orginal_url = $url::TEXT;

      SELECT
        ps.message_subject as title,
        ${this.absoluteURL(
        "/cak/periodical_anchor.sql?periodical_uniform_resource_id=",
      )
      } || ps.periodical_uniform_resource_id AS link
      FROM
        periodicals_subject ps
      INNER JOIN periodical_anchor pa ON pa.uniform_resource_id = ps.periodical_uniform_resource_id
      WHERE
        pa.orginal_url = $url::TEXT;

      SELECT
        'Meta Data' AS title,
        ${this.absoluteURL("/cak/periodicals_meta.sql?url=")}|| $url AS link;

    --- Dsply Page Title
      SELECT
          'title'   as component,
          'Meta Data ('|| ps.message_subject || ')'  as contents
          FROM periodicals_subject ps
          INNER JOIN periodical_anchor pa ON pa.uniform_resource_id = ps.periodical_uniform_resource_id
          WHERE pa.orginal_url = $url::TEXT;

    select
    'text'              as component,
    'The Link Metadata Viewer page offers a detailed look at the metadata and Open Graph properties of each newsletter link. For every link, this page displays essential metadata fields like title, description, and keywords, as well as Open Graph data such as images, type, and URL, providing a rich context for the content. This structured view allows you to easily understand the attributes and presentation of each link, making it an invaluable tool for analyzing and curating high-quality, shareable content from newsletters.' as contents;

     SELECT 'table' AS component,
          'Column Count' as align_right,
          TRUE as sort,
          TRUE as search;
      SELECT
        property_name as property,
        content
      FROM
        ur_transform_html_email_anchor_meta_cached
      WHERE
        anchor = $url::TEXT AND property_name IS NOT NULL
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/periodical_removed_anchor.sql"() {
    const viewName = `removed_anchor_list`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "WHERE uniform_resource_id=$periodical_uniform_resource_id",
    });
    return this.SQL`

    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}   AS link;
      SELECT
        'Content Assembler' AS title,
        ${this.absoluteURL("/cak/index.sql")} AS link;
      SELECT
        'Periodicals' AS title,
        ${this.absoluteURL("/cak/periodicals.sql")} AS link;
      SELECT message_from AS title, ${this.absoluteURL("/cak/periodicals_subject.sql?message_from=")
      }|| message_from  AS link FROM periodicals_subject WHERE periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

      SELECT
        message_subject as title,
        ${this.absoluteURL(
        "/cak/periodical_removed_anchor.sql?periodical_uniform_resource_id=",
      )
      }|| periodical_uniform_resource_id AS link
      FROM
        periodicals_subject
      WHERE
        periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;

    --- Dsply Page Title
      SELECT
        'title' as component,
        message_subject as contents
      FROM
        periodicals_subject
      WHERE
        periodical_uniform_resource_id = $periodical_uniform_resource_id::TEXT;


    select
    'text'              as component,
    'This feature removes links from newsletters that are related to subscription management. It checks for links containing keywords such as unsubscribe, opt-out, preferences, remove, manage, subscription, subscribe, email-settings, list-unsubscribe, mailto, or #main. These links allow recipients to modify or manage their email preferences and subscriptions.' as contents;

    ${pagination.init()}
    SELECT 'table' AS component,
          'Column Count' as align_right,
          TRUE as sort,
          TRUE as search;
      SELECT
        anchor  AS "original link url",
        url_text as 'url text'
      FROM
        ${viewName}
      WHERE
        uniform_resource_id = $periodical_uniform_resource_id::TEXT
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown("periodical_uniform_resource_id")};
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/error_periodicals.sql"() {
    const viewName = `error_link_list`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "",
    });
    return this.SQL`
    --- Display breadcrumb
     SELECT
        'breadcrumb' AS component;
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")}    AS link;
      SELECT
        'Content Assembler' AS title,
        ${this.absoluteURL("/cak/index.sql")} AS link;
      SELECT
        'Error Periodicals' AS title,
        ${this.absoluteURL("/cak/error_periodicals.sql")} AS link;

      --- Dsply Page Title
      SELECT
          'title'   as component,
          'Error Periodicals' || $message_from as contents;

       -- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)


      -- Display uniform_resource table with pagination
      SELECT 'table' AS component,
          'Column Count' as align_right,
          TRUE as sort,
          TRUE as search,
          'error links' AS markdown;
      ${pagination.init()}
      SELECT
      '['|| url_text ||']('|| url ||')'   AS "error links",
        response_status as "response",
        response_status_code as "code",
        message as "Error Message",
        message_from as "from",
        message_to as "to",
        message_subject as subject
      FROM ${viewName}
      LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()};
      `;
  }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statefulcakSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
      async statelesscakSQL() {
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
