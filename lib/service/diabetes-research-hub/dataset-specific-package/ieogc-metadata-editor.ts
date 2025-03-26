import { readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

(async () => {
  try {
    // Set the correct folder and file path
    const folderPath =
      "/home/anitha/workspaces/github.com/www.surveilr.com/lib/service/diabetes-research-hub/direc-net-inPt-exercise";
    const fileName = "cgm_file_metadata.csv";
    const filePath = join(folderPath, fileName);

    // Read the CSV file
    const csvData = await readFile(filePath, "utf8");

    console.log(`✅ Successfully read CSV from: ${filePath}`);

    // Split CSV into lines
    const lines = csvData.trim().split("\n");

    if (lines.length < 2) {
      console.error("CSV file has no data rows.");
      Deno.exit(1);
    }

    // Extract header and determine column indexes
    const headers = lines[0].split(",");
    const deviceNameIndex = headers.indexOf("devicename");
    const sourcePlatformIndex = headers.indexOf("source_platform");

    if (deviceNameIndex === -1 || sourcePlatformIndex === -1) {
      console.error('Columns "devicename" or "source_platform" not found.');
      Deno.exit(1);
    }

    // Process each row (excluding the header)
    const updatedRows = lines.map((line, index) => {
      if (index === 0) return line; // Keep header unchanged

      const columns = line.split(",");
      const deviceName = columns[deviceNameIndex]?.trim(); // Trim spaces

      if (!deviceName) return line; // Skip if device_name is missing

      // Determine the correct source_platform
      if (deviceName.includes("FreeStyle Navigator")) {
        columns[sourcePlatformIndex] = "Abbott";
      } else if (deviceName.includes("MiniMed Continuous Glucose Monitor")) {
        columns[sourcePlatformIndex] = "MiniMed";
      } else {
        console.warn(
          `⚠️ Unrecognized device: "${deviceName}", leaving source_platform unchanged.`,
        );
      }

      return columns.join(",");
    });

    // Join the updated rows into a CSV string
    const updatedCsv = updatedRows.join("\n");

    // Write the updated CSV back to the file
    await writeFile(filePath, updatedCsv, "utf8");

    console.log(`✅ CSV file "${fileName}" updated successfully.`);
  } catch (error) {
    console.error("❌ Error:", error.message);
  }
})();
