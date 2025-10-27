#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
import * as sppn from "../..//std/notebook/sqlpage.ts";

// custom decorator that makes navigation for this notebook type-safe
function drhNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "drh/index.sql",
  });
}

export class DrhShellSqlPages extends sh.ShellSqlPages {
  defaultShell() {
    return {
      component: "shell",
      title: "Diabetes Research Hub Edge",
      icon: "",
      favicon: "https://drh.diabetestechnology.org/_astro/favicon.CcrFY5y9.ico",
      image:
        "https://drh.diabetestechnology.org/images/diabetic-research-hub-logo.png",
      layout: "fluid",
      fixed_top_menu: true,
      link: "/",
      menu_item: [
        { link: "/", title: "Home" },
      ],
      javascript: [
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
        "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js",
        // "https://app.devl.drh.diabetestechnology.org/js/d3-aide.js",
        "/static/d3-aide.js",
        "/js/chart-component.js",
      ],
      // javascript_module: [
      //   "https://app.devl.drh.diabetestechnology.org/js/wc/d3/stacked-bar-chart.js",
      //   "https://app.devl.drh.diabetestechnology.org/js/wc/d3/gri-chart.js",
      //   "https://app.devl.drh.diabetestechnology.org/js/wc/d3/dgp-chart.js",
      //   "https://app.devl.drh.diabetestechnology.org/js/wc/d3/agp-chart.js",
      //   "https://app.devl.drh.diabetestechnology.org/js/wc/formula-component.js",
      // ]
      javascript_module: [
        "/static/stacked-bar-chart.js",
        "/static/gri-chart.js",
        "/static/dgp-chart.js",
        "/static/agp-chart.js",
        "/static/formula-component.js",
      ],
      footer: `Resource Surveillance Web UI`,
    };
  }

  @sppn.shell({ eliminate: true })
  "shell/shell.json"() {
    return this.SQL`
      ${JSON.stringify(this.defaultShell(), undefined, "  ")}
    `;
  }

  @sppn.shell({ eliminate: true })
  "shell/shell.sql"() {
    const literal = (value: unknown) =>
      typeof value === "number"
        ? value
        : value
        ? this.emitCtx.sqlTextEmitOptions.quotedLiteral(value)[1]
        : "NULL";
    const selectNavMenuItems = (
      rootPath: string,
      caption: string,
      target: string = "",
    ) =>
      `json_object(
            'link', ${this.absoluteURL("")}||'${rootPath}',
            'title', ${literal(caption)},      
            'target', '${target}',      
            'submenu', (
                SELECT json_group_array(
                    json_object(
                        'title', title,
                        'link', ${this.absoluteURL("/")}||link,
                        'description', description,
                        'target', target                      
                    )
                )
                FROM (
                    SELECT
                        COALESCE(abbreviated_caption, caption) as title,
                        COALESCE(url, path) as link,
                        description,
                        elaboration as target
                    FROM sqlpage_aide_navigation
                    WHERE namespace = 'prime' AND parent_path = '${rootPath}/index.sql'
                    ORDER BY sibling_order
                )
            )
        ) as menu_item`;

    const handlers = {
      DEFAULT: (key: string, value: unknown) => `${literal(value)} AS ${key}`,
      menu_item: (key: string, items: Record<string, unknown>[]) =>
        items.map((item) => `${literal(JSON.stringify(item))} AS ${key}`),
      javascript_module: (key: string, javascript_module: string[]) => {
        const items = javascript_module.map((s) => `${literal(s)} AS ${key}`);
        return items;
      },
      javascript: (key: string, scripts: string[]) => {
        const items = scripts.map((s) => `${literal(s)} AS ${key}`);
        // items.push(
        //   selectNavMenuItems("drh/study/", "Study"),
        // );
        //items.push(selectNavMenuItems("/docs/index.sql", "Docs"));
        items.push(selectNavMenuItems("ur", "Uniform Resource"));
        items.push(selectNavMenuItems("console", "Console"));
        items.push(
          selectNavMenuItems("orchestration", "Orchestration"),
        );
        items.push(
          selectNavMenuItems(
            "https://drh.diabetestechnology.org/",
            "DRH Home",
            "__blank",
          ),
        );
        items.push(
          selectNavMenuItems(
            "https://www.diabetestechnology.org/",
            "DTS Home",
            "__blank",
          ),
        );
        return items;
      },
      footer: () =>
        // TODO: add "open in IDE" feature like in other Shahid apps
        literal(`Resource Surveillance Web UI (v`) +
        ` || sqlpage.version() || ') ' || ` +
        `'📄 [' || substr(sqlpage.path(), 2) || '](' || ${
          this.absoluteURL("/console/sqlpage-files/sqlpage-file.sql?path=")
        } || substr(sqlpage.path(), 2) || ')' as footer`,
    };
    const shell = this.defaultShell();
    const sqlSelectExpr = Object.entries(shell).flatMap(([k, v]) => {
      switch (k) {
        case "menu_item":
          return handlers.menu_item(
            k,
            v as Record<string, unknown>[],
          );
        case "javascript":
          return handlers.javascript(k, v as string[]);
        case "javascript_module":
          return handlers.javascript_module(k, v as string[]);
        case "footer":
          return handlers.footer();
        default:
          return handlers.DEFAULT(k, v);
      }
    });
    return this.SQL`
    SELECT ${sqlSelectExpr.join(",\n       ")};
  `;
  }
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class DRHSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
    -- delete all /drh-related entries and recreate them in case routes are changed
    DELETE FROM sqlpage_aide_navigation WHERE parent_path="drh/index.sql";
    ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
  `;
  }

  // //use this only for combined view sql generation
  // //based on the ingested dataset the function call must be handled
  // combinedViewDDL() {
  //   const dbFilePath = "./resource-surveillance.sqlite.db";
  //   //const sqlStatements= createUVACombinedCGMViewSQL(dbFilePath);
  //   const sqlStatements = generateDetrendedDSCombinedCGMViewSQL(dbFilePath);
  //   return this.SQL`
  //       ${sqlStatements}
  //   `;
  // }

  @spn.navigationPrimeTopLevel({
    caption: "DRH Edge UI Home",
    description: "Welcome to Diabetes Research Hub Edge UI",
  })
  "drh/index.sql"() {
    return this.SQL`
            SELECT
                  'card'                      as component,
                  'Welcome to the Diabetes Research Hub Edge UI' as title,
                  1                           as columns;

            SELECT
                  'About' as title,
                  'green'                        as color,
                  'white'                  as background_color,
                  'The Diabetes Research Hub (DRH) addresses a growing need for a centralized platform to manage and analyze continuous glucose monitor (CGM) data.Our primary focus is to collect data from studies conducted by various researchers. Initially, we are concentrating on gathering CGM data, with plans to collect additional types of data in the future.' as description,
                  'home'                 as icon;

            SELECT
                  'card'                  as component,
                  'Files Log' as title,
                  1                     as columns;


            SELECT
                'Study Files Log'  as title,
                ${this.absoluteURL("/drh/ingestion-log/index.sql")} as link,
                'This section provides an overview of the files that have been accepted and converted into database format for research purposes' as description,
                'book'                as icon,
                'red'                    as color;

            ;

            SELECT
                  'card'                  as component,
                  'File Verification Results' as title,
                  1                     as columns;

            SELECT
                'Verification Log' AS title,
                ${
      this.absoluteURL("/drh/verification-validation-log/index.sql")
    } AS link,
                'Use this section to review the issues identified in the file content and take appropriate corrective actions.' AS description,
                'table' AS icon,
                'red' AS color;



            SELECT
                  'card'                  as component,
                  'Features ' as title,
                  9                     as columns;


            SELECT
                'Study Participant Dashboard'  as title,
                ${
      this.absoluteURL("/drh/study-participant-dashboard/index.sql")
    } as link,
                'The dashboard presents key study details and participant-specific metrics in a clear, organized table format' as description,
                'table'                as icon,
                'red'                    as color;
            ;




            SELECT
                'Researcher and Associated Information'  as title,
                ${
      this.absoluteURL("/drh/researcher-related-data/index.sql")
    } as link,
                'This section provides detailed information about the individuals , institutions and labs involved in the research study.' as description,
                'book'                as icon,
                'red'                    as color;
            ;

            SELECT
                'Study ResearchSite Details'  as title,
                ${
      this.absoluteURL("/drh/study-related-data/index.sql")
    } as link,
                'This section provides detailed information about the study , and sites involved in the research study.' as description,
                'book'                as icon,
                'red'                    as color;
            ;

            SELECT
                'Participant Demographics'  as title,
                ${
      this.absoluteURL("/drh/participant-related-data/index.sql")
    } as link,
                'This section provides detailed information about the the participants involved in the research study.' as description,
                'book'                as icon,
                'red'                    as color;
            ;

            SELECT
                'Author and Publication Details'  as title,
                ${this.absoluteURL("/drh/author-pub-data/index.sql")} as link,
                'Information about research publications and the authors involved in the studies are also collected, contributing to the broader understanding and dissemination of research findings.' as description,
                 'book' AS icon,
                'red'                    as color;
            ;



            SELECT
                'CGM Meta Data and Associated information'  as title,
                ${
      this.absoluteURL("/drh/cgm-associated-data/index.sql")
    } as link,
                'This section provides detailed information about the CGM device used, the relationship between the participant''s raw CGM tracing file and related metadata, and other pertinent information.' as description,
                'book'                as icon,
                'red'                    as color;

            ;


            SELECT
                'Raw CGM Data Description' AS title,
                ${this.absoluteURL("/drh/cgm-data/index.sql")} AS link,
                'Explore detailed information about glucose levels over time, including timestamp, and glucose value.' AS description,
                'book'                as icon,
                'red'                    as color;                

            SELECT
                'Combined CGM Tracing' AS title,
                ${this.absoluteURL("/drh/cgm-combined-data/index.sql")} AS link,
                'Explore the comprehensive CGM dataset, integrating glucose monitoring data from all participants for in-depth analysis of glycemic patterns and trends across the study.' AS description,
                'book'                as icon,
                'red'                    as color;         
            

            SELECT
                'PHI De-Identification Results' AS title,
                ${
      this.absoluteURL("/drh/deidentification-log/index.sql")
    } AS link,
                'Explore the results of PHI de-identification and review which columns have been modified.' AS description,
                'book'                as icon,
                'red'                    as color;
            ;




     `;
  }

  @drhNav({
    caption: "Researcher And Associated Information",
    abbreviatedCaption: "Researcher And Associated Information",
    description: "Researcher And Associated Information",
    siblingOrder: 4,
  })
  "drh/researcher-related-data/index.sql"() {
    return this.SQL`
     ${this.activePageTitle()}

    SELECT
      'text' as component,
      'The Diabetes Research Hub collaborates with a diverse group of researchers or investigators dedicated to advancing diabetes research. This section provides detailed information about the individuals and institutions involved in the research studies.' as contents;


    SELECT
      'text' as component,
      'Researcher / Investigator ' as title;
    SELECT
      'These are scientific professionals and medical experts who design and conduct studies related to diabetes management and treatment. Their expertise ranges from clinical research to data analysis, and they are crucial in interpreting results and guiding future research directions.Principal investigators lead the research projects, overseeing the study design, implementation, and data collection. They ensure the research adheres to ethical standards and provides valuable insights into diabetes management.' as contents;
    SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
    SELECT * from drh_investigator;

    SELECT
      'text' as component,
      'Institution' as title;
    SELECT
      'The researchers and investigators are associated with various institutions, including universities, research institutes, and hospitals. These institutions provide the necessary resources, facilities, and support for conducting high-quality research. Each institution brings its unique strengths and expertise to the collaborative research efforts.' as contents;
    SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
    SELECT * from drh_institution;


    SELECT
      'text' as component,
      'Lab' as title;
    SELECT
      'Within these institutions, specialized labs are equipped with state-of-the-art technology to conduct diabetes research. These labs focus on different aspects of diabetes studies, such as glucose monitoring, metabolic analysis, and data processing. They play a critical role in executing experiments, analyzing samples, and generating data that drive research conclusions.' as contents;
    SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
    SELECT * from drh_lab;



   `;
  }

  @drhNav({
    caption: "Study and Participant Information",
    abbreviatedCaption: "Study and Participant Information",
    description: "Study and Participant Information",
    siblingOrder: 5,
  })
  "drh/study/index.sql"() {
    const viewName = `drh_participant_data`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}
    SELECT
  'text' as component,
    '
    In Continuous Glucose Monitoring (CGM) research, studies are designed to evaluate the effectiveness, accuracy, and impact of CGM systems on diabetes management. Each study aims to gather comprehensive data on glucose levels, treatment efficacy, and patient outcomes to advance our understanding of diabetes care.

    ### Study Details

    - **Study ID**: A unique identifier assigned to each study.
    - **Study Name**: The name or title of the study.
    - **Start Date**: The date when the study begins.
    - **End Date**: The date when the study concludes.
    - **Treatment Modalities**: Different treatment methods or interventions used in the study.
    - **Funding Source**: The source(s) of financial support for the study.
    - **NCT Number**: ClinicalTrials.gov identifier for the study.
    - **Study Description**: A description of the study’s objectives, methodology, and scope.

    ' as contents_md;

    SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows,'study_id' as markdown;
    SELECT 
      format('[%s](/drh/study-participant-dashboard/index.sql?study_id=%s)',study_id, study_id) as study_id,      
      study_name,
      start_date,
      end_date,
      treatment_modalities,
      funding_source,
      nct_number,
      study_description  
    from drh_study;


      `;
  }

  @drhNav({
    caption: "Study and Participant Information",
    abbreviatedCaption: "Study and Participant Information",
    description: "Study and Participant Information",
    siblingOrder: 5,
  })
  "drh/study-related-data/index.sql"() {
    const viewName = `drh_participant`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}
    SELECT
  'text' as component,
  '
  In Continuous Glucose Monitoring (CGM) research, studies are designed to evaluate the effectiveness, accuracy, and impact of CGM systems on diabetes management. Each study aims to gather comprehensive data on glucose levels, treatment efficacy, and patient outcomes to advance our understanding of diabetes care.

  ### Study Details

  - **Study ID**: A unique identifier assigned to each study.
  - **Study Name**: The name or title of the study.
  - **Start Date**: The date when the study begins.
  - **End Date**: The date when the study concludes.
  - **Treatment Modalities**: Different treatment methods or interventions used in the study.
  - **Funding Source**: The source(s) of financial support for the study.
  - **NCT Number**: ClinicalTrials.gov identifier for the study.
  - **Study Description**: A description of the study’s objectives, methodology, and scope.

  ' as contents_md;

  SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT * from drh_study;


      SELECT
          'text' as component,
          '

## Site Information

Research sites are locations where the studies are conducted. They include clinical settings where participants are recruited, monitored, and data is collected.

### Site Details

  - **Study ID**: A unique identifier for the study associated with the site.
  - **Site ID**: A unique identifier for each research site.
  - **Site Name**: The name of the institution or facility where the research is carried out.
  - **Site Type**: The type or category of the site (e.g., hospital, clinic).

      ' as contents_md;

      SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
      SELECT * from drh_site;



      `;
  }

  @drhNav({
    caption: "Uniform Resource Participant",
    description: "Participant demographics with pagination",
    siblingOrder: 6,
  })
  "drh/uniform-resource-participant.sql"() {
    const viewName = `drh_participant`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
    ${this.activePageTitle()}


    ${pagination.init()}

    -- Display uniform_resource table with pagination
    SELECT 'table' AS component,
          TRUE AS sort,
          TRUE AS search;
    SELECT * FROM ${viewName}
     LIMIT $limit
    OFFSET $offset;

    ${pagination.renderSimpleMarkdown()}
  `;
  }

  @drhNav({
    caption: "Author Publication Information",
    abbreviatedCaption: "Author Publication Information",
    description: "Author Publication Information",
    siblingOrder: 7,
  })
  "drh/author-pub-data/index.sql"() {
    return this.SQL`
  ${this.activePageTitle()}

  SELECT
  'text' as component,
  '

## Authors

This section contains information about the authors involved in study publications. Each author plays a crucial role in contributing to the research, and their details are important for recognizing their contributions.

### Author Details

- **Author ID**: A unique identifier for the author.
- **Name**: The full name of the author.
- **Email**: The email address of the author.
- **Investigator ID**: A unique identifier for the investigator the author is associated with.
- **Study ID**: A unique identifier for the study associated with the author.


      ' as contents_md;

  SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT * from drh_author;
  SELECT
  'text' as component,
  '
## Publications Overview

This section provides information about the publications resulting from a study. Publications are essential for sharing research findings with the broader scientific community.

### Publication Details

- **Publication ID**: A unique identifier for the publication.
- **Publication Title**: The title of the publication.
- **Digital Object Identifier (DOI)**: Identifier for the digital object associated with the publication.
- **Publication Site**: The site or journal where the publication was released.
- **Study ID**: A unique identifier for the study associated with the publication.


  ' as contents_md;

  SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT * from drh_publication;


      `;
  }

  @drhNav({
    caption: "PHI DeIdentification Results",
    abbreviatedCaption: "PHI DeIdentification Results",
    description: "PHI DeIdentification Results",
    siblingOrder: 8,
  })
  "drh/deidentification-log/index.sql"() {
    return this.SQL`
  ${this.activePageTitle()}

  /*
  SELECT
  'breadcrumb' as component;
  SELECT
      'Home' as title,
      'index.sql'    as link;
  SELECT
      'DeIdentificationResults' as title;
      */

  SELECT
    'text' as component,
    'DeIdentification Results' as title;
   SELECT
    'The DeIdentification Results section provides a view of the outcomes from the de-identification process ' as contents;


  SELECT 'table' as component, 1 as search, 1 as sort, 1 as hover, 1 as striped_rows;
  SELECT input_text as "deidentified column", orch_started_at,orch_finished_at ,diagnostics_md from drh_vw_orchestration_deidentify;
  `;
  }

  @drhNav({
    caption: "Combined CGM Tracing",
    abbreviatedCaption: "Combined CGM Tracing",
    description: "Combined CGM Tracing",
    siblingOrder: 21,
  })
  "drh/cgm-combined-data/index.sql"() {
    const viewName = `combined_cgm_tracing`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}


    SELECT
'text' as component,
'

The **Combined CGM Tracing** refers to a consolidated dataset of continuous glucose monitoring (CGM) data, collected from multiple participants in a research study. CGM devices track glucose levels at regular intervals throughout the day, providing detailed insights into the participants'' glycemic control over time.

In a research study, this combined dataset is crucial for analyzing glucose trends across different participants and understanding overall patterns in response to interventions or treatments. The **Combined CGM Tracing** dataset typically includes:
- **Participant ID**: A unique identifier for each participant, ensuring the data is de-identified while allowing for tracking individual responses.
- **Date_Time**: The timestamp for each CGM reading, formatted uniformly to allow accurate time-based analysis.(YYYY-MM-DD HH:MM:SS)
- **CGM_Value**: The recorded glucose level at each time point, often converted to a standard unit (e.g., mg/dL or mmol/L) and stored as a real number for precise calculations.

This combined view enables researchers to perform comparative analyses, evaluate glycemic variability, and assess overall glycemic control across participants, which is essential for understanding the efficacy of treatments or interventions in the study. By aggregating data from multiple sources, researchers can identify population-level trends while maintaining the integrity of individual data. 

' as contents_md;

${pagination.init()}

-- Display uniform_resource table with pagination
SELECT 'table' AS component,
    TRUE AS sort,
    TRUE AS search;
SELECT * FROM ${viewName} 
LIMIT $limit
OFFSET $offset;

${pagination.renderSimpleMarkdown()}

      `;
  }

  @drhNav({
    caption: "CGM File MetaData Information",
    abbreviatedCaption: "CGM File MetaData Information",
    description: "CGM File MetaData Information",
    siblingOrder: 9,
  })
  "drh/cgm-associated-data/index.sql"() {
    const viewName = `drh_cgmfilemetadata_view`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}

      /*SELECT
  'breadcrumb' as component;
  SELECT
      'Home' as title,
      'index.sql'    as link;
  SELECT
      'CGM File Meta Data' as title;
      */



    SELECT
'text' as component,
'

CGM file metadata provides essential information about the Continuous Glucose Monitoring (CGM) data files used in research studies. This metadata is crucial for understanding the context and quality of the data collected.

### Metadata Details

- **Metadata ID**: A unique identifier for the metadata record.
- **Device Name**: The name of the CGM device used to collect the data.
- **Device ID**: A unique identifier for the CGM device.
- **Source Platform**: The platform or system from which the CGM data originated.
- **Patient ID**: A unique identifier for the patient from whom the data was collected.
- **File Name**: The name of the uploaded CGM data file.
- **File Format**: The format of the uploaded file (e.g., CSV, Excel).
- **File Upload Date**: The date when the file was uploaded to the system.
- **Data Start Date**: The start date of the data period covered by the file.
- **Data End Date**: The end date of the data period covered by the file.
- **Study ID**: A unique identifier for the study associated with the CGM data.


' as contents_md;

${pagination.init()}

-- Display uniform_resource table with pagination
SELECT 'table' AS component,
    TRUE AS sort,
    TRUE AS search;
SELECT * FROM ${viewName}
LIMIT $limit
OFFSET $offset;

${pagination.renderSimpleMarkdown()}

      `;
  }

  @drhNav({
    caption: "Raw CGM Data",
    abbreviatedCaption: "Raw CGM Data",
    description: "Raw CGM Data",
    siblingOrder: 10,
  })
  "drh/cgm-data/index.sql"() {
    return this.SQL`
  ${this.activePageTitle()}

  SELECT
  'text' as component,
  '
  The raw CGM data includes the following key elements.

  - **Date_Time**:
  The exact date and time when the glucose level was recorded. This is crucial for tracking glucose trends and patterns over time. The timestamp is usually formatted as YYYY-MM-DD HH:MM:SS.
  - **CGM_Value**:
  The measured glucose level at the given timestamp. This value is typically recorded in milligrams per deciliter (mg/dL) or millimoles per liter (mmol/L) and provides insight into the participant''s glucose fluctuations throughout the day.' as contents_md;

  SELECT 'table' AS component,
          'Table' AS markdown,
          'Column Count' as align_right,
          TRUE as sort,
          TRUE as search;
  SELECT '[' || table_name || '](raw-cgm/' || table_name || '.sql)' AS "Table"
  FROM drh_raw_cgm_table_lst;
  `;
  }
  // no @drhNav since this is a "utility" page (not navigable)
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "drh/cgm-data/data.sql"() {
    // Assume $name is passed as a request parameter
    const viewName = `$name`;
    const pagination = this.pagination({ tableOrViewName: viewName });

    return this.SQL`
  ${this.activeBreadcrumbsSQL({ titleExpr: `$name || ' Table'` })}


  SELECT 'title' AS component, $name AS contents;

  -- Initialize pagination
  ${pagination.init()}

  -- Display table with pagination
  SELECT 'table' AS component,
        TRUE AS sort,
        TRUE AS search;
  SELECT * FROM ${viewName}
  LIMIT $limit
  OFFSET $offset;

  ${pagination.renderSimpleMarkdown()}
`;
  }

  @drhNav({
    caption: "Study Files",
    abbreviatedCaption: "Study Files",
    description: "Study Files",
    siblingOrder: 11,
  })
  "drh/ingestion-log/index.sql"() {
    const viewName = `drh_study_files_table_info`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}

  SELECT
    'text' as component,
    'Study Files' as title;
   SELECT
    '
    This section provides an overview of the files that have been accepted and converted into database format for research purposes. The conversion process ensures that data from various sources is standardized, making it easier for researchers to analyze and draw meaningful insights.
    Additionally, the corresponding database table names generated from these files are listed for reference.' as contents;

   ${pagination.init()}

    SELECT 'table' AS component,
    TRUE AS sort,
    TRUE AS search;
    SELECT file_name,file_format, table_name FROM ${viewName}
    LIMIT $limit
    OFFSET $offset;

    ${pagination.renderSimpleMarkdown()}
  `;
  }

  @drhNav({
    caption: "Participant Information",
    abbreviatedCaption: "Participant Information",
    description:
      "The Participants Detail page is a comprehensive report that includes glucose statistics, such as the Ambulatory Glucose Profile (AGP), Glycemia Risk Index (GRI), Daily Glucose Profile, and all other metrics data.",
    siblingOrder: 20,
  })
  "drh/participant-info/index.sql"() {
    return this.SQL`
  ${this.activePageTitle()}

    SELECT
     'card'     as component,
     '' as title,
      1         as columns;
    SELECT 
     'The Participants Detail page is a comprehensive report that includes glucose statistics, such as the Ambulatory Glucose Profile (AGP), Glycemia Risk Index (GRI), Daily Glucose Profile, and all other metrics data.' as description;
  
     

    SELECT 
        'form'            as component,
        'Filter by Date Range'   as title,
        'Submit' as validate,    
        'Clear'           as reset;
    SELECT 
        'start_date' as name,
        'Start Date' as label,
         strftime('%Y-%m-%d', MIN(Date_Time))  as value, 
        'date'       as type,
        6            as width,
        'mt-1' as class
    FROM     
        combined_cgm_tracing        
    WHERE 
        participant_id = $participant_id;  
    SELECT 
        'end_date' as name,
        'End Date' as label,
         strftime('%Y-%m-%d', MAX(Date_Time))  as value, 
        'date'       as type,
         6             as width,
         'mt-1' as class
    FROM     
        combined_cgm_tracing        
    WHERE 
        participant_id = $participant_id; 



  SELECT
    'datagrid' AS component;
  SELECT
      'MRN: ' || participant_id || '' AS title,
      ' ' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      'Study: ' || study_arm || '' AS title,
      ' ' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  
  SELECT
      'Age: '|| age || ' Years' AS title,
      ' ' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      'hba1c: ' || baseline_hba1c || '' AS title,
      ' ' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      'BMI: '|| bmi || '' AS title,
      ' ' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      'Diabetes Type: '|| diabetes_type || ''  AS title,
      ' ' AS description
  FROM
      drh_participant
  WHERE participant_id = $participant_id;

  SELECT
      strftime('Generated: %Y-%m-%d %H:%M:%S', 'now') AS title,
      ' ' AS description
 
  SELECT    
    'html' as component,
      '<input type="hidden" name="participant_id" class="participant_id" value="'|| $participant_id ||'">' as html;      
      
    SELECT 
    'card' as component,    
    2      as columns;
SELECT 
    '' AS title,
    'white' As background_color,
    ${
      this.absoluteURL(
        "/drh/glucose-statistics-and-targets/index.sql?_sqlpage_embed&participant_id=",
      )
    } || $participant_id ||
    '&start_date=' || COALESCE($start_date, participant_cgm_dates.cgm_start_date) ||
    '&end_date=' || COALESCE($end_date, participant_cgm_dates.cgm_end_date) AS embed
FROM 
    (SELECT participant_id, 
            MIN(Date_Time) AS cgm_start_date, 
            MAX(Date_Time) AS cgm_end_date
     FROM combined_cgm_tracing
     GROUP BY participant_id) AS participant_cgm_dates
WHERE 
    participant_cgm_dates.participant_id = $participant_id;  

         
SELECT 
    '' as title,
    'white' As background_color,
    ${
      this.absoluteURL(
        "/drh/goals-for-type-1-and-type-2-diabetes/index.sql?_sqlpage_embed&participant_id=",
      )
    } || $participant_id ||
    '&start_date=' || COALESCE($start_date, participant_cgm_dates.cgm_start_date) ||
    '&end_date=' || COALESCE($end_date, participant_cgm_dates.cgm_end_date) AS embed
FROM 
    (SELECT participant_id, 
            MIN(Date_Time) AS cgm_start_date, 
            MAX(Date_Time) AS cgm_end_date
     FROM combined_cgm_tracing
     GROUP BY participant_id) AS participant_cgm_dates
WHERE 
    participant_cgm_dates.participant_id = $participant_id;  

SELECT 
    '' as title,
    'white' As background_color,
    ${
      this.absoluteURL(
        "/drh/ambulatory-glucose-profile/index.sql?_sqlpage_embed&participant_id=",
      )
    } || $participant_id as embed;  
SELECT 
    '' as title,
    'white' As background_color,
    ${
      this.absoluteURL(
        "/drh/daily-gluecose-profile/index.sql?_sqlpage_embed&participant_id=",
      )
    } || $participant_id as embed;  
SELECT 
    '' as title,
    'white' As background_color,
    ${
      this.absoluteURL(
        "/drh/glycemic_risk_indicator/index.sql?_sqlpage_embed&participant_id=",
      )
    } || $participant_id as embed;  
  SELECT 
    '' as title,
    'white' As background_color,
    ${
      this.absoluteURL(
        "/drh/advanced_metrics/index.sql?_sqlpage_embed&participant_id=",
      )
    } || $participant_id  || 
    '&start_date=' || COALESCE($start_date, participant_cgm_dates.cgm_start_date) ||
    '&end_date=' || COALESCE($end_date, participant_cgm_dates.cgm_end_date) AS embed 
    FROM 
        (SELECT participant_id, 
                MIN(Date_Time) AS cgm_start_date, 
                MAX(Date_Time) AS cgm_end_date
        FROM combined_cgm_tracing
        GROUP BY participant_id) AS participant_cgm_dates
    WHERE 
        participant_cgm_dates.participant_id = $participant_id;  
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/glucose-statistics-and-targets/index.sql"() {
    const formulaTimeCgm =
      "This metric calculates the percentage of time during a specific period (e.g., a day, week, or month) that the CGM device is actively collecting data. It takes into account the total duration of the monitoring period and compares it to the duration during which the device was operational and recording glucose readings.";
    const formulaCgmWorn =
      "This metric represents the total number of days the CGM device was worn by the user over a monitoring period. It helps in assessing the adherence to wearing the device as prescribed.";
    const formulaMeanGlucose =
      "Mean glucose reflects the average glucose level over the monitoring period, serving as an indicator of overall glucose control. It is a simple yet powerful measure in glucose management.";
    const formulaGmi =
      "GMI provides an estimated A1C level based on mean glucose, which can be used as an indicator of long-term glucose control. GMI helps in setting and assessing long-term glucose goals.";
    const formulaGlucoseVariab =
      "Glucose variability measures fluctuations in glucose levels over time, calculated as the coefficient of variation (%CV). A lower %CV indicates more stable glucose control.";
    return this.SQL`    
     SELECT  
    'html' as component;
    SELECT '<div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black;">GLUCOSE STATISTICS AND TARGETS</div><div class="px-4">' as html;
    SELECT  
      '<div class="card-content my-1">'|| strftime('%Y-%m-%d', MIN(Date_Time)) || ' - ' ||  strftime('%Y-%m-%d', MAX(Date_Time)) || ' <span style="float: right;">'|| CAST(julianday(MAX(Date_Time)) - julianday(MIN(Date_Time)) AS INTEGER) ||' days</span></div>' as html
    FROM  
        combined_cgm_tracing
    WHERE 
        participant_id = $participant_id
     AND Date_Time BETWEEN $start_date AND $end_date;   

    SELECT  
      '<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Time CGM Active</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>' || ROUND(
        (COUNT(DISTINCT DATE(Date_Time)) / 
        ROUND((julianday(MAX(Date_Time)) - julianday(MIN(Date_Time)) + 1))
        ) * 100, 2) || '</b> % <formula-component content="${formulaTimeCgm}"></formula-component></div></div></div>' as html
    FROM
      combined_cgm_tracing  
    WHERE 
      participant_id = $participant_id
    AND Date_Time BETWEEN $start_date AND $end_date;    

    SELECT  
      '<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Number of Days CGM Worn</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>'|| COUNT(DISTINCT DATE(Date_Time)) ||'</b> days<formula-component content="${formulaCgmWorn}"></formula-component></div></div></div>' as html
    FROM
        combined_cgm_tracing  
    WHERE 
        participant_id = $participant_id
    AND Date_Time BETWEEN $start_date AND $end_date;

    SELECT  
      '<div class="card-body" style="background-color: #E3E3E2;border: 1px solid black;">
                      <div class="table-responsive">
                        <table class="table">                           
                           <tbody class="table-tbody list">
                           <tr>
                                <th colspan="2" style="text-align: center;">
                                  Ranges And Targets For Type 1 or Type 2 Diabetes
                                </th>
                              </tr>
                              <tr> 
                                <th>
                                  Glucose Ranges
                                </th>
                                <th>
                                  Targets % of Readings (Time/Day)
                                </th>
                              </tr>
                              <tr>
                                <td>Target Range 70-180 mg/dL</td>
                                <td>Greater than 70% (16h 48min)</td>
                              </tr>
                              <tr>
                                <td>Below 70 mg/dL</td>
                                <td>Less than 4% (58min)</td>
                              </tr>
                              <tr>
                                <td>Below 54 mg/dL</td>
                                <td>Less than 1% (14min)</td>
                              </tr>
                              <tr>
                                <td>Above 180 mg/dL</td>
                                <td>Less than 25% (6h)</td>
                              </tr>
                              <tr>
                                <td>Above 250 mg/dL</td>
                                <td>Less than 5% (1h 12min)</td>
                              </tr>
                              <tr>
                                <td colspan="2">Each 5% increase in time in range (70-180 mg/dL) is clinically beneficial.</td>                                
                              </tr>
                           </tbody>
                        </table>
                      </div>
                    </div>' as html; 

    SELECT  
      '<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Mean Glucose</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>'|| ROUND(AVG(CGM_Value), 2) ||'</b> mg/dL<formula-component content="${formulaMeanGlucose}"></formula-component></div></div></div>' as html
    FROM
      combined_cgm_tracing  
    WHERE 
      participant_id = $participant_id
    AND Date_Time BETWEEN $start_date AND $end_date;

    SELECT  
      '<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Glucose Management Indicator (GMI)</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>'|| ROUND(AVG(CGM_Value) * 0.155 + 95, 2) ||'</b> %<formula-component content="${formulaGmi}"></formula-component></div></div></div>' as html
    FROM
      combined_cgm_tracing  
    WHERE 
      participant_id = $participant_id
    AND Date_Time BETWEEN $start_date AND $end_date;
      
    SELECT  
      '<div class="card-content my-1" style="display: flex; flex-direction: row; justify-content: space-between;"><b>Glucose Variability</b> <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;"><b>'|| ROUND((SQRT(AVG(CGM_Value * CGM_Value) - AVG(CGM_Value) * AVG(CGM_Value)) / AVG(CGM_Value)) * 100, 2) ||'</b> %<formula-component content="${formulaGlucoseVariab}"></formula-component></div></div></div>' as html   
    FROM
      combined_cgm_tracing  
    WHERE 
      participant_id = $participant_id
    AND Date_Time BETWEEN $start_date AND $end_date;  
      
    SELECT  
      '<div class="card-content my-1">Defined as percent coefficient of variation (%CV); target ≤36%</div></div>' as html;                         
    
  `;
  }

  @spn.shell({ eliminate: true })
  async "js/chart-component.js"() {
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve("./d3-aide-component.js"),
    );
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/api/time_range_stacked_metrics/index.sql"() {
    return this.SQL`
    SELECT 'json' AS component, 
        JSON_OBJECT(
            'timeMetrics', (
                SELECT 
                    JSON_OBJECT(
                        'participant_id', participant_id, 
                        'timeBelowRangeLow', CAST(COALESCE(SUM(CASE WHEN CGM_Value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                        'timeBelowRangeVeryLow', CAST(COALESCE(SUM(CASE WHEN CGM_Value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                        'timeInRange', CAST(COALESCE(SUM(CASE WHEN CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                        'timeAboveRangeVeryHigh', CAST(COALESCE(SUM(CASE WHEN CGM_Value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER),                        
                        'timeAboveRangeHigh', CAST(COALESCE(SUM(CASE WHEN CGM_Value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS INTEGER) 
                    )
                FROM 
                    combined_cgm_tracing
                WHERE 
                    participant_id = $participant_id    
                AND Date_Time BETWEEN $start_date AND $end_date
            )
        ) AS contents;   
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/goals-for-type-1-and-type-2-diabetes/index.sql"() {
    const formula =
      `Goals for Type 1 and Type 2 Diabetes Chart provides a comprehensive view of a participant&#39;s glucose readings categorized into different ranges over a specified period.`;
    return this.SQL`
    SELECT 'html' as component,
    '<input type="hidden" name="start_date" class="start_date" value="'|| $start_date ||'">
    <input type="hidden" name="end_date" class="end_date" value="'|| $end_date ||'">
    <div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">Goals for Type 1 and Type 2 Diabetes <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="${formula}"></formula-component></div></div>
    <stacked-bar-chart class="p-5"></stacked-bar-chart>
    ' as html; 
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/api/ambulatory-glucose-profile/index.sql"() {
    return this.SQL`
    SELECT 'json' AS component, 
        JSON_OBJECT(
            'ambulatoryGlucoseProfile', (
                        WITH glucose_data AS (
              SELECT
                  participant_id,
                  strftime('%H', Date_Time) AS hourValue,
                  CGM_Value AS glucose_level
              FROM
                  combined_cgm_tracing
              WHERE
                  participant_id = $participant_id
              AND Date_Time BETWEEN $start_date AND $end_date
          ),
          percentiles AS (
              SELECT
                  participant_id,
                  hourValue AS hour,
                  MAX(CASE WHEN row_num = CAST(0.05 * total_count AS INT) THEN glucose_level END) AS p5,
                  MAX(CASE WHEN row_num = CAST(0.25 * total_count AS INT) THEN glucose_level END) AS p25,
                  MAX(CASE WHEN row_num = CAST(0.50 * total_count AS INT) THEN glucose_level END) AS p50,
                  MAX(CASE WHEN row_num = CAST(0.75 * total_count AS INT) THEN glucose_level END) AS p75,
                  MAX(CASE WHEN row_num = CAST(0.95 * total_count AS INT) THEN glucose_level END) AS p95
              FROM (
                  SELECT
                      participant_id,
                      hourValue,
                      glucose_level,
                      ROW_NUMBER() OVER (PARTITION BY participant_id, hourValue ORDER BY glucose_level) AS row_num,
                      COUNT(*) OVER (PARTITION BY participant_id, hourValue) AS total_count
                  FROM
                      glucose_data
              ) ranked_data
              GROUP BY
                  participant_id, hourValue
          )
          SELECT JSON_GROUP_ARRAY(
                    JSON_OBJECT(
                        'participant_id', participant_id,
                        'hour', hour,
                        'p5', COALESCE(p5, 0),
                        'p25', COALESCE(p25, 0),
                        'p50', COALESCE(p50, 0),
                        'p75', COALESCE(p75, 0),
                        'p95', COALESCE(p95, 0)
                    )
                ) AS result
          FROM
              percentiles
          GROUP BY
              participant_id
   

            )
        ) AS contents;
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/ambulatory-glucose-profile/index.sql"() {
    const formula =
      "The Ambulatory Glucose Profile (AGP) summarizes glucose monitoring data over a specified period, typically 14 to 90 days. It provides a visual representation of glucose levels, helping to identify patterns and variability in glucose management.";
    return this.SQL`
    SELECT 'html' as component,
    '<style>
        .text-\\[11px\\] { 
            font-size: 11px;  
        }
    </style>
    <div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">AMBULATORY GLUCOSE PROFILE (AGP) <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="${formula}"></formula-component></div></div>
    <agp-chart class="p-5"></agp-chart>
    ' as html;
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/api/daily-glcuose-profile/index.sql"() {
    return this.SQL`
    SELECT 'json' AS component, 
        JSON_OBJECT(
            'daily_glucose_profile', (
                SELECT JSON_GROUP_ARRAY(
                    JSON_OBJECT(
                        'date_time', Date_Time, 
                        'date', strftime('%Y-%m-%d', Date_Time), 
                        'hour', strftime('%H', Date_Time),                        
                        'glucose', CGM_Value                     
                    )
                ) 
                  FROM
                    combined_cgm_tracing
                  WHERE
                    participant_id = $participant_id
                  AND Date_Time BETWEEN $start_date AND $end_date
            )
        ) AS contents;   
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/daily-gluecose-profile/index.sql"() {
    const formula =
      `The Ambulatory Glucose Profile (AGP) summarizes glucose monitoring data over a specified period, typically 14 to 90 days. It provides a visual representation of glucose levels, helping to identify patterns and variability in glucose management.`;
    return this.SQL`
    SELECT 'html' as component,
        '<style>
    .line {
        fill: none;
        stroke: lightgrey;
        stroke-width: 1px;
    }

    .highlight-area {
        fill: lightgreen;
        opacity: 1;
    }

    .highlight-line {
        fill: none;
        stroke: green;
        stroke-width: 1px;
    }

    .highlight-glucose-h-line {
        fill: none;
        stroke: orange;
        stroke-width: 1px;
    }

    .highlight-glucose-l-line {
        fill: none;
        stroke: red;
        stroke-width: 1px;
    }

    .reference-line {
        stroke: black;
        stroke-width: 1px;
    }

    .vertical-line {
        stroke: rgb(223, 223, 223);
        stroke-width: 1px;
    }

    .day-label {
        font-size: 10px;
        fill: #000;
    }

    .day-label-top {
        font-size: 12px;
        text-anchor: middle;
        fill: #000;
    }

    .axis path,
    .axis line {
        fill: none;
        shape-rendering: crispEdges;
    }

    .mg-dl-label {
        font-size: 14px;
        font-weight: bold;
        text-anchor: middle;
        fill: #000;
        transform: rotate(-90deg);
        transform-origin: left center;
    }

    .horizontal-line {
        stroke: rgb(223, 223, 223);
        stroke-width: 1px;
    }
</style> 
        <div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">DAILY GLUCOSE PROFILE <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="${formula}"></formula-component></div></div>
        <dgp-chart></dgp-chart>
        <p class="py-2 px-4 text-gray-800 font-normal text-xs hidden" id="dgp-note"><b>NOTE:</b> The Daily Glucose
            Profile
            plots the glucose levels of the last 14 days.</p>
    ' as html;
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/api/glycemic_risk_indicator/index.sql"() {
    return this.SQL`
    SELECT 'json' AS component, 
        JSON_OBJECT(
            'glycemicRiskIndicator', (
                SELECT JSON_OBJECT(
                        'time_above_VH_percentage', ROUND(COALESCE((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                        'time_above_H_percentage', ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                        'time_in_range_percentage', ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                        'time_below_low_percentage', ROUND(COALESCE((SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                        'time_below_VL_percentage', ROUND(COALESCE((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 0), 2),
                        'Hypoglycemia_Component', ROUND(COALESCE((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                                              (0.8 * (SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))), 0), 2),
                        'Hyperglycemia_Component', ROUND(COALESCE((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                                                  (0.5 * (SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))), 0), 2),
                        'GRI', ROUND(COALESCE((3.0 * ((SUM(CASE WHEN cgm_value < 54 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                                    (0.8 * (SUM(CASE WHEN cgm_value BETWEEN 54 AND 69 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))) + 
                                        (1.6 * ((SUM(CASE WHEN cgm_value > 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) + 
                                                (0.5 * (SUM(CASE WHEN cgm_value BETWEEN 181 AND 250 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))))), 0), 2)
                ) 
                  FROM
                    combined_cgm_tracing
                  WHERE
                    participant_id = $participant_id 
                  AND Date_Time BETWEEN $start_date AND $end_date
            )
        ) AS contents;   
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/glycemic_risk_indicator/index.sql"() {
    const formula = `Hypoglycemia Component = VLow + (0.8 × Low)
                    Hyperglycemia Component = VHigh + (0.5 × High)
                    GRI = (3.0 × Hypoglycemia Component) + (1.6 × Hyperglycemia Component)
                    Equivalently,
                    GRI = (3.0 × VLow) + (2.4 × Low) + (1.6 × VHigh) + (0.8 × High)`;

    return this.SQL`
    SELECT 'html' as component,
        '<style>
        svg {
          display: block;
          margin: auto;
        }
      </style>        
        <div class="fs-3 p-1 fw-bold" style="background-color: #E3E3E2; text-black; display: flex; flex-direction: row; justify-content: space-between;">Glycemia Risk Index <div style="display: flex; justify-content: flex-end; align-items: center;"><formula-component content="${formula}"></formula-component></div></div>
        <div class="px-4 pb-4">
        <gri-chart></gri-chart>' as html; 
      SELECT '
        <table class="w-full text-center border">
        <thead>
          <tr class="bg-gray-900">
            <th >TIR</th>
            <th >TAR(VH)</th>
            <th >TAR(H)</th>
            <th >TBR(L)</th>
            <th >TBR(VL)</th>
            <th >TITR</th>
            <th >GRI</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="TIR"></td>
            <td class="TAR_VH"></td>
            <td class="TAR_H"></td>
            <td class="TBR_L"></td>
            <td class="TBR_VL"></td>
            <td class="timeInTightRangeCdata"></td>
            <td class="GRI"></td>
          </tr>
        </tbody> 
      </table>
      </div>
    ' as html; 
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/api/advanced_metrics/index.sql"() {
    return this.SQL`
    SELECT 'json' AS component, 
        JSON_OBJECT(
            'advancedMetrics', (
                SELECT JSON_OBJECT(
                        'time_in_tight_range_percentage', round(time_in_tight_range_percentage,3) 
                ) 
                  FROM 
                    drh_advanced_metrics
                  WHERE
                    participant_id = $participant_id 
            )
        ) AS contents;   
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no", shellStmts: "do-not-include" })
  "drh/advanced_metrics/index.sql"() {
    const formulaLiabIndex =
      `The Liability Index quantifies the risk associated with glucose variability, measured in mg/dL.`;
    const formulaHypoEpi =
      `This metric counts the number of occurrences when glucose levels drop below a specified hypoglycemic threshold, indicating potentially dangerous low blood sugar events.`;
    const formulaEuglEpi =
      `This metric counts the number of instances where glucose levels remain within the target range, indicating stable and healthy glucose control.`;
    const formulaHyperEpi =
      `This metric counts the number of instances where glucose levels exceed a certain hyperglycemic threshold, indicating potentially harmful high blood sugar events.`;
    const formulaMValue =
      `The M Value provides a measure of glucose variability, calculated from the mean of the absolute differences between consecutive CGM values over a specified period.`;
    const formulaManAmpli =
      `Mean Amplitude quantifies the average degree of fluctuation in glucose levels over a given time frame, giving insight into glucose stability.`;
    const formulaAvgDaily =
      `This metric assesses the average risk associated with daily glucose variations, expressed in mg/dL.`;
    const formulaJIndex =
      `The J Index calculates glycemic variability using both high and low glucose readings, offering a comprehensive view of glucose fluctuations.`;
    const formulaLBGI =
      `This metric quantifies the risk associated with low blood glucose levels over a specified period, measured in mg/dL.`;
    const formulaHBGI =
      `This metric quantifies the risk associated with high blood glucose levels over a specified period, measured in mg/dL.`;
    const formulaGrade =
      `GRADE is a metric that combines various glucose metrics to assess overall glycemic risk in individuals with diabetes, calculated using multiple input parameters.`;
    const formulaConga =
      `CONGA quantifies the net glycemic effect over time by evaluating the differences between CGM values at specified intervals.`;
    const formulaMeanDaily =
      `This metric calculates the average of the absolute differences between daily CGM readings, giving insight into daily glucose variability.`;
    return this.SQL`
     SELECT  
    'html' as component;
    SELECT
      '<div class="px-4">' as html;
    SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Liability Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| ROUND(CAST((SUM(CASE WHEN CGM_Value < 70 THEN 1 ELSE 0 END) + SUM(CASE WHEN CGM_Value > 180 THEN 1 ELSE 0 END)) AS REAL) / COUNT(*), 2) ||' mg/dL<formula-component content="${formulaLiabIndex}"></formula-component></div></div></div>
      <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Hypoglycemic Episodes <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| SUM(CASE WHEN CGM_Value < 70 THEN 1 ELSE 0 END) ||'<formula-component content="${formulaHypoEpi}"></formula-component></div></div></div>
      <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Euglycemic Episodes <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| SUM(CASE WHEN CGM_Value BETWEEN 70 AND 180 THEN 1 ELSE 0 END) ||'<formula-component content="${formulaEuglEpi}"></formula-component></div></div></div>
      <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Hyperglycemic Episodes <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| SUM(CASE WHEN CGM_Value > 180 THEN 1 ELSE 0 END) ||'<formula-component content="${formulaHyperEpi}"></formula-component></div></div></div>' as html 
      FROM combined_cgm_tracing 
                    WHERE participant_id = $participant_id AND Date(Date_Time) BETWEEN $start_date AND $end_date
                    GROUP BY participant_id;
     SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">M Value <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| round((MAX(CGM_Value) - MIN(CGM_Value)) / 
    ((strftime('%s', MAX(DATETIME(Date_Time))) - strftime('%s', MIN(DATETIME(Date_Time)))) / 60.0),3) ||' mg/dL<formula-component content="${formulaMValue}"></formula-component></div></div></div>' as html   
      FROM combined_cgm_tracing 
                    WHERE participant_id = $participant_id AND Date(Date_Time) BETWEEN $start_date AND $end_date
                    GROUP BY participant_id;
      SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Mean Amplitude <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| round(AVG(amplitude),3) ||'<formula-component content="${formulaManAmpli}"></formula-component></div></div></div>' as html  
      FROM (SELECT ABS(MAX(CGM_Value) - MIN(CGM_Value)) AS amplitude   
      FROM combined_cgm_tracing  WHERE participant_id = $participant_id AND Date(Date_Time) BETWEEN $start_date AND $end_date   
      GROUP BY DATE(Date_Time) 
      );      

      CREATE TEMPORARY TABLE DailyRisk AS 
      SELECT 
          participant_id, 
          DATE(date_time) AS day, 
          MAX(CGM_Value) - MIN(CGM_Value) AS daily_range 
      FROM 
          combined_cgm_tracing cct 
      WHERE 
          participant_id = $participant_id
          AND DATE(date_time) BETWEEN DATE($start_date) AND DATE($end_date) 
      GROUP BY 
          participant_id, 
          DATE(date_time);

      CREATE TEMPORARY TABLE AverageDailyRisk AS 
      SELECT 
          participant_id, 
          AVG(daily_range) AS average_daily_risk 
      FROM 
          DailyRisk 
      WHERE 
          participant_id = $participant_id
      GROUP BY 
          participant_id;    

      SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Average Daily Risk Range <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| round(average_daily_risk,3) ||' mg/dL<formula-component content="${formulaAvgDaily}"></formula-component></div></div></div>' as html  
      FROM 
          AverageDailyRisk 
      WHERE 
           participant_id = $participant_id;

      DROP TABLE IF EXISTS DailyRisk;
      DROP TABLE IF EXISTS AverageDailyRisk;

      CREATE TEMPORARY TABLE glucose_stats AS 
      SELECT
          participant_id,
          AVG(CGM_Value) AS mean_glucose,
          (AVG(CGM_Value * CGM_Value) - AVG(CGM_Value) * AVG(CGM_Value)) AS variance_glucose
      FROM
          combined_cgm_tracing
      WHERE
          participant_id = $participant_id
          AND DATE(Date_Time) BETWEEN DATE($start_date) AND DATE($end_date) 
      GROUP BY
          participant_id;

      SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">J Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| ROUND(0.001 * (mean_glucose + SQRT(variance_glucose)) * (mean_glucose + SQRT(variance_glucose)), 2) ||' mg/dL<formula-component content="${formulaJIndex}"></formula-component></div></div></div>' as html  
      FROM
        glucose_stats;
      DROP TABLE IF EXISTS glucose_stats;

    SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Low Blood Glucose Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| ROUND(SUM(CASE WHEN (CGM_Value - 2.5) / 2.5 > 0 
                   THEN ((CGM_Value - 2.5) / 2.5) * ((CGM_Value - 2.5) / 2.5) 
                   ELSE 0 
              END) * 5, 2) ||'<formula-component content="${formulaLBGI}"></formula-component></div></div></div>
      <div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">High Blood Glucose Index <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| ROUND(SUM(CASE WHEN (CGM_Value - 9.5) / 9.5 > 0 
                   THEN ((CGM_Value - 9.5) / 9.5) * ((CGM_Value - 9.5) / 9.5) 
                   ELSE 0 
              END) * 5, 2) ||'<formula-component content="${formulaHBGI}"></formula-component></div></div></div>' as html  
      FROM 
          combined_cgm_tracing
      WHERE 
          participant_id = $participant_id
          AND DATE(Date_Time) BETWEEN $start_date AND $end_date;   

      SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Glycaemic Risk Assessment Diabetes Equation (GRADE) <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| round(AVG(CASE
            WHEN CGM_Value < 90 THEN 10 * (5 - (CGM_Value / 18.0)) * (5 - (CGM_Value / 18.0))
            WHEN CGM_Value > 180 THEN 10 * ((CGM_Value / 18.0) - 10) * ((CGM_Value / 18.0) - 10)
            ELSE 0
        END),3) ||'<formula-component content="${formulaGrade}"></formula-component></div></div></div>' as html
      FROM 
          combined_cgm_tracing
      WHERE 
          participant_id = $participant_id
          AND DATE(Date_Time) BETWEEN $start_date AND $end_date;


      CREATE TEMPORARY TABLE lag_values AS 
      SELECT 
          participant_id,
          Date_Time,
          CGM_Value,
          LAG(CGM_Value) OVER (PARTITION BY participant_id ORDER BY Date_Time) AS lag_CGM_Value
      FROM 
          combined_cgm_tracing
      WHERE
         participant_id = $participant_id
          AND DATE(Date_Time) BETWEEN $start_date AND $end_date;

      CREATE TEMPORARY TABLE conga_hourly AS 
      SELECT 
          participant_id,
          SQRT(
              AVG(
                  (CGM_Value - lag_CGM_Value) * (CGM_Value - lag_CGM_Value)
              ) OVER (PARTITION BY participant_id ORDER BY Date_Time)
          ) AS conga_hourly
      FROM 
          lag_values
      WHERE 
          lag_CGM_Value IS NOT NULL;    

      SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Continuous Overall Net Glycemic Action (CONGA) <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| round(AVG(conga_hourly),3) ||'<formula-component content="${formulaConga}"></formula-component></div></div></div>' as html
      FROM 
        conga_hourly;

        DROP TABLE IF EXISTS lag_values;
        DROP TABLE IF EXISTS conga_hourly;

      SELECT  
      '<div class="card-content my-3 border-bottom" style="display: flex; flex-direction: row; justify-content: space-between;">Mean of Daily Differences <div style="display: flex; justify-content: flex-end; align-items: center;"><div style="display: flex;align-items: center;gap: 0.1rem;">'|| round(AVG(daily_diff),3) ||'<formula-component content="${formulaMeanDaily}"></formula-component></div></div></div>' as html  
      FROM (
          SELECT
              participant_id,
              CGM_Value - LAG(CGM_Value) OVER (PARTITION BY participant_id ORDER BY DATE(Date_Time)) AS daily_diff
          FROM
              combined_cgm_tracing
          WHERE 
              participant_id = $participant_id
          AND DATE(Date_Time) BETWEEN $start_date AND $end_date
      ) AS daily_diffs
      WHERE
          daily_diff IS NOT NULL;                          
      SELECT
      '</div>' as html;         
  `;
  }

  @drhNav({
    caption: "Study Participant Dashboard",
    abbreviatedCaption: "Study Participant Dashboard",
    description: "Study Participant Dashboard",
    siblingOrder: 12,
  })
  "drh/study-participant-dashboard/index.sql"() {
    const viewName = `participant_dashboard_cached`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}


  SELECT
  'datagrid' AS component; 

  SELECT
      'Study Name' AS title,
      '' || study_name || '' AS description
  FROM
      drh_study_vanity_metrics_details;

  SELECT
      'Start Date' AS title,
      '' || start_date || '' AS description
  FROM
      drh_study_vanity_metrics_details;

  SELECT
      'End Date' AS title,
      '' || end_date || '' AS description
  FROM
      drh_study_vanity_metrics_details;

  SELECT
      'NCT Number' AS title,
      '' || nct_number || '' AS description
  FROM
      drh_study_vanity_metrics_details;




  SELECT
     'card'     as component,
     '' as title,
      4         as columns;

  SELECT
     'Total Number Of Participants' AS title,
     '' || total_number_of_participants || '' AS description
  FROM
      drh_study_vanity_metrics_details;

  SELECT

      'Total CGM Files' AS title,
     '' || number_of_cgm_raw_files || '' AS description
  FROM
    drh_number_cgm_count;



  SELECT
     '% Female' AS title,
     '' || percentage_of_females || '' AS description
  FROM
      drh_study_vanity_metrics_details;


  SELECT
     'Average Age' AS title,
     '' || average_age || '' AS description
  FROM
      drh_study_vanity_metrics_details;




  SELECT
  'datagrid' AS component;


  SELECT
      'Study Description' AS title,
      '' || study_description || '' AS description
  FROM
      drh_study_vanity_metrics_details;

      SELECT
      'Study Team' AS title,
      '' || investigators || '' AS description
  FROM
      drh_study_vanity_metrics_details;


      SELECT
     'card'     as component,
     '' as title,
      1         as columns;

      SELECT
      'Device Wise Raw CGM File Count' AS title,
      GROUP_CONCAT(' ' || devicename || ': ' || number_of_files || '') AS description
      FROM
          drh_device_file_count_view;

          SELECT
  'text' as component,
  '# Participant Dashboard' as contents_md;

      ${pagination.init()}

    -- Display uniform_resource table with pagination
    SELECT 'table' AS component,
          'participant_id' as markdown,
          TRUE AS sort,
          TRUE AS search;        
    SELECT tenant_id,format('[%s]('||${
      this.absoluteURL("/drh/participant-info/index.sql?participant_id=")
    }||'%s)',participant_id, participant_id) as participant_id,gender,age,study_arm,baseline_hba1c,cgm_devices,cgm_files,tir,tar_vh,tar_h,tbr_l,tbr_vl,tar,tbr,gmi,percent_gv,gri,days_of_wear,data_start_date,data_end_date FROM ${viewName}
    LIMIT $limit
    OFFSET $offset;

    ${pagination.renderSimpleMarkdown()}



  `;
  }

  @drhNav({
    caption: "Verfication And Validation Results",
    abbreviatedCaption: "Verfication And Validation Results",
    description: "Verfication And Validation Results",
    siblingOrder: 13,
  })
  "drh/verification-validation-log/index.sql"() {
    const viewName = `drh_vandv_orch_issues`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}

  SELECT
    'text' as component,
    '
    Validation is a detailed process where we assess if the data within the files conforms to expecuted rules or constraints. This step ensures that the content of the files is both correct and meaningful before they are utilized for further processing.' as contents;



SELECT
  'steps' AS component,
  TRUE AS counter,
  'green' AS color;


SELECT
  'Check the Validation Log' AS title,
  'file' AS icon,
  '#' AS link,
  'If the log is empty, no action is required. Your files are good to go! If the log has entries, follow the steps below to fix any issues.' AS description;


SELECT
  'Note the Issues' AS title,
  'note' AS icon,
  '#' AS link,
  'Review the log to see what needs fixing for each file. Note them down to make a note on what needs to be changed in each file.' AS description;


SELECT
  'Stop the Edge UI' AS title,
  'square-rounded-x' AS icon,
  '#' AS link,
  'Make sure to stop the UI (press CTRL+C in the terminal).' AS description;


SELECT
  'Make Corrections in Files' AS title,
  'edit' AS icon,
  '#' AS link,
  'Edit the files according to the instructions provided in the log. For example, if a file is empty, fill it with the correct data.' AS description;


SELECT
  'Copy the modified Files to the folder' AS title,
  'copy' AS icon,
  '#' AS link,
  'Once you’ve made the necessary changes, replace the old files with the updated ones in the folder.' AS description;


SELECT
  'Execute the automated script again' AS title,
  'retry' AS icon,
  '#' AS link,
  'Run the command again to perform file conversion.' AS description;


SELECT
  'Repeat the steps until issues are resolved' AS title,
  'refresh' AS icon,
  '#' AS link,
  'Continue this process until the log is empty and all issues are resolved' AS description;


SELECT
    'text' as component,
    '
    Reminder: Keep updating and re-running the process until you see no entries in the log below.' as contents;


    ${pagination.init()}

    SELECT 'table' AS component,
    TRUE AS sort,
    TRUE AS search;
    SELECT * FROM ${viewName}
    LIMIT $limit
    OFFSET $offset;

    ${pagination.renderSimpleMarkdown()}
    `;
  }

  @drhNav({
    caption: "Participant Information",
    abbreviatedCaption: "Participant Information",
    siblingOrder: 19,
  })
  "drh/participant-related-data/index.sql"() {
    const viewName = `drh_participant`;
    const pagination = this.pagination({ tableOrViewName: viewName });
    return this.SQL`
  ${this.activePageTitle()}

  SELECT
      'text' as component,
      '
## Participant Information

Participants are individuals who volunteer to take part in CGM research studies. Their data is crucial for evaluating the performance of CGM systems and their impact on diabetes management.

### Participant Details

  - **Participant ID**: A unique identifier assigned to each participant.
  - **Study ID**: A unique identifier for the study in which the participant is involved.
  - **Site ID**: The identifier for the site where the participant is enrolled.
  - **Diagnosis ICD**: The diagnosis code based on the International Classification of Diseases (ICD) system.
  - **Med RxNorm**: The medication code based on the RxNorm system.
  - **Treatment Modality**: The type of treatment or intervention administered to the participant.
  - **Gender**: The gender of the participant.
  - **Race Ethnicity**: The race and ethnicity of the participant.
  - **Age**: The age of the participant.
  - **BMI**: The Body Mass Index (BMI) of the participant.
  - **Baseline HbA1c**: The baseline Hemoglobin A1c level of the participant.
  - **Diabetes Type**: The type of diabetes diagnosed for the participant.
  - **Study Arm**: The study arm or group to which the participant is assigned.


      ' as contents_md;

      ${pagination.init()}

    -- Display uniform_resource table with pagination
    SELECT 'table' AS component,
          TRUE AS sort,
          TRUE AS search;
    SELECT * FROM ${viewName}
     LIMIT $limit
    OFFSET $offset; 

    ${pagination.renderSimpleMarkdown()}

      `;
  }
}

export async function drhNotebooks() {
  return [
    new class extends spn.TypicalSqlPageNotebook {
    }(),
    // new sh.ShellSqlPages(),
    new DrhShellSqlPages(),
    new c.ConsoleSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new DRHSqlPages(),
  ];
}

export async function drhSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    ...(await drhNotebooks()),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await drhSQL()).join("\n"));
}
