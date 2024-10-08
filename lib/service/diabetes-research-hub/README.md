# Surveilr Data Transformation and SQLPage Preview Guide

## Overview

Welcome to the Surveilr Data Transformation and SQLPage Preview guide! This tool
allows you to securely convert your CSV files, perform de-identification, and
conduct verification and validation (V&V) processes behind your firewall. You
can view the results directly on your local system. The following steps will
guide you through converting your files, performing de-identification, V&V, and
verifying the data all within your own environment.

# Try outside this repo

### Requirements for Previewing the Edge UI:

1. **Surveilr Tool** (use latest version surveilr)
2. **Deno Runtime** (requires `deno` v1.40 or above):
   [Deno Installation Guide](https://docs.deno.com/runtime/manual/getting_started/installation/)

Installation steps may vary depending on your operating system.

## Getting Started

### Step 1: Navigate to the Folder Containing the Files

- Open the command prompt and navigate to the directory with your files.
- Command: `cd <folderpath>`
- Example: `cd D:/DRH-Files`

### Step 2: Download Surveilr

- Follow the installation instructions at the
  [Surveilr Installation Guide](https://docs.opsfolio.com/surveilr/how-to/installation-guide).
- Download latest version `surveilr` from
  [Surveilr Releases](https://github.com/opsfolio/releases.opsfolio.com/releases)
  to this folder.

### Step 3: Verify the Tool Version

- Run the command `surveilr --version` in command prompt and
  `.\surveilr --version` in powershell.
- If the tool is installed correctly, it will display the version number.

### Step 4 : Execute the commands below

1. Run the single execution command:**

   ```bash
   deno run -A https://raw.githubusercontent.com/surveilr/www.surveilr.com/main/lib/service/diabetes-research-hub/drhctl.ts 'foldername'
   ```

- Replace `foldername` with the name of your folder containing all CSV files to
  be converted.

  **Example:**

  ```bash
  deno run -A https://raw.githubusercontent.com/surveilr/www.surveilr.com/main/lib/service/diabetes-research-hub/drhctl.ts study-files
  ```

  - After the above command completes execution launch your browser and go to
    [http://localhost:9000/drh/index.sql](http://localhost:9000/drh/index.sql).

  This method provides a streamlined approach to complete the process and see
  the results quickly.

### Step 5 : Verify the Verification Validation Results in the UI

- Check the below section in UI and Perform the steps as in the second image

<p align="center">
   <img src="../diabetes-research-hub/assets/vv-image.png" alt="vv-image">
  </p>

<p align="center"><b>Image 1</b></p>

<p align="center">
   <img src="../diabetes-research-hub/assets/vv-step-img.png" alt="vv-steps-image">
  </p>

<p align="center"><b>Image 2</b></p>

# Try it out in this repo using automation script

**Note**: Reference sample files can be found in the repository folder:
/service/diabetes-research-hub/study-files.zip

First, prepare the directory with sample files and copy them to this folder, or
extract the sample files and move them to this folder:

```bash
$ cd service/diabetes-research-hub
```

Now
[Download `surveilr`](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into this directory,and use the automation script

```bash
# Use the automation script
$ deno run -A ./drhctl.ts study-files
```

**Note**: `study-files` is the folder name containing csv files.

# Try it out in this repo(for development activities)

The following SQL scripts will be used:

- drh-deidentification.sql: De-identifies sensitive columns in the study data.
- stateless.sql: Creates database views for SQLPage preview.
- orchestrate-drh-vv.sql: Performs verification and validation on the study data
  tables.

**Note**: Reference sample files can be found in the repository folder:
/service/diabetes-research-hub/study-files.zip

First, prepare the directory with sample files and copy them to this folder, or
extract the sample files and move them to this folder:

```bash
$ cd service/diabetes-research-hub
```

The directory should look like this now:

```
├── de-identification
|   ├──drh-deidentification.sql
├── study-files
│   ├── author.csv
│   ├── publication.csv
│   └── ...many other study files    
├── verfication-validation
|   ├──orchestrate-drh-vv.sql
├── stateless.sql
```

Now
[Download `surveilr`](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into this directory, then ingest and query the data:

```bash
# ingest and transform the CSV files in the "study-files/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r study-files/ && surveilr orchestrate transform-csv
```

```bash
# generate the combined  cgm tracing
$ deno run -A ./combined-cgm-tracing-generator.ts
```

```bash
# Apply de-identification
$ cat de-identification/drh-deidentification.sql| surveilr orchestrate -n "deidentification"
```

```bash
# Perform verification and validation
$ cat verfication-validation/orchestrate-drh-vv.sql | surveilr orchestrate -n "v&v"
```

```bash
# load the "Console" and other menu/routing utilities plus DRH Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2.Use the option 2 as the option1 has some issues)
$ surveilr shell ./package.sql.ts                 # option 2 (same as option 1)


# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ ../../std/surveilrctl.ts dev

# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/drh/index.sql to view DRH speciifc UI
```
