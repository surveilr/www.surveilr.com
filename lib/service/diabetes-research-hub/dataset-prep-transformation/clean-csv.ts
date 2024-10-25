import * as fs from 'node:fs';
import * as path from 'node:path';
import { copySync, ensureDirSync } from "https://deno.land/std@0.203.0/fs/mod.ts"; // Use Deno's fs utilities
import { parse } from "https://deno.land/std@0.203.0/csv/mod.ts"; // Deno CSV parser

// Function to clean a CSV file (removing any 'Unnamed' columns)
async function cleanCsv(filePath: string, outputFolder: string): Promise<void> {
    try {
        // Read and process the CSV file
        const fileContent = await Deno.readTextFile(filePath);
        const rows = await parse(fileContent, { skipFirstRow: false });

        const cleanedRows = rows.map((row: Record<string, string>) =>
            Object.fromEntries(
                Object.entries(row).filter(([key]) => !key.startsWith('Unnamed'))
            )
        );

        // Write the cleaned CSV to the output folder
        const filename = path.basename(filePath);
        const newFilePath = path.join(outputFolder, filename);
        const csvContent = cleanedRows.map((row: Record<string, any>) => Object.values(row).join(',')).join('\n');

        await Deno.writeTextFile(newFilePath, csvContent);
        console.log(`Successfully cleaned and moved '${filePath}' to '${newFilePath}'`);
    } catch (error) {
        console.error(`Error processing file '${filePath}': ${error.message}`);
    }
}

// Function to rename the file by replacing spaces with underscores
function renameFileWithNoSpaces(filePath: string, outputFolder: string): string {
    const filename = path.basename(filePath).replace(/ /g, '_');
    const newFilePath = path.join(outputFolder, filename);
    copySync(filePath, newFilePath);

    console.log(`Renamed and moved file from '${filePath}' to '${newFilePath}'`);
    return newFilePath;
}

// Main function to process files in the input folder
async function processFilesInFolder(inputFolder: string, outputSubfolderName: string = 'detrended-fluctation-analysis-csv-dataset') {
    const outputFolder = path.join(inputFolder, outputSubfolderName);
    ensureDirSync(outputFolder); // Ensure the output folder exists

    for (const entry of Deno.readDirSync(inputFolder)) {
        if (entry.isFile && entry.name.endsWith('.csv')) {
            const filePath = path.join(inputFolder, entry.name);

            // Rename and move the file to the new folder
            const newFilePath = renameFileWithNoSpaces(filePath, outputFolder);

            // Clean the CSV after renaming and moving
            await cleanCsv(newFilePath, outputFolder);
        }
    }
}

// Example usage
const inputFolder = './detrended-fluctation-analysis/S1'; // Replace with your folder path
await processFilesInFolder(inputFolder);
