import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { ensureDir, exists } from "https://deno.land/std@0.201.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { dirname } from "https://deno.land/std@0.204.0/path/mod.ts"; // Import dirname to extract the directory path

/**
 * FileHandler class handles file operations like downloading, unzipping, and directory management.
 */
class FileHandler {
  /**
   * Removes the directory if it exists.
   * @param dirPath - Path to the directory to be removed.
   */
  static async removeDirIfExists(dirPath: string): Promise<void> {
    if (await exists(dirPath)) {
      console.log(`Directory exists: ${dirPath}. Removing...`);
      await $`rm -r ${dirPath}`;
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
   * Ensures a directory exists.
   * @param dirPath - Path to the directory to be created.
   */
  static async ensureDirectory(dirPath: string): Promise<void> {
    console.log(`Ensuring directory exists: ${dirPath}`);
    await ensureDir(dirPath);
    console.log(`Directory ensured: ${dirPath}`);
  }

  /**
   * Downloads a file from a given URL.
   * @param url - The URL to download the file from.
   * @param outputFilePath - Path where the downloaded file will be saved.
   */
  static async downloadFile(
    url: string,
    outputFilePath: string,
  ): Promise<void> {
    console.log(`Downloading file from: ${url}`);
    await $`wget -O ${outputFilePath} ${url}`;
    console.log(`File downloaded to: ${outputFilePath}`);
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
      console.error(`Error: ${error instanceof Error ? error.message : error}`);
      Deno.exit(1);
    }
  }
}

/**
 * Main Application Class.
 * This orchestrates the download, unzipping, and command execution.
 */
class App {
  private zipFilePath: string;
  private ingestDir: string;
  private rssdPath: string;
  private ingestCommand: string[];
  private zipDownloadUrl: string;

  constructor(
    zipFilePath: string,
    outputDir: string,
    rssdPath: string,
    ingestCommand: string[],
    zipDownloadUrl: string,
  ) {
    this.zipFilePath = zipFilePath;
    this.ingestDir = outputDir;
    this.ingestCommand = ingestCommand;
    this.rssdPath = rssdPath;
    this.zipDownloadUrl = zipDownloadUrl;
  }

  /**
   * Runs the application workflow: Downloading the ZIP file, unzipping it, and executing the command.
   */
  async run(): Promise<void> {
    try {
      // Step 1: Remove the existing ingest directory if it exists
      await FileHandler.removeDirIfExists(this.ingestDir);

      await FileHandler.createDirForPathIfNotExists(this.ingestDir);
      await FileHandler.createDirForPathIfNotExists(this.rssdPath);

      // Step 2: Download the ZIP file
      await FileHandler.downloadFile(this.zipDownloadUrl, this.zipFilePath);

      // Step 3: Ensure the ingest directory exists
      await FileHandler.ensureDirectory(this.ingestDir);

      // Step 4: Unzip the downloaded file into the ingest directory
      await FileHandler.unzipFile(this.zipFilePath, this.ingestDir);

      // Step 5: Execute the ingest command
      await CommandExecutor.executeCommand(this.ingestCommand);
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

  // Get rssdpath from arguments, or default to "resource-surveillance.sqlite.db"
  const rssdPath = (args.rssdPath)
    ? args.rssdPath
    : "resource-surveillance.sqlite.db";

  // Set paths and commands
  const basePath = "";
  const zipFilePath = path.join(
    basePath,
    "synthea_sample_data_fhir_latest.zip",
  );
  const zipDownloadUrl =
    "https://synthetichealth.github.io/synthea-sample-data/downloads/latest/synthea_sample_data_fhir_latest.zip";

  const ingestDir = path.join(basePath, "ingest");
  const ingestCommand = [
    "surveilr",
    "ingest",
    "files",
    "-d",
    rssdPath,
    "-r",
    ingestDir,
  ];
  await FileHandler.removeDirIfExists(ingestDir);
  // Run the app
  const app = new App(
    zipFilePath,
    ingestDir,
    rssdPath,
    ingestCommand,
    zipDownloadUrl,
  );
  await app.run();
}
