import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { ensureDir, exists } from "https://deno.land/std@0.201.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { dirname } from "https://deno.land/std@0.204.0/path/mod.ts"; // Import dirname to extract the directory path
/**
 * FileHandler class handles file operations like unzipping and directory management.
 */
class FileHandler {
  /**
   * Removes the directory if it exists and creates it if not exist.
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
 * This orchestrates the unzipping and command execution.
 */
class App {
  private zipFilePath: string;
  private ingestDir: string;
  private rssdPath: string;
  private ingestCommand: string[];

  constructor(
    zipFilePath: string,
    ingestDir: string,
    rssdPath: string,
    ingestCommand: string[],
  ) {
    this.zipFilePath = zipFilePath;
    this.ingestDir = ingestDir;
    this.ingestCommand = ingestCommand;
    this.rssdPath = rssdPath;
  }

  /**
   * Runs the application workflow: Unzipping the file and executing the command.
   */
  async run(): Promise<void> {
    try {
      // Ensure the ingest directory name matches the command
      const ingestDir = this.ingestDir;

      // Step 1: Remove the existing directory if it exists
      await FileHandler.removeDirIfExists(ingestDir);

      await FileHandler.createDirForPathIfNotExists(this.ingestDir);
      await FileHandler.createDirForPathIfNotExists(this.rssdPath);

      // Step 2: Unzip the file
      await FileHandler.unzipFile(this.zipFilePath, ingestDir);

      // Step 3: Execute the ingest command
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
  const zipFilePath = "ingest.zip"; // Path to the ZIP file
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
  const app = new App(zipFilePath, basePath, rssdPath, ingestCommand);
  await app.run();
}
