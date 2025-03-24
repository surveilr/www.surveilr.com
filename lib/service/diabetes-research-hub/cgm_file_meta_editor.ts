import { readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

(async () => {
  try {
    // Get the directory of the script file
    const __dirname = dirname(fileURLToPath(import.meta.url));

    // Define the folder and file path
    const folderPath = join(__dirname, "de-trended-analysis-files"); // Adjust folder name as needed
    const fileName = "cgm_file_metadata.csv";
    const filePath = join(folderPath, fileName);

    // Read the CSV file
    const data = await readFile(filePath, "utf8");

    // Split CSV into lines
    const lines = data.split("\n");

    // Extract header
    const header = lines[0].split(",");

    // Find the index of the 'source_platform' column
    const sourcePlatformIndex = header.indexOf("source_platform");
    if (sourcePlatformIndex === -1) {
      console.error('Column "source_platform" not found.');
      Deno.exit(1);
    }

    // Process each row (skip the header)
    const updatedRows = lines.map((line, index) => {
      if (index === 0 || line.trim() === "") return line; // Keep header and empty lines unchanged

      const columns = line.split(",");
      columns[sourcePlatformIndex] = "Medtronic"; // Update 'source_platform' column
      return columns.join(",");
    });

    // Join the modified lines into a CSV string
    const updatedCsv = updatedRows.join("\n");

    // Write the updated CSV back to the file
    await writeFile(filePath, updatedCsv, "utf8");

    console.log(`CSV file "${fileName}" updated successfully.`);
  } catch (error) {
    console.error("Error:", error.message);
  }
})();
