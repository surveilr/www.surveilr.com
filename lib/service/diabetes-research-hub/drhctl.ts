#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run

import * as colors from "https://deno.land/std@0.224.0/fmt/colors.ts";
import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";
import * as drhux from "./package.sql.ts";
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
      colors.cyan(`Error fetching SQL content from ${url}:`),
      error.message,
    );
    //Deno.exit(1);
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
      //console.log(`Error ${result.stderr}`);
      throw new Error(`Command failed with status ${result.code}`);
    }
  } catch (error) {
    console.error(
      colors.cyan(`Error executing command ${cmd.join(" ")}:`),
      error.message,
    );
    //Deno.exit(1);
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
        colors.cyan(`Error checking or deleting file ${filePath}:`),
        error.message,
      );
      //Deno.exit(1);
    }
  }
}

// Function to fetch UX SQL content
async function fetchUxSqlContent(): Promise<string> {
  try {
    const uxSQLContent = await drhux.drhSQL();
    return uxSQLContent.join("\n");
  } catch (error) {
    console.error(
      colors.red("Error fetching UX SQL content:"),
      error.message,
    );
    Deno.exit(1);
  }
}

// Function to execute SQL commands directly on SQLite database
function executeSqlCommands(sqlCommands: string) {
  try {
    const db = new DB(dbFilePath);
    db.execute(sqlCommands); // Execute the SQL commands
    db.close();
    console.log(colors.green("UX SQL executed successfully."));
  } catch (error) {
    console.error(colors.red("Error executing SQL commands:"), error.message);
    Deno.exit(1);
  }
}


// Check if a folder name was provided
if (Deno.args.length === 0) {
  console.error(
    colors.cyan("No folder name provided. Please provide a folder name."),
  );
  Deno.exit(1);
}

// Store the folder name in a variable
const folderName = Deno.args[0];


// Define synchronous suppliers
const deidentificationSQLSupplier: FlexibleTextSupplierSync = () =>
  deidentificationSQL;
const vvSQLSupplier: FlexibleTextSupplierSync = () => vvSQL;
//const uxSQLSupplier: FlexibleTextSupplierSync = () => uxSQL;

let deidentificationSQL: string;
let vvSQL: string;
let uxSQL: string;



try {
  // Fetch SQL content for DeIdentification, Verification & Validation, and UX orchestration
  deidentificationSQL = await fetchSqlContent(
    `${RSC_BASE_URL}/de-identification/drh-deidentification.sql`,
  );
  vvSQL = await fetchSqlContent(
    `${RSC_BASE_URL}/verfication-validation/orchestrate-drh-vv.sql`,
  );  
  // uxSQL = await fetchSqlContent(
  //   `${UX_URL}/package.sql`,
  // );
  uxSQL = await fetchUxSqlContent(); // Fetch UX SQL content
} catch (error) {
  console.error(
    colors.cyan(
      "Error fetching SQL contents for DeIdentification and Verification & Validation:",
    ),
    error.message,
  );
  //Deno.exit(1);
}

// Check and delete the file if it exists
await checkAndDeleteFile(dbFilePath);

// Log the start of the process
console.log(colors.cyan(`Starting the process for folder: ${folderName}`));

try {
  console.log(colors.dim(`Ingesting files from folder: ${folderName}...`));
  await executeCommand([toolCmd, "ingest", "files", "-r", `${folderName}/`]);
} catch (error) {
  console.error(colors.cyan("Error ingesting files:"), error.message);
  //Deno.exit(1);
}


try {
  await executeCommand([toolCmd, "orchestrate", "transform-csv"]);
  console.log(
    colors.green("Files ingestion and CSV transformation successful."),
  );
} catch (error) {
  console.error(colors.cyan("Error transforming CSV files:"), error.message);
  //Deno.exit(1);
}


try {
  console.log(colors.dim(`Performing DeIdentification: ${folderName}...`));
  await executeCommand(
    [toolCmd, "orchestrate", "-n", "deidentification"],
    deidentificationSQLSupplier,
  );
  console.log(colors.green("Deidentification successful."));
} catch (error) {
  console.error(colors.cyan("Error during DeIdentification:"), error.message);
  //Deno.exit(1);
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
    colors.cyan("Error during Verification and Validation:"),
    error.message,
  );
  //Deno.exit(1);
}

try {
  console.log(colors.dim(`Performing UX orchestration: ${folderName}...`));  
  //await executeCommand([toolCmd, "shell"], uxSQLSupplier);
  executeSqlCommands(uxSQL); // Execute UX SQL commands
  console.log(colors.green("UX orchestration completed successfully."));
} catch (error) {
  console.error(colors.cyan("Error during UX orchestration:"), error.message);
  //Deno.exit(1);
}

try {
  console.log(
    colors.green(
      `Loading DRH Edge UI... at http://localhost:9000/drh/index.sql`,
    ),
  );
  await executeCommand([toolCmd, "web-ui", "--port", "9000"]);
} catch (error) {
  console.error(colors.cyan("Error starting DRH Edge UI:"), error.message);
  //Deno.exit(1);
}
