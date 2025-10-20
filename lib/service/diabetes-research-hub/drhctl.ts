#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-net --allow-ffi

import { $ } from "https://deno.land/x/dax@0.33.0/mod.ts";
import { existsSync } from "https://deno.land/std/fs/mod.ts";
import * as colors from "https://deno.land/std@0.224.0/fmt/colors.ts";
import * as drhUx from "./drhctl-package.sql.ts";
import { ensureDir } from "https://deno.land/std@0.201.0/fs/mod.ts";
import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";

import {
  FlexibleTextSupplierSync,
  spawnedResult,
  textFromSupplierSync,
} from "../../universal/spawn.ts";

// Constants
const isWindows = Deno.build.os === "windows";
const toolCmd = isWindows ? ".\\surveilr" : "surveilr";
const dbFilePath = "resource-surveillance.sqlite.db";
const requiredExtension = ".csv";
const cgmMetadataFileName = "cgm_file_metadata.csv";

// --- Schema Definitions for Validation ---

type ColumnSchema = {
  name: string;
  required: boolean;
};

type FileSchema = {
  fileName: string; // Base name for single files, or pattern for multiple
  required: boolean;
  multiple: boolean;
  columns: ColumnSchema[];
};

const schemas: Record<string, FileSchema> = {
  // Required Files
  "cgm_file_metadata": {
    fileName: "cgm_file_metadata.csv",
    required: true,
    multiple: false,
    columns: [
      { name: "metadata_id", required: true },
      { name: "devicename", required: false },
      { name: "device_id", required: false },
      { name: "source_platform", required: false },
      { name: "patient_id", required: true },
      { name: "file_name", required: true }, // Required and checked for emptiness
      { name: "file_format", required: false },
      { name: "file_upload_date", required: false },
      { name: "data_start_date", required: false },
      { name: "data_end_date", required: false },
      { name: "map_field_of_cgm_date", required: true }, // Required and checked for emptiness
      { name: "map_field_of_cgm_value", required: true }, // Required and checked for emptiness
      { name: "study_id", required: true },
    ],
  },
  "participant": {
    fileName: "participant.csv",
    required: true,
    multiple: false,
    columns: [
      { name: "participant_id", required: true },
      { name: "study_id", required: true },
      { name: "site_id", required: false },
      { name: "diagnosis_icd", required: false },
      { name: "med_rxnorm", required: false },
      { name: "treatment_modality", required: false },
      { name: "gender", required: false },
      { name: "race_ethnicity", required: false },
      { name: "age", required: false },
      { name: "bmi", required: false },
      { name: "baseline_hba1c", required: false },
      { name: "diabetes_type", required: false },
      { name: "study_arm", required: false },
    ],
  },
  // Recommended Files
  "site": {
    fileName: "site.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "study_id", required: true },
      { name: "site_id", required: true },
      { name: "site_name", required: false },
      { name: "site_type", required: false },
    ],
  },
  "study": {
    fileName: "study.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "study_id", required: true },
      { name: "study_name", required: false },
      { name: "start_date", required: false },
      { name: "end_date", required: false },
      { name: "treatment_modalities", required: false },
      { name: "funding_source", required: false },
      { name: "nct_number", required: false },
      { name: "study_description", required: false },
    ],
  },
  "investigator": {
    fileName: "investigator.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "investigator_id", required: true },
      { name: "investigator_name", required: false },
      { name: "email", required: false },
      { name: "institution_id", required: false },
      { name: "study_id", required: true },
    ],
  },
  // Optional Files (Conditional existence check in App.run)
  "meal_data": {
    fileName: "meal_data.csv",
    required: false,
    multiple: true,
    columns: [
      { name: "meal_id", required: true },
      { name: "participant_id", required: true },
      { name: "meal_time", required: true },
      { name: "calories", required: false },
      { name: "meal_type", required: false },
    ],
  },
  "meal_file_metadata": {
    fileName: "meal_file_metadata.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "meal_meta_id", required: true },
      { name: "participant_id", required: true },
      { name: "file_name", required: true },
      { name: "source", required: false },
      { name: "file_format", required: false },
    ],
  },
  "fitness_data": {
    fileName: "fitness_data.csv",
    required: false,
    multiple: true,
    columns: [
      { name: "fitness_id", required: true },
      { name: "participant_id", required: true },
      { name: "date", required: true },
      { name: "steps", required: false },
      { name: "exercise_minutes", required: false },
      { name: "calories_burned", required: false },
      { name: "distance", required: false },
      { name: "heart_rate", required: false },
    ],
  },
  "fitness_file_metadata": {
    fileName: "fitness_file_metadata.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "fitness_meta_id", required: true },
      { name: "participant_id", required: true },
      { name: "file_name", required: true },
      { name: "source", required: false },
      { name: "file_format", required: false },
    ],
  },
  // Other Optional Files (Only existence and schema validation)
  "institution": {
    fileName: "institution.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "institution_id", required: true },
      { name: "institution_name", required: false },
      { name: "city", required: false },
      { name: "state", required: false },
      { name: "country", required: false },
    ],
  },
  "lab": {
    fileName: "lab.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "lab_id", required: true },
      { name: "lab_name", required: false },
      { name: "lab_pi", required: false },
      { name: "institution_id", required: false },
      { name: "study_id", required: false },
    ],
  },
  "author": {
    fileName: "author.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "author_id", required: true },
      { name: "name", required: false },
      { name: "email", required: false },
      { name: "investigator_id", required: false },
      { name: "study_id", required: false },
    ],
  },
  "publication": {
    fileName: "publication.csv",
    required: false,
    multiple: false,
    columns: [
      { name: "publication_id", required: true },
      { name: "publication_title", required: false },
      { name: "digital_object_identifier", required: false },
      { name: "publication_site", required: false },
      { name: "study_id", required: false },
    ],
  },
};

// --- Helper Functions ---

async function executeSqlBatch(
  dbPath: string,
  sqlContent: string,
): Promise<void> {
  let db: Database | null = null;
  // ... (function body for direct execution)
  try {
    console.log(`Executing SQL batch directly on: ${dbPath}`);
    db = new Database(dbPath);
    db.exec(sqlContent);
  } catch (error) {
    // ... (error handling)
    throw error;
  } finally {
    if (db) db.close();
  }
}

/** Reads the first line of a CSV file to get headers. */
async function getFileHeaders(filePath: string): Promise<string[]> {
  try {
    const content = await Deno.readTextFile(filePath);
    const firstLine = content.split("\n")[0];
    if (!firstLine) return [];
    // Assuming comma delimiter and trimming quotes/whitespace
    return firstLine.split(",").map((h) =>
      h.trim().replace(/^['"]|['"]$/g, "")
    );
  } catch (e) {
    throw new Error(`Failed to read headers from ${filePath}: ${e.message}`);
  }
}

/** Reads the content of a CSV file. */
async function getFileContent(filePath: string): Promise<string[]> {
  try {
    const content = await Deno.readTextFile(filePath);
    // Split by line, remove header (first line), and trim to get data lines
    const lines = content.trim().split("\n").slice(1).map((line) => line.trim())
      .filter((line) => line.length > 0);
    return lines;
  } catch (e) {
    throw new Error(`Failed to read content from ${filePath}: ${e.message}`);
  }
}

class Validator {
  /**
   * 1. Check folder name for spaces.
   */
  static checkFolderName(dirPath: string): void {
    dirPath = dirPath.trim();
    console.log(colors.cyan(`Checking folder name: ${dirPath}`));
    if (/\s/.test(dirPath)) {
      console.error(
        colors.red(
          `Error : The specified path "${dirPath}" should not contain spaces.`,
        ),
      );
      Deno.exit(1);
    }
    console.log(colors.green("✅ Folder name check passed."));
  }

  /**
   * 2. Check for subfolders or files other than .csv.
   * 3. List all files and check against required structure (Part 1/3).
   * 4. Check if all required files are present (Part 1/2).
   * @param dirPath - Path to the directory.
   * @returns A list of only valid CSV file names.
   */
  static async validateFolderContentsAndList(
    dirPath: string,
  ): Promise<string[]> {
    console.log(colors.cyan("Checking for subfolders/invalid files ."));
    console.log(colors.cyan("Checking file presence and listing valid files."));

    if (!existsSync(dirPath)) {
      console.error(
        colors.red(`Error: The specified folder "${dirPath}" does not exist.`),
      );
      Deno.exit(1);
    }

    const fileNames: string[] = [];

    for await (const entry of Deno.readDir(dirPath)) {
      if (entry.isDirectory) {
        // Req 2: Subfolders
        console.error(
          colors.red(
            `Error: Subfolder found: ${entry.name}. Only csv files are allowed.`,
          ),
        );
        Deno.exit(1);
      }

      if (entry.isFile) {
        const fileExtension = `.${entry.name.split(".").pop()?.toLowerCase()}`;

        // Req 2: Invalid extensions
        if (fileExtension !== requiredExtension) {
          console.error(
            colors.red(
              `Error : Invalid file found: ${entry.name}. Only ${requiredExtension} files are allowed.`,
            ),
          );
          Deno.exit(1);
        }

        fileNames.push(entry.name);
      }
    }

    if (fileNames.length === 0) {
      console.log(colors.yellow("No files found in the directory."));
      Deno.exit(1);
    }

    // Log folder contents
    console.log(colors.cyan(`Folder contents (${fileNames.length} files):`));
    fileNames.forEach((file) => console.log(colors.green(`File: ${file}`)));

    // Check all required files
    const requiredFiles = Object.values(schemas).filter((s) =>
      s.required && !s.multiple
    ).map((s) => s.fileName);
    for (const requiredFile of requiredFiles) {
      if (!fileNames.includes(requiredFile)) {
        console.error(
          colors.red(`Error : Required file "${requiredFile}" is missing.`),
        );
        Deno.exit(1);
      }
    }

    console.log(
      colors.green(
        "✅ Folder contents and required file existence check passed.",
      ),
    );
    return fileNames;
  }

  /**
   * 3 & 5. Schema validation (Header check for all files).
   * @param allFileNames - List of all files in the folder.
   * @param cgmRawBaseNames - The list of actual CGM raw file BASE names to check (Req 7).
   */
  static async validateFileSchemas(
    dirPath: string,
    allFileNames: string[],
    cgmRawBaseNames: string[],
  ): Promise<void> {
    console.log(
      colors.cyan("Performing schema (header) validation on all files."),
    );

    // Step 1: Validate fixed-name files (Required, Recommended, Optional Metadata)
    for (const schema of Object.values(schemas)) {
      if (allFileNames.includes(schema.fileName)) {
        await Validator.validateSingleFileSchema(
          dirPath,
          schema.fileName,
          schema,
        );
      }
    }

    // Step 2: Validate the ACTUAL CGM raw files
    const uniqueCgmRawBaseNames = [...new Set(cgmRawBaseNames)];
    for (const baseFileName of uniqueCgmRawBaseNames) {
      // Construct the full file name including the mandatory extension for checking
      const fullFileName = baseFileName.endsWith(requiredExtension)
        ? baseFileName
        : baseFileName + requiredExtension;

      const filePath = `${dirPath}/${fullFileName}`;

      // Ensure the file exists (redundant if Req 7 passes, but safe)
      if (!allFileNames.includes(fullFileName)) continue;

      // Since we already ensured existence, now we check content (Req 5)
      const headers = await getFileHeaders(filePath);
      // Req 5: cgm_tracing columns can differ, check only for non-empty headers
      if (headers.length === 0) {
        console.error(
          colors.red(
            `Error: CGM raw file "${fullFileName}" is empty or has no headers.`,
          ),
        );
        Deno.exit(1);
      }
      console.log(
        colors.green(
          ` Schema check passed for CGM raw file: ${fullFileName} (Columns differ for cgm_tracing).`,
        ),
      );
    }

    console.log(colors.green("✅ All file schema validations passed."));
  }

  /**
   * Helper for schema validation of a single file.
   */
  private static async validateSingleFileSchema(
    dirPath: string,
    fileName: string,
    schema: FileSchema,
  ): Promise<void> {
    const filePath = `${dirPath}/${fileName}`;
    const actualHeaders = await getFileHeaders(filePath);
    const missingHeaders: string[] = [];

    for (const col of schema.columns) {
      if (col.required && !actualHeaders.includes(col.name)) {
        missingHeaders.push(col.name);
      }
    }

    if (missingHeaders.length > 0) {
      console.error(
        colors.red(
          `Error : File "${fileName}" is missing required column(s): ${
            missingHeaders.join(", ")
          }`,
        ),
      );
      Deno.exit(1);
    }
    console.log(colors.green(`   - Schema check passed for ${fileName}.`));
  }

  /**
   * 6. Check file_name column in cgm_file_metadata.csv for emptiness.
   * @param dirPath - Path to the directory.
   * @returns List of CGM raw file names found in the metadata.
   */
  /**
   * 6. Check file_name column in cgm_file_metadata.csv for emptiness.
   * @returns List of CGM raw file names found in the metadata (BASE NAME, without extension).
   */
  static async validateCgmMetadataFilenames(
    dirPath: string,
  ): Promise<string[]> {
    console.log(
      colors.cyan("Validating 'file_name' column in cgm_file_metadata."),
    );
    const metadataPath = `${dirPath}/${cgmMetadataFileName}`;
    const metadataContent = await getFileContent(metadataPath);

    if (metadataContent.length === 0) {
      console.error(
        colors.red(
          "Error: cgm_file_metadata.csv has no data rows. Must contain at least one row linking a CGM file.",
        ),
      );
      Deno.exit(1);
    }

    const headers = await getFileHeaders(metadataPath);
    const fileNameIndex = headers.indexOf("file_name");

    if (fileNameIndex === -1) {
      console.error(
        colors.red(
          "Internal Error: 'file_name' column not found in cgm_file_metadata (Schema validation failed).",
        ),
      );
      Deno.exit(1);
    }

    const cgmRawBaseNames: string[] = []; // Array to hold base names
    let lineNum = 1; // Start after header
    for (const line of metadataContent) {
      lineNum++;
      const columns = line.split(",").map((c) =>
        c.trim().replace(/^['"]|['"]$/g, "")
      );
      const fileName = columns[fileNameIndex];

      if (!fileName || fileName.length === 0) {
        console.error(
          colors.red(
            `Error: 'file_name' is empty in ${cgmMetadataFileName} at line ${lineNum}.`,
          ),
        );
        Deno.exit(1);
      }
      // Store the base name from the column
      cgmRawBaseNames.push(fileName);
    }

    console.log(
      colors.green(
        "✅ 'file_name' column in cgm_file_metadata.csv is not empty.",
      ),
    );
    return cgmRawBaseNames;
  }

  /**
   * 7. Check if cgm raw files (from metadata) are present in folder. (Req 7).
   * FIX: Appends the mandatory .csv extension to the base name before checking the folder.
   * @param cgmRawBaseNames - List of CGM file base names from cgm_file_metadata.
   * @param allFileNames - List of all files (with extensions) in the folder.
   */
  static checkCgmRawFilePresence(
    cgmRawBaseNames: string[],
    allFileNames: string[],
  ): void {
    console.log(
      colors.cyan("Checking if CGM raw files listed in metadata are present."),
    );
    const uniqueRawBaseNames = [...new Set(cgmRawBaseNames)];

    for (const baseFileName of uniqueRawBaseNames) {
      // Construct the full file name, assuming .csv is mandatory (Req 2)
      // This fixes the issue where metadata stores "cgm_tracing" but the file is "cgm_tracing.csv"
      const fullFileName = baseFileName.endsWith(requiredExtension)
        ? baseFileName
        : baseFileName + requiredExtension;

      if (!allFileNames.includes(fullFileName)) {
        console.error(
          colors.red(
            `Error: CGM raw file "${fullFileName}" (derived from metadata base name "${baseFileName}" and mandatory extension ${requiredExtension}) is missing from the folder.`,
          ),
        );
        Deno.exit(1);
      }
    }
    console.log(
      colors.green(
        "✅ All CGM raw files listed in metadata are present in the folder.",
      ),
    );
  }

  /**
   * 8. Check mapping fields in cgm_file_metadata for emptiness.
   * @param dirPath - Path to the directory.
   */
  static async validateCgmMetadataMappingFields(
    dirPath: string,
  ): Promise<void> {
    console.log(colors.cyan("Validating mapping fields in cgm_file_metadata."));
    const metadataPath = `${dirPath}/${cgmMetadataFileName}`;
    const metadataContent = await getFileContent(metadataPath);

    // Existence and rows checked in Req 4 and 6, just check content here
    if (metadataContent.length === 0) {
      /* should not happen if Req 6 passed */ return;
    }

    const headers = await getFileHeaders(metadataPath);
    const dateMapIndex = headers.indexOf("map_field_of_cgm_date");
    const valueMapIndex = headers.indexOf("map_field_of_cgm_value");

    // Indices should be valid if schema validation passed
    if (dateMapIndex === -1 || valueMapIndex === -1) Deno.exit(1);

    let lineNum = 1; // Start after header
    for (const line of metadataContent) {
      lineNum++;
      const columns = line.split(",").map((c) =>
        c.trim().replace(/^['"]|['"]$/g, "")
      );
      const dateMap = columns[dateMapIndex];
      const valueMap = columns[valueMapIndex];

      if (!dateMap || dateMap.length === 0) {
        console.error(
          colors.red(
            `Error : 'map_field_of_cgm_date' is empty in ${cgmMetadataFileName} at line ${lineNum}.`,
          ),
        );
        Deno.exit(1);
      }
      if (!valueMap || valueMap.length === 0) {
        console.error(
          colors.red(
            `Error : 'map_field_of_cgm_value' is empty in ${cgmMetadataFileName} at line ${lineNum}.`,
          ),
        );
        Deno.exit(1);
      }
    }

    console.log(
      colors.green(
        "✅ All mapping fields in cgm_file_metadata.csv are not empty.",
      ),
    );
  }

  /**
   * 9. Conditional existence check for meal/fitness data and metadata.
   * @param allFileNames - List of all files in the folder.
   */
  static validateOptionalFileExistence(allFileNames: string[]): void {
    console.log(
      colors.cyan("Conditional check for meal/fitness data and metadata ."),
    );

    const mealDataPresent = allFileNames.includes("meal_data.csv");
    const mealMetadataPresent = allFileNames.includes("meal_file_metadata.csv");
    const fitnessDataPresent = allFileNames.includes("fitness_data.csv");
    const fitnessMetadataPresent = allFileNames.includes(
      "fitness_file_metadata.csv",
    );

    // Rule: if data is provided, corresponding metadata must be included
    if (mealDataPresent && !mealMetadataPresent) {
      console.error(
        colors.red(
          "Error : 'meal_data.csv' is present, but required corresponding 'meal_file_metadata.csv' is missing.",
        ),
      );
      Deno.exit(1);
    }
    // Rule: if metadata is provided, corresponding data should also be included (Implied integrity)
    if (mealMetadataPresent && !mealDataPresent) {
      console.error(
        colors.red(
          "Error : 'meal_file_metadata.csv' is present, but corresponding 'meal_data.csv' is missing.",
        ),
      );
      Deno.exit(1);
    }

    // Rule: if data is provided, corresponding metadata must be included
    if (fitnessDataPresent && !fitnessMetadataPresent) {
      console.error(
        colors.red(
          "Error : 'fitness_data.csv' is present, but required corresponding 'fitness_file_metadata.csv' is missing.",
        ),
      );
      Deno.exit(1);
    }
    // Rule: if metadata is provided, corresponding data should also be included (Implied integrity)
    if (fitnessMetadataPresent && !fitnessDataPresent) {
      console.error(
        colors.red(
          "Error : 'fitness_file_metadata.csv' is present, but corresponding 'fitness_data.csv' is missing.",
        ),
      );
      Deno.exit(1);
    }

    console.log(
      colors.green("✅ Optional file existence and integrity check passed ."),
    );
  }
}

// Class to handle file operations
class FileHandler {
  static async verifyFolderContents(dirPath: string): Promise<void> {
    try {
      // Trim spaces from the path
      dirPath = dirPath.trim();

      // Check if the path contains spaces
      if (/\s/.test(dirPath)) {
        console.error(
          colors.red(
            `Error: The specified path "${dirPath}" should not contain spaces.`,
          ),
        );
        Deno.exit(1);
      }

      // Check if the path exists
      if (!existsSync(dirPath)) {
        console.error(
          colors.red(
            `Error: The specified folder "${dirPath}" does not exist.`,
          ),
        );
        Deno.exit(1);
      }

      // Define valid extensions
      const validExtensions = [".csv"]; // Add other extensions if needed

      // List all files in the directory
      const files: string[] = [];
      for await (const entry of Deno.readDir(dirPath)) {
        if (entry.isFile) {
          const fileExtension = `.${
            entry.name.split(".").pop()?.toLowerCase()
          }`;
          files.push(entry.name);

          // Check if the file extension is valid
          if (!validExtensions.includes(fileExtension)) {
            console.error(
              colors.red(
                `Invalid file found: ${entry.name}. Only ${
                  validExtensions.join(", ")
                } files are allowed.`,
              ),
            );
            Deno.exit(1);
          }
        }
      }

      // Log folder contents
      if (files.length > 0) {
        console.log(colors.cyan(`Folder contents:`));
        files.forEach((file) => console.log(colors.green(`File: ${file}`)));
      } else {
        console.log(colors.yellow("No files found in the directory."));
      }
    } catch (error) {
      console.error(
        colors.red(
          `An error occurred while verifying the folder: ${
            error instanceof Error ? error.message : String(error)
          }`,
        ),
      );
      Deno.exit(1);
    }
  }
  static async checkAndDeleteFile(dbFilePath: string): Promise<void> {
    if (existsSync(dbFilePath)) {
      console.log(
        colors.cyan(`Database file ${dbFilePath} exists. Deleting...`),
      );

      try {
        await Deno.remove(dbFilePath);
        console.log(colors.green("Database file deleted successfully."));
      } catch (error) {
        console.error(
          colors.red("Error deleting database file:"),
          error instanceof Error ? error.message : String(error),
        );
      }
    } else {
      console.log(
        colors.green(`File ${dbFilePath} not found. No action needed.`),
      );
    }
  }

  /**
   * Unzips a given ZIP file into a specified directory.
   * @param zipFilePath - Path to the ZIP file.
   * @param outputDir - Directory where the ZIP file will be extracted.
   */
  static async unzipFile(
    zipFilePath: string,
    outputDir: string,
  ): Promise<void> {
    console.log(`Ensuring output directory exists: ${outputDir}`);
    await ensureDir(outputDir); // Ensure the output directory exists
    console.log(`Unzipping file: ${zipFilePath} to ${outputDir}`);
    await $`unzip ${zipFilePath} -d ${outputDir}`;
    console.log(`Unzipping completed successfully.`);
  }
}

// Class to handle database operations
class DBHandler {
  private dbFilePath: string;

  constructor(dbFilePath: string) {
    this.dbFilePath = dbFilePath;
  }

  async fetchUxSqlContent(): Promise<string> {
    try {
      const uxSQLContent = await drhUx.DRHSQL(this.dbFilePath);
      return uxSQLContent.join("\n");
    } catch (error) {
      console.error(
        colors.red("Error fetching UX SQL content:"),
        error instanceof Error ? error.message : String(error),
      );
      return "";
    }
  }
}

class CommandExecutor {
  /**
   * Executes a shell command and streams the output.
   * @param command - Command to be executed along with its arguments.
   * @param input - Optional input to pass into the command (like SQL content).
   * @param env - Optional environment variables
   */
  static async executeCommand(
    command: string[],
    input: string | null = null,
    env: Record<string, string> = {}, // Optional environment variables
  ): Promise<void> {
    console.log(`Executing command: ${command.join(" ")}`);

    const process = Deno.run({
      cmd: command,
      env, // Pass the environment variables
      stdin: input ? "piped" : undefined, // Only pipe input if provided
      stdout: "piped",
      stderr: "piped",
    });

    // If input is provided, write it to the stdin of the process
    if (input) {
      const writer = process.stdin.getWriter();
      writer.write(new TextEncoder().encode(input)); // Pass SQL content into the command
      writer.close();
    }

    const [status, stdout, stderr] = await Promise.all([
      process.status(),
      process.output(),
      process.stderrOutput(),
    ]);

    // Print standard output and standard error
    console.log(new TextDecoder().decode(stdout));
    console.error(new TextDecoder().decode(stderr));

    process.close();

    // Handle if the command fails
    if (!status.success) {
      throw new Error(`Command failed with status: ${status.code}`);
    }

    console.log(`Command executed successfully.`);
  }

  static async executeCommandWithEnv(
    cmd: string[],
    env: Record<string, string>,
    stdinSupplier?: FlexibleTextSupplierSync,
  ) {
    try {
      console.log(
        colors.dim(
          `Executing command with environment: ${JSON.stringify(env)}`,
        ),
      );
      console.log(colors.dim(`Command: ${cmd.join(" ")}`));

      // Use Deno.run to execute the command with the environment
      // deno-lint-ignore no-deprecated-deno-api
      const process = Deno.run({
        cmd,
        env, // Pass the environment variables
        stdin: "piped",
        stdout: "piped",
        stderr: "piped",
      });

      // If a stdin supplier is provided, write to stdin
      if (stdinSupplier) {
        const input = textFromSupplierSync(stdinSupplier);
        if (input) {
          const writer = process.stdin.getWriter();
          await writer.write(new TextEncoder().encode(input));
          writer.releaseLock();
          process.stdin.close();
        }
      }

      const { code } = await process.status();
      const stdout = new TextDecoder().decode(await process.output());
      const stderr = new TextDecoder().decode(await process.stderrOutput());

      // Handle process output
      if (code === 0) {
        console.log(colors.green(stdout));
      } else {
        console.error(colors.red(stderr));
        throw new Error(`Command failed with status ${code}`);
      }
    } catch (error) {
      console.error(
        colors.cyan(`Error executing command ${cmd.join(" ")}:`),
        error instanceof Error ? error.message : String(error),
      );
      Deno.exit(1);
    }
  }

  static async executeShellCommand(
    cmd: string[],
    stdinSupplier?: FlexibleTextSupplierSync,
  ) {
    try {
      console.log(colors.dim(`Executing command: ${cmd.join(" ")}`));

      // Use spawnedResult for executing the command
      const result = await spawnedResult(
        cmd,
        undefined,
        stdinSupplier ? textFromSupplierSync(stdinSupplier) : undefined,
      );

      if (!result.success) {
        console.log(`Error ${result.stderr()}`);
        throw new Error(`Command failed with status ${result.code}`);
      }
    } catch (error) {
      console.error(
        colors.cyan(`Error executing command ${cmd.join(" ")}:`),
        error instanceof Error ? error.message : String(error),
      );
      Deno.exit(1);
    }
  }
}

/**
 * Executes a command and streams the content of a file into its standard input (stdin).
 * This is highly memory efficient as the entire file is not loaded into a single string
 * during execution, minimizing the memory spike.
 */
async function executeSqlFileStream(
  cmd: string[],
  filePath: string,
): Promise<void> {
  let file: Deno.FsFile | null = null;
  try {
    console.log(
      colors.dim(
        `Executing command with file stream: ${cmd.join(" ")} < ${filePath}`,
      ),
    );

    // Open the file for reading
    file = await Deno.open(filePath, { read: true });

    // Spawn the command process
    const commandProcess = new Deno.Command(cmd[0], {
      args: cmd.slice(1),
      stdin: "piped", // IMPORTANT: Set stdin to piped to accept the stream
      stdout: "piped",
      stderr: "piped",
    }).spawn();

    // Stream the file content directly to the command's stdin
    // This is the memory-efficient step: data moves chunk by chunk
    await file.readable.pipeTo(commandProcess.stdin);

    // Wait for the command to finish and get the result
    const result = await commandProcess.output();

    if (result.code !== 0) {
      const stderr = new TextDecoder().decode(result.stderr);
      console.error(colors.red(`Error ${stderr}`));
      throw new Error(`Command failed with status ${result.code}`);
    }
  } catch (error) {
    // The outer App.run() catch block handles Deno.exit(1)
    throw error;
  } finally {
    // Ensure the file handle is closed
    if (file) {
      file.close();
    }
  }
}

// Helper functions for performance timing
function timeStart(label: string): number {
  console.log(colors.dim(`\nStarting ${label}...`));
  return performance.now();
}

function timeEnd(label: string, startTime: number): void {
  const durationMs = performance.now() - startTime;
  const durationSeconds = (durationMs / 1000).toFixed(2);
  console.log(
    colors.yellow(
      ` ${label} completed in ${durationSeconds} seconds.`,
    ),
  );
}

// Main Application Class
class App {
  private folderName: string;
  private tenantId: string | undefined;
  private tenantName: string | undefined;

  constructor(folderName: string, tenantId?: string, tenantName?: string) {
    this.folderName = folderName;
    this.tenantId = tenantId;
    this.tenantName = tenantName;

    // Optional: Log the received arguments
    if (tenantId) console.log(colors.dim(`Tenant ID received: ${tenantId}`));
    if (tenantName) {
      console.log(colors.dim(`Tenant Name received: ${tenantName}`));
    }
  }

  async run() {
    let startTime: number;

    console.log(colors.yellow("Starting Data Folder Validation Process..."));
    startTime = timeStart("Data Validation");

    // 1. Check folder name for spaces (Req 1)
    Validator.checkFolderName(this.folderName);

    // 2, 4. Check contents, list files, and check fixed REQUIRED file existence (Req 2, 4)
    const allFileNames = await Validator.validateFolderContentsAndList(
      this.folderName,
    );

    // 6. Validate file_name column in cgm_file_metadata and extract CGM raw file BASE names (Req 6)
    // Renamed variable to reflect it holds BASE NAMES
    const cgmRawBaseNames = await Validator.validateCgmMetadataFilenames(
      this.folderName,
    );

    // 7. Check if all CGM raw files (BASE names + .csv extension) are present (Req 7)
    // UPDATED CALL: passing base names and all file names for comparison
    Validator.checkCgmRawFilePresence(cgmRawBaseNames, allFileNames);

    // 3, 5. Schema validation (Header check for all fixed files + CGM raw files) (Req 3, 5)
    // UPDATED CALL: passing base names
    await Validator.validateFileSchemas(
      this.folderName,
      allFileNames,
      cgmRawBaseNames,
    );

    // 8. Validate mapping fields in cgm_file_metadata (Req 8)
    await Validator.validateCgmMetadataMappingFields(this.folderName);

    // 9. Conditional existence check for meal/fitness data/metadata (Req 9)
    Validator.validateOptionalFileExistence(allFileNames);

    timeEnd("Data Validation", startTime);
    console.log(
      colors.yellow(
        "All Data Validation Passed. Proceeding with Ingestion and Transformation Process...",
      ),
    );

    // --- Start of Surveilr Ingestion and Transformation ---

    // Delete existing database if it exists
    startTime = timeStart("Database Cleanup");
    await FileHandler.checkAndDeleteFile(dbFilePath);
    timeEnd("Database Cleanup", startTime);

    // Log the start of the process
    console.log(
      colors.cyan(`Starting the process for folder: ${this.folderName}`),
    );
    // Execute file ingestion
    try {
      startTime = timeStart("File Ingestion (surveilr ingest)");
      console.log(
        colors.dim(`Ingesting files from folder: ${this.folderName}...`),
      );
      await CommandExecutor.executeCommand([
        toolCmd,
        "ingest",
        "files",
        "-r",
        `${this.folderName}/`,
      ]);
      timeEnd("File Ingestion (surveilr ingest)", startTime);
    } catch (error) {
      console.error(
        colors.red("Error ingesting files:"),
        error instanceof Error ? error.message : String(error),
      );
      Deno.exit(1);
    }

    // 4: Run the transformation command
    try {
      startTime = timeStart("File Transform (surveilr transform)");
      await CommandExecutor.executeCommand([
        toolCmd,
        "orchestrate",
        "transform-csv",
      ]);
      console.log(
        colors.green("Files ingestion and CSV transformation successful."),
      );
      timeEnd("File Transform (surveilr transform)", startTime);
    } catch (error) {
      console.error(
        colors.red("Error transforming CSV files:"),
        error instanceof Error ? error.message : String(error),
      );
      Deno.exit(1);
    }

    // Execute UX orchestration (SQL)
    try {
      console.log(
        colors.dim(`Performing UX orchestration: ${this.folderName}...`),
      );

      // Fetch UX SQL content
      startTime = timeStart("SQL Generation (fetchUxSqlContent)");
      const dbHandler = new DBHandler(dbFilePath);
      const drhSQL = await dbHandler.fetchUxSqlContent();
      timeEnd("SQL Generation (fetchUxSqlContent)", startTime);

      if (drhSQL) {

        //write Sql to a file
        const sqlOutputPath = "drh_generated.sql";
        startTime = timeStart("SQL File Write");
        await Deno.writeTextFile(sqlOutputPath, drhSQL);
        console.log(colors.magenta(`Generated SQL written to: ${sqlOutputPath}`));
        timeEnd("SQL File Write", startTime);

        // Execute the SQL command by streaming the file content (Low Memory Read)
        // This is the critical change for reducing the memory spike during execution.
        // startTime = timeStart("SQL Execution ");
        // await executeSqlFileStream([toolCmd, "shell"], sqlOutputPath);
        // timeEnd("SQL Execution ", startTime);

        // Execute the SQL command using the CommandExecutor        
        //   await CommandExecutor.executeShellCommand([toolCmd, "shell"], drhSQL);

        // Execute the SQL command by streaming the file content (Low Memory Read)
        // This is the critical change for reducing the memory spike during execution.
        startTime = timeStart("SQL Execution ");
        await executeSqlBatch(dbFilePath, drhSQL);
        timeEnd("SQL Execution ", startTime);
        console.log(colors.green("UX orchestration completed successfully."));
      }
    } catch (error) {
      console.error(
        colors.cyan("Error during UX orchestration:"),
        error instanceof Error ? error.message : String(error),
      );
      Deno.exit(1);
    }

    // Start the UI
    try {
      console.log(
        colors.green("Starting the UI at http://localhost:9000/drh/index.sql"),
      );
      await CommandExecutor.executeCommandWithEnv(
        [toolCmd, "web-ui", "--port", "9000"],
        { SQLPAGE_SITE_PREFIX: "" },
      );
      console.log(colors.green("DRH Edge UI started successfully."));
    } catch (error) {
      console.error(
        colors.red("Error starting DRH Edge UI:"),
        error instanceof Error ? error.message : String(error),
      );
      Deno.exit(1);
    }
  }
}

// Main Execution Block
if (import.meta.main) {
  const args = Deno.args;

  if (args.length === 0) {
    console.error(
      colors.red("No folder name provided. Please provide a folder name."),
    );
    console.error(
      colors.yellow(
        "Usage: deno run drhctl.ts <folderName> [tenantId] [tenantName]",
      ),
    );
    Deno.exit(1);
  }

  const folderName = args[0];
  // Optional arguments are accessed by index 1 and 2
  const tenantId = args[1]; // undefined if not provided
  const tenantName = args[2]; // undefined if not provided

  // Run the application with the provided arguments
  const app = new App(folderName, tenantId, tenantName);
  await app.run();
}
