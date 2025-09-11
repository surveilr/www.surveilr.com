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
      // Remove the RSSD (database file) if it exists, for a clean run
      try {
        await Deno.remove(this.rssdPath);
        console.log(`Removed existing database: ${this.rssdPath}`);
      } catch (e) {
        if (e instanceof Deno.errors.NotFound) {
          // File does not exist, nothing to remove
        } else {
          throw e;
        }
      }
      // 1. Fetch files from GitHub
      await $`deno run --allow-net --allow-run --allow-write --allow-read fetch-and-ingest.ts ${this.repo} ${this.branch} ${this.subdir} ${this.ingestDir}`;
      console.log("Files fetched.");

      // 2. Ingest files into surveilr DB
      await $`surveilr ingest files -d ${this.rssdPath} -r ${this.ingestDir}`;
      console.log("Files ingested into DB.");

      // 3. Create/refresh the ai_ctxe_prompt view
      await $`cat ai-ctxe-prompt.sql | surveilr shell --state-db-fs-path ${this.rssdPath}`;
      console.log("View created/refreshed.");

      // 4. Compose system prompts as SQL
      await $`deno run --allow-read --allow-env compose-and-persist-prompt.surveilr-SQL.ts > output.sql`;
      console.log("Composed system prompts SQL.");

      // TODO: Handle transactions properly
      // 5. Ingest composed SQL into DB
      await $`grep -v -E '^(BEGIN;|COMMIT;)$' output.sql | surveilr shell --state-db-fs-path resource-surveillance.sqlite.db`;
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

  // Use env vars, fallback to hardcoded defaults
  const repo = Deno.env.get("SURVEILR_REPO") || "opsfolio/www.opsfolio.com";
  const branch = Deno.env.get("SURVEILR_BRANCH") || "main";
  const subdir = Deno.env.get("SURVEILR_SUBDIR") || "src/ai-context-engineering";
  const ingestDir = Deno.env.get("SURVEILR_INGEST_DIR") || "ingest";
  const rssdPath = Deno.env.get("SURVEILR_DB_PATH") || "resource-surveillance.sqlite.db";

  // Initialize and run the application
  const app = new App(repo, branch, subdir, ingestDir, rssdPath);
  await app.run();
}