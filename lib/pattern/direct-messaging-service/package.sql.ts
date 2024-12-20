#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

const WEB_UI_TITLE: string = "Direct Messaging Service";
const WEB_UI_LOGO = "dms.png";
const WEB_UI_FAV = "dms-favicon.ico";

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
function dmsNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "dms/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class DirectMessageSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /dms-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE parent_path=${
      this.constructHomePath("dms")
    };
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Direct Protocol Email System",
    description: "Email system with direct protocol",
  })
  "dms/index.sql"() {
    return this.SQL`
    select
        'text'              as component,
        'The Direct Secure Messaging Service facilitates the secure exchange of clinical data using the phiMail service. PhiMail is built on the DIRECT protocol, a standardized method for secure email communication in healthcare. This enables seamless and secure transmission of health information. Specifically, this page focuses on the receive module, providing a view of the mailbox within the phiMail service. ' as contents;
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path=${this.constructHomePath("dms")}
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title,${
      this.absoluteURL("/")
    } || COALESCE(url, path) AS link,  
      description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${
      this.constructHomePath("dms")
    }
       ORDER BY sibling_order;`;
  }
  @dmsNav({
    caption: "Inbox",
    description: `Inbox provides a view of the mail inbox`,
    siblingOrder: 1,
  })
  "dms/inbox.sql"() {
    return this.SQL`
    
    -- select 'debug' as component, sqlpage.environment_variable('SQLPAGE_SITE_PREFIX');
    select
        'text'              as component,
        'The Inbox is a feature that provides users with a centralized, secure interface for accessing and managing messages received through the phiMail service. It is designed to support efficient and compliant handling of sensitive communications, often related to protected health information (PHI).' as contents;

      SELECT 'table' AS component,
            'subject' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;

      SELECT id,
      "from",
        '[' || subject || '](' || ${
      this.absoluteURL("/dms/email-detail.sql?id=")
    } || id || ')' AS "subject",
      date
      from inbox
      `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "dms/email-detail.sql"() {
    return this.SQL`

    select
    'breadcrumb' as component;
    select
        'Home' as title,
        ${this.absoluteURL("/")} as link;
    select
        'Direct Protocol Email System' as title,
         ${this.absoluteURL("/dms/index.sql")} as link;
    select
        'inbox' as title,
         ${this.absoluteURL("/dms/inbox.sql")} as link;
    select
        "subject" as title from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);

    select
        'text'              as component,
        'This page provides the details of a received message, including information about any attachments.' as contents;

    select
        'datagrid' as component;
    select
        'From' as title,
        "from" as "description" from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
    select
        'To' as title,
        "to" as "description"  from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
    select
        'Subject' as title,
        "subject" as "description"  from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
    select
        'Date' as title,
        "date" as "description"  from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);

    select 'datagrid' as component;
      SELECT content AS description FROM inbox WHERE id = $id::TEXT;
      SELECT 'table' AS component, 'attachment' AS markdown;
      SELECT
          CASE
              WHEN attachment_filename LIKE '%.xml' OR attachment_mime_type = 'application/xml'
              THEN '[' || attachment_filename || '](' || ${
      this.absoluteURL("")
    } || attachment_file_path || ' "download")' || ' | ' || '[View Details]('||${
      this.absoluteURL("/dms/patient-detail.sql?id=")
    } || message_uid || ' "View Details")'
              ELSE '[' || attachment_filename || '](' || ${
      this.absoluteURL("")
    } || attachment_file_path || ' "download")'
          END AS "attachment"
      FROM mail_content_attachment
      WHERE CAST(message_uid AS TEXT) = CAST($id AS TEXT);

    `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "dms/patient-detail.sql"() {
    return this.SQL`
    
    SELECT
    'breadcrumb' as component;
    SELECT
       'Home' as title,
       ${this.absoluteURL("/")} as link;
    SELECT
        'Direct Protocol Email System' as title,
        ${this.absoluteURL("/dms/index.sql")} as link;
    SELECT
        'inbox' as title,
        ${this.absoluteURL("/dms/inbox.sql")} as link;
    SELECT
         ${this.absoluteURL("/dms/email-detail.sql?id=")}  || id AS link,
        "subject" as title from inbox where CAST(id AS TEXT)=CAST($id AS TEXT);
    SELECT
        first_name as title from patient_detail where CAST(message_uid AS TEXT)=CAST($id AS TEXT) ;

   SELECT 'html' AS component, '
  <link rel="stylesheet" href="'||${
      this.absoluteURL("/assets/style-dms.css")
    }||'">'
  ||'<h2>' || document_title || '</h2>
  <table class="patient-summary">
    <tr>
      <th>Patient</th>
      <td>' || first_name || ' ' || last_name || '<br>
          <b>Patient-ID</b>: ' || id || ' (SSN) <b>Date of Birth</b>: ' || substr(birthTime, 7, 2) ||
      CASE
        WHEN strftime('%d', birthTime) IN ('01', '21', '31') THEN 'st'
        WHEN strftime('%d', birthTime) IN ('02', '22') THEN 'nd'
        WHEN strftime('%d', birthTime) IN ('03', '23') THEN 'rd'
        ELSE 'th'
      END || ' ' ||
      CASE
        WHEN cast(substr(birthTime, 5, 2) AS text) = '1' THEN 'January'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '2' THEN 'February'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '3' THEN 'March'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '4' THEN 'April'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '5' THEN 'May'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '6' THEN 'June'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '7' THEN 'July'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '8' THEN 'August'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '9' THEN 'September'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '10' THEN 'October'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '11' THEN 'November'
        WHEN cast(substr(birthTime, 5, 2) AS text) = '12' THEN 'December'
        ELSE 'Invalid Month'
      END || ' ' || substr(birthTime, 1, 4) || ' <b>Gender</b>: Female</td>
    </tr>
    <tr>
      <th>Guardian</th>
      <td>' || guardian_name || ' ' || guardian_family_name || ' - ' || guardian_display_name || '</td>
    </tr>
    <tr>'
    ||
    CASE
      WHEN performer_name != '' THEN '
      <th>Documentation Of</th>
      <td><b>Performer</b>: ' || performer_name || ' ' || performer_family || ' ' || performer_suffix || ' <b>Organization</b>: ' || performer_organization || '</td>
    </tr>'
      ELSE ''
    END ||'
    <tr>
      <th>Author</th>
      <td>' || ad.author_given_names || ' ' || ad.author_family_names || ' ' || ad.author_suffixes || ', <b>Authored On</b>: ' ||
      CASE
        WHEN substr(author_times, 7, 2) = '01' THEN substr(author_times, 9, 2) || 'st '
        WHEN substr(author_times, 7, 2) = '02' THEN substr(author_times, 9, 2) || 'nd '
        WHEN substr(author_times, 7, 2) = '03' THEN substr(author_times, 9, 2) || 'rd '
        ELSE substr(author_times, 9, 2) || 'th '
      END ||
      CASE
        WHEN substr(author_times, 5, 2) = '01' THEN 'January '
        WHEN substr(author_times, 5, 2) = '02' THEN 'February '
        WHEN substr(author_times, 5, 2) = '03' THEN 'March '
        WHEN substr(author_times, 5, 2) = '04' THEN 'April '
        WHEN substr(author_times, 5, 2) = '05' THEN 'May '
        WHEN substr(author_times, 5, 2) = '06' THEN 'June '
        WHEN substr(author_times, 5, 2) = '07' THEN 'July '
        WHEN substr(author_times, 5, 2) = '08' THEN 'August '
        WHEN substr(author_times, 5, 2) = '09' THEN 'September '
        WHEN substr(author_times, 5, 2) = '10' THEN 'October '
        WHEN substr(author_times, 5, 2) = '11' THEN 'November '
        WHEN substr(author_times, 5, 2) = '12' THEN 'December '
        ELSE 'Invalid Month'
      END ||
      substr(author_times, 1, 4) || '</td>
    </tr>
    ' ||
    CASE
      WHEN ad.organization_names != '' THEN '
      <tr>
        <th>Author</th>
        <td>' || ad.device_manufacturers || ' - ' || ad.device_software || ', Organization: ' || ad.organization_names || ', <b>Authored On</b>: ' ||
        CASE
          WHEN substr(author_times, 7, 2) = '01' THEN substr(author_times, 9, 2) || 'st '
          WHEN substr(author_times, 7, 2) = '02' THEN substr(author_times, 9, 2) || 'nd '
          WHEN substr(author_times, 7, 2) = '03' THEN substr(author_times, 9, 2) || 'rd '
          ELSE substr(author_times, 9, 2) || 'th '
        END ||
        CASE
          WHEN substr(author_times, 5, 2) = '01' THEN 'January '
          WHEN substr(author_times, 5, 2) = '02' THEN 'February '
          WHEN substr(author_times, 5, 2) = '03' THEN 'March '
          WHEN substr(author_times, 5, 2) = '04' THEN 'April '
          WHEN substr(author_times, 5, 2) = '05' THEN 'May '
          WHEN substr(author_times, 5, 2) = '06' THEN 'June '
          WHEN substr(author_times, 5, 2) = '07' THEN 'July '
          WHEN substr(author_times, 5, 2) = '08' THEN 'August '
          WHEN substr(author_times, 5, 2) = '09' THEN 'September '
          WHEN substr(author_times, 5, 2) = '10' THEN 'October '
          WHEN substr(author_times, 5, 2) = '11' THEN 'November '
          WHEN substr(author_times, 5, 2) = '12' THEN 'December '
        END ||
        substr(author_times, 1, 4) || '</td>
      </tr>'
      ELSE ''
    END || '
  </table>' AS html
FROM patient_detail pd
JOIN author_detail ad ON pd.message_uid = ad.message_uid
WHERE CAST(pd.message_uid AS TEXT) = CAST($id AS TEXT);

    SELECT 'html' AS component, '
      <link rel="stylesheet" href="'||${
      this.absoluteURL("/assets/style-dms.css")
    }||'">
      <table class="patient-details">
      <tr>
      <th class="no-border-bottom" style="background-color: #f2f2f2"><b>Document</b></th>
      <td class="no-border-bottom" style="width:30%">
        ID: '|| document_extension||' ('|| document_id||')<br>
        Version:'|| version||'<br>
        Set-ID: '|| set_id_extension||'
      </td>
      <th style="background-color: #f2f2f2"><b>Created On</b></th>
      <td class="no-border-bottom"> ' ||
      CASE
          WHEN substr(custodian_time, 7, 2) = '01' THEN substr(custodian_time, 9, 2) || 'st '
          WHEN substr(custodian_time, 7, 2) = '02' THEN substr(custodian_time, 9, 2) || 'nd '
          WHEN substr(custodian_time, 7, 2) = '03' THEN substr(custodian_time, 9, 2) || 'rd '
          ELSE substr(custodian_time, 9, 2) || 'th '
      END ||
      CASE
          WHEN substr(custodian_time, 5, 2) = '01' THEN 'January '
          WHEN substr(custodian_time, 5, 2) = '02' THEN 'February '
          WHEN substr(custodian_time, 5, 2) = '03' THEN 'March '
          WHEN substr(custodian_time, 5, 2) = '04' THEN 'April '
          WHEN substr(custodian_time, 5, 2) = '05' THEN 'May '
          WHEN substr(custodian_time, 5, 2) = '06' THEN 'June '
          WHEN substr(custodian_time, 5, 2) = '07' THEN 'July '
          WHEN substr(custodian_time, 5, 2) = '08' THEN 'August '
          WHEN substr(custodian_time, 5, 2) = '09' THEN 'September '
          WHEN substr(custodian_time, 5, 2) = '10' THEN 'October '
          WHEN substr(custodian_time, 5, 2) = '11' THEN 'November '
          WHEN substr(custodian_time, 5, 2) = '12' THEN 'December '
      END ||
      substr(custodian_time, 1, 4) || '</td>
      </tr>
      <tr>
        <th style="background-color: #f2f2f2"><b>Custodian</b></th>
        <td>'|| custodian||'</td>
        <th style="background-color: #f2f2f2"><b>Contact Details</b></th>
        <td>
          Workplace: '|| custodian_address_line1||' '|| custodian_city||', '|| custodian_state||' '|| custodian_postal_code||'<br> '|| custodian_country||'<br>
          Tel Workplace: '|| custodian_telecom||'
        </td>
      </tr>
    </table>'AS html
    FROM patient_detail
    WHERE CAST(message_uid AS TEXT)=CAST($id AS TEXT);

    SELECT 'html' AS component, '
    <link rel="stylesheet" href="'||${
      this.absoluteURL("/assets/style-dms.css")
    }||'">
    <style>
      .patient-details {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
        font-family: Arial, sans-serif;
      }

    </style>

    <table class="patient-details">
      <tr>
        <th class="no-border-bottom" ><b>Patient</b></th>
        <td class="no-border-bottom" style="width:30%">'|| first_name||'  '|| last_name||'</td>
        <th class="no-border-bottom" ><b>Contact Details</b></th>
        <td class="no-border-bottom">'|| address||' '|| city||', '|| state||' '|| postalCode||' '|| addr_use||'</td>
      </tr>
      <tr>
        <th class="no-border-bottom" ><b>Date of Birth</b></th>
        <td class="no-border-bottom">'|| strftime('%Y-%m-%d', substr(birthTime, 1, 4) || '-' || substr(birthTime, 5, 2) || '-' || substr(birthTime, 7, 2))||' </td>
        <th class="no-border-bottom" ><b>Gender</b></th>
        <td class="no-border-bottom">'|| CASE
        WHEN gender_code = 'F' THEN 'Female'
        WHEN gender_code = 'M' THEN 'Male'
        ELSE 'Other'
      END||'</td>
      </tr>
      <tr>
        <th class="no-border-bottom" ><b>Race</b></th>
        <td class="no-border-bottom">'||race_displayName||'</td>
        <th class="no-border-bottom" ><b>Ethnicity</b></th>
        <td class="no-border-bottom">'||ethnic_displayName||'</td>
      </tr>
      <tr>
        <th class="no-border-bottom" ><b>Patient-IDs</b></th>
        <td class="no-border-bottom">'||id||'</td>
        <th class="no-border-bottom" ><b>Language Communication</b></th>
        <td class="no-border-bottom">'||
        CASE
            WHEN language_code IS NOT NULL THEN language_code
            ELSE 'Not Given'
        END
        ||'</td>
      </tr>

      <tr>
        <th class="no-border-bottom" ><b>Guardian</b></th>
        <td class="no-border-bottom">'||guardian_name||' '||guardian_family_name||' '||guardian_display_name||'</td>
        <th class="no-border-bottom" ><b>Contact Details</b></th>
        <td class="no-border-bottom">'|| guardian_address||', '|| guardian_city||' ,'|| guardian_state||', '|| guardian_zip||' ,'|| guardian_country||'</td>
      </tr>

      <tr>
        <th class="no-border-bottom" ><b>Provider Organization</b></th>
        <td class="no-border-bottom">'||provider_organization||'</td>
        <th class="no-border-bottom" ><b>Contact Details (Organization)</b></th>
        <td class="no-border-bottom">'|| provider_address_line||', '|| provider_city||' ,'|| provider_state||', '|| provider_country||' ,'|| provider_zip||'</td>
      </tr>


    </table> 'AS html
  FROM patient_detail
  WHERE CAST(message_uid AS TEXT)=CAST($id AS TEXT);


  select 'html' as component;
  select '<link rel="stylesheet" href="'||${
      this.absoluteURL("/assets/style-dms.css")
    }||'">
    <details class="accordian-head">
  <summary>'||section_title||'</summary>
  <div class="patient-details">
    <div>'||table_data||'</div>
  </div>
  </details>' as html
  FROM patient_diagnosis
  WHERE CAST(message_uid AS TEXT)=CAST($id AS TEXT);
  `;
  }
  @dmsNav({
    caption: "Dispatched",
    description: "Provides a list of messages dispatched",
    siblingOrder: 2,
  })
  "dms/dispatched.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
      select
        'text'              as component,
        'This page provides a list of messages dispatched using the sender module, detailing the sent messages and their associated information.' as contents;
      

      SELECT 'table' as component,
            'subject' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;
      SELECT * from phimail_delivery_detail where status='dispatched'`;
  }

  @dmsNav({
    caption: "Failed",
    description: "Provides a list of messages Failed",
    siblingOrder: 2,
  })
  "dms/failed.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

      select
        'text'              as component,
        'This page provides a list of messages that failed after being sent using the sender module, displaying details of each failed message.' as contents;

      SELECT 'table' as component,
            'subject' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;
      SELECT * from phimail_delivery_detail where status!='dispatched'`;
  }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessDmsSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new sh.ShellSqlPages(WEB_UI_TITLE, WEB_UI_LOGO, WEB_UI_FAV),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new c.ConsoleSqlPages(),
    new DirectMessageSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
