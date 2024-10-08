#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run

import * as colors from "https://deno.land/std@0.224.0/fmt/colors.ts";
import { DB } from "https://deno.land/x/sqlite@v3.6.0/mod.ts";
import * as drhux from "./package.sql.ts";
import { createCombinedCGMView } from "./combined-cgm-tracing-generator.ts";
import {
  FlexibleTextSupplierSync,
  spawnedResult,
  textFromSupplierSync,
} from "../../universal/spawn.ts";


// Detect platform-specific command format
const isWindows = Deno.build.os === "windows";
const toolCmd = isWindows ? ".\\surveilr" : "surveilr";
const dbFilePath = "resource-surveillance.sqlite.db"; // Path to your SQLite DB

const RSC_BASE_URL =
  "https://raw.githubusercontent.com/surveilr/www.surveilr.com/main/lib/service/diabetes-research-hub";

const UX_URL ="https://www.surveilr.com/lib/service/diabetes-research-hub"

// Helper function to fetch SQL content
async function fetchSqlContent(url: string): Promise<string> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Failed to fetch SQL content from ${url}`);
    }
    return response.text();
  } catch (error) {
    console.error(
      colors.red(`Error fetching SQL content from ${url}:`),
      error.message,
    );
    Deno.exit(1);
  }
}



// Helper function to execute a command
async function executeCommand(
  cmd: string[],
  stdinSupplier?: FlexibleTextSupplierSync,
) {
  try {
    console.log(colors.dim(`Executing command: ${cmd.join(" ")}`));

    // Use spawnedResult for executing the command
    const result = await spawnedResult(
      cmd,
      undefined,
      stdinSupplier ? textFromSupplierSync(stdinSupplier) : undefined,
    );

    if (!result.success) {
      throw new Error(`Command failed with status ${result.code}`);
    }
  } catch (error) {
    console.error(
      colors.red(`Error executing command ${cmd.join(" ")}:`),
      error.message,
    );
    Deno.exit(1);
  }
}

// Function to check if a file exists and delete it if it does
async function checkAndDeleteFile(filePath: string) {
  try {
    const fileInfo = await Deno.stat(filePath);
    if (fileInfo.isFile) {
      console.log(colors.yellow(`File ${filePath} found. Deleting...`));
      await Deno.remove(filePath);
      console.log(colors.green(`File ${filePath} deleted.`));
    }
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      console.log(
        colors.green(`File ${filePath} not found. No action needed.`),
      );
    } else {
      console.error(
        colors.red(`Error checking or deleting file ${filePath}:`),
        error.message,
      );
      Deno.exit(1);
    }
  }
}

// Function to check for table existence and create combined view
async function checkAndCreateCombinedView() {  
  const db = new DB(dbFilePath);

  try {
    // Check if the specific table exists
    const tableName = 'uniform_resource_cgm_file_metadata'; // Change to your required table name
    const tableExists = db.query(`SELECT name FROM sqlite_master WHERE type='table' AND name='${tableName}';`).length > 0;
    

    if (tableExists) {
        console.log(colors.green("Required table exists. Proceeding to create the combined view."));
        await createCombinedCGMView(dbFilePath); // Call the function to create the combined view
      
    } else {
      console.error(colors.red("The required table does not exist. Cannot create the combined view."));
    }
  } catch (error) {
    console.error(colors.red("Error in checkAndCreateCombinedView:"), error.message);
  } finally {
    // Close the database connection
    db.close();
  }
}

// Check if a folder name was provided
if (Deno.args.length === 0) {
  console.error(
    colors.red("No folder name provided. Please provide a folder name."),
  );
  Deno.exit(1);
}

// Store the folder name in a variable
const folderName = Deno.args[0];


// Path to the SQLite database journal
const dbjournalfile = "./resource-surveillance.sqlite.db-journal";

// Define synchronous suppliers
const deidentificationSQLSupplier: FlexibleTextSupplierSync = () =>
  deidentificationSQL;
const vvSQLSupplier: FlexibleTextSupplierSync = () => vvSQL;
const uxSQLSupplier: FlexibleTextSupplierSync = () => uxSQL;

let deidentificationSQL: string;
let vvSQL: string;
let uxSQL: string;



try {
  // Fetch SQL content for DeIdentification, Verification & Validation, and UX orchestration
  deidentificationSQL = await fetchSqlContent(
    `${UX_URL}/de-identification/drh-deidentification.sql`,
  );
  vvSQL = await fetchSqlContent(
    `${UX_URL}/verfication-validation/orchestrate-drh-vv.sql`,
  );  
  uxSQL = await fetchSqlContent(
    `${UX_URL}/package.sql`,
  );
} catch (error) {
  console.error(
    colors.red(
      "Error fetching SQL contents for DeIdentification and Verification & Validation:",
    ),
    error.message,
  );
  Deno.exit(1);
}

// Check and delete the file if it exists
await checkAndDeleteFile(dbFilePath);

// Log the start of the process
console.log(colors.cyan(`Starting the process for folder: ${folderName}`));

try {
  console.log(colors.dim(`Ingesting files from folder: ${folderName}...`));
  await executeCommand([toolCmd, "ingest", "files", "-r", `${folderName}/`]);
} catch (error) {
  console.error(colors.red("Error ingesting files:"), error.message);
  Deno.exit(1);
}


try {
  await executeCommand([toolCmd, "orchestrate", "transform-csv"]);
  console.log(
    colors.green("Files ingestion and CSV transformation successful."),
  );
} catch (error) {
  console.error(colors.red("Error transforming CSV files:"), error.message);
  Deno.exit(1);
}

// Check and delete the file if it exists
await checkAndDeleteFile(dbjournalfile);

try {
  console.log(colors.dim(`Generate combined views: ${folderName}...`));
  checkAndCreateCombinedView(); 
  console.log(colors.green("View generation completed successfully."));
} catch (error) {
  console.error(colors.red("Error during View generation:"), error.message);
  Deno.exit(1);
}


try {
  console.log(colors.dim(`Performing DeIdentification: ${folderName}...`));
  await executeCommand(
    [toolCmd, "orchestrate", "-n", "deidentification"],
    deidentificationSQLSupplier,
  );
  console.log(colors.green("Deidentification successful."));
} catch (error) {
  console.error(colors.red("Error during DeIdentification:"), error.message);
  Deno.exit(1);
}

try {
  console.log(
    colors.dim(`Performing Verification and Validation: ${folderName}...`),
  );
  await executeCommand([toolCmd, "orchestrate", "-n", "v&v"], vvSQLSupplier);
  console.log(
    colors.green(
      "Verification and validation orchestration completed successfully.",
    ),
  );
} catch (error) {
  console.error(
    colors.red("Error during Verification and Validation:"),
    error.message,
  );
  Deno.exit(1);
}

try {
  console.log(colors.dim(`Performing UX orchestration: ${folderName}...`));  
  await executeCommand([toolCmd, "shell"], uxSQLSupplier);
  console.log(colors.green("UX orchestration completed successfully."));
} catch (error) {
  console.error(colors.red("Error during UX orchestration:"), error.message);
  Deno.exit(1);
}

try {
  console.log(
    colors.green(
      `Loading DRH Edge UI... at http://localhost:9000/drh/index.sql`,
    ),
  );
  await executeCommand([toolCmd, "web-ui", "--port", "9000"]);
} catch (error) {
  console.error(colors.red("Error starting DRH Edge UI:"), error.message);
  Deno.exit(1);
}
