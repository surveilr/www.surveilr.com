import { $ } from "https://deno.land/x/dax/mod.ts";

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
      console.log(`Executing ingest command: ${this.ingestCommand.join(" ")}`);
      await $`${this.ingestCommand}`; // Using dax to run the command
      console.log("Command executed successfully.");
    } catch (error) {
      console.error("Failed to execute the command.");
      console.error(`Error: ${error instanceof Error ? error.message : error}`);
      Deno.exit(1);
    }
  }
}

if (import.meta.main) {
  // Parse command-line arguments with a default for rssdPath
  const args = Object.fromEntries(
    Deno.args.map((arg) => {
      const [key, value] = arg.split("=");
      return [key, value];
    }),
  );
  const rssdPath = args.rssdPath ?? "resource-surveillance.sqlite.db";
  const __dirname = new URL('.', import.meta.url).pathname;
  const ingestFolder_ai_context = `${__dirname}../ai-context-middleware/ingest`;

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
      "-r",
    ingestFolder_ai_context,
  ];

  // Initialize and run the application
  const app = new App(rssdPath, ingestCommand);
  await app.run();
}
