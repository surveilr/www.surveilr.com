/**
 * CommandExecutor class handles executing shell commands.
 */
class CommandExecutor {
    /**
     * executeCommand a shell command and streams the output.
     * @param command - Command to be executed along with its arguments.
     */

    static async executeCommand(command: string[]): Promise<void> {
        console.log(`Executing command: ${command.join(" ")}`);

        const process = new Deno.Command(command[0], {
            args: command.slice(1), // Extract executable and arguments
            stdout: "piped",
            stderr: "piped",
        });

        try {
            // Execute the command and collect outputs
            const { code, stdout, stderr } = await process.output();

            console.log(new TextDecoder().decode(stdout)); // Print standard output
            console.error(new TextDecoder().decode(stderr)); // Print standard error

            if (code !== 0) {
                throw new Error(`Command failed with status: ${code}`);
            }

            console.log(`Command executed successfully.`);
        } catch (error) {
            if (error instanceof Error) {
                console.error(`Error: ${error.message}`);
            } else {
                console.error("An unknown error occurred.", error);
            }
        }
    }
}

/**
 * Main Application Class orchestrates the command execution workflow.
 */
class App {
    private rssdPath: string;
    private ingestCommand: string[];

    constructor(rssdPath: string, ingestCommand: string[]) {
        this.rssdPath = rssdPath;
        this.ingestCommand = ingestCommand;
    }

    /**
     * Executes the command for the application workflow.
     */
    async run(): Promise<void> {
        try {
            await CommandExecutor.executeCommand(this.ingestCommand);
        } catch (error) {
            if (error instanceof Error) {
                console.error(`Error: ${error.message}`);
            } else {
                console.error("An unknown error occurred.", error);
            }
            Deno.exit(1);
        }
    }
}

if (import.meta.main) {
    // Parse command-line arguments with a default for rssdPath
    const args = Object.fromEntries(Deno.args.map((arg) => {
        const [key, value] = arg.split("=");
        return [key, value];
    }));
    const rssdPath = args.rssdPath ?? "resource-surveillance.sqlite.db";

    // Define the ingest command
    const ingestCommand = [
        "surveilr",
        "ingest",
        "files",
        "--csv-transform-auto",
        "-d",
        rssdPath,
        "-r",
        "ingest",
    ];

    // Initialize and run the application
    const app = new App(rssdPath, ingestCommand);
    await app.run();
}
