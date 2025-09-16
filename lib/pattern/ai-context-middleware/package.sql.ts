#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
import * as sqlite_jsonschema from "https://deno.land/x/sqlite_jsonschema/mod.ts";
 
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
      'card' as component,
      2 as columns;
      select
      '## Opsfolio' as description_md,
      'white' as background_color,
     
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/opsfolio.sql")} as link
      ;

      select
      '## Compliance Explorer' as description_md,
      'white' as background_color,
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/compliance.sql")} as link
    


    `;
  }
  //display all cards in suite opsfolio
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/opsfolio.sql"() {
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
      'Opsfolio' as title,
      '#' as link;
     
     

     
     select
      'card' as component,
      4 as columns;
     
      select
      '## Total Counts of Prompt Module' as description_md,
      'white' as background_color,
      '## ' || count(DISTINCT uri) as description_md,
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/prompts.sql")} as link
      FROM ai_ctxe_uniform_resource_prompts WHERE uri NOT LIKE '%/.build/anythingllm/%'
  AND uri NOT LIKE '%/regime/hipaa/%'
  AND uri NOT LIKE '%/regime/soc2/%'
  AND uri NOT LIKE '%/regime/nist/%';
     
      select
      '## Total counts of Merge Group' as description_md,
      'white' as background_color,
      '## ' || count(DISTINCT merge_group) as description_md,
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/merge-group.sql")} as link
      FROM ai_ctxe_uniform_resource_prompts;
     
      select
      '## Ingest Health' as description_md,
      'white' as background_color,
      '12' as width,
      'green' as color,
      'file-plus' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select
      '## Risk/QA Panel' as description_md,
      'white' as background_color,
      '12' as width,
      'red' as color,
      'alert-circle' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/risk.sql")} as link;
 
      select
      'card' as component,
      4 as columns;
     
      select
      '## Total Count of Prompts fed into AnythingLLM' as description_md,
      'white' as background_color,
      '## ' || count(DISTINCT uri) as description_md,
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/prompts-anythingllm.sql")} as link
      FROM uniform_resource_build_anythingllm;
    `;
  }

  //complaince explorer
  
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/compliance.sql"() {
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
      'card' as component,
      3 as columns;

      select
      '## Total Counts of HIPAA Prompt Modules' as description_md,
      'white' as background_color,
      '## ' || count(DISTINCT uniform_resource_id) as description_md,
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/prompts-complaince-hipaa.sql")} as link
      FROM ai_ctxe_view_uniform_resource_complaince where regime='HIPAA';

      select
      '## Total Counts of SOC2 Prompt Modules' as description_md,
      'white' as background_color,
      '## ' || count(DISTINCT uniform_resource_id) as description_md,
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/prompts-complaince-soc.sql")} as link
      FROM ai_ctxe_view_uniform_resource_complaince where regime='SOC2';

     
      
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
       SELECT 'title'AS component, 
     'Merge group' as contents;
      SELECT 'text' as component,
'This page displays all defined merge groups for AI context engineering prompts. Each group represents a collection of related prompts that can be explored further by clicking on the group name.' as contents;

     
      SELECT
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'merge_group' as markdown;
     
      SELECT
      '['||merge_group||']('||${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")}||'?uniform_resource_id='||uniform_resource_id||')' as merge_group,
      title as 'title',
      uri as 'uri'
     
      FROM ai_ctxe_uniform_resource_prompts
      WHERE merge_group IS NOT NULL
     AND uri NOT LIKE '%/.build/anythingllm/%'
     ORDER BY merge_group;
    `;
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
     
      select 'title' AS component, 'Ingest Health Overview' AS contents;
      SELECT 'text' as component,
'This dashboard provides visibility into the health of the AI context ingestion pipeline. Use the metrics below to monitor the number of files ingested, processed for content, and validated for frontmatter. You can also filter recent ingests by time range.' as contents;

     
      -- === FILES SEEN ===
      select
      'big_number' as component,
      4 as columns,
      'colorfull_dashboard' as id;
     
      select
      'Files Seen' AS title,
      (SELECT COUNT(*)
      FROM uniform_resource
      WHERE deleted_at IS NULL
      ) as value,
      'green' as color,
      '/ai-context-engineering/file-list.sql' as value_link,
      TRUE as value_link_new_tab;
     
      -- === FILE WITH CONTENT ===
      SELECT
      'Files with Content' AS title,
      (
      SELECT COUNT(*)
      FROM ai_ctxe_uniform_resource_with_content
      ) AS value,
      'blue' AS color,
      '/ai-context-engineering/file-with-content-list.sql' as value_link,
      TRUE as value_link_new_tab;
     
      -- === FILES WITH FRONTMATTER ===
      SELECT
      'Files with Frontmatter' AS title,
      (
      SELECT COUNT(*)
      FROM ai_ctxe_uniform_resource_with_frontmatter
      ) AS value,
      'orange' AS color,
      '/ai-context-engineering/file-with-frontmatter-list.sql' as value_link;
 
      -- === FILES WITH VALID FRONTMATTER ===
      SELECT
      'Files with valid Frontmatter' AS title,
      (
      SELECT COUNT(*)
      FROM ai_ctxe_uniform_resource_transformed_resources_valid
      ) AS value,
      'green' AS color,
      '/ai-context-engineering/file-with-valid-frontmatter-list.sql' as value_link;
     
      -- === TIME RANGE SELECTION ===
      -- 1. Define the form
      SELECT 'form' AS component, TRUE AS auto_submit;
     
      SELECT
      'select' AS type,
      'time_range' AS name,
      'Select time range' AS label,
      'Select time range' AS empty_option,
      '[{"label": "Today", "value": "0"}, {"label": "7 day", "value": "1"}, {"label": "30 day", "value": "2"}]' AS options,
      :time_range AS value;
     
      -- 2. Define the table
      SELECT 'table' AS component,
      TRUE AS sort,
      TRUE AS search,
      'filename' AS markdown;
     
      -- 3. Query the filtered data
      SELECT
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/time-range-file-detail.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' AS "filename",
      uri AS "uri",
      nature AS "Nature",
      created_at AS "Created At"
      FROM ai_ctxe_uniform_resource_all_files
      WHERE
      :time_range IS NOT NULL
      AND :time_range != ''
      AND CASE
      WHEN :time_range = '0' THEN DATE(created_at) = DATE('now')
      WHEN :time_range = '1' THEN DATE(created_at) >= DATE('now', '-7 days')
      WHEN :time_range = '2' THEN DATE(created_at) >= DATE('now', '-30 days')
      ELSE 0 = 1
      END
      ORDER BY created_at DESC;
    `;
  }
 
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/merge-group-detail.sql"() {
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
      'Merge Groups' as title,
      ${this.absoluteURL("/ai-context-engineering/merge-group.sql")} as link;
     
      select
      "frontmatter_merge_group" as title,
      "#" as link from ai_ctxe_uniform_resource_frontmatter_view where uniform_resource_id = $uniform_resource_id;
;
SELECT 'title' AS component, 'Merge Group Details' AS contents;
 SELECT 'text' as component,
'This page provides a detailed view of a specific merge group in the AI Context Engineering system. It structured frontmatter details (title, summary, lifecycle, product metadata, provenance, reviewers, and features), and the list of prompts associated with the selected resource.' as contents;

      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
       '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
 
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' as component, 1 as columns;
     
      SELECT
     
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_prompts p
     
      WHERE p.uniform_resource_id = $uniform_resource_id
    GROUP BY p.uniform_resource_id
      ORDER BY p.ord, p.uniform_resource_id;
    `;
  }
 
  //Display all prompts available
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompts.sql"() {
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
      'Prompt' as title;
      SELECT 'title'AS component, 
     'Prompt' as contents; 
       SELECT 'text' as component,
'This page provides an overview of AI context engineering prompts, including their purpose, target audience, and validation status. Use the table below to explore and evaluate individual prompts and their associated metadata.' as contents;

   
     
-- Add CSS styling for validation status colors
SELECT 'html' as component,
'<style>
  /* Target the validation status column specifically */
  ._col_validation_status a {
    text-decoration: none;
  }
 
  /* Success styling for validation status column */
  .rowClass-success ._col_validation_status a {
    color: #28a745 !important;
    font-weight: bold;
  }
 
  /* Failure styling for validation status column */
  .rowClass-failure ._col_validation_status a {
    color: #dc3545 !important;
    font-weight: bold;
  }
</style>' as html;
 
SELECT
  'table' as component,
  TRUE AS sort,
  TRUE AS search,
  "title" as markdown,
  "validation status" as markdown;
     
SELECT
  '[' || title || '](' || ${this.absoluteURL("/ai-context-engineering/prompt-detail.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "title",
  CASE
    WHEN validation_status = 'success' THEN
      '[success](' || ${this.absoluteURL("/ai-context-engineering/validation-detail.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')'
    WHEN validation_status IN ('failure', 'failed') THEN
      '[failure](' || ${this.absoluteURL("/ai-context-engineering/validation-detail.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')'
    ELSE
      '[' || validation_status || '](' || ${this.absoluteURL("/ai-context-engineering/validation-detail.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')'
  END as "validation status",
 
  frontmatter_artifact_nature as "Artifact nature",
  frontmatter_function as "Function",
  frontmatter_audience as "Audience",
  frontmatter_summary as "Summary",
  uri as "URI",
 
  -- Add CSS class based on validation status
  CASE
    WHEN validation_status = 'success' THEN 'rowClass-success'
    WHEN validation_status IN ('failure', 'failed') THEN 'rowClass-failure'
    ELSE NULL
  END as _sqlpage_css_class
 
FROM ai_ctxe_uniform_resource_frontmatter_view WHERE uri NOT LIKE '%/.build/anythingllm/%'
  AND uri NOT LIKE '%/regime/hipaa/%'
  AND uri NOT LIKE '%/regime/soc2/%'
  AND uri NOT LIKE '%/regime/nist/%'
;
 
    `;
  }


  //complaince explorer prompts


  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompts-complaince-hipaa.sql"() {
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
      'Prompt' as title;
      SELECT 'title'AS component, 
     'Prompt' as contents; 
       SELECT 'text' as component,
'This page provides an overview of compliance-focused AI context engineering prompts, including those related to US HIPAA Controls prompts. Use the table below to review individual prompts along with their summaries and source details.' as contents;

   
     

 
SELECT
  'table' as component,
  TRUE AS sort,
  TRUE AS search,
  "title" as markdown
 ;
     
SELECT
  '[' || title || '](' || ${this.absoluteURL("/ai-context-engineering/prompt-detail-complaince-hipaa.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "title",
  

  frontmatter_summary as "Summary",
  uri as "URI"

 
FROM ai_ctxe_view_uniform_resource_complaince where regime='HIPAA'
;
 
    `;
  }
 
  //prompt details
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompt-detail.sql"() {
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
      'Prompt' as title,
      ${this.absoluteURL("/ai-context-engineering/prompts.sql")} as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'Prompt Details' AS contents;
      SELECT 'text' as component,
     'This page displays comprehensive details about the selected AI Context Engineering prompt, including its frontmatter metadata (such as title, summary, lifecycle, and provenance), reviewers, product features, and the full prompt content. Use the sections below to explore the prompt’s information and related resources.' as contents;

      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
       '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
 
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,

       '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_prompts p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  //files seen
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-list.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title;
     
      select
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'filename' as markdown;
     
      select
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/prompt-detail-all.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "filename",
      created_at as "Created At"
      from ai_ctxe_uniform_resource_prompts;
    `;
  }
 
  //files with content list
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-with-content-list.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title;
     
      select
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'filename' as markdown;
     
      select
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/file-detail-all.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "filename",
      created_at as "Created At"
      from ai_ctxe_uniform_resource_with_content;
    `;
  }
 
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompt-detail-all.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title,
      ${this.absoluteURL("/ai-context-engineering/file-list.sql")} as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'File Details' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
      '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_prompts p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-detail-all.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title,
      ${this.absoluteURL("/ai-context-engineering/file-list.sql")} as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_with_content
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'File Details' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
     '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_with_content p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  //file with fromtmatter list
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-with-frontmatter-list.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title;
     
      select
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'filename' as markdown;
     
      select
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/file-detail-all-frontmatter.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "filename",
      created_at as "Created At"
      from ai_ctxe_uniform_resource_with_frontmatter;
    `;
  }
 
  //file with frontmatter details
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-detail-all-frontmatter.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title,
      ${this.absoluteURL("/ai-context-engineering/file-list.sql")} as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_with_content
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'File Details' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
      '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_with_frontmatter p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  //risk panel
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/risk.sql"() {
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
      'Risk' as title;
     
      -- QA Risk Panel Card
      SELECT 'card' AS component, 'Risk / QA Panel' AS title;
     SELECT 'text' as component,
'This page highlights potential risks and quality issues within the AI context ingestion pipeline. Review invalid frontmatter, duplicate or unordered merge groups, and oversized files to ensure prompt quality and system reliability.' as contents;

      -- Risk summary table
      select
      'big_number' as component,
      3 as columns,
      'colorfull_dashboard' as id;
     
      select
      'Invalid Frontmatter' AS title,
      (SELECT count_empty_frontmatter
      FROM ai_ctxe_uniform_resource_risk_view
      ) as value,
      'red' as color,
      '/ai-context-engineering/file-without-frontmatter.sql' as value_link,
      TRUE as value_link_new_tab;
     
      -- === Duplicate merge group ===
      SELECT
      'Duplicate or Missing Order in Merge Groups' AS title,
      (
      SELECT count_grouped_resources
      FROM ai_ctxe_uniform_resource_risk_view
      ) AS value,
      'red' AS color,
      '/ai-context-engineering/file-with-merge-group-risk-list.sql' as value_link,
      TRUE as value_link_new_tab;
     
      -- === FILES OVERSIZED ===
      SELECT
      'Oversized Files (> 1MB)' AS title,
      (
      SELECT count_large_files
      FROM ai_ctxe_uniform_resource_risk_view
      ) AS value,
      'orange' AS color,
      '/ai-context-engineering/file-oversized-list.sql' as value_link;
    `;
  }
 
  //ingest files time rage detils
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/time-range-file-detail.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title, '#' as link;
     
      SELECT 'title' AS component, 'File Details' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
      '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\n **Merge group** : ' || a.frontmatter_merge_group AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_all_files p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-without-frontmatter.sql"() {
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
      'Risk' as title,
      ${this.absoluteURL("/ai-context-engineering/risk.sql")} as link;
     
      Select 'Files' as title, '#' as link;
      SELECT 'text' as component,
'This page lists ingested files that are missing frontmatter metadata. These files may require manual inspection or correction to be fully processed and included in the AI context engineering pipeline.' as contents;

     
      select
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'filename' as markdown;
     
      select
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/file-detail-without-frontmatter.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "filename",
      uri as "URI",
      nature as "Nature"
      from ai_ctxe_uniform_resource_transformed_resources_cleaned;
    `;
  }
 
  //file detail without frontmatter
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-detail-without-frontmatter.sql"() {
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
      'Risk' as title,
      ${this.absoluteURL("/ai-context-engineering/risk.sql")} as link;
     
      Select 'Files' as title,
      ${this.absoluteURL("/ai-context-engineering/file-without-frontmatter.sql")} as link;
     
      select filename as title,
      '#' as link
      from ai_ctxe_uniform_resource_transformed_resources_cleaned
      where uniform_resource_id = $uniform_resource_id;
     
       -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
       '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
 
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
 
     
      SELECT 'card' as component, 1 as columns;
     
      SELECT
      '\n' || p.body_content AS description_md
      FROM ai_ctxe_uniform_resource_transformed_resources_cleaned p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  //files oversized list
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-oversized-list.sql"() {
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
      'Risk' as title,
      ${this.absoluteURL("/ai-context-engineering/risk.sql")} as link;
     
      Select 'Files' as title, '#' as link;
     
      select
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'filename' as markdown;
     
      select
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/file-detail-oversize.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "filename",
      uri as "URI",
      nature as "Nature"
      from ai_ctxe_uniform_resource_oversized_list;
    `;
  }
 
  // file deatils oversized
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-detail-oversize.sql"() {
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
      'Risk' as title,
      ${this.absoluteURL("/ai-context-engineering/risk.sql")} as link;
     
      Select 'Files' as title,
      ${this.absoluteURL("/ai-context-engineering/file-oversized-list.sql")} as link;
     
      select filename as title,
      '#' as link
      from ai_ctxe_uniform_resource_oversized_list
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'File Details' AS contents;
     
      SELECT 'card' as component, 1 as columns;
     
      SELECT
      '\n' || p.content AS description_md
      FROM ai_ctxe_uniform_resource_oversized_list p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  //merge group risk
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-with-merge-group-risk-list.sql"() {
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
      'Risk' as title,
      ${this.absoluteURL("/ai-context-engineering/risk.sql")} as link;
     
      Select 'Files' as title, '#' as link;
     
       SELECT 'title'AS component, 
     'Missing Order' as contents;
      SELECT 'text' as component,
'This page lists files with merge group configuration issues, such as duplicate entries or missing order values. These risks may affect the correct merging and sequencing of prompts within the AI context pipeline.' as contents;


     
      select
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'filename' as markdown;
     
      select
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/file-detail-merge-group-risk.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "filename",
      uri as "URI",
      nature as "Nature"
      from ai_ctxe_uniform_resource_merge_group_risks;
    `;
  }
 
  //merge group risk files details
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-detail-merge-group-risk.sql"() {
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
      'Risk' as title,
      ${this.absoluteURL("/ai-context-engineering/risk.sql")} as link;
     
      Select 'Files' as title,
      ${this.absoluteURL("/ai-context-engineering/file-with-merge-group-risk-list.sql")} as link;
     
      select filename as title,
      '#' as link
      from ai_ctxe_uniform_resource_merge_group_risks
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'File Details' AS contents;
 
      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
       '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
 
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' as component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_merge_group_risks p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  //prompt anythingllm
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompts-anythingllm.sql"() {
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
      'Prompt' as title;
      SELECT 'title'AS component, 
     'Prompt' as contents;

      SELECT 'text' as component,
'This page lists AI context engineering prompts designed for use with AnythingLLM. Each entry includes metadata such as function, audience, and summary to help evaluate its suitability for specific LLM use cases.' as contents;

     
      SELECT
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      "title" as markdown;
     
      SELECT
      '[' || title || '](' || ${this.absoluteURL("/ai-context-engineering/prompt-detail-anythingllm.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "title",
      frontmatter_artifact_nature as "Artifact nature",
      frontmatter_function as "Function",
      frontmatter_audience as "Audience",
      frontmatter_summary as "Summary",
      uri as "URI"
      from ai_ctxe_uniform_resource_frontmatter_view_anythingllm;
    `;
  }
 
  //anything llm prompt details
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompt-detail-anythingllm.sql"() {
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
      'Prompt' as title,
      ${this.absoluteURL("/ai-context-engineering/prompts-anythingllm.sql")} as link;
     
      select
      "title" as title,
      "#" as link
      from uniform_resource_build_anythingllm
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'Prompt Details' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
       '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
 
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view_anythingllm a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM uniform_resource_build_anythingllm p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }
 
  //valid frontmatter
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-with-valid-frontmatter-list.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title;
     
      select
      'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'filename' as markdown;
     
      select
      '[' || filename || '](' || ${this.absoluteURL("/ai-context-engineering/file-detail-all-frontmatter-valid.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "filename",
      created_at as "Created At"
      from ai_ctxe_uniform_resource_transformed_resources_valid;
    `;
  }
 
  //file with valid frontmatter details
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/file-detail-all-frontmatter-valid.sql"() {
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
      'Ingest Health' as title,
      ${this.absoluteURL("/ai-context-engineering/ingest-health.sql")} as link;
     
      select 'Files' as title,
      ${this.absoluteURL("/ai-context-engineering/file-with-valid-frontmatter-list.sql")} as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_with_content
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'File Details' AS contents;
     
      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **Lifecycle** : ' || a.frontmatter_lifecycle AS description_md,
      '\n **Product name** : ' || a.frontmatter_product_name AS description_md,
      '\n **Provenance source uri** : ' || a.frontmatter_provenance_source_uri AS description_md,
     '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,
      '\n **Reviewers** : ' || a.frontmatter_reviewers AS description_md,
      '\n **Product features** : ' || a.frontmatter_product_features AS description_md,
      '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_uniform_resource_frontmatter_view a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_uniform_resource_with_frontmatter p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }

//soc2 type and type 2 cards
@spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompts-complaince-soc.sql"() {
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
      'SOC2 Type I' as title,
      ${this.absoluteURL("/ai-context-engineering/prompts-complaince-soc.sql")} as link;
      select
      'card' as component,
      3 as columns;

      select
      '## Total Counts of SOC2 Type I Prompt Modules' as description_md,
      'white' as background_color,
      '## ' || count(DISTINCT uniform_resource_id) as description_md,
      '12' as width,
      'pink' as color,
      'timeline-event' as icon,
      'background-color: #FFFFFF' as style,
      ${this.absoluteURL("/ai-context-engineering/prompts-complaince-soc2-typeI.sql")} as link
      FROM ai_ctxe_view_uniform_resource_complaince where regime='SOC2'; 
    `;
  }

  //soc type i prompt details
  
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompts-complaince-soc2-typeI.sql"() {
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
      'SOC2 Type I' as title,
      ${this.absoluteURL("/ai-context-engineering/prompts-complaince-soc.sql")} as link;
     
      select
      'Prompt' as title,
      '#' as link;
      SELECT 'title'AS component, 
     'Prompt' as contents; 
       SELECT 'text' as component,
'This page provides an overview of SOC2 Type I compliance-focused AI context engineering prompts. It includes a summary of each prompt, and a searchable, sortable table with links to detailed prompt pages. Each entry highlights the prompt’s title, a short description, and its source URI, enabling quick access to compliance-related resources.' as contents;

   
     

 
SELECT
  'table' as component,
  TRUE AS sort,
  TRUE AS search,
  "title" as markdown
 ;
     
SELECT
  '[' || title || '](' || ${this.absoluteURL("/ai-context-engineering/prompt-detail-complaince-soc2I.sql")} || '?uniform_resource_id=' || uniform_resource_id || ')' as "title",
  

  frontmatter_summary as "Summary",
  uri as "URI"

 
FROM ai_ctxe_view_uniform_resource_complaince where regime='SOC2'
;
 
    `;
  }
 
//validation error details
@spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/validation-detail.sql"() {
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
      'Prompt' as title,
      ${this.absoluteURL("/ai-context-engineering/prompts.sql")} as link;
     
      select
      "Validation" as title,
      "#" as link
      from ai_ctxe_uniform_resource_frontmatter_view
      where uniform_resource_id = $uniform_resource_id;
       select
      'card' as component,
      1 as columns;
     SELECT
      '\n' || p.elaboration_warning AS description_md
      
      from ai_ctxe_uniform_resource_frontmatter_view p
      where p.uniform_resource_id = $uniform_resource_id;
     
      `;
  }
//complaince prompt details
@spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompt-detail-complaince-hipaa.sql"() {
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
      'Complaince Prompt' as title,
      ${this.absoluteURL("/ai-context-engineering/prompts-complaince-hipaa.sql")} as link;
     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'Prompt Details' AS contents;
      SELECT 'text' as component,
     'This page provides detailed compliance prompt information from AI Context Engineering. 
 It displays the selected prompt’s metadata (including title, control question, control ID, 
 domain, SCF mapping, summary, publish date, category, satisfies frameworks, and provenance dependencies), 
 along with its merge group reference and full prompt content.' as contents;

      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
       '\n **Control question** : ' || a.frontmatter_control_question AS description_md,
       '\n **Control id** : ' || a.frontmatter_control_id AS description_md,
         '\n **Control domain** : ' || a.frontmatter_control_domain AS description_md,
           '\n **SCF control** : ' || a.SCF_control AS description_md,

      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **publishDate** : ' || a.publishDate AS description_md,
      '\n **category** : ' || a.frontmatter_category AS description_md,
      '\n **Satisfies** : ' || a.frontmatter_satisfies AS description_md,
       '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,

        '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }

  //soc2 type I drill in 
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ai-context-engineering/prompt-detail-complaince-soc2I.sql"() {
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
      'SOC2 Type I' as title,
      ${this.absoluteURL("/ai-context-engineering/prompts-complaince-soc.sql")} as link;
     
      select
      'Prompt' as title,
       ${this.absoluteURL("/ai-context-engineering/prompts-complaince-soc2-typeI.sql")} as link;

     

     
      select
      "title" as title,
      "#" as link
      from ai_ctxe_uniform_resource_prompts
      where uniform_resource_id = $uniform_resource_id;
     
      SELECT 'title' AS component, 'Prompt Details' AS contents;
      SELECT 'text' as component,
     'This page provides detailed SOC2 TypeI compliance prompt information from AI Context Engineering. 
 It displays the selected prompt’s metadata (including title, control question, control ID, 
 domain, SCF mapping, summary, publish date, category, satisfies frameworks, and provenance dependencies), 
 along with its merge group reference and full prompt content.' as contents;

      -- First card for accordion (frontmatter details)
      SELECT 'html' AS component,
      '<details open>
      <summary>Frontmatter details</summary>
      <div>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n **Title** : ' || a.title AS description_md,
       '\n **Control question** : ' || a.frontmatter_control_question AS description_md,
       '\n **Control id** : ' || a.frontmatter_control_id AS description_md,
         '\n **Control domain** : ' || a.frontmatter_control_domain AS description_md,
           '\n **SCF control** : ' || a.SCF_control AS description_md,

      '\n **Summary** : ' || a.frontmatter_summary AS description_md,
      '\n **publishDate** : ' || a.publishDate AS description_md,
      '\n **category** : ' || a.frontmatter_category AS description_md,
      '\n **Satisfies** : ' || a.frontmatter_satisfies AS description_md,
       '\n**Provenance dependencies**:\n' ||
  ifnull((
    SELECT group_concat('- ' || value, char(10))
    FROM json_each(a.frontmatter_provenance_dependencies)
  ), 'None')
  AS description_md,

        '\nMerge group: [' || a.frontmatter_merge_group || '](' || 
  ${this.absoluteURL("/ai-context-engineering/merge-group-detail.sql")} || 
  '?uniform_resource_id=' || uniform_resource_id || ')' 
  AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince a
      WHERE a.uniform_resource_id = $uniform_resource_id;
     
      SELECT 'html' AS component, '</div></details>' AS html;
     
      SELECT 'card' AS component, 1 as columns;
     
      SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_view_uniform_resource_complaince p
      WHERE p.uniform_resource_id = $uniform_resource_id;
    `;
  }

  
 
}


//soc2 prompt drill in


 
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