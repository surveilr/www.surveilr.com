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

const WEB_UI_TITLE = "Qualityfolio";
const WE_UI_LOGO = "qf-logo.png";
const WE_UI_FAV_ICON = "qf-favicon.ico";
const HIDE_HEADER_TITLE = true; // Hide header title text since logo contains "QualityFolio" text

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
function qltyfolioNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "qualityfolio/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class QualityfolioSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /qualityfolio-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE parent_path like ${this.constructHomePath("qualityfolio")
      };
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }
  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
  })
  "qualityfolio/test-suites-common.sql"() {
    return this.SQL`
    
      SELECT 'html' as component,
        '<style>
        p strong {
        color: red !important;
    }

    /* Escape the dot in the class name */
    tr.rowClass-100 p strong {
        color: green !important;
    }
    .btn-list {
        display: flex;
        justify-content: flex-end;
    }
    </style>
   
    
    '
    
  as html;
  select
    'button' as component;
    select
      'Generate Report'           as title,
      'download-test-suites.sql' as link;
 SELECT 'table' as component,
        'Column Count' as align_right,
        TRUE as sort,
        TRUE as search,
        'id' as markdown,
        'Success Rate' as markdown;
      SELECT
      '['||suite_id||']('||${this.absoluteURL("/qualityfolio/suite-data.sql")
      }||'?id='||suite_id||')' as id,
      
      suite_name,
      created_by_user as "Created By",
      total_test_case as "test case count",
    --   CASE
    --     WHEN total_test_case > 0
    --     THEN
    --         '**'||ROUND(
    --             100.0 * success_count /
    --             (total_test_case-todo_count),
    --             2
    --         ) || '%**' ||' *('||success_count || '/' || (total_test_case-todo_count)  ||'*)'
    --     ELSE '0%'
    -- END AS "Success Rate",
       CASE
        WHEN total_test_case > 0
        THEN
            '**'||ROUND(
                100.0 * success_count /
                total_test_case,
                2
            ) || '%**' ||' *('||success_count || '/' || total_test_case  ||'*)'
        ELSE '0%'
    END AS "Success Rate",
    --  todo_count as "TO DO",
      strftime('%d-%m-%Y', created_at) as "Created On",
       'rowClass-'||(100* success_count/(total_test_case)) as _sqlpage_css_class
      
      FROM test_suite_success_and_failed_rate st order by suite_id asc;

    

    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/test-suites.sql"() {
    return this.SQL`

     select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link;
    select
    'Test Suites' as title;

 
    SELECT 'title'AS component, 
     'Test Suite' as contents; 
        SELECT 'text' as component,
        'Test suite is a collection of test cases designed to verify the functionality, performance, and security of a software application. It ensures that the application meets the specified requirements by executing predefined tests across various scenarios, identifying defects, and validating that the system works as intended.' as contents;

     select 'dynamic' as component, sqlpage.run_sql('qualityfolio/test-suites-common.sql') as properties;
    `;
  }

  "qualityfolio/test-plan.sql"() {
    return this.SQL`
    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link;
    select
    'Test Plans' as title;



    SELECT 'title'AS component, 
     'Test Plans' as contents; 
        SELECT 'text' as component,
        'A test plan is a high-level document that outlines the overall approach to testing a software application. It serves as a blueprint for the testing process.' as contents;

     SELECT 'table' as component,
        'Column Count' as align_right,
        TRUE as sort,
        TRUE as search,
        'id' as markdown,
        'test case count' as markdown;
      SELECT 
      '['||id||']('||${this.absoluteURL("/qualityfolio/plan-overview.sql")
      }||'?id='||id||')' as id,      
      name,
      '['||test_case_count||']('||${this.absoluteURL("/qualityfolio/test-cases-list.sql")
      }||'?id='||id||')' as "test case count",   
      created_by as "Created By",
      created_at as "Created On"
      FROM test_plan_list  order by id asc;
    `;
  }
  @spn.navigationPrimeTopLevel({
    caption: "Test Management System",
    description: "Test management system",
  })
  "qualityfolio/index.sql"() {
    return this.SQL`
    
    SELECT 'text' as component,
    'The dashboard provides a centralized view of your testing efforts, displaying key metrics such as test progress, results, and team productivity. It offers visual insights with charts and reports, enabling efficient tracking of test runs, milestones, and issue trends, ensuring streamlined collaboration and enhanced test management throughout the project lifecycle.' as contents;
    select 
    'card' as component,
    4      as columns;

    SELECT
    '## Automation Coverage' AS description_md,
    'white' AS background_color,
    '##  ' || ROUND(100.0 * SUM(CASE WHEN test_type = 'Automation' THEN 1 ELSE 0 END) / COUNT(*), 2) || '%' AS description_md,    
    'orange' AS color,
    'brand-ansible' AS icon
    FROM
    test_cases;

     SELECT
    '## Automated Test Cases' AS description_md,
    'white' AS background_color,
    '##  ' || SUM(CASE WHEN test_type = 'Automation' THEN 1 ELSE 0 END) AS description_md,    
    'green' AS color,
    'brand-ansible' AS icon
    FROM
    test_cases;

    SELECT
    '## Manual Test Cases' AS description_md,
    'white' AS background_color,
    '##  ' || SUM(CASE WHEN test_type = 'Manual' THEN 1 ELSE 0 END) AS description_md,    
    'yellow' AS color,
    'analyze' AS icon
    FROM
    test_cases;
    
    

select
    '## Total Test Cases Count' as description_md,
 
    'white' as background_color,
    '## '||count(DISTINCT test_case_id) as description_md,
    '12' as width,
     'red' as color,
    'brand-speedtest'       as icon,
     ${this.absoluteURL("/qualityfolio/test-cases-full-list.sql")} as link
    
    FROM test_cases ;

     select
    '## Total Test Suites Count' as description_md,
    'white' as background_color,
    '## '||count(id) as description_md,
    '12' as width,
    'sum'       as icon,
    ${this.absoluteURL("/qualityfolio/test-suites.sql")} as link
    FROM test_suites ; 

  select
    '## Total Test Plans Count' as description_md,
 
    'white' as background_color,
    '## '||count(id) as description_md,
    '12' as width,
     'pink' as color,
    'timeline-event'       as icon,
    'background-color: #FFFFFF' as style,
    ${this.absoluteURL("/qualityfolio/test-plan.sql")} as link
    FROM test_plan ; 

    select
    '## Success Rate' as description_md,

    'white' as background_color,
    '## '||ROUND(100.0 * SUM(CASE WHEN r.status = 'passed' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2)||'%' as description_md,
    '12' as width,
     'lime' as color,
    'circle-dashed-check'       as icon,
    'background-color: #FFFFFF' as style
    FROM 
    test_cases t
LEFT JOIN 
    (select * from test_case_run_results group by test_case_id) r
    ON
    t.test_case_id = r.test_case_id;

    


    select
    '## Failed Rate' as description_md,

    'white' as background_color,
    '## '||ROUND(100.0 * SUM(CASE WHEN r.status = 'failed' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2)||'%' as description_md,
    '12' as width,
     'red' as color,
    'details-off'       as icon,
    'background-color: #FFFFFF' as style
    FROM 
    test_cases t
LEFT JOIN 
    (select * from test_case_run_results group by test_case_id) r
    ON
    t.test_case_id = r.test_case_id;


 select
    '## Total Defects' as description_md,

    'white' as background_color,
    '## '||count(bug_id) as description_md,
    '12' as width,
     'red' as color,
    'details-off'       as icon,
    'background-color: #FFFFFF' as style,
    ${this.absoluteURL("/qualityfolio/bug-list.sql")} as link
    FROM 
    jira_issues t ;
    select
    '## Open Defects' as description_md,

    'white' as background_color,
    '## '||count(bug_id) as description_md,
    '12' as width,
     'orange' as color,
    'details-off'       as icon,
    'background-color: #FFFFFF' as style,
    ${this.absoluteURL("/qualityfolio/bug-list.sql?status=To Do")} as link
    FROM 
    jira_issues t  where status='To Do';


    select
    '## Closed Defects' as description_md,

    'white' as background_color,
    '## '||count(bug_id) as description_md,
    '12' as width,
     'purple' as color,
    'details-off'       as icon,
    'background-color: #FFFFFF' as style,
    ${this.absoluteURL("/qualityfolio/bug-list.sql?status=Completed")} as link
    FROM 
    jira_issues t where status='Completed';


    select
    '## Rejected Defects' as description_md,

    'white' as background_color,
    '## '||count(bug_id) as description_md,
    '12' as width,
     'cyan' as color,
    'details-off'       as icon,
    'background-color: #FFFFFF' as style,
    ${this.absoluteURL("/qualityfolio/bug-list.sql?status=Rejected")} as link
    FROM 
    jira_issues t where status='Rejected';


SELECT 'html' as component,
'<style>
.apexcharts-legend-seriesd {
    color: #ffff; /* Red color */
    font-weight: bold; /* Makes the text bold */
}



</style>' 
as html;

select 
    'card' as component,
    2      as columns;
select 
    ${this.absoluteURL("/qualityfolio/chart1.sql?_sqlpage_embed")} as embed;
select 
    ${this.absoluteURL("/qualityfolio/chart2.sql?_sqlpage_embed")} as embed;
    
 SELECT 'title'AS component, 
     'Test Suite List' as contents; 
        SELECT 'text' as component;

        
select 'dynamic' as component, sqlpage.run_sql('qualityfolio/test-suites-common.sql') as properties;

-- select 
--     'chart'             as component,
--     'Test Suites' as title,
--     -- 'area'              as type,
--     -- 'purple'            as color,
--     0         as ymin,
--      5                   as marker,
--     'Success Test Case' as ytitle,
--     'Total Test Case' as xtitle;

-- select 
--     total_test_case as x,
--     success_count    as value,
    
--     suite_name as series
--     FROM test_suite_success_and_failed_rate;


    `;
  }
  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
  })
  "qualityfolio/download-test-suites.sql"() {
    return this.SQL`
    select 'csv' as component, 'test_suites.csv' as filename;
    SELECT * FROM test_suites;
    `;
  }
  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
  })
  "qualityfolio/chart1.sql"() {
    return this.SQL`
    --First Chart: Test Case Status Distribution
    SELECT
    'chart' AS component,
      'Comprehensive Test Status' AS title,
        'pie' AS type,
          TRUE AS labels,
            'green' as color,
            'red' as color,
            'azure' as color,
            'chart-left' AS class; --Custom class for styling the first chart

    --Data for the first chart
SELECT
    'Passed' AS label,
      ROUND(100.0 * SUM(CASE WHEN r.status = 'passed' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2) AS value
    FROM 
    test_cases t
LEFT JOIN 
    test_case_run_results r
    ON
    t.test_case_id = r.test_case_id;

    SELECT
    'Failed' AS label,
      ROUND(100.0 * SUM(CASE WHEN r.status = 'failed' THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2) AS value
    FROM 
    test_cases t
LEFT JOIN 
    (select * from test_case_run_results group by test_case_id ) r
    ON
    t.test_case_id = r.test_case_id;

    SELECT
    'Todo' AS label,
      ROUND(100.0 * SUM(CASE WHEN r.status IS NULL THEN 1 ELSE 0 END) / COUNT(t.test_case_id), 2) AS value
    FROM 
    test_cases t
LEFT JOIN 
    test_case_run_results r
    ON
    t.test_case_id = r.test_case_id;



    `;
  }
  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
  })
  "qualityfolio/progress-bar.sql"() {
    return this.SQL`
    select
    'chart' as component,
      'treemap' as type,
      'Quarterly Results By Region (in k$)' as title,
      TRUE as labels;
    select
    'North America' as series,
      'United States' as label,
      35 as value;
    select
    'North America' as series,
      'Canada' as label,
      15 as value;
    select
    'Europe' as series,
      'France' as label,
      30 as value;
    select
    'Europe' as series,
      'Germany' as label,
      55 as value;
    select
    'Asia' as series,
      'China' as label,
      20 as value;
    select
    'Asia' as series,
      'Japan' as label,
      10 as value;
    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "qualityfolio/chart2.sql"() {
    return this.SQL`
    SELECT
    'chart' AS component,
      'Total Automated Test Case Coverage' AS title,
        'pie' AS type,
          TRUE AS labels,
            'green' as color,
            'yellow' as color,
            'chart-right' AS class; --Custom class for styling the second chart

    --Data for the second chart
SELECT
    'Automated' AS label,
      ROUND(100.0 * SUM(CASE WHEN test_type = 'Automation' THEN 1 ELSE 0 END) / COUNT(*), 2) AS value
    FROM
    test_cases;

    SELECT
    'Manual' AS label,
      ROUND(100.0 * SUM(CASE WHEN test_type = 'Manual' THEN 1 ELSE 0 END) / COUNT(*), 2) AS value
    FROM
    test_cases;
    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no", pageTitleFromNavStmts: "no" })
  "qualityfolio/suite-data.sql"() {
    return this.SQL`
    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link;
    select
    "name" as title from test_suites where CAST(id AS TEXT) = CAST($id AS TEXT);
    SELECT 'title'AS component,
      name as contents FROM test_suites  WHERE id = $id;

    -- Custom CSS for accordion styling
    SELECT 'html' AS component,
      '<style>
        .custom-accordion {
          margin: 20px 0;
          border: 1px solid #ddd;
          border-radius: 4px;
          overflow: hidden;
        }
        .custom-accordion details {
          border: none;
          margin: 0;
        }
        .custom-accordion details + details {
          border-top: 1px solid #ddd;
        }
        .custom-accordion summary {
          background-color: #f5f5f5;
          padding: 15px 20px;
          cursor: pointer;
          font-weight: 500;
          color: #333;
          border: none;
          outline: none;
          position: relative;
          user-select: none;
          list-style: none;
        }
        .custom-accordion summary::-webkit-details-marker {
          display: none;
        }
        .custom-accordion summary::after {
          content: "+";
          position: absolute;
          right: 20px;
          top: 50%;
          transform: translateY(-50%);
          font-size: 18px;
          font-weight: bold;
          color: #666;
        }
        .custom-accordion details[open] summary::after {
          content: "−";
        }
        .custom-accordion summary:hover {
          background-color: #ebebeb;
        }
        .custom-accordion .content {
          padding: 20px;
          background-color: white;
          border-top: 1px solid #ddd;
        }
      </style>' AS html;

    -- Accordion container
    SELECT 'html' AS component,
      '<div class="custom-accordion">' AS html;

    -- Suite Details Section (open by default)
    SELECT 'html' AS component,
      '<details open>
        <summary>Suite Details</summary>
        <div class="content">' AS html;

    SELECT 'card' AS component,
           1 AS columns;

    SELECT
    '**Description:** ' || COALESCE(rn."description", 'No description available') ||
    '\n\n**Created By:** ' || COALESCE(rn.created_by_user, 'Unknown') ||
    '\n\n**Created At:** ' || strftime('%d-%m-%Y', rn.created_at) ||
    '\n\n**Linked Requirements:** ' || COALESCE(rn.linked_requirements, 'None specified') ||
    CASE
      WHEN rn.body IS NOT NULL AND rn.body != ''
      THEN '\n\n**Additional Details:**\n' || rn.body
      ELSE ''
    END AS description_md
    FROM test_suites rn WHERE id = $id;

    SELECT 'html' AS component,
      '</div></details>' AS html;

    -- Test Case Groups Section (closed by default)
    SELECT 'html' AS component,
      '<details>
        <summary>Test Case Groups (' || COUNT(*) || ')</summary>
        <div class="content">' AS html
    FROM (SELECT DISTINCT group_id FROM test_cases_run_status WHERE suite_id = $id);

    SELECT 'text' AS component,
      'This section contains all test case groups within this test suite. Each group represents a collection of related test cases organized by functionality or testing scope.' AS contents;

    SELECT 'table' as component,
      TRUE AS sort,
      TRUE AS search,
      'Group ID' AS markdown,
      'Group Name' AS markdown;

    SELECT
    '[' || group_id || '](' || ${this.absoluteURL("/qualityfolio/group-detail.sql?id=")
      }|| group_id || ')' as "Group ID",
      group_name AS "Group Name",
      created_by as "Created By",
      formatted_test_case_created_at as "Created On"
    FROM test_cases_run_status
    WHERE suite_id = $id
    ORDER BY group_id ASC;

    SELECT 'html' AS component,
      '</div></details>' AS html;

    -- Close accordion container
    SELECT 'html' AS component,
      '</div>' AS html;


    `;
  }
  @qltyfolioNav({
    caption: "Test Cases",
    description: "Complete list of all test cases across all projects and suites",
    siblingOrder: 3,
  })
  "qualityfolio/test-cases.sql"() {
    const viewName = `test_cases`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
      whereSQL: "WHERE ($id IS NULL OR group_id = $id)",
    });

    return this.SQL`
    ${this.activePageTitle()}

    -- Page description based on context
    SELECT 'text' AS component,
      CASE
        WHEN $id IS NOT NULL THEN
          'This page displays test cases for the selected group: ' || (SELECT group_name FROM test_cases WHERE group_id = $id LIMIT 1) || '. Use the search and filter functionality to find specific test cases.'
        ELSE
          'This page displays a comprehensive list of all test cases across all projects and test suites. Use the search and filter functionality to find specific test cases by name, status, group, or priority.'
      END AS contents;

    -- Status overview based on context
    SELECT 'alert' AS component,
           'info' AS color,
           CASE
             WHEN $id IS NOT NULL THEN 'Group Test Case Overview'
             ELSE 'Test Case Overview'
           END AS title,
           'Total test cases: ' ||
           CASE
             WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id)
             ELSE (SELECT COUNT(*) FROM test_cases)
           END ||
           ' | Passed: ' ||
           CASE
             WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id AND test_status = 'passed')
             ELSE (SELECT COUNT(*) FROM test_cases WHERE test_status = 'passed')
           END ||
           ' | Failed: ' ||
           CASE
             WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id AND test_status = 'failed')
             ELSE (SELECT COUNT(*) FROM test_cases WHERE test_status = 'failed')
           END ||
           ' | Pending: ' ||
           CASE
             WHEN $id IS NOT NULL THEN (SELECT COUNT(*) FROM test_cases WHERE group_id = $id AND (test_status IS NULL OR test_status = 'TODO'))
             ELSE (SELECT COUNT(*) FROM test_cases WHERE test_status IS NULL OR test_status = 'TODO')
           END AS description;

    SELECT 'html' as component,
      '<style>
         tr td.test_status {
              color: blue !important;
          }
          tr.rowClass-passed td.test_status {
              color: green !important;
          }
           tr.rowClass-failed td.test_status {
              color: red !important;
          }
          tr.rowClass-TODO td.test_status {
              color: orange !important;
          }
          .btn-list {
          display: flex;
          justify-content: flex-end;
      }
      </style>' as html;

    SELECT 'button' as component;

    -- Show "View All Test Cases" button when filtering by group
    SELECT 'View All Test Cases' as title,
           'test-cases.sql' as link,
           'list' as icon
    WHERE $id IS NOT NULL
    UNION ALL
    -- Show "Export Group Test Cases" button when filtering by group
    SELECT 'Export Group Test Cases' as title,
           'download-test-case.sql?group_id=' || $id as link,
           'download' as icon
    WHERE $id IS NOT NULL
    UNION ALL
    -- Show "Export All Test Cases" button when showing all test cases
    SELECT 'Export All Test Cases' as title,
           'download-full_list.sql' as link,
           'download' as icon
    WHERE $id IS NULL;

    ${pagination.init()}

    SELECT 'table' as component,
           TRUE AS sort,
           TRUE AS search,
           'Test Case ID' as markdown,
           'Title' as markdown,
           'Group' as markdown,
           'Suite' as markdown,
           'Status' as markdown;

    SELECT
      '[' || tc.test_case_id || '](' || ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=actual-result&id=")
      }|| tc.test_case_id || ')' as "Test Case ID",
      tc.test_case_title AS "Title",
      '[' || tc.group_name || '](' || ${this.absoluteURL("/qualityfolio/group-detail.sql?id=")
      }|| tc.group_id || ')' AS "Group",
      '[' || ts.name || '](' || ${this.absoluteURL("/qualityfolio/suite-data.sql?id=")
      }|| ts.id || ')' AS "Suite",
      CASE
        WHEN tc.test_status IS NOT NULL THEN tc.test_status
        ELSE 'TODO'
      END AS "Status",
      'rowClass-' || COALESCE(tc.test_status, 'TODO') as _sqlpage_css_class,
      tc.test_type AS "Type",
      tc.priority AS "Priority",
      tc.created_by AS "Created By",
      tc.formatted_test_case_created_at AS "Created On"
    FROM ${viewName} tc
    LEFT JOIN test_suites ts ON ts.id = tc.suite_id
    WHERE ($id IS NULL OR tc.group_id = $id)
    ORDER BY tc.test_case_id
    LIMIT $limit OFFSET $offset;

    ${pagination.renderSimpleMarkdown("id")};
    `;
  }

  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
  })
  "qualityfolio/download-test-case.sql"() {
    return this.SQL`
    select 'csv' as component, 'test_suites_'||$group_id||'.csv' as filename;
     SELECT
      test_case_id as id,
      test_case_title AS "title",
      group_name AS "group",
      test_status,
      created_by as "Created By",
      formatted_test_case_created_at as "Created On",
      priority as "Priority"
    FROM test_cases t
    WHERE  group_id = $group_id;

    `;
  }

  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
  })
  "qualityfolio/download-full_list.sql"() {
    return this.SQL`
    select 'csv' as component, 'test_cases.csv' as filename;
     SELECT
      test_case_id as id,
      test_case_title AS "title",
      group_name AS "group",
      test_status,
      created_by as "Created By",
      formatted_test_case_created_at as "Created On",
      priority as "Priority"
    FROM test_cases t

    `;
  }

  @spn.shell({
    breadcrumbsFromNavStmts: "no",
  })
  "qualityfolio/bug-list.sql"() {
    const viewName = `jira_issues`;

    return this.SQL`
    SELECT 'html' as component,
    '<style>
        
        tr td.Statealign-middle {
            color: blue !important; /* Default to blue */
        }
        tr.rowClass-Completed td.state {
            color: green !important; /* Default to blue */
        }
         tr.rowClass-Rejected td.state {
            color: red !important; /* Default to blue */
        }
         tr.rowClass-Completed td.Statealign-middle {
            color: green !important; /* Default to blue */
        }
         tr.rowClass-Rejected td.Statealign-middle {
            color: red !important; /* Default to blue */
        }
    
    }
    </style>' as html;
     select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link; 
    select 'bug list' as title;  
    
     SELECT 'table' as component,
      TRUE AS sort,
        TRUE AS search,
          'URL' AS align_left,
            'title' AS align_left,
              'group' as markdown,
              'id' as markdown,
              "status_new" as markdown,
              'count' as markdown;
    SELECT
    '[' || bug_id || '](' || ${this.absoluteURL("/qualityfolio/bug-detail.sql?id=")
      }|| bug_id || ')' as id,
      title,
      reporter as 'Reporter',
      strftime('%d-%m-%Y', created) as "Created At",
      assignee,
      status as "State",
      'rowClass-'||status as _sqlpage_css_class
    FROM jira_issues t WHERE ($status IS NOT NULL AND status = $status) OR $status IS NULL;
    --  FROM ${viewName} t
    --  LIMIT $limit
    --   OFFSET $offset;

    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/suite-group.sql"() {
    return this.SQL`

    --Define tabs
    SELECT
    'tab' AS component,
      TRUE AS center;

    --Tab 1: Test Suite list
    SELECT
    'Test Plan List' AS title,
      ${this.absoluteURL("/qualityfolio/suite-group?tab=test_suites")} AS link,
        $tab = 'test_suites' AS active;


    --Tab 2: Test case list
    SELECT
    'Test Case List' AS title,
      ${this.absoluteURL("/qualityfolio/suite-group?tab=test_cases")} AS link,
        $tab = 'test_cases' AS active;

    --Tab 3: Meta Tags Missing URLs
    SELECT
    'Test Run List' AS title,
      $tab = 'test_run' AS active;

    SELECT 
      case when $tab = 'test_suites' THEN 'card'
      END AS component,
       1                          as columns;

   
    SELECT
    ' **Name**  :  ' || rn.name AS description_md,
      '\n **Description**  :  ' || rn."description" AS description_md,
        '\n **Created By**  :  ' || rn.created_by_user AS description_md,
          '\n **Created At**  :  ' || strftime('%d-%m-%Y', rn.created_at) AS description_md,
            '\n **Priority**  :  ' || rn.linked_requirements AS description_md,
              '\n' || rn.body AS description_md
FROM test_suites rn WHERE id = $id;


    --Define component type based on active tab
    SELECT
    CASE
        WHEN $tab = 'test_cases' THEN 'table'
        WHEN $tab = 'test_suites' THEN 'table'
        WHEN $tab = 'test_run' THEN 'table'
      END AS component,
      TRUE AS sort,
        --TRUE AS search,
          'URL' AS align_left,
            'title' AS align_left,
              'group' as markdown,
              'id' as markdown,
              'count' as markdown;

    --Conditional content based on active tab

    --Tab - specific content for "test_suites"
    SELECT
      '[' || test_case_id || '](' || ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=actual-result&id=")
      }|| test_case_id || ')' as id,
      test_case_title AS "title",
        group_name AS "group",
          created_by as "Created By",
          formatted_test_case_created_at as "Created On",
          priority as "Priority"
    FROM test_cases
    WHERE $tab = 'test_cases' and group_id = $id 
    order by test_case_id;




    --Tab - specific content for "test_run"
   SELECT
      name AS "Property Name"
    FROM groups
    WHERE $tab = 'test_run';


    `;
  }
  @qltyfolioNav({
    caption: "Projects",
    description: ``,
    siblingOrder: 1,
  })
  "qualityfolio/test-management.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

      SELECT 'list' AS component,
      'Column Count' as align_right,
      TRUE as sort,
      TRUE as search;



    SELECT
    '[' || project_name || '](/qualityfolio/detail.sql?name=' || project || ')' as description_md
      from projects

      `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/test-detail.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link; 
    select s.name as title,
      ${this.absoluteURL("/qualityfolio/suite-data.sql?id=")} || s.id as link
         FROM test_cases r
         INNER JOIN groups g on g.id = r.group_id 
         INNER JOIN test_suites s on s.id = g.suite_id
         where test_case_id = $id
         group by title;  
    select g.name as title,
      ${this.absoluteURL("/qualityfolio/test-cases.sql?id=")} || g.id as link
         FROM test_cases r
         INNER JOIN groups g on g.id = r.group_id 
         where test_case_id = $id
         group by title;
         
    SELECT title FROM test_cases where test_case_id = $id order by created_at desc limit 1;      
         

         

    SELECT 'title'AS component,
      title as contents FROM test_cases where test_case_id = $id order by created_at desc limit 1;

     SELECT 'card'  AS component,
    1                          as columns;
    SELECT
    '\n **Title**  :  ' || bd.title AS description_md,
    '\n **Group**  :  ' || bd.group_name AS description_md,
    '\n **Created By**  :  ' || bd.created_by AS description_md,
    '\n **Created At**  :  ' || strftime('%d-%m-%Y',  bd.created_at) AS description_md,
    '\n **Priority**  :  ' || bd.priority AS description_md,
    '\n' || bd.body AS description_md
FROM  test_cases bd WHERE bd.test_case_id = $id  group by bd.test_case_id;


  SELECT 'html' as component,
    '<style>
        tr.actualClass-passed td.State {
            color: green !important; /* Default to red */
        }
         tr.actualClass-failed td.State {
            color: red !important; /* Default to red */
        }
          tr.actualClass-passed td.Statealign-middle {
            color: green !important; /* Default to red */
        }
          tr.actualClass-failed td.Statealign-middle {
            color: red !important; /* Default to red */
        }
        
        .btn-list {
        display: flex;
        justify-content: flex-end;
        }
       h2.accordion-header button {
        font-weight: 700;
      }
    </style>
    
    ' as html FROM test_case_run_results where test_case_id = $id group by group_id;


    --Define tabs
    SELECT
    'tab' AS component,
      TRUE AS center
     FROM test_case_run_results where test_case_id = $id group by group_id;

    --Tab 1: Actual Result
    SELECT
    'Actual Result' AS title,
      ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=actual-result&id=")
      }|| $id || '#actual-result-content'  AS link,
      $tab = 'actual-result' AS active
        FROM test_case_run_results where test_case_id = $id group by group_id;


    --Tab 2: Test Run
    SELECT
    'Test Run' AS title,
      ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=test-run&id=")
      }|| $id || '#test-run-content'  AS link,
      $tab = 'test-run' AS active
         FROM test_case_run_results where test_case_id = $id group by group_id;

--Tab 3: Bug Report
    SELECT
    'Bug Report' AS title,
      ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=bug-report&id=")
      }|| $id || '#bug-report-content'  AS link,
      $tab = 'bug-report' AS active
         FROM bug_list  where test_case_id = $id;



    SELECT
    CASE
        WHEN $tab = 'actual-result' THEN 'title'
    END AS component,
      'Actual Result' as contents   
    FROM test_case_run_results WHERE test_case_id = $id group by group_id;

    SELECT
    CASE
        WHEN $tab = 'actual-result' THEN 'table'
        WHEN $tab = 'test-run' THEN 'list'
         WHEN $tab = 'bug-report' THEN 'foldable'
      END AS component,
      'Column Count' as align_right,
      TRUE as sort,
      TRUE as search
        FROM test_case_run_results  where test_case_id = $id group by group_id;


    --Tab - specific content for "actual-result"  

      
    SELECT
    step_name as 'Activity',
      step_status as 'State',
      'actualClass-'||step_status as _sqlpage_css_class,
      step_start_time as 'Start Time',
      step_end_time as 'End Time'
          FROM test_execution_log
          WHERE $tab = 'actual-result' and  test_case_id = $id order by step_start_time desc;
    SELECT
    CASE
        WHEN $tab = 'actual-result' THEN 'html'
    END AS component,
      '<div id="actual-result-content"></div>' as html
       FROM test_execution_log
          WHERE $tab = 'actual-result' and  test_case_id = $id;



    --Tab - specific content for "test-run"
    SELECT
    '\n **Run Date**  :  ' || strftime('%d-%m-%Y',run_date) AS description_md,
      '\n **Environment**  :  ' || environment AS description_md,
        '\n' || body AS description_md
    FROM  test_run WHERE $tab = 'test-run' and test_case_id = $id;

    SELECT
    CASE
        WHEN $tab = 'test-run' THEN 'html'
    END AS component,
      '<div id="test-run-content"></div>' as html
      FROM  test_run WHERE $tab = 'test-run' and test_case_id = $id;
   

    --Tab - specific content for "bug-report"
    
     
    select
    title         as title,
     '\n \n\n**id**  :  ' || l.bug_id AS description_md,
    '\n **Created By**  :  ' || reporter AS description_md,
    '\n **Run Date**  :  ' || strftime('%d-%m-%Y', created) AS description_md,
    '\n **Type**  :  ' || type AS description_md,
    '\n **Assigned**  :  ' || assignee AS description_md,
    '\n **Status**  :  ' || status AS description_md,
    '\n' || description AS description_md
    FROM
    bug_list l
    inner join
    jira_issues j on l.bug_id=j.bug_id
    where l.test_case_id=$id;

    SELECT
    CASE
        WHEN $tab = 'bug-report' THEN 'html'
    END AS component,
      '<div id="bug-report-content"></div>' as html
    FROM  bug_list l
    inner join
    jira_issues j on l.bug_id=j.bug_id
    where l.test_case_id=$id;

    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/bug-detail.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link; 
    select 'bug list' as title,
      ${this.absoluteURL("/qualityfolio/bug-list.sql")} as link;  
      
    SELECT title FROM jira_issues where bug_id = $id order by created desc ;      
         

         

    /*SELECT 'title'AS component,
      title as contents FROM jira_issues where id = $id order by created_at desc;*/

    select 
    'datagrid'      as component,
    title         as title,
    'bulb'          as icon,
     '\n \n\n**id**  :  ' || bug_id AS description_md,    
    '\n **Created By**  :  ' || reporter AS description_md,
    '\n **Run Date**  :  ' || strftime('%d-%m-%Y', created) AS description_md,
    '\n **Type**  :  ' || type AS description_md,
    '\n **Assigned**  :  ' || assignee AS description_md,
    '\n **Status**  :  ' || status AS description_md,
    '\n' || description AS description_md 
      FROM  jira_issues  WHERE bug_id = $id;
     
    /*SELECT 'datagrid'AS component;
     SELECT
    '\n **id**  :  ' || id AS description_md
    
    '\n **Title**  :  ' || title AS description_md,
    '\n **Created By**  :  ' || b.created_by AS description_md,
    '\n **Run Date**  :  ' || strftime('%d-%m-%Y', b.created_at) AS description_md,
    '\n **Type**  :  ' || b.type AS description_md,
    '\n **Priority**  :  ' || b.priority AS description_md,
    '\n **Assigned**  :  ' || b.assigned AS description_md,
    '\n **Status**  :  ' || b.status AS description_md,
    '\n' || b.body AS description_md
    FROM  bug_report b 
    WHERE b.id = $id;*/


    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/group-detail.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link;
    select
    s."name" as title,
      ${this.absoluteURL("/qualityfolio/suite-data.sql?id=")} || s.id as link
         from groups g
        inner join  test_suites s on s.id = g.suite_id where g.id = $id;
    select
    g."name" as title from groups g
        inner join  test_suites s on s.id = g.suite_id where g.id = $id;


    SELECT 'title'AS component,
      name as contents FROM groups where id = $id;

    -- Custom CSS for accordion styling (same as suite-data)
    SELECT 'html' AS component,
      '<style>
        .custom-accordion {
          margin: 20px 0;
          border: 1px solid #ddd;
          border-radius: 4px;
          overflow: hidden;
        }
        .custom-accordion details {
          border: none;
          margin: 0;
        }
        .custom-accordion details + details {
          border-top: 1px solid #ddd;
        }
        .custom-accordion summary {
          background-color: #f5f5f5;
          padding: 15px 20px;
          cursor: pointer;
          font-weight: 500;
          color: #333;
          border: none;
          outline: none;
          position: relative;
          user-select: none;
          list-style: none;
        }
        .custom-accordion summary::-webkit-details-marker {
          display: none;
        }
        .custom-accordion summary::after {
          content: "+";
          position: absolute;
          right: 20px;
          top: 50%;
          transform: translateY(-50%);
          font-size: 18px;
          font-weight: bold;
          color: #666;
        }
        .custom-accordion details[open] summary::after {
          content: "−";
        }
        .custom-accordion summary:hover {
          background-color: #ebebeb;
        }
        .custom-accordion .content {
          padding: 20px;
          background-color: white;
          border-top: 1px solid #ddd;
        }
        tr td.test_status {
             color: blue !important;
         }
         tr.rowClass-passed td.test_status {
             color: green !important;
         }
          tr.rowClass-failed td.test_status {
             color: red !important;
         }
         tr.rowClass-TODO td.test_status {
             color: orange !important;
         }
      </style>' AS html;

    -- Accordion container
    SELECT 'html' AS component,
      '<div class="custom-accordion">' AS html;

    -- Group Details Section (open by default)
    SELECT 'html' AS component,
      '<details open>
        <summary>Group Details</summary>
        <div class="content">' AS html;

    SELECT 'card'  AS component,
    1                          as columns;
    SELECT
    '**Group ID:** ' || rn.id ||
    '\n\n**Name:** ' || rn."name" ||
    '\n\n**Description:** ' || COALESCE(rn."description", 'No description available') ||
    '\n\n**Created By:** ' || COALESCE(rn."created_by", 'Unknown') ||
    '\n\n**Created On:** ' || strftime('%d-%m-%Y', rn."created_at") ||
    CASE
      WHEN rn.body IS NOT NULL AND rn.body != ''
      THEN '\n\n**Additional Details:**\n' || rn.body
      ELSE ''
    END AS description_md
FROM groups rn
INNER JOIN test_suites st ON st.id = rn.suite_id
WHERE rn.id = $id;

    SELECT 'html' AS component,
      '</div></details>' AS html;

    -- Test Cases Section (closed by default)
    SELECT 'html' AS component,
      '<details>
        <summary>Test Cases (' || COUNT(*) || ')</summary>
        <div class="content">' AS html
    FROM test_cases WHERE group_id = $id;

    SELECT 'text' AS component,
      'This section displays all test cases associated with this group, including their current status and execution details.' AS contents;

    -- Show test case count for this group
    SELECT 'alert' AS component,
           'info' AS color,
           'Test Cases Summary' AS title,
           'Total: ' || COUNT(*) ||
           ' | Passed: ' || SUM(CASE WHEN test_status = 'passed' THEN 1 ELSE 0 END) ||
           ' | Failed: ' || SUM(CASE WHEN test_status = 'failed' THEN 1 ELSE 0 END) ||
           ' | Pending: ' || SUM(CASE WHEN test_status IS NULL OR test_status = 'TODO' THEN 1 ELSE 0 END) AS description
    FROM test_cases WHERE group_id = $id;

    SELECT 'table' as component,
           TRUE AS sort,
           TRUE AS search,
           'Test Case ID' as markdown,
           'Title' as markdown,
           'Status' as markdown;

    SELECT
      '[' || tc.test_case_id || '](' || ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=actual-result&id=")
      }|| tc.test_case_id || ')' as "Test Case ID",
      tc.test_case_title AS "Title",
      CASE
        WHEN tc.test_status IS NOT NULL THEN tc.test_status
        ELSE 'TODO'
      END AS "Status",
      'rowClass-' || COALESCE(tc.test_status, 'TODO') as _sqlpage_css_class,
      tc.test_type AS "Type",
      tc.priority AS "Priority",
      tc.created_by AS "Created By",
      tc.formatted_test_case_created_at AS "Created On"
    FROM test_cases tc
    WHERE tc.group_id = $id
    ORDER BY tc.test_case_id;

    SELECT 'html' AS component,
      '</div></details>' AS html;

    -- Close accordion container
    SELECT 'html' AS component,
      '</div>' AS html;

    `;
  }



  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/plan-overview.sql"() {
    return this.SQL`
    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link;
    select
    'Plan List' as title,
      ${this.absoluteURL("/qualityfolio/test-plan.sql")} as link;

    select
    "name" as title from test_plan where id = $id;
              

          SELECT 'title'AS component,
      name as contents FROM groups where id = $id; 

          SELECT 'card'  AS component,
      1 as columns;
    SELECT
    ' **Id**  :  ' || id AS description_md,
      '\n **name**  :  ' || "name" AS description_md,
        '\n **Description**  :  ' || "description" AS description_md,
          '\n **Created By**  :  ' || "created_by" AS description_md,
            '\n **Created On**  :  ' || strftime('%d-%m-%Y', "created_at") AS description_md,
              '\n' || body AS description_md
      FROM test_plan 
      WHERE id = $id;
    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/test-cases-list.sql"() {
    return this.SQL`
    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link;
    select
    'Plan List' as title,
      ${this.absoluteURL("/qualityfolio/test-plan.sql")} as link;
    select
    "name" as title from test_plan where id = $id;
    SELECT 'list'  AS component,
      name as title FROM test_plan
    WHERE  id = $id;
    SELECT
    'A structured summary of a specific test scenario, detailing its purpose, preconditions, test data, steps, and expected results. The description ensures clarity on the tests objective, enabling accurate validation of functionality or compliance. It aligns with defined requirements, identifies edge cases, and facilitates efficient defect detection during execution.
    ' as description;

 SELECT 'html' as component,
      '<style>
     tr td.test_status {
      color: blue!important; /* Default to blue */
    }
    tr.rowClass - passed td.test_status {
      color: green!important; /* Default to blue */
    }
    tr.rowClass - failed td.test_status {
      color: red!important; /* Default to blue */
    }
        .btn - list {
      display: flex;
      justify - content: flex - end;
    }
    </style>

    ' as html;

    SELECT 'table' as component,
      TRUE AS sort,
        --TRUE AS search,
          'URL' AS align_left,
            'title' AS align_left,
              'group' as markdown,
              'id' as markdown,
              'count' as markdown;
    SELECT
    '[' || t.test_case_id || '](' || ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=actual-result&id=")
      }|| t.test_case_id || ')' as id,
      t.title,
       case when t.test_status is not null then t.test_status
        else 'TODO' END AS "test_status",
      t.created_by as "Created By",
      strftime('%d-%m-%Y', t.created_at) as "Created On",
      t.priority,
      'rowClass-' || p.status as _sqlpage_css_class
    FROM test_cases t
    inner join groups g on t.group_id = g.id
    left join test_case_run_results p on p.test_case_id = t.test_case_id
    WHERE  g.plan_id like '%' || $id || '%'

      `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "qualityfolio/jsonviewer.sql"() {
    return this.SQL`
   select "dynamic" as component, sqlpage.run_sql('qualityfolio/progress-bar.sql') as properties;
    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qualityfolio/test-cases-full-list.sql"() {
    const viewName = `test_cases`;
    const pagination = this.pagination({
      tableOrViewName: viewName,
    });
    return this.SQL`
    select
    'breadcrumb' as component;
    select
    'Home' as title,
      ${this.absoluteURL("/")} as link;
    select
    'Test Management System' as title,
      ${this.absoluteURL("/qualityfolio/index.sql")} as link;
    select
    'Test Cases' as title;  
    

   SELECT 'html' as component,
      '<style>
       tr td.State {
      color: blue!important; /* Default to blue */
    }
    tr.rowClass - passed td.State {
      color: green!important; /* Default to red */
    }
    tr.rowClass - failed td.State {
      color: red!important; /* Default to red */
    }

        tr td.Statealign - middle {
      color: blue!important; /* Default to blue */
    }
    tr.rowClass - passed td.Statealign - middle {
      color: green!important; /* Default to red */
    }
    tr.rowClass - failed td.Statealign - middle {
      color: red!important; /* Default to red */
    }

        
        .btn - list {
      display: flex;
      justify - content: flex - end;
    }
    </style>

    ' as html;
    select
    'button' as component;
    select
    'Generate Report' as title,
      'download-full_list.sql' as link;
   ${pagination.init()}
    SELECT 'table' as component,
      TRUE AS sort,
        TRUE AS search,
          'URL' AS align_left,
            'title' AS align_left,
              'group' as markdown,
              'id' as markdown,
              "status_new" as markdown,
              'count' as markdown;
    SELECT
    '[' || test_case_id || '](' || ${this.absoluteURL("/qualityfolio/test-detail.sql?tab=actual-result&id=")
      }|| test_case_id || ')' as id,
      test_case_title AS "title",
        group_name AS "group",
        case when test_status is not null then test_status
        else 'TODO' END AS "State",
      'rowClass-' || test_status as _sqlpage_css_class,
      created_by as "Created By",
      formatted_test_case_created_at as "Created On",
      priority as "Priority"
    FROM ${viewName} t
     LIMIT $limit
      OFFSET $offset;
      ${pagination.renderSimpleMarkdown()};

    `;
  }
  @spn.shell({
    breadcrumbsFromNavStmts: "no",
    shellStmts: "do-not-include",
    pageTitleFromNavStmts: "no",
  })
  "sqlpage/templates/shell-custom.handlebars"() {
    return this.SQL`< !DOCTYPE html >
      <html lang="{{language}}" style = "font-size: {{default font_size 18}}px" { { #if class} } class="{{class}}" { {/if } }>
        <head>
        <meta charset="utf-8" />

          <!--Base CSS-- >
            <link rel="stylesheet" href = "{{static_path 'sqlpage.css'}}" >
              {{ #each(to_array css) }
  }
              { { #if this } }
<link rel="stylesheet" href = "{{this}}" >
  {{/if }}
{ {/each } }

<!--Font Setup-- >
  {{ #if font }}
{ { #if(starts_with font "/") } }
<style>
  @font - face {
  font - family: 'LocalFont';
  src: url('{{font}}') format('woff2');
  font - weight: normal;
  font - style: normal;
}
                      :root {
  --tblr - font - sans - serif: 'LocalFont', Arial, sans - serif;
}
</style>
{ {else } }
<link rel="preconnect" href = "https://fonts.googleapis.com" >
  <link rel="preconnect" href = "https://fonts.gstatic.com" crossorigin >
    <link rel="stylesheet" href = "https://fonts.googleapis.com/css2?family={{font}}&display=fallback" >
      <style>
                      :root {
  --tblr - font - sans - serif: '{{font}}', Arial, sans - serif;
}
</style>
{ {/if } }
{ {/if } }

<!--JavaScript -->
  <script src="{{static_path 'sqlpage.js'}}" defer nonce = "{{@csp_nonce}}" > </script>
{ { #each(to_array javascript) } }
{ { #if this } }
<script src="{{this}}" defer nonce = "{{@../csp_nonce}}" > </script>
{ {/if } }
{ {/each } }
{ { #each(to_array javascript_module) } }
{ { #if this } }
<script src="{{this}}" type = "module" defer nonce = "{{@../csp_nonce}}" > </script>
{ {/if } }
{ {/each } }
</head>

  < body class="layout-{{#if sidebar}}fluid{{else}}{{default layout 'boxed'}}{{/if}}" { { #if theme } } data - bs - theme="{{theme}}" { {/if } }>
    <div class="page" >
      <!--Header -->


        <!--Page Wrapper-- >
          <div class="page-wrapper" >
            <main class="page-body w-full flex-grow-1 px-0" id = "sqlpage_main_wrapper" >
              {{ ~#each_row~}}{ { ~/each_row~ } }
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
      async statefulqltyfolioSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
      async statelessqltyfolioSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new QualityfolioSqlPages(),
    new c.ConsoleSqlPages(),
    new d.DocsSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new sh.ShellSqlPages(WEB_UI_TITLE, WE_UI_LOGO, WE_UI_FAV_ICON, HIDE_HEADER_TITLE),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
