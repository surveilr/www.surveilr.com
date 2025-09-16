import { $ } from "https://deno.land/x/dax/mod.ts";

/**
 * Minimal Application Class for RSSD ingest workflow.
 */
class App {
  private rssdPath: string;
  private ingestCommand: string[];

  constructor(rssdPath: string, ingestCommand: string[]) {
    this.rssdPath = rssdPath;
    this.ingestCommand = ingestCommand;
  }

  /**
   * Executes the ingest command for the application workflow.
   */
  async run(): Promise<void> {
    try {
      console.log(`Executing ingest command: ${this.ingestCommand.join(" ")}`);
      await $`${this.ingestCommand}`; // Using dax to run the command
      console.log("Ingestion executed successfully.");

      // 1. Create/refresh the ai_ctxe_prompt view
      await $`cat ai-ctxe-prompt.sql | surveilr shell --state-db-fs-path ${this.rssdPath}`;
      console.log("View created/refreshed.");

      // 2. Compose system prompts as SQL
      await $`deno run -A compose-and-persist-prompt.surveilr-SQL.ts ${this.rssdPath} > output.sql`;
      console.log("Composed system prompts SQL.");

      // TODO: Handle transactions properly
      // 3. Ingest composed SQL into DB
      await $`grep -v -E '^(BEGIN;|COMMIT;)$' output.sql | surveilr shell --state-db-fs-path ${this.rssdPath}`;
      console.log("Composed prompts ingested into DB.");
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

  // Define the ingest command
  const ingestCommand = [
    "surveilr",
    "ingest",
    "files",
    "-d",
    rssdPath,
    "-r",
    "ingest",
  ];

  // Initialize and run the application
  const app = new App(rssdPath, ingestCommand);
  await app.run();
}