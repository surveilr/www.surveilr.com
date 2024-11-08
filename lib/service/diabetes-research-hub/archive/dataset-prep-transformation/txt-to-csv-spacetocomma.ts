import { ensureDirSync } from "https://deno.land/std/fs/mod.ts";
import * as path from "https://deno.land/std/path/mod.ts";

// Define the input text file and output CSV file paths
const inputFilePath = "./detrended-fluctation-analysis/clinical_data.txt"; // Input text file path
const outputFolder =
  "./detrended-fluctation-analysis/S1/detrended-fluctation-analysis-csv-dataset"; // Output folder path
const outputFilePath = path.join(outputFolder, "clinical_data.csv"); // Output CSV file path

// Ensure output directory exists
ensureDirSync(outputFolder);

// Function to convert text data to CSV format
async function convertTextToCsvCommadelimiter(inputFilePath: string) {
  // Read the input text file
  const text = await Deno.readTextFile(inputFilePath);

  // Split the input text into lines
  const lines = text.split("\n");

  // Prepare the CSV data array
  const csvData: string[] = [];

  // Set the header
  const headers = [
    "pid",
    "gender",
    "age",
    "BMI",
    "glycaemia",
    "HbA1c",
    "follow.up",
    "T2DM",
  ];
  csvData.push(headers.join(",")); // Join headers with comma

  // Process each line after the header
  for (const line of lines.slice(1)) {
    if (line.trim() === "") continue; // Skip empty lines
    // Replace double quotes and split by space
    const row = line.replace(/"/g, "").split(/\s+/);

    // Prepend the row with a pid value (based on the first column value)
    const pid = row[0]; // Use the value in the first column as pid
    const newRow = [pid, ...row.slice(1)]; // Keep the rest of the columns

    // Join the new row with comma and add to csvData
    csvData.push(newRow.join(","));
  }

  // Write the CSV data to a file
  await Deno.writeTextFile(outputFilePath, csvData.join("\n"));
  console.log(`Successfully converted to CSV: ${outputFilePath}`);
}

// Convert the input text file to CSV
await convertTextToCsvCommadelimiter(inputFilePath);
