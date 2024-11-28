import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { ensureDir, exists } from "https://deno.land/std@0.201.0/fs/mod.ts";
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
    static async unzipFile(zipFilePath: string, outputDir: string): Promise<void> {
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
    private ingestCommand: string[];

    constructor(zipFilePath: string, outputDir: string, rssdPath: string, ingestCommand: string[]) {
        this.zipFilePath = zipFilePath;
        this.outputDir = outputDir;
        this.ingestCommand = ingestCommand;
        this.rssdPath = rssdPath;
    }

    /**
     * Runs the application workflow: Unzipping the file and executing the command.
     */
    async run(): Promise<void> {
        try {
            // Ensure the ingest directory name matches the command
            const ingestDir = this.outputDir;

            // Step 1: Remove the existing directory if it exists
            await FileHandler.removeDirIfExists(ingestDir);

            // Step 2: Unzip the file
            await FileHandler.unzipFile(this.zipFilePath, ingestDir);

            // Step 3: Execute the ingest command
            await CommandExecutor.executeCommand(this.ingestCommand);
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


    // Get rssdpath from arguments, or default to "rssd/resource-surveillance.sqlite.db"
    let rssdPath = args.rssdPath;

    // Set paths and commands
    const basePath = "rssd";
    const zipFilePath = "ingest.zip"; // Path to the ZIP file
    const outputDir = basePath; // Target directory to unzip into
    if (Deno.args.length === 0) {
        rssdPath = path.join(
            basePath,
            "resource-surveillance.sqlite.db",
        );
    }
    const ingestDir = path.join(basePath, "ingest");
    const ingestCommand = ["surveilr", "ingest", "files", "-d", rssdPath, "-r", ingestDir];

    // Run the app
    const app = new App(zipFilePath, outputDir, rssdPath, ingestCommand);
    await app.run();
}
