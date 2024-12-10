import { DB } from "https://deno.land/x/sqlite/mod.ts";

// Create or connect to SQLite database

// Function to generate a random device ID
function getRandomDeviceId(): string {
  return "DEV-" + Math.floor(Math.random() * 100000).toString(); // Example device ID format
}

// Function to generate a random device name from the list
function getRandomDeviceName(): string {
  const devices = [
    "FreeStyle Navigator",
    "Dexcom SEVEN",
    "Medtronic Paradigm",
  ];

  // Generate a random index and return the corresponding device name
  const randomIndex = Math.floor(Math.random() * devices.length);
  return devices[randomIndex];
}

// Function to insert distinct PtID into cgm_file_metadata
async function insertPtIdToMetadata(db: DB, ptId: string, fileName: string) {
  const metadata_id = "MD-" + Math.floor(Math.random() * 1000000).toString();
  const device_name = getRandomDeviceName();
  const device_id = "";
  const study_id = "RTCCGM";
  const tenant_id = "JAEB001";
  const file_format = "CSV";
  const file_upload_date = "";

  // Trim 'uniform_resource_' from the file name
  const trimmedFileName = fileName.replace(/^uniform_resource_/, "");

  // Append 'RTCCGM-' to PtID
  const ptIdWithPrefix = `RTCCGM-${ptId}`;

  // SQL query to insert into cgm_file_metadata
  const query = `
    INSERT INTO uniform_resource_cgm_file_metadata (metadata_id, patient_id, file_name, study_id, tenant_id, devicename, device_id, file_format, file_upload_date)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  // Execute the insert query
  db.query(query, [
    metadata_id,
    ptIdWithPrefix,
    trimmedFileName,
    study_id,
    tenant_id,
    device_name,
    device_id,
    file_format,
    file_upload_date,
  ]);
  console.log(`Inserted PtID ${ptIdWithPrefix} from file ${trimmedFileName}`);
}

// Function to process all tblADataRTCGM_* tables
export async function processCgmFiles(dbFilePath: string): Promise<string> {
  let db: DB;
  try {
    db = new DB(dbFilePath);

    // Get list of tables in the database
    const tablesQuery =
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'uniform_resource_tblADataRTCGM_%'";
    const tables = db.query(tablesQuery); // db.query returns an array of rows

    if (tables.length === 0) {
      console.log("No tables found matching the pattern.");
      return "No tables found.";
    }

    // Loop through each table
    for (const [table] of tables) {
      console.log(`Processing table: ${table}`);

      // Get distinct PtIDs from the table
      const query = `SELECT DISTINCT PtID FROM ${table}`;
      const ptIds = db.query(query); // db.query returns an array of rows

      if (ptIds.length === 0) {
        console.log(`No PtIDs found in table: ${table}`);
        continue;
      }

      // For each PtID, insert into cgm_file_metadata
      for (const [ptId] of ptIds) {
        await insertPtIdToMetadata(db, ptId, table as string); // Ensure table is a string
      }
    }

    console.log("Processing completed.");
    return "Processing completed.";
  } catch (err) {
    console.error("Error processing CGM files:", err);
    return "Error occurred.";
  } finally {
    if (db) {
      db.close(); // Close the database connection
    }
  }
}

if (import.meta.main) {
  const dbFilePath = "resource-surveillance.sqlite.db";
  // Run the function to process CGM files
  processCgmFiles(dbFilePath);
}
