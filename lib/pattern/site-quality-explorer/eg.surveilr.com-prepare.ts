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

class App {
    private resourceName: string;
    private outputDir: string;

    constructor(resourceName: string, outputDir: string) {
        this.resourceName = resourceName;
        this.outputDir = outputDir;
    }

    /**
     * Runs the application workflow: Execute commands for each URL.
     */
    async run(): Promise<void> {
        // Define the command to download the website
        const wgetCommand = [
            "wget",
            "--recursive",
            "--page-requisites",
            "--adjust-extension",
            "--span-hosts",
            "--convert-links",
            "--restrict-file-names=windows",
            "--domains",
            this.resourceName,
            "--no-parent",
            `--directory-prefix=${this.outputDir}`,
            this.resourceName,
        ];

        // Run the wget command
        try {
            console.log(`Processing resource: ${this.resourceName}`);
            await CommandExecutor.executeCommand(wgetCommand);
        } catch (error) {
            console.error(`Failed to process resource: ${this.resourceName}`);
            if (error instanceof Error) {
                console.error(`Error: ${error.message}`);
            } else {
                console.error("An unknown error occurred.", error);
            }
            // Log and continue processing other tasks if necessary
        }

        // Execute second command for ingestion (no arguments required)
        const ingestCommand = [
            "surveilr",
            "ingest",
            "files",
            "-r",
            "content/",
        ];
        try {
            console.log("Executing ingest command...");
            await CommandExecutor.executeCommand(ingestCommand);
        } catch (error) {
            console.error("Failed to execute ingest command");
            if (error instanceof Error) {
                console.error(`Error: ${error.message}`);
            } else {
                console.error("An unknown error occurred.", error);
            }
        }
    }
}

if (import.meta.main) {
    const args = Object.fromEntries(Deno.args.map((arg) => {
        const [key, value] = arg.split("=");
        return [key, value];
    }));

    // Get the resourceName argument, or default to a predefined value
    const resourceName = args.resourceName || "www.surveilr.com";
    const outputDir = args.outputDir || "content/website-resources";

    if (!resourceName) {
        console.error(
            "No resource name provided. Use --resourceName=example.com",
        );
        Deno.exit(1);
    }

    const app = new App(resourceName, outputDir);
    await app.run();
}
