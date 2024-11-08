import * as fs from "node:fs";
//import * as path from 'node:path';
import {
  copySync,
  ensureDirSync,
} from "https://deno.land/std@0.203.0/fs/mod.ts"; // Use Deno's fs utilities
import { parse } from "https://deno.land/std@0.177.0/encoding/csv.ts"; // Update to the latest stable version
import * as path from "https://deno.land/std@0.177.0/path/mod.ts";

async function cleanCsv(
  filePath: string,
  outputFolder: string,
  baseDate: string = "2012-01-01",
): Promise<void> {
  try {
    const fileContent = await Deno.readTextFile(filePath);

    // Parse the CSV content
    const rows = await parse(fileContent, { skipFirstRow: false }); // Adjust based on your needs
    const cleanedRows = [];

    // Retain headers
    const headers = ["hora", "glucemia"]; // Define the headers you want to retain

    // Iterate over rows and clean data
    for (let i = 0; i < rows.length; i++) {
      let row = rows[i];

      // Remove the first column (index 0)
      row = row.slice(1);

      // Access and clean 'hora' value
      const hora = row[0]?.trim().replace(/"/g, ""); // Ensure this matches the correct index after slicing

      if (!hora) {
        console.error(`Missing hora for row: ${JSON.stringify(row)}`);
        continue; // Skip this row if hora is missing
      }

      // Ensure that hora is in the correct format (HH:MM:SS)
      const timeParts = hora.split(":");
      if (timeParts.length !== 3) {
        console.error(`Invalid hora format for row: ${JSON.stringify(row)}`);
        continue; // Skip if the format is incorrect
      }

      // Add leading zeros to hours, minutes, and seconds if necessary
      const [hours, minutes, seconds] = timeParts.map((part) => {
        return part.padStart(2, "0"); // Add leading zero
      });

      // Combine base date with formatted time
      const formattedHora = `${baseDate} ${hours}:${minutes}:${seconds}`;
      cleanedRows.push([formattedHora, ...row.slice(1)]); // Include the cleaned hora and remaining columns
    }

    // Increment the date every 288 records
    const finalRows = cleanedRows.map((row, index) => {
      const newDate = new Date(baseDate);
      newDate.setDate(newDate.getDate() + Math.floor(index / 288)); // Increment the date by 1 after every 288 records
      return [
        row[0].replace(baseDate, newDate.toISOString().split("T")[0]),
        ...row.slice(1),
      ]; // Replace the date
    });

    // Write the cleaned CSV to the output folder with headers
    const filename = path.basename(filePath);
    const newFilePath = path.join(outputFolder, filename);
    const csvContent = [headers, ...finalRows].map((row) => row.join(",")).join(
      "\n",
    ); // Add headers to the beginning

    // Ensure the output folder exists
    ensureDirSync(outputFolder);
    await Deno.writeTextFile(newFilePath, csvContent);
    console.log(
      `Successfully cleaned and moved '${filePath}' to '${newFilePath}'`,
    );
  } catch (error) {
    console.error(`Error processing file '${filePath}': ${error.message}`);
  }
}

// Function to rename the file by replacing spaces with underscores
function renameFileWithNoSpaces(
  filePath: string,
  outputFolder: string,
): string {
  const filename = path.basename(filePath).replace(/ /g, "_");
  const newFilePath = path.join(outputFolder, filename);
  copySync(filePath, newFilePath);

  console.log(`Renamed and moved file from '${filePath}' to '${newFilePath}'`);
  return newFilePath;
}

// Main function to process files in the input folder
async function processFilesInFolder(
  inputFolder: string,
  baseDate: string,
  outputSubfolderName: string = "detrended-fluctation-analysis-csv-dataset",
) {
  const outputFolder = path.join(inputFolder, outputSubfolderName);
  ensureDirSync(outputFolder); // Ensure the output folder exists

  for (const entry of Deno.readDirSync(inputFolder)) {
    if (entry.isFile && entry.name.endsWith(".csv")) {
      const filePath = path.join(inputFolder, entry.name);

      // Rename and move the file to the new folder
      const newFilePath = renameFileWithNoSpaces(filePath, outputFolder);

      // Clean the CSV after renaming and moving
      await cleanCsv(newFilePath, outputFolder, baseDate);
    }
  }
}

// Example usage
const inputFolder = "./detrended-fluctation-analysis/S1"; // Replace with your folder path
const baseDate = "2012-01-01"; // Set your base date here
await processFilesInFolder(inputFolder, baseDate);
