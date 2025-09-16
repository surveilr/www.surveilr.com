import { $ } from "https://deno.land/x/dax/mod.ts";
import { load } from "jsr:@std/dotenv";


/**
 * Main Application Class orchestrates the fetch and ingest workflow.
 */
class App {
  private repo: string;
  private branch: string;
  private subdir: string;
  private ingestDir: string;
  private rssdPath: string;

  constructor(repo: string, branch: string, subdir: string, ingestDir: string, rssdPath: string) {
    this.repo = repo;
    this.branch = branch;
    this.subdir = subdir;
    this.ingestDir = ingestDir;
    this.rssdPath = rssdPath;
  }

  /**
   * Executes the fetch-and-ingest and surveilr ingest workflow.
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
      console.error("Workflow failed.", error);
      Deno.exit(1);
    }
  }
}

if (import.meta.main) {
  // Load .env variables
  await load({ export: true });

  // Use env vars, fallback to hardcoded defaults (except rssdPath)
  const repo = Deno.env.get("SURVEILR_REPO") || "opsfolio/www.opsfolio.com";
  const branch = Deno.env.get("SURVEILR_BRANCH") || "main";
  const subdir = Deno.env.get("SURVEILR_SUBDIR") || "src/ai-context-engineering";
  const ingestDir = Deno.env.get("SURVEILR_INGEST_DIR") || "ingest";

  // Parse command-line arguments with a default for rssdPath
  const args = Object.fromEntries(
    Deno.args.map((arg) => {
      const [key, value] = arg.split("=");
      return [key, value];
    }),
  );
  const rssdPath = args.rssdPath ?? "resource-surveillance.sqlite.db";

  // Initialize and run the application
  const app = new App(repo, branch, subdir, ingestDir, rssdPath);
  await app.run();
}