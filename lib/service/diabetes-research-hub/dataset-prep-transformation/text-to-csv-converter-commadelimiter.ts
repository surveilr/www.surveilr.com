import { ensureDirSync } from "https://deno.land/std/fs/mod.ts";
import * as path from "https://deno.land/std/path/mod.ts";
import Papa from "https://esm.sh/papaparse";

const folderPath = "./ctr-anderson";
const outputFolder = "./ctr-anderson/ctr-anderson-with-comma";

// Ensure output folder exists
ensureDirSync(outputFolder);

// Function to convert text files to CSV
async function convertTxtToCsvSpace(filePath: string, newFilePath: string) {
  // Read the content of the file
  const fileContent = await Deno.readTextFile(filePath);

  // Parse the text file with pipe delimiter
  const results = Papa.parse(fileContent, {
    delimiter: "|", // Specify pipe delimiter
    skipEmptyLines: true,
    header: false, // Change to true if the first line is a header
  });

  // Convert parsed results to CSV format with comma delimiter
  const csvContent = results.data.map((row: string[]) => row.join(",")).join(
    "\n",
  );

  // Write to a new CSV file
  await Deno.writeTextFile(newFilePath, csvContent);
  console.log(
    `Converted ${path.basename(filePath)} to ${path.basename(newFilePath)}`,
  );
}

// Iterate through all files in the folder
for await (const entry of Deno.readDir(folderPath)) {
  if (entry.isFile && entry.name.endsWith(".txt")) {
    const filePath = path.join(folderPath, entry.name);
    const newFileName = entry.name.replace(".txt", ".csv");
    const newFilePath = path.join(outputFolder, newFileName);

    await convertTxtToCsvSpace(filePath, newFilePath);
  }
}
