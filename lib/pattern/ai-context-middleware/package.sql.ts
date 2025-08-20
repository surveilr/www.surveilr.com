#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
 
const AI_CONTEXT_MIDDLEWARE_TITLE = "AI Context Middleware Explorer";
const AI_CONTEXT_MIDDLEWARE_LOGO = "ai-context-middleware.png";
const AI_CONTEXT_MIDDLEWARE_ICON = "ai-context-middleware-fav.ico";

// custom decorator that makes navigation for this notebook type-safe
function aiCtxNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "ai-context-middleware/index.sql",
  });
}

export class AIContextSqlPages extends spn.TypicalSqlPageNotebook {
  // Define navigation for AI context engineering
  navigationDML() {
    return this.SQL`
      DELETE FROM sqlpage_aide_navigation WHERE parent_path=${this.constructHomePath("ai-context-engineering")};
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  // Define an example home page for AI Context Engineering
  @spn.navigationPrimeTopLevel({
    caption: "AI Context Engineering Overview",
    description: "Explore and query AI-generated and RSSD ingested context data.",
  })
  "ai-context-engineering/index.sql"() {
    return this.SQL`
    select
    'card'             as component,
    3                 as columns;
 
    select
    '## Total Counts of Prompt Module' as description_md,
    'white' as background_color,
    '## ' || count(DISTINCT uri) as description_md,
    '12' as width,
    'pink' as color,
    'timeline-event' as icon,
    'background-color: #FFFFFF' as style
    FROM uniform_resource;
 
    select
    '## Total counts of Merge Group' as description_md,
    'white' as background_color,
    '## ' || count(DISTINCT merge_group) as description_md,
    '12' as width,
    'pink' as color,
    'timeline-event' as icon,
    'background-color: #FFFFFF' as style,
    ${this.absoluteURL("/ai-context-engineering/merge-group.sql")} as link
      FROM ai_ctxe_prompt;
   
    select
    '## Ingest Health' as description_md,
    'white' as background_color,
   
    '12' as width,
    'pink' as color,
    'timeline-event' as icon,
    'background-color: #FFFFFF' as style,
    ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
    `;
  }
 
// Displays merge groups available.
 @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/merge-group.sql"() {
    return this.SQL`
    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'AI Context Engineering Overview' as title,
      ${this.absoluteURL("/ai-context-engineering/index.sql")} as link;
    select
    'Merge Groups' as title;
 
    select
    'table' as component,
    TRUE AS sort,
    TRUE AS search;
    SELECT DISTINCT merge_group from ai_ctxe_prompt WHERE merge_group IS NOT NULL; `;
 }
 
  // Displays ingest health of the AI Context Engineering
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/ingest-health.sql"() {
    return this.SQL`
     select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'AI Context Engineering Overview' as title,
      ${this.absoluteURL("/ai-context-engineering/index.sql")} as link;
    select
    'Ingest Health' as title;
 
    select
    'table' as component,
    TRUE AS sort,
    TRUE AS search;
    select
    total_files_seen   as "Total files seen",
    files_with_content as "file with content",
    files_with_frontmatter as "files with frontmatter" ,
    oldest_modified_at as "Oldest modified at",
    youngest_modified_at as "Youngest modified at"
    FROM uniform_resource_summary;
  `;
 }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  const SQL = await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
 
      async orchestrateStatefulSQL() {
        // read the file from either local or remote (depending on location of this file)
        // optional, for better performance:
        // return await TypicalSqlPageNotebook.fetchText(
        //   import.meta.resolve("./stateful.sql"),
        // );
      }
    }(),
    new sh.ShellSqlPages(AI_CONTEXT_MIDDLEWARE_TITLE),
    new ur.UniformResourceSqlPages(),
    new c.ConsoleSqlPages(),
    new orch.OrchestrationSqlPages(),
    new AIContextSqlPages(),
  );
  console.log(SQL.join("\n"));
}