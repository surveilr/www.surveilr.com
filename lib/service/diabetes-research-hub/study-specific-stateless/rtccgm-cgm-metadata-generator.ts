import { DB } from "https://deno.land/x/sqlite/mod.ts";

// Function to generate a random device ID
function getRandomDeviceId(): string {
  return "DEV-" + Math.floor(Math.random() * 100000).toString();
}

// Function to generate a random device with source platform
function getRandomDevice(): { devicename: string; source_platform: string } {
  const devices = [
    { devicename: "FreeStyle Navigator", source_platform: "Abbott" },
    { devicename: "Dexcom G7", source_platform: "Dexcom" },
    { devicename: "Medtronic Paradigm", source_platform: "Medtronic" },
  ];
  return devices[Math.floor(Math.random() * devices.length)];
}

// Function to insert PtID into cgm_file_metadata
function insertPtIdToMetadata(db: DB, ptId: string, fileName: string) {
  console.log(`Preparing to insert PtID: ${ptId} from file: ${fileName}`);

  const metadata_id = "MD-" + Math.floor(Math.random() * 1000000).toString();
  const { devicename, source_platform } = getRandomDevice(); // Get device and source platform
  const device_id = "";
  const study_id = "RTCCGM";
  const tenant_id = "JAEB001";
  const file_format = "csv";
  const file_upload_date = "";
  const data_start_date = "";
  const data_end_date = "";
  const map_field_of_cgm_date = "DeviceDtTm";
  const map_field_of_cgm_value = "Glucose";
  const map_field_of_patient_id = "PtID";

  // Trim 'uniform_resource_' from the file name
  const trimmedFileName = fileName.replace(/^uniform_resource_/, "");
  const ptIdWithPrefix = `RTCCGM-${ptId}`;

  console.log(
    `Generated metadata_id: ${metadata_id}, devicename: ${devicename}, device_id: ${device_id},source_platform=${source_platform}`,
  );

  // SQL query to insert into cgm_file_metadata
  const query = `
    INSERT INTO uniform_resource_cgm_file_metadata (
      metadata_id, devicename, device_id, source_platform, patient_id, file_name, 
      file_format, file_upload_date, data_start_date, data_end_date, study_id, 
      tenant_id, map_field_of_cgm_date, map_field_of_cgm_value, map_field_of_patient_id
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  try {
    db.query(query, [
      metadata_id,
      devicename,
      device_id,
      source_platform,
      ptIdWithPrefix,
      trimmedFileName,
      file_format,
      file_upload_date,
      data_start_date,
      data_end_date,
      study_id,
      tenant_id,
      map_field_of_cgm_date,
      map_field_of_cgm_value,
      map_field_of_patient_id,
    ]);
    console.log(
      `Successfully inserted PtID ${ptIdWithPrefix} from file ${trimmedFileName}`,
    );
  } catch (error) {
    console.error(`Error inserting PtID ${ptIdWithPrefix}:`, error);
  }
}

// Function to process all tblADataRTCGM_* tables
export async function processCgmFiles(dbFilePath: string): Promise<string> {
  let db: DB;
  const result = "";
  try {
    console.log(`Opening database: ${dbFilePath}`);
    db = new DB(dbFilePath);

    // Get list of tables matching the pattern
    const tablesQuery =
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'uniform_resource_tblADataRTCGM_%'";
    const tables = db.query(tablesQuery);

    console.log(`Found ${tables.length} tables matching the pattern.`);

    if (tables.length === 0) {
      console.log("No tables found matching the pattern.");
      return "No tables found.";
    }

    // Loop through each table
    for (const [table] of tables) {
      console.log(`Processing table: ${table}`);

      // Get distinct PtIDs from the table
      const query = `SELECT DISTINCT PtID FROM ${table}`;
      const ptIds = db.query(query);

      console.log(`Found ${ptIds.length} unique PtIDs in table: ${table}`);

      if (ptIds.length === 0) {
        console.log(`No PtIDs found in table: ${table}`);
        continue;
      }

      // Insert each PtID separately for each table
      for (const [ptId] of ptIds) {
        console.log(`Processing PtID: ${ptId} from table: ${table}`);
        await insertPtIdToMetadata(db, ptId as string, table as string);
      }
    }

    console.log("Processing completed.");
    return "Success";
  } catch (err) {
    console.error("Error processing CGM files:", err);
    return "Error occurred.";
  } finally {
    if (db) {
      console.log("Closing database connection.");
      db.close();
    }
  }
}

if (import.meta.main) {
  const dbFilePath = "resource-surveillance.sqlite.db";
  console.log("Starting CGM file processing...");
  processCgmFiles(dbFilePath);
}
