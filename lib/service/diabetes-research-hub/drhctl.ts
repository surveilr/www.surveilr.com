#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-net --allow-ffi

import { $ } from "https://deno.land/x/dax@0.33.0/mod.ts";
import { existsSync } from "https://deno.land/std/fs/mod.ts";
import * as colors from "https://deno.land/std@0.224.0/fmt/colors.ts";
import * as uvaUx from "./drhctl-package.sql.ts";
import { ensureDir } from "https://deno.land/std@0.201.0/fs/mod.ts";

import {
  FlexibleTextSupplierSync,
  spawnedResult,
  textFromSupplierSync,
} from "../../universal/spawn.ts";

// Constants
const isWindows = Deno.build.os === "windows";
const toolCmd = isWindows ? ".\\surveilr" : "surveilr";
const dbFilePath = "resource-surveillance.sqlite.db";

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
          `An error occurred while verifying the folder: ${error.message}`,
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
          error.message,
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
      const uxSQLContent = await uvaUx.uvadclp1SQL(this.dbFilePath);
      return uxSQLContent.join("\n");
    } catch (error) {
      console.error(
        colors.red("Error fetching UX SQL content:"),
        error.message,
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
        error.message,
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
        error.message,
      );
      Deno.exit(1);
    }
  }
}

// Main Application Class
class App {
  private folderName: string;

  constructor(folderName: string) {
    this.folderName = folderName;
  }

  async run() {
    // Verify folder contents
    console.log(
      colors.cyan(`Verifying folder contents for: ${this.folderName}`),
    );
    await FileHandler.verifyFolderContents(this.folderName);

    // Delete existing database if it exists
    await FileHandler.checkAndDeleteFile(dbFilePath);

    // Log the start of the process
    console.log(
      colors.cyan(`Starting the process for folder: ${this.folderName}`),
    );
    // Execute file ingestion
    try {
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
    } catch (error) {
      console.error(colors.red("Error ingesting files:"), error.message);
      Deno.exit(1);
    }

    // 4: Run the transformation command
    try {
      await CommandExecutor.executeCommand([
        toolCmd,
        "orchestrate",
        "transform-csv",
      ]);
      console.log(
        colors.green("Files ingestion and CSV transformation successful."),
      );
    } catch (error) {
      console.error(colors.red("Error transforming CSV files:"), error.message);
      Deno.exit(1);
    }

    // Execute UX orchestration (SQL)
    try {
      console.log(
        colors.dim(`Performing UX orchestration: ${this.folderName}...`),
      );

      // Fetch UX SQL content
      const dbHandler = new DBHandler(dbFilePath);
      const uvaSQL = await dbHandler.fetchUxSqlContent();

      // Execute the SQL command using the CommandExecutor
      if (uvaSQL) {
        await CommandExecutor.executeShellCommand([toolCmd, "shell"], uvaSQL); // Pass SQL content to the command
        console.log(colors.green("UX orchestration completed successfully."));
      }
    } catch (error) {
      console.error(
        colors.cyan("Error during UX orchestration:"),
        error.message,
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
      console.error(colors.red("Error starting DRH Edge UI:"), error.message);
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
    Deno.exit(1);
  }

  const folderName = args[0];

  // Run the application with the provided folder name
  const app = new App(folderName);
  await app.run();
}
