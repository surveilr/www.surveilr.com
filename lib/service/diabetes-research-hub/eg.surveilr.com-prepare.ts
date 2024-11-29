import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import {
    ensureDir,
    exists,
    walk,
} from "https://deno.land/std@0.201.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

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
        console.log(`Executing command: ${command.join(" ")}`);
        const process = Deno.run({
            cmd: command,
            stdout: "piped",
            stderr: "piped",
        });

        const [status, stdout, stderr] = await Promise.all([
            process.status(),
            process.output(),
            process.stderrOutput(),
        ]);

        console.log(new TextDecoder().decode(stdout)); // Print standard output
        console.error(new TextDecoder().decode(stderr)); // Print standard error

        process.close();

        if (!status.success) {
            throw new Error(`Command failed with status: ${status.code}`);
        }
        console.log(`Command executed successfully.`);
    }
}

/**
 * Main Application Class.
 * This orchestrates the unzipping and command execution.
 */
class App {
    private zipFilePath: string;
    private outputDir: string;
    private rssdPath: string;
    //private internalrssdPath: string;
    private ingestCommand: string[];
    private transformCommand: string[];

    constructor(
        zipFilePath: string,
        outputDir: string,
        rssdPath: string,
        //internalrssdPath: string,
        ingestCommand: string[],
        transformCommand: string[],
    ) {
        this.zipFilePath = zipFilePath;
        this.outputDir = outputDir;
        //this.internalrssdPath = internalrssdPath;
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
            const ingestDir = this.outputDir;

            // Step 1: Remove the existing directory if it exists
            await FileHandler.removeDirIfExists(ingestDir);

            // Step 2: Unzip the file
            await FileHandler.unzipFile(this.zipFilePath, ingestDir);

            // Step 3: Verify that all files in the unzip directory are CSV files
            const allCsv = await FileHandler.verifyCsvFiles(ingestDir);
            if (!allCsv) {
                console.log("Error: Not all files are CSV files. Exiting...");
                Deno.exit(1);
            }

            // Step 4: Change to the RSSD folder
            const baseFolder = "rssd";
            console.log(`Changing directory to: ${baseFolder}`);

            // console.log(`Checking if RSSD folder exists at: ${this.rssdPath}`);
            // if (!(await exists(path.dirname(this.rssdPath)))) {
            //     console.log(
            //         `RSSD folder not found at: ${
            //             path.dirname(this.rssdPath)
            //         }. Creating it now.`,
            //     );
            //     await ensureDir(path.dirname(this.rssdPath));
            //     console.log(
            //         `RSSD folder created successfully: ${
            //             path.dirname(this.rssdPath)
            //         }`,
            //     );
            // } else {
            //     console.log(
            //         `RSSD folder already exists: ${
            //             path.dirname(this.rssdPath)
            //         }`,
            //     );
            // }

            Deno.chdir(baseFolder);

            // Step 4: Execute the ingest command
            await CommandExecutor.executeCommand(this.ingestCommand);

            // Step 5: Run the transform command
            await CommandExecutor.executeCommand(this.transformCommand);

            // Step 3: Execute the ingest and transform commands combined
            // const combinedCommand = [
            //     ...this.ingestCommand,
            //     "&&",
            //     ...this.transformCommand,
            // ];

            // await CommandExecutor.executeCommand(combinedCommand);

            // Step 6: Move the generated database to the target path

            await FileHandler.moveDatabase(
                "resource-surveillance.sqlite.db",
                this.rssdPath,
            );
        } catch (error) {
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
    //const rssdPath = args.rssdPath || "rssd/resource-surveillance.sqlite.db";
    let rssdPath = args.rssdPath;

    // Set paths and commands
    const basePath = "rssd";
    const zipFilePath = "datasets-transformed-archive/study-files.zip"; // Path to the ZIP file
    const outputDir = basePath;
    const ingestDir = "study-files/";
    if (Deno.args.length === 0) {
        rssdPath = path.join(
            basePath,
            "resource-surveillance.sqlite.db",
        );
    }

    const ingestCommand = [
        "surveilr",
        "ingest",
        "files",
        "-d",
        "resource-surveillance.sqlite.db",
        "-r",
        ingestDir,
    ];

    // Define the transform command
    const transformCommand = [
        "surveilr",
        "orchestrate",
        "transform-csv",
    ];

    // Run the app
    const app = new App(
        zipFilePath,
        outputDir,
        rssdPath,
        ingestCommand,
        transformCommand,
    );
    await app.run();
}
