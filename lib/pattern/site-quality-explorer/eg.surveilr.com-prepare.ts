import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";

class App {
  private resourceName: string;
  private outputDir: string;
  private rssdPath: string;

  constructor(resourceName: string, outputDir: string, rssdPath: string) {
    this.resourceName = resourceName;
    this.outputDir = outputDir;
    this.rssdPath = rssdPath;
  }

  /**
   * Installs the SQLite extension using sqlpkg.
   */
  async installSQLiteExtension(): Promise<void> {
    try {
      console.log("Installing SQLite extension...");
      await $`sqlpkg install asg017/html`; // Executes the sqlpkg command
      console.log("SQLite extension installed successfully.");
    } catch (error) {
      console.error("Failed to install SQLite extension.");
      console.error(
        `Error: ${error instanceof Error ? error.message : error}`,
      );
    }
  }

  /**
   * Runs the application workflow: Execute commands for each URL.
   */
  async run(): Promise<void> {
    // Install the SQLite extension first
    await this.installSQLiteExtension();

    // Command to download the website
    try {
      console.log(`Processing resource: ${this.resourceName}`);
      await $`wget --recursive --page-requisites --adjust-extension --span-hosts --convert-links --restrict-file-names=windows --domains ${this.resourceName} --no-parent --directory-prefix=${this.outputDir} ${this.resourceName}`;
      console.log("Website downloaded successfully.");
    } catch (error) {
      console.error(`Failed to process resource: ${this.resourceName}`);
      console.error(
        `Error: ${error instanceof Error ? error.message : error}`,
      );
    }

    // Command for ingestion
    try {
      console.log("Executing ingest command...");
      await $`surveilr ingest files -d ${this.rssdPath} -r content/`;
      console.log("Ingestion completed successfully.");
    } catch (error) {
      console.error("Failed to execute ingest command.");
      console.error(
        `Error: ${error instanceof Error ? error.message : error}`,
      );
    }
  }
}

if (import.meta.main) {
  const args = Object.fromEntries(
    Deno.args.map((arg) => {
      const [key, value] = arg.split("=");
      return [key, value];
    }),
  );

  // Get the resourceName argument, or default to a predefined value
  const resourceName = args.resourceName || "www.surveilr.com";
  const outputDir = args.outputDir || "content/website-resources";
  const rssdPath = args.rssdPath ?? "resource-surveillance.sqlite.db";

  if (!resourceName) {
    console.error(
      "No resource name provided. Use --resourceName=example.com",
    );
    Deno.exit(1);
  }

  const app = new App(resourceName, outputDir, rssdPath);
  await app.run();
}
