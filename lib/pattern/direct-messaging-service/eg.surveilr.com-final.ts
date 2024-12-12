import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import {
  basename,
  dirname,
  join,
} from "https://deno.land/std@0.224.0/path/mod.ts";
import { exists } from "https://deno.land/std@0.201.0/fs/mod.ts";

class FileHandler {
  static async createDirIfNotExists(dirPath: string): Promise<void> {
    try {
      const dirExists = await exists(dirPath);
      if (!dirExists) {
        console.log(`Directory does not exist: ${dirPath}. Creating...`);
        await $`mkdir -p ${dirPath}`; // Create directory if it doesn't exist
        console.log(`Directory created: ${dirPath}`);
      } else {
        console.log(`Directory already exists: ${dirPath}`);
      }
    } catch (error) {
      console.error(`Error creating directory: ${dirPath}`, error);
      throw error;
    }
  }
}

class CopyFile {
  static async moveFiles(destFolder: string): Promise<void> {
    try {
      // Move `style-dms.css` to the `assets` folder
      const styleSource = "assets/style-dms.css";
      const styleDest = join(destFolder, "assets", "style-dms.css");
      if (await exists(styleSource)) {
        await FileHandler.createDirIfNotExists(dirname(styleDest));
        console.log(`Moving ${styleSource} to ${styleDest}`);
        await $`cp ${styleSource} ${styleDest}`;
      } else {
        console.warn(`Source file not found: ${styleSource}`);
      }

      // Move other files from `ingest` to the `ingest` folder in destination
      const ingestSourceDir = "ingest";
      const ingestDestDir = join(destFolder, "ingest");
      await FileHandler.createDirIfNotExists(ingestDestDir);

      const files = await $`ls ${ingestSourceDir}`.lines();
      for (const file of files) {
        const sourceFile = join(ingestSourceDir, file);
        const destinationFile = join(ingestDestDir, file);

        if (await exists(sourceFile)) {
          console.log(`Moving ${sourceFile} to ${destinationFile}`);
          await $`cp ${sourceFile} ${destinationFile}`;
        } else {
          console.warn(`File not found: ${sourceFile}`);
        }
      }
    } catch (error) {
      console.error(`An error occurred while moving files:`, error);
      throw error;
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
      // Move files to their respective destinations
      await CopyFile.moveFiles(this.destFolder);
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
