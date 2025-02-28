#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-net --allow-ffi

import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";
import { ulid } from "https://deno.land/x/ulid/mod.ts";

// Create views before processing CGM data
function createViews(db: Database) {
  db.exec(`
    DROP VIEW IF EXISTS drh_tbldatafreestyleview;
    CREATE VIEW drh_tbldatafreestyleview AS
    SELECT 
        (SELECT party_id FROM party LIMIT 1) AS tenant_id,
        (SELECT study_id FROM uniform_resource_study LIMIT 1) AS study_id,
        (SELECT study_id FROM uniform_resource_study LIMIT 1) || '-' || PtID AS participant_id,
        strftime('%Y-%m-%d %H:%M:%S', ReadingDtTm) AS Date_Time,
        CAST(ReadingValue AS REAL) AS CGM_value
    FROM uniform_resource_tblddatafreestyle;

    DROP VIEW IF EXISTS drh_tblddatacgmsview;
    CREATE VIEW drh_tblddatacgmsview AS
    SELECT 
        (SELECT party_id FROM party LIMIT 1) AS tenant_id,
        (SELECT study_id FROM uniform_resource_study LIMIT 1) AS study_id,
        (SELECT study_id FROM uniform_resource_study LIMIT 1) || '-' || PtID AS participant_id,
        strftime('%Y-%m-%d', ReadingDt) || ' ' ||
        CASE 
            WHEN substr(ReadingTm, -2) = 'PM' AND substr(ReadingTm, 1, 2) != '12' THEN 
                printf('%02d:%s:00', CAST(substr(ReadingTm, 1, instr(ReadingTm, ':') - 1) AS INTEGER) + 12, substr(ReadingTm, instr(ReadingTm, ':') + 1, 2))
            WHEN substr(ReadingTm, -2) = 'AM' AND substr(ReadingTm, 1, 2) = '12' THEN 
                printf('00:%s:00', substr(ReadingTm, instr(ReadingTm, ':') + 1, 2)) 
            WHEN substr(ReadingTm, -2) = 'PM' AND substr(ReadingTm, 1, 2) = '12' THEN 
                printf('12:%s:00', substr(ReadingTm, instr(ReadingTm, ':') + 1, 2))  
            ELSE 
                printf('%02d:%s:00', CAST(substr(ReadingTm, 1, instr(ReadingTm, ':') - 1) AS INTEGER), substr(ReadingTm, instr(ReadingTm, ':') + 1, 2))
        END AS Date_Time,
        CAST(SensorGLU AS REAL) AS CGM_value
    FROM uniform_resource_tblddatacgms;
  `);
}

function fetchCgmData(
  db: Database,
  viewName: string,
  patientId: string,
): string {
  try {
    const rows = db.prepare(
      `SELECT  Date_Time,CGM_value FROM ${viewName} WHERE participant_id = ?`,
    ).all(patientId);
    return JSON.stringify(rows);
  } catch (error) {
    console.error(`Error fetching CGM data: ${error.message}`);
    return "[]"; // Return empty JSON array if an error occurs
  }
}

export function processIEOGCgm(dbFilePath: string): string {
  const db = new Database(dbFilePath);
  createViews(db); // Ensure views exist before querying

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
      map_field_of_cgm_date: "Date_Time",
      map_field_of_cgm_value: "CGM_value",
      map_field_of_patient_id: row.map_field_of_patient_id,
    };

    const jsonStringMeta = JSON.stringify(jsonObject);
    let viewName = "";

    if (row.file_name === "tblDDataFreestyle") {
      viewName = "drh_tbldatafreestyleview";
    } else if (row.file_name === "tblDDataCGMS") {
      viewName = "drh_tblddatacgmsview";
    } else {
      console.warn(`Unknown file type for participant: ${row.patient_id}`);
      continue;
    }

    const jsonStringCgm = fetchCgmData(db, viewName, row.patient_id);

    db.prepare(
      `INSERT INTO file_meta_ingest_data(file_meta_id, db_file_id, participant_display_id, cgm_data, file_meta_data) VALUES (?, ?, ?, ?,?);`,
    ).run(ulid(), db_file_id, row.patient_id, jsonStringCgm, jsonStringMeta);
  }

  db.close();
  return ""; // No need to return `ctrSQL`
}
