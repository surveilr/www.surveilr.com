import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { dirname, join, basename } from "https://deno.land/std@0.224.0/path/mod.ts";
import { ensureDir, exists } from "https://deno.land/std@0.201.0/fs/mod.ts";

class FileHandler {
    static async createDirForPathIfNotExists(dirPath: string): Promise<void> {
        try {
            const directoryPath = dirname(dirPath); // Extract directory path
            const dirExists = await exists(directoryPath); // dax's `exists`
            if (!dirExists) {
                console.log(`Directory does not exist: ${directoryPath}. Creating...`);
                await $`mkdir -p ${directoryPath}`; // dax's `mkdir`
                console.log(`Directory created: ${directoryPath}`);
            } else {
                console.log(`Directory already exists: ${directoryPath}`);
            }
        } catch (error) {
            console.error(`Error creating directory for path: ${dirPath}`, error);
            throw error;
        }
    }
}

class CopyFile {
    static async copyFileToDestinationPath(destFolder: string): Promise<void> {
        try {
            const sourceFiles = [
                "assets/style-dms.css",
                ...await $`ls ingest`.lines(), // dax's `ls` to list files in `ingest`
            ].map((file) => file.startsWith("ingest/") ? file : `ingest/${file}`); // Ensure correct paths

            for (const sourceFile of sourceFiles) {
                const destinationPath = join(destFolder, basename(sourceFile));
                if (await exists(sourceFile)) {
                    console.log(`Copying ${sourceFile} to ${destinationPath}`);
                    await $`cp ${sourceFile} ${destinationPath}`; // dax's `cp`
                } else {
                    console.warn(`Source file does not exist: ${sourceFile}`);
                }
            }
        } catch (err) {
            console.error(`An error occurred while copying files:`, err);
        }
    }
}

class App {
    private destFolder: string;

    constructor(destFolder: string) {
        this.destFolder = destFolder;
    }

    async run(): Promise<void> {
        try {
            // Create directories
            await FileHandler.createDirForPathIfNotExists(this.destFolder);
            await FileHandler.createDirForPathIfNotExists(join(this.destFolder, "ingest"));

            // Copy files
            await CopyFile.copyFileToDestinationPath(this.destFolder);
        } catch (error: any) {
            console.error(`Error: ${error.message}`);
            Deno.exit(1);
        }
    }
}

if (import.meta.main) {
    const args = Object.fromEntries(Deno.args.map((arg) => {
        const [key, value] = arg.split("=");
        return [key, value];
    }));

    const destFolder = args.destFolder || "rssd";
    const app = new App(destFolder);
    await app.run();
}
