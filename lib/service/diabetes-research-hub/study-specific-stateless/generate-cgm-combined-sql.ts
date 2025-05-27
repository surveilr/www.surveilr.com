#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-net --allowffi

import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";
import { ulid } from "https://deno.land/x/ulid/mod.ts";

// Common function to log errors into the database
function logError(db: Database, errorMessage: string): void {
  db.exec(`CREATE TABLE IF NOT EXISTS error_log (
    errorLogId INTEGER PRIMARY KEY AUTOINCREMENT,
    datetime TEXT DEFAULT (datetime('now')),
    error_message TEXT
  );`);

  const params = JSON.stringify({ message: errorMessage });
  db.prepare("INSERT INTO error_log (error_message) VALUES (?);").run(params);
}

export function createVsvSQL(dbFilePath: string, tableName: string): string {
  const db = new Database(dbFilePath);

  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);

  if (!tableExists) {
    console.error(
      `The required table "${tableName}" does not exist. Cannot create the vsv table.`,
    );
    db.close();
    return "";
  }

  let vsvSQL = ``;
  const rows = db.prepare(`SELECT * FROM ${tableName}`).all();
  if (rows.length > 0) {
    const firstColumnNames = Object.keys(rows[0]);
    const separator = firstColumnNames[0].includes(";")
      ? ";"
      : firstColumnNames[0].includes("|")
      ? "|"
      : firstColumnNames[0].includes(":")
      ? ":"
      : ",";

    let allConcatenatedValues = "";
    if (separator == ";" || separator == "|" || separator == ":") {
      const firstColumnName = firstColumnNames[0];

      for (const row of rows) {
        const concatenatedValues = Object.values(row).join(", ");
        allConcatenatedValues += concatenatedValues + "\n";
      }

      vsvSQL = `create virtual table ${tableName}_vsv using vsv(
            data="${firstColumnName}\n${allConcatenatedValues}",            
            header=yes,
            affinity=integer,
            fsep='${separator}'
        );
        drop table ${tableName};
        create table ${tableName} as select * from ${tableName}_vsv;   
        drop table ${tableName}_vsv;
            `;
    }
  }

  db.close();
  return vsvSQL;
}

export function checkAndConvertToVsp(dbFilePath: string): string {
  const db = new Database(dbFilePath);
  let vsvSQL = ``;
  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);

  if (!tableExists) {
    console.error(
      `The required table "${tableName}" does not exist. Cannot create the vsv table.`,
    );

    db.close();
    return "";
  }

  const participantsStmt = db.prepare(
    `SELECT DISTINCT file_name FROM ${tableName};`,
  );
  const fileNames = participantsStmt.all();

  for (const { file_name } of fileNames) {
    const arrFileName = file_name.split(".");
    const tableNameCgm = `uniform_resource_${arrFileName[0].toLowerCase()}`;
    const vsvSQLCgm = createVsvSQL(dbFilePath, tableNameCgm);

    if (vsvSQLCgm) {
      vsvSQL += vsvSQLCgm;
    }
  }

  db.close();
  return vsvSQL;
}

export async function saveJsonCgm(dbFilePath: string): string {
  const db = new Database(dbFilePath);
  let vsvSQL = ``;

  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);
  // Debugging output
  //console.log(" Table Check Result:", tableExists);

  if (!tableExists) {
    console.error(
      `The required table "${tableName}" does not exist. `,
    );

    db.close();
    return "";
  }

  const db_file_id = ulid();
  const rows = db.prepare(`SELECT * FROM ${tableName}`).all();

  db.exec(`CREATE TABLE IF NOT EXISTS file_meta_ingest_data (
    file_meta_id text not null,
    db_file_id TEXT NOT NULL,
    participant_display_id text NOT NULL,
    file_meta_data TEXT NULL,
    cgm_data TEXT
  );`);

  for (const row of rows) {
    const jsonObject = {
      device_id: row.device_id,
      file_name: row.file_name,
      devicename: row.devicename,
      file_format: row.file_format,
      source_platform: row.source_platform,
      file_upload_date: row.file_upload_date,
      map_field_of_cgm_date: row.map_field_of_cgm_date,
      map_field_of_cgm_value: row.map_field_of_cgm_value,
      map_field_of_patient_id: row.map_field_of_patient_id,
    };

    const jsonStringMeta = JSON.stringify(jsonObject);

    const file_name = row.file_name.replace(`.${row.file_format}`, "");

    const rows_obs = db.prepare(
      `SELECT * FROM uniform_resource_${file_name} ${
        row.map_field_of_patient_id
          ? `WHERE ${row.map_field_of_patient_id} = '${row.patient_id}'`
          : ""
      }`,
    ).all();
    const jsonStringObs = [];
    let isNonCommaseparated = false;
    for (const row_obs of rows_obs) {
      let jsonObjectObs;
      if (Object.keys(row_obs).length > 1) {
        // jsonObjectObs = { ...row_obs };
      } else {
        isNonCommaseparated = true;
        const firstKey = Object.keys(row_obs)[0];
        const firstVal = row_obs[firstKey];
        const splitKey = firstKey.split(/[\|;]/);
        const splitValues = firstVal.split(/[\|;]/);

        jsonObjectObs = {};
        splitKey.forEach((key, index) => {
          jsonObjectObs[key] = splitValues[index];
        });
      }
      jsonStringObs.push(jsonObjectObs);
    }

    const jsonStringCgm = isNonCommaseparated
      ? JSON.stringify(jsonStringObs)
      : JSON.stringify(rows_obs);

    db.prepare(
      `INSERT INTO file_meta_ingest_data(file_meta_id, db_file_id, participant_display_id, cgm_data, file_meta_data) VALUES (?, ?, ?, ?,?);`,
    ).run(ulid(), db_file_id, row.patient_id, jsonStringCgm, jsonStringMeta);
  }

  db.close();
  return vsvSQL;
}

// Function to create the initial view and return SQL for combined CGM tracing view (first dataset)
export function createCommonCombinedCGMViewSQL(dbFilePath: string): string {
  const db = new Database(dbFilePath);

  // Check if the required table exists
  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);

  if (!tableExists) {
    console.error(
      `The required table "${tableName}" does not exist. Cannot create the combined view.`,
    );
    db.close();
    return "";
  }

  const cgmDateStmt = db.prepare(`SELECT CASE 
      WHEN EXISTS (
          SELECT 1 
          FROM pragma_table_info('uniform_resource_cgm_file_metadata') 
          WHERE name = 'map_field_of_cgm_date'
      ) THEN 1
      ELSE 0
  END AS map_field_of_cgm_date_exists;`);
  const cgm_date_row = cgmDateStmt.get();
  const map_field_of_cgm_date_exists = cgm_date_row
    ?.map_field_of_cgm_date_exists;

  const cgmValueStmt = db.prepare(`SELECT CASE 
      WHEN EXISTS (
          SELECT 1 
          FROM pragma_table_info('uniform_resource_cgm_file_metadata') 
          WHERE name = 'map_field_of_cgm_value'
      ) THEN 1
      ELSE 0 
  END AS map_field_of_cgm_value_exists;`);
  const cgm_value_row = cgmValueStmt.get();
  const map_field_of_cgm_value_exists = cgm_value_row
    ?.map_field_of_cgm_value_exists;

  try {
    // Execute the initial view
    db.exec(`DROP VIEW IF EXISTS drh_participant_file_names;`);
    db.exec(`
      CREATE VIEW drh_participant_file_names AS
      SELECT patient_id, GROUP_CONCAT(file_name, ', ') AS file_names ${
      map_field_of_cgm_date_exists ? ", map_field_of_cgm_date" : ""
    } ${map_field_of_cgm_value_exists ? ",map_field_of_cgm_value" : ""}  
      FROM uniform_resource_cgm_file_metadata
      GROUP BY patient_id;
    `);

    //console.log("View 'drh_participant_file_names' created successfully.");
  } catch (error) {
    //console.error("Error creating view 'drh_participant_file_names':", error);
    logError(db, error.message);
    db.close();
    return "";
  }

  const participantsStmt = db.prepare(
    "SELECT DISTINCT patient_id FROM drh_participant_file_names;",
  );
  const participants = participantsStmt.all();

  const sqlParts: string[] = [];
  for (const { patient_id } of participants) {
    const fileNamesStmt = db.prepare(
      `SELECT file_names ${
        map_field_of_cgm_date_exists ? ", map_field_of_cgm_date" : ""
      } ${
        map_field_of_cgm_value_exists ? ",map_field_of_cgm_value" : ""
      }  FROM drh_participant_file_names WHERE patient_id = ?;`,
    );
    const file_names_row = fileNamesStmt.get(patient_id);

    if (!file_names_row) {
      //console.log(`No file names found for participant ${patient_id}.`);
      continue;
    }

    const file_names = file_names_row.file_names;
    const mapFieldOfCGMDate = map_field_of_cgm_date_exists
      ? file_names_row?.map_field_of_cgm_date
      : "date_time";
    const mapFieldOfCGMValue = map_field_of_cgm_value_exists
      ? file_names_row?.map_field_of_cgm_value
      : "cgm_value";

    let cgmDate = "";

    if (mapFieldOfCGMDate.includes("/")) {
      let arrDates = mapFieldOfCGMDate.split("/");
      cgmDate = `datetime(${arrDates[0]} || '-' || printf('%02d',${
        arrDates[1]
      }) || '-' || printf('%02d',${arrDates[2]})) as Date_Time`;
    } else {
      cgmDate =
        `strftime('%Y-%m-%d %H:%M:%S', "${mapFieldOfCGMDate}") as Date_Time`;
    }

    if (file_names) {
      const participantTableNames = file_names.split(", ").map((fileName) =>
        `uniform_resource_${fileName}`
      );
      participantTableNames.forEach((tableName) => {
        const arrTableName = tableName.split(".");
        sqlParts.push(`
          SELECT 
             'IL0001' as tenant_id,
            '${patient_id}' as participant_id, 
            ${cgmDate}, 
            CAST("${mapFieldOfCGMValue}" as REAL) as CGM_Value 
          FROM ${arrTableName[0]}
        `);
      });
    }
    fileNamesStmt.finalize();
  }

  let combinedViewSQL = "";
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    combinedViewSQL = `DROP VIEW IF EXISTS combined_cgm_tracing;
      CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    //console.log("No participant tables found, so the combined view will not be created.");
  }

  participantsStmt.finalize();
  db.close();

  return combinedViewSQL; // Return the SQL string instead of executing it
}

// Function to create the initial view and return SQL for combined CGM tracing view (first dataset)
export function createUVACombinedCGMViewSQL(dbFilePath: string): string {
  const db = new Database(dbFilePath);

  // Check if the required table exists
  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);

  if (!tableExists) {
    console.error(
      `The required table "${tableName}" does not exist. Cannot create the combined view.`,
    );
    db.close();
    return "";
  }

  try {
    // Execute the initial view
    db.exec(`DROP VIEW IF EXISTS drh_participant_file_names;`);
    db.exec(`
      CREATE VIEW drh_participant_file_names AS
      SELECT patient_id, GROUP_CONCAT(file_name, ', ') AS file_names
      FROM uniform_resource_cgm_file_metadata
      GROUP BY patient_id;
    `);
    //console.log("View 'drh_participant_file_names' created successfully.");
  } catch (error) {
    //console.error("Error creating view 'drh_participant_file_names':", error);
    logError(db, error.message);
    db.close();
    return "";
  }

  const participantsStmt = db.prepare(
    "SELECT DISTINCT patient_id FROM drh_participant_file_names;",
  );
  const participants = participantsStmt.all();

  const sqlParts: string[] = [];
  for (const { patient_id } of participants) {
    const fileNamesStmt = db.prepare(
      "SELECT file_names FROM drh_participant_file_names WHERE patient_id = ?;",
    );
    const file_names_row = fileNamesStmt.get(patient_id);

    if (!file_names_row) {
      //console.log(`No file names found for participant ${patient_id}.`);
      continue;
    }

    const file_names = file_names_row.file_names;
    if (file_names) {
      const participantTableNames = file_names.split(", ").map((fileName) =>
        `uniform_resource_${fileName}`
      );
      participantTableNames.forEach((tableName) => {
        sqlParts.push(`
          SELECT 
             'UVA001' as tenant_id,
            '${patient_id}' as participant_id, 
            strftime('%Y-%m-%d %H:%M:%S', date_time) as Date_Time, 
            CAST(CGM_Value as REAL) as CGM_Value 
          FROM ${tableName}
        `);
      });
    }
    fileNamesStmt.finalize();
  }

  let combinedViewSQL = "";
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    combinedViewSQL =
      `CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    //console.log("No participant tables found, so the combined view will not be created.");
  }

  participantsStmt.finalize();
  db.close();

  return combinedViewSQL; // Return the SQL string instead of executing it
}

// Function to generate the combined CGM tracing view SQL for the second dataset
export function generateDetrendedDSCombinedCGMViewSQL(
  dbFilePath: string,
): string {
  const db = new Database(dbFilePath);

  const tablesStmt = db.prepare(
    "SELECT name AS table_name FROM sqlite_master WHERE type = 'table' AND name LIKE 'uniform_resource_case__%'",
  );
  const tables = tablesStmt.all();
  const sqlParts: string[] = [];

  // Fetch the tenant_id from the party table (assuming it returns a single result)
  const tenantStmt = db.prepare(
    "SELECT party_id AS tenant_id FROM party LIMIT 1",
  );
  const tenantResult = tenantStmt.get();
  const tenantId = tenantResult ? tenantResult.tenant_id : "DFA001"; // Default to 'DFA001' if no tenant_id found

  const studyStmt = db.prepare(
    "select study_id from uniform_resource_study limit 1",
  );
  const studyResult = studyStmt.get();
  const studyId = studyResult ? studyResult.studyId : "DFA";

  // Loop through each table and generate the SQL for their CGM data
  for (const { table_name } of tables) {
    const participantId = table_name.split("__").pop(); // Extract participant ID from the table name

    // Generate SQL for each participant's CGM data
    sqlParts.push(`
      SELECT 
        '${tenantId}' as tenant_id,        
        'DFA' as study_id,
        TRIM('DFA-'||'${participantId}') AS participant_id, 
        strftime('%Y-%m-%d %H:%M:%S', hora ) AS Date_Time,
        CAST(glucemia AS REAL) AS CGM_Value 
      FROM ${table_name}
    `);
  }

  let combinedViewSQL = "";
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    combinedViewSQL =
      `CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    //console.log("No participant tables found, so the combined view will not be created.");
  }

  db.close();

  return combinedViewSQL; // Return the SQL string instead of executing it
}

// Function to generate the combined CGM tracing view SQL
export function generateCombinedRTCCGMSQL(dbFilePath: string): string {
  const db = new Database(dbFilePath);

  // Query to fetch all relevant tables (matching the pattern 'uniform_resource_tblADataRTCGM_%')
  const tablesStmt = db.prepare(
    "SELECT name AS table_name FROM sqlite_master WHERE type = 'table' AND name LIKE 'uniform_resource_tbladatartcgm_%'",
  );
  const tables = tablesStmt.all();
  const sqlParts: string[] = [];

  // Fetch the tenant_id from the party table (assuming it returns a single result)
  const tenantStmt = db.prepare(
    "SELECT party_id AS tenant_id FROM party LIMIT 1",
  );
  const tenantResult = tenantStmt.get();
  const tenantId = tenantResult ? tenantResult.tenant_id : "JAEB001"; // Default to 'JAEB001' if no tenant_id found

  // Fetch the study_id from the uniform_resource_study table (assuming it returns a single result)
  const studyStmt = db.prepare(
    "SELECT study_id FROM uniform_resource_study LIMIT 1",
  );
  const studyResult = studyStmt.get();
  const studyId = studyResult ? studyResult.study_id : "RTCCGM"; // Default to 'RTCCGM' if no study_id found

  // Loop through each table and generate the SQL for their CGM data
  for (const { table_name } of tables) {
    // Generate SQL for each participant's CGM data
    sqlParts.push(`
      SELECT 
        '${tenantId}' AS tenant_id,        
        '${studyId}' AS study_id,
        'RTCCGM-' || PtID AS participant_id, 
        strftime('%Y-%m-%d %H:%M:%S', DeviceDtTm) AS Date_Time,
        CAST(Glucose AS REAL) AS CGM_Value 
      FROM ${table_name}
    `);
  }

  // Combine all the individual SELECT queries using UNION ALL
  let combinedViewSQL = "";
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    combinedViewSQL =
      `CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    // If no tables were found, no view will be created
    console.log(
      "No matching tables found. The combined CGM tracing view will not be created.",
    );
  }

  // Close the database connection
  db.close();

  return combinedViewSQL; // Return the generated SQL string
}

function fetchCgmData(
  db: Database,
  file_name: string,
  map_field_of_patient_id: string,
  patient_id: string,
): string {
  try {
    const rows_obs = db
      .prepare(
        `SELECT * FROM uniform_resource_${file_name} WHERE ${map_field_of_patient_id} = ?`,
      )
      .all(patient_id);

    const jsonStringObs = [];
    let isNonCommaseparated = false;

    for (const row_obs of rows_obs) {
      let jsonObjectObs;
      if (Object.keys(row_obs).length > 1) {
        jsonObjectObs = { ...row_obs };
      } else {
        isNonCommaseparated = true;
        const firstKey = Object.keys(row_obs)[0];
        const firstVal = row_obs[firstKey];
        const splitKey = firstKey.split(/[\|;]/);
        const splitValues = firstVal.split(/[\|;]/);

        jsonObjectObs = {};
        splitKey.forEach((key, index) => {
          jsonObjectObs[key] = splitValues[index];
        });
      }
      jsonStringObs.push(jsonObjectObs);
    }

    return isNonCommaseparated
      ? JSON.stringify(jsonStringObs)
      : JSON.stringify(rows_obs);
  } catch (error) {
    console.error(`Error fetching CGM data: ${error.message}`);
    return "[]"; // Return empty JSON array if an error occurs
  }
}

export function saveCTRJsonCgm(dbFilePath: string): string {
  const db = new Database(dbFilePath);
  let ctrSQL = "";

  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);
  if (!tableExists) {
    console.error(`The required table "${tableName}" does not exist.`);
    db.close();
    return "";
  }

  const db_file_id = ulid();
  const rows = db.prepare(`SELECT * FROM ${tableName}`).all();

  db.exec(`CREATE TABLE IF NOT EXISTS file_meta_ingest_data (
    file_meta_id text not null,
    db_file_id TEXT NOT NULL,
    participant_display_id TEXT NOT NULL,
    file_meta_data TEXT NULL,
    cgm_data TEXT
  );`);

  for (const row of rows) {
    const jsonObject = {
      device_id: row.device_id,
      file_name: row.file_name,
      devicename: row.devicename,
      file_format: row.file_format,
      source_platform: row.source_platform,
      file_upload_date: row.file_upload_date,
      map_field_of_cgm_date: row.map_field_of_cgm_date,
      map_field_of_cgm_value: row.map_field_of_cgm_value,
      map_field_of_patient_id: row.map_field_of_patient_id,
    };

    const jsonStringMeta = JSON.stringify(jsonObject);

    // Trim the "CTR3-" prefix from patient_id safely
    const deidentID = typeof row.patient_id === "string"
      ? row.patient_id.replace(/^CTR3-/, "")
      : row.patient_id;

    // console.log(
    //   `Processing participant: ${row.patient_id} -> Deidentified ID: ${deidentID}`,
    // );

    const file_name = row.file_name
      .replace(`.${row.file_format}`, "")
      .replace(/[^a-zA-Z0-9_]/g, "");

    if (!file_name) {
      console.warn(`Skipping row due to invalid file name: ${row.file_name}`);
      continue;
    }

    const jsonStringCgm = fetchCgmData(
      db,
      file_name,
      row.map_field_of_patient_id,
      deidentID,
    );

    const file_meta_id = ulid();

    db.prepare(
      `INSERT INTO file_meta_ingest_data(file_meta_id, db_file_id, participant_display_id, cgm_data, file_meta_data) VALUES (?, ?, ?, ?,?);`,
    ).run(
      file_meta_id,
      db_file_id,
      row.patient_id,
      jsonStringCgm,
      jsonStringMeta,
    );
  }

  db.close();
  return ctrSQL;
}

export function savertccgmJsonCgm(dbFilePath: string): string {
  console.log("Opening database:", dbFilePath);
  const db = new Database(dbFilePath);
  let rtccgmSQL = "";

  const tableName = "uniform_resource_cgm_file_metadata";
  console.log("Checking if table exists:", tableName);
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);
  console.log("Table existence check result:", tableExists);

  if (!tableExists) {
    console.error(`The required table "${tableName}" does not exist.`);
    db.close();
    return "";
  }

  const db_file_id = ulid();
  console.log("Generated db_file_id:", db_file_id);

  const recordCountStmt = db.prepare(
    `SELECT COUNT(*) as count FROM ${tableName}`,
  );
  const recordCount = recordCountStmt.get();
  console.log("Total records in table:", recordCount.count);

  if (recordCount.count === 0) {
    console.warn("No records found in table. Exiting function.");
    db.close();
    return "";
  }

  const rows = db.prepare(`SELECT * FROM ${tableName}`).all();
  console.log("Number of rows fetched:", rows.length);

  db.exec(`CREATE TABLE IF NOT EXISTS file_meta_ingest_data (
    file_meta_id text not null,
    db_file_id TEXT NOT NULL,
    participant_display_id TEXT NOT NULL,
    file_meta_data TEXT NULL,
    cgm_data TEXT
  );`);
  console.log("Ensured table file_meta_ingest_data exists.");

  for (const row of rows) {
    console.log("Processing row:", JSON.stringify(row, null, 2));

    const jsonObject = {
      device_id: row.device_id,
      file_name: row.file_name,
      devicename: row.devicename,
      file_format: row.file_format,
      source_platform: row.source_platform,
      file_upload_date: row.file_upload_date,
      map_field_of_cgm_date: row.map_field_of_cgm_date,
      map_field_of_cgm_value: row.map_field_of_cgm_value,
      map_field_of_patient_id: row.map_field_of_patient_id,
    };

    const jsonStringMeta = JSON.stringify(jsonObject);
    console.log("Generated JSON metadata:", jsonStringMeta);

    const deidentID = typeof row.patient_id === "string"
      ? row.patient_id.replace(/^RTCCGM-/, "")
      : row.patient_id;
    console.log("De-identified patient ID:", deidentID);

    let file_name = row.file_name;
    if (typeof file_name === "string" && row.file_format) {
      file_name = file_name.replace(`.${row.file_format}`, "");
    }
    console.log("Processed file name:", file_name);

    if (!file_name) {
      console.warn(`Skipping row due to invalid file name: ${row.file_name}`);
      continue;
    }

    console.log("Fetching CGM data...");
    const jsonStringCgm = fetchCgmData(
      db,
      file_name,
      row.map_field_of_patient_id,
      deidentID,
    );
    console.log("Generated CGM data JSON length:", jsonStringCgm?.length);

    const file_meta_id = ulid();
    console.log("Generated file_meta_id:", file_meta_id);

    console.log("Executing INSERT INTO file_meta_ingest_data...");
    try {
      db.prepare(
        `INSERT INTO file_meta_ingest_data(file_meta_id, db_file_id, participant_display_id, cgm_data, file_meta_data) VALUES (?, ?, ?, ?,?);`,
      ).run(
        file_meta_id,
        db_file_id,
        row.patient_id,
        jsonStringCgm,
        jsonStringMeta,
      );
      console.log("Data successfully inserted into file_meta_ingest_data.");
    } catch (error) {
      console.error("Error inserting data:", error);
    }
  }

  console.log("Closing database connection...");
  db.close();
  console.log("Database closed.");
  return rtccgmSQL;
}

export function saveDFAJsonCgm(dbFilePath: string): string {
  const db = new Database(dbFilePath);
  let dfaSQL = "";

  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);
  if (!tableExists) {
    console.error(`The required table "${tableName}" does not exist.`);
    db.close();
    return "";
  }

  const db_file_id = ulid();
  const rows = db.prepare(`SELECT * FROM ${tableName}`).all();

  db.exec(`CREATE TABLE IF NOT EXISTS file_meta_ingest_data (
    file_meta_id text not null,
    db_file_id TEXT NOT NULL,
    participant_display_id TEXT NOT NULL,
    file_meta_data TEXT NULL,
    cgm_data TEXT
  );`);

  for (const row of rows) {
    const jsonObject = {
      device_id: row.device_id,
      file_name: row.file_name,
      devicename: row.devicename,
      file_format: row.file_format,
      source_platform: row.source_platform,
      file_upload_date: row.file_upload_date,
      map_field_of_cgm_date: row.map_field_of_cgm_date,
      map_field_of_cgm_value: row.map_field_of_cgm_value,
      map_field_of_patient_id: row.map_field_of_patient_id,
    };

    const jsonStringMeta = JSON.stringify(jsonObject);

    const file_name = row.file_name.replace(`.${row.file_format}`, "");

    const rows_obs = db.prepare(`SELECT * FROM uniform_resource_${file_name}`)
      .all();
    const jsonStringObs = [];
    let isNonCommaseparated = false;
    for (const row_obs of rows_obs) {
      let jsonObjectObs;
      if (Object.keys(row_obs).length > 1) {
        jsonObjectObs = { ...row_obs };
      } else {
        isNonCommaseparated = true;
        const firstKey = Object.keys(row_obs)[0];
        const firstVal = row_obs[firstKey];
        const splitKey = firstKey.split(/[\|;]/);
        const splitValues = firstVal.split(/[\|;]/);

        jsonObjectObs = {};
        splitKey.forEach((key, index) => {
          jsonObjectObs[key] = splitValues[index];
        });
      }
      jsonStringObs.push(jsonObjectObs);
    }

    const jsonStringCgm = isNonCommaseparated
      ? JSON.stringify(jsonStringObs)
      : JSON.stringify(rows_obs);

    db.prepare(
      `INSERT INTO file_meta_ingest_data(file_meta_id, db_file_id, participant_display_id, cgm_data, file_meta_data) VALUES (?, ?, ?, ?,?);`,
    ).run(ulid(), db_file_id, row.patient_id, jsonStringCgm, jsonStringMeta);
  }

  db.close();
  return dfaSQL;
}

export function generateMealFitnessJson(dbFilePath: string) {
  const db = new Database(dbFilePath);
  let mealJson = "";

  // Step 1: Ensure tables exist
  db.exec(`
        CREATE TABLE IF NOT EXISTS uniform_resource_fitness_data (
            fitness_id TEXT PRIMARY KEY,
            participant_id TEXT,
            date TEXT,
            steps INTEGER,
            exercise_minutes INTEGER,
            calories_burned INTEGER,
            distance INTEGER,
            heart_rate INTEGER
        );

        CREATE TABLE IF NOT EXISTS uniform_resource_meal_data (
            meal_id TEXT PRIMARY KEY,
            participant_id TEXT,
            meal_time TEXT,
            calories INTEGER,
            meal_type TEXT
        );

        CREATE TABLE IF NOT EXISTS participant_meal_fitness_data (
            db_file_id TEXT,
            tenant_id TEXT,
            study_display_id TEXT,
            fitness_meal_id TEXT,
            participant_display_id TEXT,
            meal_data TEXT DEFAULT '[]',
            fitness_data TEXT DEFAULT '[]'
        );
    `);

  // Step 2: Get participants who have at least one meal OR fitness record
  const participantIds = db.prepare(`
        SELECT participant_id FROM uniform_resource_meal_data
        UNION
        SELECT participant_id FROM uniform_resource_fitness_data
    `).all();

  // Step 3: Get study metadata (single-row values)
  const studyMetadata: {
    db_file_id: string;
    tenant_id: string;
    study_display_id: string;
  } = db.prepare(`
        SELECT 
            COALESCE((SELECT db_file_id FROM file_meta_ingest_data LIMIT 1), 'UNKNOWN') AS db_file_id,
            COALESCE((SELECT party_id FROM party LIMIT 1), 'UNKNOWN') AS tenant_id,
            COALESCE((SELECT study_id FROM uniform_resource_study LIMIT 1), 'UNKNOWN') AS study_display_id
    `).get() ||
    {
      db_file_id: "UNKNOWN",
      tenant_id: "UNKNOWN",
      study_display_id: "UNKNOWN",
    };

  if (!studyMetadata.db_file_id || studyMetadata.db_file_id === "UNKNOWN") {
    console.error("❌ ERROR: Missing db_file_id. Check database records.");
    return;
  }

  // console.log("🟢 Preparing to insert participant data...");
  // console.log(`🔹 db_file_id: ${studyMetadata.db_file_id}`);
  // console.log(`🔹 tenant_id: ${studyMetadata.tenant_id}`);
  // console.log(`🔹 study_display_id: ${studyMetadata.study_display_id}`);

  // // Step 4: Prepare insert statement (NO conflict update)
  // const insertStmt = db.prepare(`
  //     INSERT INTO participant_meal_fitness_data (
  //         db_file_id, tenant_id, study_display_id, fitness_meal_id,
  //         participant_display_id, meal_data, fitness_data
  //     )
  //     VALUES (@db_file_id, @tenant_id, @study_display_id, @fitness_meal_id,
  //             @participant_display_id, @meal_data, @fitness_data);
  // `);

  // Step 5: Loop through each participant and insert JSON
  db.transaction(() => {
    for (const { participant_id } of participantIds) {
      //console.log(`🔄 Processing participant: ${participant_id}`);

      // Fetch meal data
      const meals = db.prepare(`

                SELECT json_group_array(json_object(
                    'meal_id', meal_id,
                    'meal_time', meal_time,
                    'calories', calories,
                    'meal_type', meal_type
                )) AS meal_data
                FROM uniform_resource_meal_data
                WHERE participant_id = ?
            `).get(participant_id) as { meal_data: string | null };

      // Fetch fitness data
      const fitness = db.prepare(`
                SELECT json_group_array(json_object(
                    'fitness_id', fitness_id,
                    'date', date,
                    'steps', steps,
                    'exercise_minutes', exercise_minutes,
                    'calories_burned', calories_burned,
                    'distance', distance,
                    'heart_rate', heart_rate
                )) AS fitness_data
                FROM uniform_resource_fitness_data
                WHERE participant_id = ?
            `).get(participant_id) as { fitness_data: string | null };

      // Ensure empty arrays for missing data
      const mealDataJson = meals.meal_data ?? "[]";
      const fitnessDataJson = fitness.fitness_data ?? "[]";

      // Skip insert if both meal and fitness data are empty
      if (mealDataJson === "[]" && fitnessDataJson === "[]") {
        console.warn(
          `⚠️ Skipping participant ${participant_id} - No data found.`,
        );
        continue;
      }

      // Generate a ULID for `fitness_meal_id`
      const fitness_meal_id = ulid();

      // console.log("📌 Insert Data:", {
      //     db_file_id: studyMetadata.db_file_id,
      //     tenant_id: studyMetadata.tenant_id,
      //     study_display_id: studyMetadata.study_display_id,
      //     fitness_meal_id,
      //     participant_display_id: participant_id,
      //     meal_data: mealDataJson,
      //     fitness_data: fitnessDataJson
      // });

      console.log("Executing INSERT INTO file_meta_ingest_data...");
      try {
        db.prepare(
          `INSERT INTO participant_meal_fitness_data (
                db_file_id, tenant_id, study_display_id, fitness_meal_id, 
                participant_display_id, meal_data, fitness_data
            )
            VALUES (?, ?, ?, ?,?,?,?);`,
        ).run(
          studyMetadata.db_file_id,
          studyMetadata.tenant_id,
          studyMetadata.study_display_id,
          fitness_meal_id,
          participant_id,
          mealDataJson,
          fitnessDataJson,
        );
        console.log("Data successfully inserted ");
      } catch (error) {
        console.error("Error inserting data:", error);
      }
    }
  })();

  db.close();
  return mealJson;
}

export function generateMealFitnessandMetadataJson(dbFilePath: string) {
  const db = new Database(dbFilePath);
  let mealJson = "";

  db.exec(`
    CREATE TABLE IF NOT EXISTS uniform_resource_fitness_data (
        fitness_id TEXT PRIMARY KEY,
        participant_id TEXT,
        date TEXT,
        steps INTEGER,
        exercise_minutes INTEGER,
        calories_burned INTEGER,
        distance INTEGER,
        heart_rate INTEGER
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_meal_data (
        meal_id TEXT PRIMARY KEY,
        participant_id TEXT,
        meal_time TEXT,
        calories INTEGER,
        meal_type TEXT
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_fitness_file_metadata (
        fitness_meta_id TEXT PRIMARY KEY,
        participant_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        source TEXT NOT NULL,
        file_format TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_meal_file_metadata (
        meal_meta_id TEXT PRIMARY KEY,
        participant_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        source TEXT NOT NULL,
        file_format TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS participant_meal_fitness_data (
        db_file_id TEXT,
        tenant_id TEXT,
        study_display_id TEXT,
        fitness_meal_id TEXT,
        participant_display_id TEXT,
        meal_data TEXT DEFAULT '[]',
        fitness_data TEXT DEFAULT '[]',
        fitness_file_metadata TEXT DEFAULT '[]',   -- JSON array of fitness file metadata objects
        meal_file_metadata TEXT DEFAULT '[]'       -- JSON array of meal file metadata objects
    );
  `);

  // Get all distinct participant_ids present in meal or fitness data
  const participantIds = db.prepare(`
    SELECT participant_id FROM uniform_resource_meal_data
    UNION
    SELECT participant_id FROM uniform_resource_fitness_data
  `).all();

  // Fetch study metadata for insertion
  const studyMetadata = db.prepare(`
    SELECT 
      COALESCE((SELECT db_file_id FROM file_meta_ingest_data LIMIT 1), 'UNKNOWN') AS db_file_id,
      COALESCE((SELECT party_id FROM party LIMIT 1), 'UNKNOWN') AS tenant_id,
      COALESCE((SELECT study_id FROM uniform_resource_study LIMIT 1), 'UNKNOWN') AS study_display_id
  `).get() || {
    db_file_id: "UNKNOWN",
    tenant_id: "UNKNOWN",
    study_display_id: "UNKNOWN",
  };

  if (!studyMetadata.db_file_id || studyMetadata.db_file_id === "UNKNOWN") {
    console.error("❌ ERROR: Missing db_file_id. Check database records.");
    return;
  }

  db.transaction(() => {
    for (const { participant_id } of participantIds) {
      // Get meal data JSON array
      const meals = db.prepare(`
        SELECT json_group_array(json_object(
          'meal_id', meal_id,
          'meal_time', meal_time,
          'calories', calories,
          'meal_type', meal_type
        )) AS meal_data
        FROM uniform_resource_meal_data
        WHERE participant_id = ?
      `).get(participant_id) as { meal_data: string | null };

      // Get fitness data JSON array
      const fitness = db.prepare(`
        SELECT json_group_array(json_object(
          'fitness_id', fitness_id,
          'date', date,
          'steps', steps,
          'exercise_minutes', exercise_minutes,
          'calories_burned', calories_burned,
          'distance', distance,
          'heart_rate', heart_rate
        )) AS fitness_data
        FROM uniform_resource_fitness_data
        WHERE participant_id = ?
      `).get(participant_id) as { fitness_data: string | null };

      // Get meal file metadata JSON array (objects)
      const mealFileMetaRows = db.prepare(`
        SELECT meal_meta_id, file_name, source, file_format
        FROM uniform_resource_meal_file_metadata
        WHERE participant_id = ?
      `).all(participant_id);

      const mealFileMetadataJson = JSON.stringify(mealFileMetaRows.map(row => ({
        meal_meta_id: row.meal_meta_id,
        file_name: row.file_name,
        source: row.source,
        file_format: row.file_format
      })));

      // Get fitness file metadata JSON array (objects)
      const fitnessFileMetaRows = db.prepare(`
        SELECT fitness_meta_id, file_name, source, file_format
        FROM uniform_resource_fitness_file_metadata
        WHERE participant_id = ?
      `).all(participant_id);

      const fitnessFileMetadataJson = JSON.stringify(fitnessFileMetaRows.map(row => ({
        fitness_meta_id: row.fitness_meta_id,
        file_name: row.file_name,
        source: row.source,
        file_format: row.file_format
      })));

      // Fallback to empty arrays if no data
      const mealDataJson = meals.meal_data ?? "[]";
      const fitnessDataJson = fitness.fitness_data ?? "[]";

      // Skip if everything is empty
      if (
        mealDataJson === "[]" &&
        fitnessDataJson === "[]" &&
        mealFileMetadataJson === "[]" &&
        fitnessFileMetadataJson === "[]"
      ) {
        console.warn(`⚠️ Skipping participant ${participant_id} - No data or metadata found.`);
        continue;
      }

      const fitness_meal_id = ulid();

      try {
        db.prepare(`
          INSERT INTO participant_meal_fitness_data (
            db_file_id, tenant_id, study_display_id, fitness_meal_id, participant_display_id, 
            meal_data, fitness_data, fitness_file_metadata, meal_file_metadata
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        `).run(
          studyMetadata.db_file_id,
          studyMetadata.tenant_id,
          studyMetadata.study_display_id,
          fitness_meal_id,
          participant_id,
          mealDataJson,
          fitnessDataJson,
          fitnessFileMetadataJson,
          mealFileMetadataJson
        );
        console.log(`✅ Inserted data for participant ${participant_id}`);
      } catch (error) {
        console.error(`❌ Error inserting data for participant ${participant_id}:`, error);
      }
    }
  })();

  db.close();
  return mealJson;
}



if (import.meta.main) {
  const dbFilePath = "resource-surveillance.sqlite.db";
  const functionName = Deno.args[0]; // Get function name from CLI arguments

  // Map available functions
  const functions: Record<string, (dbFilePath: string) => any> = {
    createUVACombinedCGMViewSQL,
    generateDetrendedDSCombinedCGMViewSQL,
    generateCombinedRTCCGMSQL,
    saveCTRJsonCgm,
    savertccgmJsonCgm,
    saveJsonCgm,
    generateMealFitnessJson,
    transformToMealsAndFitnessJson,    
    generateMealFitnessandMetadataJson
  };

  // Check if the function exists
  if (functionName in functions) {
    const result = functions[functionName](dbFilePath);
    if (result) {
      console.log(`Output for ${functionName}:`);
      console.log(result);
    }
  } else {
    console.log("Invalid function name. Available functions:");
    console.log(Object.keys(functions).join(", "));
  }
}

interface SensorRow {
  sensor_id: number;
  timestamp: number;
  value1: number;
  value2: number;
  value3: number;
}

export function estimateExerciseAndCalories(rows: SensorRow[]) {
  let activeMilliseconds = 0;
  let lastActiveTime: number | null = null;
  const movementThreshold = 12;

  for (const row of rows) {
    const { timestamp, value1, value2, value3 } = row;
      const magnitude = Math.sqrt(value1 ** 2 + value2 ** 2 + value3 ** 2);
      
      if (magnitude > movementThreshold) {
        if (lastActiveTime !== null) {
          activeMilliseconds += timestamp - lastActiveTime;
        }
        lastActiveTime = timestamp;
      } else {
        lastActiveTime = null;
      }
    
  }

  const exerciseMinutes = activeMilliseconds / (1000 * 60);
  const caloriesBurned = exerciseMinutes * 4.5; // Approx. MET value for moderate activity

  return {
    exerciseMinutes: Number(exerciseMinutes.toFixed(2)),
    caloriesBurned: Number(caloriesBurned.toFixed(2)),
  };
}

// Function to create the initial view and return SQL for combined CGM tracing view (first dataset)
export function createGlucCombinedCGMViewSQL(dbFilePath: string): string {
  const db = new Database(dbFilePath);

  // Check if the required table exists
  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);

  if (!tableExists) {
    console.error(
      `The required table "${tableName}" does not exist. Cannot create the combined view.`,
    );
    db.close();
    return "";
  }

  const cgmDateStmt = db.prepare(`SELECT CASE 
      WHEN EXISTS (
          SELECT 1 
          FROM pragma_table_info('uniform_resource_cgm_file_metadata') 
          WHERE name = 'map_field_of_cgm_date'
      ) THEN 1
      ELSE 0
  END AS map_field_of_cgm_date_exists;`);
  const cgm_date_row = cgmDateStmt.get();
  const map_field_of_cgm_date_exists = cgm_date_row
    ?.map_field_of_cgm_date_exists;

  const cgmValueStmt = db.prepare(`SELECT CASE 
      WHEN EXISTS (
          SELECT 1 
          FROM pragma_table_info('uniform_resource_cgm_file_metadata') 
          WHERE name = 'map_field_of_cgm_value'
      ) THEN 1
      ELSE 0 
  END AS map_field_of_cgm_value_exists;`);
  const cgm_value_row = cgmValueStmt.get();
  const map_field_of_cgm_value_exists = cgm_value_row
    ?.map_field_of_cgm_value_exists;

  try {
    // Execute the initial view
    db.exec(`DROP VIEW IF EXISTS drh_participant_file_names;`);
    db.exec(`
      CREATE VIEW drh_participant_file_names AS
      SELECT patient_id, GROUP_CONCAT(file_name, ', ') AS file_names ${
      map_field_of_cgm_date_exists ? ", map_field_of_cgm_date" : ""
    } ${map_field_of_cgm_value_exists ? ",map_field_of_cgm_value" : ""}  
      FROM uniform_resource_cgm_file_metadata
      GROUP BY patient_id;
    `);

    //console.log("View 'drh_participant_file_names' created successfully.");
  } catch (error) {
    //console.error("Error creating view 'drh_participant_file_names':", error);
    logError(db, error.message);
    db.close();
    return "";
  }

  const participantsStmt = db.prepare(
    "SELECT DISTINCT patient_id FROM drh_participant_file_names;",
  );
  const participants = participantsStmt.all();

  const sqlParts: string[] = [];
  for (const { patient_id } of participants) {
    const fileNamesStmt = db.prepare(
      `SELECT file_names ${
        map_field_of_cgm_date_exists ? ", map_field_of_cgm_date" : ""
      } ${
        map_field_of_cgm_value_exists ? ",map_field_of_cgm_value" : ""
      }  FROM drh_participant_file_names WHERE patient_id = ?;`,
    );
    const file_names_row = fileNamesStmt.get(patient_id);

    if (!file_names_row) {
      //console.log(`No file names found for participant ${patient_id}.`);
      continue;
    }

    const file_names = file_names_row.file_names;
    const mapFieldOfCGMDate = map_field_of_cgm_date_exists
      ? file_names_row?.map_field_of_cgm_date
      : "date_time";
    const mapFieldOfCGMValue = map_field_of_cgm_value_exists
      ? file_names_row?.map_field_of_cgm_value
      : "cgm_value";

    let cgmDate = "";

    if (mapFieldOfCGMDate.includes("/")) {
      let arrDates = mapFieldOfCGMDate.split("/");
      cgmDate = `datetime(${arrDates[0]} || '-' || printf('%02d',${
        arrDates[1]
      }) || '-' || printf('%02d',${arrDates[2]})) as Date_Time`;
    } else {
      cgmDate =
        `strftime('%Y-%m-%d %H:%M:%S', ${mapFieldOfCGMDate}) as Date_Time`;
    }

    if (file_names) {
      const participantTableNames = file_names.split(", ").map((fileName) =>
        `uniform_resource_${fileName}`
      );
      participantTableNames.forEach((tableName) => {
        const arrTableName = tableName.split(".");
        sqlParts.push(`
          SELECT 
             'BGU2021' as tenant_id,
            '${patient_id}' as participant_id, 
            ${cgmDate}, 
            CAST(${mapFieldOfCGMValue} as REAL) as CGM_Value 
          FROM ${arrTableName[0]}
        `);
      });
    }
    fileNamesStmt.finalize();
  }

  let combinedViewSQL = "";
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    combinedViewSQL = `DROP VIEW IF EXISTS combined_cgm_tracing;
      CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    //console.log("No participant tables found, so the combined view will not be created.");
  }

  participantsStmt.finalize();
  db.close();

  return combinedViewSQL; // Return the SQL string instead of executing it
}

export function isValidDateTime(value: any): boolean {
  const date = new Date(value);
  return date instanceof Date && !isNaN(date.getTime());
}

export function transformToMealsAndFitnessJson(dbFilePath: string): string {
  const db = new Database(dbFilePath);
  let vsvSQL = ``;

  // Step 1: Ensure tables exist
  db.exec(`
        CREATE TABLE IF NOT EXISTS uniform_resource_fitness_data (
            fitness_id TEXT PRIMARY KEY,
            participant_id TEXT,
            date TEXT,
            steps INTEGER,
            exercise_minutes INTEGER,
            calories_burned INTEGER,
            distance INTEGER,
            heart_rate INTEGER
        );

        CREATE TABLE IF NOT EXISTS uniform_resource_meal_data (
            meal_id TEXT PRIMARY KEY,
            participant_id TEXT,
            meal_time TEXT,
            calories INTEGER,
            meal_type TEXT
        );

        CREATE TABLE IF NOT EXISTS uniform_resource_fitness_file_metadata (
            fitness_meta_id TEXT PRIMARY KEY,
            participant_id TEXT NOT NULL,
            file_name TEXT NOT NULL,
            source TEXT NOT NULL,
            file_format TEXT NOT NULL
        );      
        

        CREATE TABLE IF NOT EXISTS uniform_resource_meal_file_metadata (
            meal_meta_id TEXT PRIMARY KEY,
            participant_id TEXT NOT NULL,
            file_name TEXT NOT NULL,
            source TEXT NOT NULL,
            file_format TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS participant_meal_fitness_data (
            db_file_id TEXT,
            tenant_id TEXT,
            study_display_id TEXT,
            fitness_meal_id TEXT,
            participant_display_id TEXT,
            meal_data TEXT DEFAULT '[]',
            fitness_data TEXT DEFAULT '[]',
            fitness_file_metadata TEXT DEFAULT '[]',   -- JSON array of fitness file metadata objects
            meal_file_metadata TEXT DEFAULT '[]'       -- JSON array of meal file metadata objects
        );
    `);



    // uniform_resource_participant_meals_file_metadata
    // Iterate data from uniform_resource_participant_meals_file_metadata table
    const mealFileRows = db.prepare(
      `SELECT * FROM uniform_resource_participant_meals_file_metadata`
    ).all();

    for (const row of mealFileRows) {
      const mealData = {
        file_name: row.file_name,
        user: row.User,
      };
      const fileNameWithoutCsv = row.file_name.replace(/\.csv$/, "");
      const tableName = `uniform_resource_${fileNameWithoutCsv}`;     
      
      const mealDataRows = db.prepare(
        `SELECT * FROM ${tableName} WHERE activity_id = 1`
      ).all();
      
      for (const mealRow of mealDataRows) {        
        // Determine meal type based on start_time (e.g., hour of day)
        let mealType = "Other";
        if (mealRow.start_time) {
          const hour = (() => {
            // Try to parse hour from time string (supports "HH:mm" or "YYYY-MM-DD HH:mm:ss")
            const timeMatch = mealRow.start_time.match(/(\d{2}):(\d{2})/);
            if (timeMatch) {
              return parseInt(timeMatch[1], 10);
            }
            return -1;
          })();

          if (hour >= 5 && hour < 11) {
            mealType = "Breakfast";
          } else if (hour >= 11 && hour < 16) {
            mealType = "Lunch";
          } else if (hour >= 16 && hour < 22) {
            mealType = "Dinner";
          }
        }

        // Remove 'T' from ISO date-time if present (e.g., "2024-06-10T08:30:00" -> "2024-06-10 08:30:00")
        let mealTime = mealRow.start_time;
        if (typeof mealTime === "string") {
          mealTime = mealTime.replace("T", " ");
        }

        const isDateTime = isValidDateTime(mealTime);
        if (mealType != "Other" && isDateTime) {
          db.prepare(
            `INSERT INTO uniform_resource_meal_data (meal_id, participant_id, meal_time, calories, meal_type) VALUES (?, ?, ?, ?, ?)`,
          ).run(
            ulid(),
            mealData.user,
            mealTime,
            Math.floor(Math.random() * 600 + 200), // random calories between 200 and 800
            mealType
          );
        }
        
      }
      
    }
    
    // Iterate data from uniform_resource_fitness_file_metadata table
    const fitnessFileRows = db.prepare(
      `SELECT * FROM uniform_resource_participant_fitness_file_metadata`
    ).all();
    for (const row of fitnessFileRows) {
      const fitnessData = {
        file_name: row.file_name,
        user: row.User,
      };
      const fileNameWithoutCsv = row.file_name.replace(/\.csv$/, "");
      const tableName = `uniform_resource_${fileNameWithoutCsv.replace(/[.\-]/g, "_")}`;

      
      const stepsRow = db.prepare(
        `SELECT sum(value1) as steps FROM ${tableName} WHERE sensor_id = 18  LIMIT 1`
      ).get() as { steps?: number} | undefined;
      const steps = stepsRow?.steps ?? 0;
      
      
      const stepsDate = db.prepare(
        `SELECT DATE(timestamp/1000.0, 'unixepoch') AS fitness_date FROM ${tableName}  LIMIT 1`
      ).get() as { fitness_date?: string } | undefined;

      const fitnessDate = stepsDate?.fitness_date;
      
      const sensorRows = db.prepare(
        `SELECT sensor_id, timestamp, value1, value2, value3 FROM ${tableName} WHERE sensor_id = 1`
      ).all() as SensorRow[];
      
      const { exerciseMinutes, caloriesBurned } = estimateExerciseAndCalories(sensorRows);

      const distance = ((steps * 0.762) / 1000).toFixed(2); // Convert steps to kilometers (assuming average step length of 0.762 meters)
      const heartRates = db.prepare(
        `SELECT sensor_id, timestamp, value1, value2, value3 FROM ${tableName} WHERE sensor_id = 21`
      ).all() as SensorRow[];
      const heartRateValues = heartRates.map((row) => row.value1); // assuming BPM in value1

      let heartRate;

      if(heartRateValues.length) {  
          const avgHeartRate = heartRateValues.reduce((sum, v) => sum + Number(v), 0) / heartRateValues.length;
          heartRate = avgHeartRate.toFixed(2); 
      } else {
          heartRate = 0; // Default value if no heart rate data is available
      }

      db.prepare(
        `INSERT INTO uniform_resource_fitness_data (fitness_id, participant_id, date, steps, exercise_minutes, calories_burned, distance, heart_rate) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      ).run(
        ulid(),
        fitnessData.user,
        fitnessDate,
        steps,
        exerciseMinutes,
        caloriesBurned,
        distance,
        heartRate
      );  
     
    }

    //
    // Prepare select and update statements
      const selectStmt = db.prepare(
        "SELECT file_meta_id, cgm_data FROM file_meta_ingest_data"
      );
      const updateStmt = db.prepare(
        "UPDATE file_meta_ingest_data SET cgm_data = ? WHERE file_meta_id = ?"
      );

      for (const row of selectStmt.iter()) {
        const { file_meta_id: fileMetaId, cgm_data: cgmJson } = row as { file_meta_id: string, cgm_data: string };
        try {
          const parsed = JSON.parse(cgmJson) as Array<Record<string, unknown>>;

          let changed = false;
          for (const item of parsed) {
            if (
              typeof item.date_time === "string" &&
              item.date_time.includes("T")
            ) {
              item.date_time = item.date_time.replace("T", " ");
              changed = true;
            }
          }

          if (changed) {
            const updatedJson = JSON.stringify(parsed);
            updateStmt.run(updatedJson, fileMetaId);
            // console.log(`Updated row with file_meta_id = ${fileMetaId}`);
          }
        } catch (err) {
          console.error(`Error parsing row with file_meta_id = ${fileMetaId}:`, err);
        }
      }

      selectStmt.finalize();
      updateStmt.finalize();

      const fitnessFileMetaRows = db.prepare(
        `SELECT * FROM uniform_resource_participant_fitness_file_metadata`
      ).all();

      for (const row of fitnessFileMetaRows) {
        db.prepare(
          `INSERT INTO uniform_resource_fitness_file_metadata (fitness_meta_id, participant_id, file_name, source, file_format) VALUES (?, ?, ?, ?, ?)`
        ).run(
          ulid(),
          row.User,
          row.file_name,
          "",
          row.file_format
        );
      }

      const mealFileMetaRows = db.prepare(
        `SELECT * FROM uniform_resource_participant_meals_file_metadata`
      ).all();

      for (const row of mealFileMetaRows) {
        db.prepare(
          `INSERT INTO uniform_resource_meal_file_metadata (meal_meta_id, participant_id, file_name, source, file_format) VALUES (?, ?, ?, ?, ?)`
        ).run(
          ulid(),
          row.User,
          row.file_name,
          "",
          row.file_format
        );
      }

    //

    const studyMetadata: {
      db_file_id: string;
      tenant_id: string;
      study_display_id: string;
    } = db.prepare(`
      SELECT 
        COALESCE((SELECT db_file_id FROM file_meta_ingest_data LIMIT 1), 'UNKNOWN') AS db_file_id,
        COALESCE((SELECT party_id FROM party LIMIT 1), 'UNKNOWN') AS tenant_id,
        COALESCE((SELECT study_id FROM uniform_resource_study LIMIT 1), 'UNKNOWN') AS study_display_id
    `).get() || {
      db_file_id: "UNKNOWN",
      tenant_id: "UNKNOWN",
      study_display_id: "UNKNOWN",
    };

    const participantIds = db.prepare(`
      SELECT participant_id FROM uniform_resource_meal_data
      UNION
      SELECT participant_id FROM uniform_resource_fitness_data
    `).all();

    db.transaction(() => {
      for (const { participant_id } of participantIds) {
        const meals = db.prepare(`
          SELECT json_group_array(json_object(
            'meal_id', meal_id,
            'meal_time', meal_time,
            'calories', calories,
            'meal_type', meal_type
          )) AS meal_data
          FROM uniform_resource_meal_data
          WHERE participant_id = ?
        `).get(participant_id) as { meal_data: string | null };

        const fitness = db.prepare(`
          SELECT json_group_array(json_object(
            'fitness_id', fitness_id,
            'date', date,
            'steps', steps,
            'exercise_minutes', exercise_minutes,
            'calories_burned', calories_burned,
            'distance', distance,
            'heart_rate', heart_rate
          )) AS fitness_data
          FROM uniform_resource_fitness_data
          WHERE participant_id = ?
        `).get(participant_id) as { fitness_data: string | null };

        const mealDataJson = meals.meal_data ?? "[]";
        const fitnessDataJson = fitness.fitness_data ?? "[]";

        if (mealDataJson === "[]" && fitnessDataJson === "[]") {
          continue;
        }

        const fitness_meal_id = ulid();

        const mealFileMetaRows = db.prepare(`
        SELECT meal_meta_id, file_name, source, file_format
        FROM uniform_resource_meal_file_metadata
        WHERE participant_id = ?
      `).all(participant_id);

      const mealFileMetadataJson = JSON.stringify(mealFileMetaRows.map(row => ({
        meal_meta_id: row.meal_meta_id,
        file_name: row.file_name,
        source: row.source,
        file_format: row.file_format
      })));

      // Get fitness file metadata JSON array (objects)
      const fitnessFileMetaRows = db.prepare(`
        SELECT fitness_meta_id, file_name, source, file_format
        FROM uniform_resource_fitness_file_metadata
        WHERE participant_id = ?
      `).all(participant_id);

      const fitnessFileMetadataJson = JSON.stringify(fitnessFileMetaRows.map(row => ({
        fitness_meta_id: row.fitness_meta_id,
        file_name: row.file_name,
        source: row.source,
        file_format: row.file_format
      })));

        db.prepare(
          `INSERT INTO participant_meal_fitness_data (
            db_file_id, tenant_id, study_display_id, fitness_meal_id, 
            participant_display_id, meal_data, fitness_data,
            fitness_file_metadata, meal_file_metadata
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);`
        ).run(
          studyMetadata.db_file_id,
          studyMetadata.tenant_id,
          studyMetadata.study_display_id,
          fitness_meal_id,
          participant_id,
          mealDataJson,
          fitnessDataJson,
          fitnessFileMetadataJson,
          mealFileMetadataJson
        );
      }
    })();

    const combinedViewSQL = createGlucCombinedCGMViewSQL(dbFilePath);
    if (combinedViewSQL) {
      db.exec(combinedViewSQL);
    }

  db.close();
  return vsvSQL;
}