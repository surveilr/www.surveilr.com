# Surveilr Data Transformation and SqlPage Preview

## Overview

The `deidentification.sql` performs the deidentification of the columns in the
data converted tables. The `stateless-privacy-surveilr.sql` creates the database
views which shall be used in SQLPage preview.

## Getting Started

1. **Move to folder containing the files:**

   - Open the command prompt and change to the directory containing the files.
   - Command: `cd <folderpath>`
   - Example: `cd D:/workfiles/common-files`

2. **Download Surveilr:**

   - Follow the installation instructions at
     [Surveilr Installation Guide](https://docs.opsfolio.com/surveilr/how-to/installation-guide).
   - Download the tool to this folder.

3. **Verify the Tool Version**

   - Input the command `surveilr --version`.
   - If the tool is available, it will show the version number.

   3.1 **Ingest the Files**

   **Command:**

   - Command: `surveilr ingest files -r <foldername>/`
   - Example: `surveilr ingest files -r reference-data/`

   **Note**: Here `reference-data` is a sub folder within `common-files`
   containing the files.

   3.2 **Transform the Files**

   **Command:**

   - Command: `surveilr transform csv`

   3.3 **Verify the Transformed Data**

   - Type the command `ls` to list the files.
   - You can also check the folder directly to see the transformed database.

4. **Steps for De-identification**

   4.1 **Download the SQL File**

   ```bash
   curl -L -o De-Identification.sql https://raw.githubusercontent.com/opsfolio/resource-surveillance-commons/main/pattern/privacy/anonymize-samples/de-identification/deidentification.sql
   ```

   4.2 **Execute the De-identification Process**

   ```bash
   surveilr anonymize --sql De-Identification.sql
   ```

   4.3 **Remove the de-identification sql after the de-identification**

   ```bash
   rm De-Identification.sql
   ```

5. **Apply the Database Views to Preview in SQLPage**

   ```bash
   curl -L https://raw.githubusercontent.com/opsfolio/resource-surveillance-commons/main/pattern/privacy/anonymize-samples/stateless-privacy-surveilr.sql | sqlite3 resource-surveillance.sqlite.db
   ```

6. **Preview Content with SQLPage (requires `deno` v1.40 or above):**

   ```bash
   deno run https://raw.githubusercontent.com/opsfolio/resource-surveillance-commons/main/pattern/privacy/anonymize-samples/ux.sql.ts | sqlite3 resource-surveillance.sqlite.db
   ```
   ```bash
   surveilr sqlpage --port 9000
   ```
   Then, open a browser and navigate to
   [http://localhost:9000/health/index.sql](http://localhost:9000/health/index.sql).
