import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import {
  ensureDir,
  exists,
  walk,
} from "https://deno.land/std@0.201.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { dirname } from "https://deno.land/std@0.204.0/path/mod.ts"; // Import dirname to extract the directory path

/**
 * FileHandler class handles file operations like unzipping and directory management.
 */
class FileHandler {
  /**
   * Removes the directory if it exists.
   * @param dirPath - Path to the directory to be removed.
   */
  static async removeDirIfExists(dirPath: string): Promise<void> {
    if (await exists(dirPath)) {
      console.log(`Directory exists: ${dirPath}. Removing...`);
      await Deno.remove(dirPath, { recursive: true });
      console.log(`Directory removed: ${dirPath}`);
    }
  }

  static async createDirForPathIfNotExists(dirPath: string): Promise<void> {
    try {
      const directoryPath = dirname(dirPath); // Extract directory path from the provided path
      const dirExists = await exists(directoryPath);
      if (!dirExists) {
        console.log(`Directory does not exist: ${directoryPath}. Creating...`);
        await $`mkdir -p ${directoryPath}`;
        console.log(`Directory created: ${directoryPath}`);
      } else {
        console.log(`Directory already exists: ${directoryPath}`);
      }
    } catch (error) {
      console.error(`Error creating directory for path: ${dirPath}`, error);
      throw error; // Rethrow error for caller to handle
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

  /**
   * Verifies that all files in a directory are CSV files.
   * @param dirPath - Path to the directory to verify.
   * @returns A boolean indicating if all files are CSV files.
   */
  static async verifyCsvFiles(dirPath: string): Promise<boolean> {
    let allCsv = true;

    for await (const entry of walk(dirPath)) {
      //console.log(`CSV file found: ${entry.name}`);
      if (entry.isFile && !entry.name.endsWith(".csv")) {
        console.log(`Non-CSV file found: ${entry.name}`);
        allCsv = false;
      }
    }

    return allCsv;
  }

  /**
   * Moves the generated database to the target path.
   * @param sourcePath - Source path of the database.
   * @param targetPath - Target path where the database should be moved.
   */
  static async moveDatabase(
    sourcePath: string,
    targetPath: string,
  ): Promise<void> {
    console.log(`Moving database from ${sourcePath} to ${targetPath}`);
    await ensureDir(path.dirname(targetPath)); // Ensure the target directory exists
    await Deno.rename(sourcePath, targetPath);
    console.log(`Database moved to: ${targetPath}`);
  }
}

/**
 * CommandExecutor class handles executing shell commands.
 */
class CommandExecutor {
  /**
   * Executes a shell command and streams the output.
   * @param command - Command to be executed along with its arguments.
   */
  static async executeCommand(command: string[]): Promise<void> {
    try {
      console.log(`Executing ingest command: ${command.join(" ")}`);
      await $`${command}`; // Using dax to run the command
      console.log("Command executed successfully.");
    } catch (error) {
      console.error("Failed to execute the command.");
      console.error(
        `Error: ${error instanceof Error ? error.message : error}`,
      );
      Deno.exit(1);
    }
  }
}

/**
 * Main Application Class.
 * This orchestrates the unzipping and command execution.
 */
class App {
  private zipFilePath: string;
  private ingestDir: string;
  private rssdPath: string;
  private ingestCommand: string[];
  private transformCommand: string[];

  constructor(
    zipFilePath: string,
    ingestDir: string,
    rssdPath: string,
    ingestCommand: string[],
    transformCommand: string[],
  ) {
    this.zipFilePath = zipFilePath;
    this.ingestDir = ingestDir;
    this.rssdPath = rssdPath;
    this.ingestCommand = ingestCommand;
    this.transformCommand = transformCommand;
  }

  /**
   * Runs the application workflow: Unzipping the file, verifying CSV files, and executing the commands.
   */
  async run(): Promise<void> {
    try {
      // Step 0: Check and ensure the RSSD path folder exists
      // Ensure the ingest directory name matches the command
      const ingestDir = this.ingestDir;

      // Step 1: Remove the existing directory if it exists
      await FileHandler.removeDirIfExists(ingestDir);

      await FileHandler.createDirForPathIfNotExists(ingestDir);
      await FileHandler.createDirForPathIfNotExists(this.rssdPath);

      // Step 2: Unzip the file
      await FileHandler.unzipFile(this.zipFilePath, ingestDir);

      // Step 3: Verify that all files in the unzip directory are CSV files
      const allCsv = await FileHandler.verifyCsvFiles(ingestDir);
      if (!allCsv) {
        console.log("Error: Not all files are CSV files. Exiting...");
        Deno.exit(1);
      }

      // Step 4: Execute the ingest command
      try {
        await CommandExecutor.executeCommand(this.ingestCommand);
        try {
          console.log(this.transformCommand);
          await CommandExecutor.executeCommand(this.transformCommand);
        } catch (errTr) {
          if (errTr instanceof Error) {
            console.error(`Error: ${errTr.message}`);
          } else {
            console.error("An unknown error occurred.", errTr);
          }
          Deno.exit(1);
        }
      } catch (error) {
        if (error instanceof Error) {
          console.error(`Error: ${error.message}`);
        } else {
          console.error("An unknown error occurred.", error);
        }
        Deno.exit(1);
      }
    } catch (error: any) {
      console.error(`Error: ${error.message}`);
      Deno.exit(1);
    }
  }
}

if (import.meta.main) {
  // Parse command-line arguments
  const args = Object.fromEntries(Deno.args.map((arg) => {
    const [key, value] = arg.split("=");
    return [key, value];
  }));

  // Get the target directory and RSSD path from arguments
  // Get rssdpath from arguments, or default to "resource-surveillance.sqlite.db"
  const rssdPath = (args.rssdPath)
    ? args.rssdPath
    : "resource-surveillance.sqlite.db";

  // Set paths and commands
  const basePath = "";
  const zipFilePath = "dclp1.zip"; // Path to the ZIP file

  const ingestDir = path.join(basePath, "dclp1");

  const ingestCommand = [
    "surveilr",
    "ingest",
    "files",
    "-d",
    rssdPath,
    "-r",
    ingestDir,
  ];

  // Define the transform command
  const transformCommand = [
    "surveilr",
    "orchestrate",
    "-d",
    rssdPath,
    "transform-csv",
  ];

  // Run the app
  const app = new App(
    zipFilePath,
    ingestDir,
    rssdPath,
    ingestCommand,
    transformCommand,
  );
  await app.run();
}
