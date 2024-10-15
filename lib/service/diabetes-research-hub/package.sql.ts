#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
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
    parentPath: "/drh",
  });
}

export class DrhShellSqlPages extends sh.ShellSqlPages {
  defaultShell() {
    const shellConfig = super.defaultShell();
    shellConfig.title = "Diabetes Research Hub EDGE";
    shellConfig.image =
      "https://drh.diabetestechnology.org/images/diabetic-research-hub-logo.png";
    shellConfig.icon = "";
    shellConfig.link = "/drh/";
    shellConfig.favicon =
      "https://drh.diabetestechnology.org/_astro/favicon.CcrFY5y9.ico";
    return shellConfig;
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
            'link', '${rootPath}',
            'title', ${literal(caption)},      
            'target', '${target}',      
            'submenu', (
                SELECT json_group_array(
                    json_object(
                        'title', title,
                        'link', link,
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
                    WHERE namespace = 'prime' AND parent_path = '${rootPath}'
                    ORDER BY sibling_order
                )
            )
        ) as menu_item`;

    const handlers = {
      DEFAULT: (key: string, value: unknown) => `${literal(value)} AS ${key}`,
      menu_item: (key: string, items: Record<string, unknown>[]) =>
        items.map((item) => `${literal(JSON.stringify(item))} AS ${key}`),
      javascript: (key: string, scripts: string[]) => {
        const items = scripts.map((s) => `${literal(s)} AS ${key}`);
        items.push(selectNavMenuItems("/ur", "Uniform Resource"));
        items.push(selectNavMenuItems("/console", "Console"));
        items.push(
          selectNavMenuItems("/orchestration", "Orchestration"),
        );
        // items.push(selectNavMenuItems("/site", "DRH"));
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
        `'📄 [' || substr(sqlpage.path(), 2) || '](/console/sqlpage-files/sqlpage-file.sql?path=' || substr(sqlpage.path(), 2) || ')' as footer`,
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
    DELETE FROM sqlpage_aide_navigation WHERE path like '/drh%';
    ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
  `;
  }

  menuDDL() {
    return this.SQL`
  INSERT OR IGNORE INTO sqlpage_aide_navigation ("path", caption, namespace, parent_path, sibling_order, url, title, abbreviated_caption, description,elaboration) VALUES
  (NULL, 'DRH Home', 'prime', '/external', 1, 'https://drh.diabetestechnology.org/', NULL, NULL, NULL,'{ "target": "_blank" }'),
  (NULL, 'DTS Home', 'prime', '/external', 1, 'https://www.diabetestechnology.org/', NULL, NULL, NULL,'{ "target": "_blank" }')
  `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "DRH EDGE UI Home",
    description: "Welcome to Diabetes Research Hub EDGE UI",
  })
  "drh/index.sql"() {
    return this.SQL`
            SELECT
                  'card'                      as component,
                  'Welcome to the Diabetes Research Hub EDGE UI' as title,
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
                '/drh/ingestion-log/index.sql' as link,
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
                '/drh/verification-validation-log/index.sql' AS link,
                'Use this section to review the issues identified in the file content and take appropriate corrective actions.' AS description,
                'table' AS icon,
                'red' AS color;



            SELECT
                  'card'                  as component,
                  'Features ' as title,
                  8                     as columns;


            SELECT
                'Study Participant Dashboard'  as title,
                '/drh/study-participant-dashboard/index.sql' as link,
                'The dashboard presents key study details and participant-specific metrics in a clear, organized table format' as description,
                'table'                as icon,
                'red'                    as color;
            ;




            SELECT
                'Researcher and Associated Information'  as title,
                '/drh/researcher-related-data/index.sql' as link,
                'This section provides detailed information about the individuals , institutions and labs involved in the research study.' as description,
                'book'                as icon,
                'red'                    as color;
            ;

            SELECT
                'Study ResearchSite Details'  as title,
                '/drh/study-related-data/index.sql' as link,
                'This section provides detailed information about the study , and sites involved in the research study.' as description,
                'book'                as icon,
                'red'                    as color;
            ;

            SELECT
                'Participant Demographics'  as title,
                '/drh/participant-related-data/index.sql' as link,
                'This section provides detailed information about the the participants involved in the research study.' as description,
                'book'                as icon,
                'red'                    as color;
            ;

            SELECT
                'Author and Publication Details'  as title,
                '/drh/author-pub-data/index.sql' as link,
                'Information about research publications and the authors involved in the studies are also collected, contributing to the broader understanding and dissemination of research findings.' as description,
                 'book' AS icon,
                'red'                    as color;
            ;



            SELECT
                'CGM Meta Data and Associated information'  as title,
                '/drh/cgm-associated-data/index.sql' as link,
                'This section provides detailed information about the CGM device used, the relationship between the participant''s raw CGM tracing file and related metadata, and other pertinent information.' as description,
                'book'                as icon,
                'red'                    as color;

            ;


            SELECT
                'Raw CGM Data Description' AS title,
                '/drh/cgm-data/index.sql' AS link,
                'Explore detailed information about glucose levels over time, including timestamp, and glucose value.' AS description,
                'book'                as icon,
                'red'                    as color;


            SELECT
                'PHI De-Identification Results' AS title,
                '/drh/deidentification-log/index.sql' AS link,
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
  
select 
    'form'            as component,
    'Filter by Date Range'   as title,
    'Submit' as validate,    
    'Clear'           as reset;
select 
    'start_date' as name,
    'Start Date' as label,
    '2017-11-02' as value,
    'date'       as type,
    6            as width;
select 
    'end_date' as name,
    'End Date' as label,
    '2018-02-23'  as value,
    'date'       as type,
    6             as width;



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
     'card'     as component,
     '' as title,
      2         as columns;

  SELECT
     'GLUCOSE STATISTICS AND TARGETS' AS title,
     '' AS description
  FROM
      drh_study_vanity_metrics_details;

  SELECT

      'Goals for Type 1 and Type 2 Diabetes' AS title,
     '' AS description
  FROM
    drh_number_cgm_count;

  `;
  }

  @drhNav({
    caption: "Study Participant Dashboard",
    abbreviatedCaption: "Study Participant Dashboard",
    description: "Study Participant Dashboard",
    siblingOrder: 12,
  })
  "drh/study-participant-dashboard/index.sql"() {
    const viewName = `drh_participant`;
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
    SELECT format('[%s](/drh/participant-info/index.sql?participant_id=%s)',participant_id, participant_id) as participant_id,gender,age,study_arm,baseline_hba1c FROM ${viewName}
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

export async function drhSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {

      
      // async deidentifyDRHSQL() {
      //   // This function retrieves the SQL script for data de-identification.
      //   // Note: Deidentification functions are only available through the `surveilr shell` or `surveilr orchestrate` commands.
      //   // Issues prevail while executing these commands on Windows OS.
      //   return await spn.TypicalSqlPageNotebook.fetchText(
      //     import.meta.resolve(
      //       "./orchestration/deidentification-orchestration.sql",
      //     ),
      //   );
      // }

      async vandvDRHSQL() {
        // This function retrieves the SQL script for verfication and validation
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./orchestration/vv-orchestration.sql"),
        );
      }

      async statelessDRHSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }

      
      // async metricsDRHSQL() {
      //   // This function fetches the SQL query for DRH metrics after the combined view has been generated.
      //   // Ensure that the combined view is created before calling this function.        
      //   return await spn.TypicalSqlPageNotebook.fetchText(
      //     import.meta.resolve("./drh-metrics.sql"),
      //   );
      // }

    }(),
    // new sh.ShellSqlPages(),
    new DrhShellSqlPages(),
    new c.ConsoleSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new DRHSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await drhSQL()).join("\n"));
}
