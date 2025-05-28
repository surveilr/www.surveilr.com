#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";
import { ulid } from "https://deno.land/x/ulid/mod.ts";
import { generateMealFitnessJson,generateMealFitnessandMetadataJson } from "../study-specific-stateless/generate-cgm-combined-sql.ts";

export async function saveJsonCgm(dbFilePath: string): string {
  const db = new Database(dbFilePath);
  let vsvSQL = ``;

  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);
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
    //const patient_id = row.patient_id.replace(/^WAD1-001-00/, "");

    // Trim the "CTR3-" prefix from patient_id safely
    const patient_id = typeof row.patient_id === "string"
      ? row.patient_id.replace(/^WADWA-/, "")
      : row.patient_id;

    const rows_obs = db.prepare(
      `SELECT * FROM uniform_resource_${file_name} ${
        row.map_field_of_patient_id
          ? `WHERE CAST(${row.map_field_of_patient_id} AS INTEGER) = ${patient_id}`
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

    let jsonStringCgm = isNonCommaseparated
      ? JSON.stringify(jsonStringObs)
      : JSON.stringify(rows_obs);

    const jsonStringCgm2 = JSON.parse(jsonStringCgm);
    jsonStringCgm = JSON.stringify(jsonStringCgm2.map((item: any) => {
      if (item.DeviceDtTm) {
        const date = new Date(item.DeviceDtTm);
        const formattedDate = `${date.getFullYear()}-${
          String(date.getMonth() + 1).padStart(2, "0")
        }-${String(date.getDate()).padStart(2, "0")} ${
          String(date.getHours()).padStart(2, "0")
        }:${String(date.getMinutes()).padStart(2, "0")}:${
          String(date.getSeconds()).padStart(2, "0")
        }`;
        item.DeviceDtTm = formattedDate;
      }
      return item;
    }));

    db.prepare(
      `INSERT INTO file_meta_ingest_data(file_meta_id, db_file_id, participant_display_id, cgm_data, file_meta_data) VALUES (?, ?, ?, ?,?);`,
    ).run(ulid(), db_file_id, row.patient_id, jsonStringCgm, jsonStringMeta);
  }

  db.close();
  return vsvSQL;
}

export class wadaSqlPages extends spn.TypicalSqlPageNotebook {
  async savecgmSQL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = saveJsonCgm(dbFilePath);
    return await sqlStatements;
  }

  async savemealDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const jsonstmts = generateMealFitnessandMetadataJson(dbFilePath);
    return await jsonstmts;
  }

  //metrics static views shall be generated after the combined_cgm_tracing is created.
  async statelessMetricsSQL() {
    // stateless SQL for the metrics
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve(
        "../drh-metrics.sql",
      ),
    );
  }

  async statelessMetricsExplanationSQL() {
    // Metrics explanations to be displayed in Hover Menu
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve(
        "../metrics-explanation-dml.sql",
      ),
    );
  }
}

export async function wadwaSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelesswadaSQL() {
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/wadwa-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new wadaSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await wadwaSQL()).join("\n"));
}
