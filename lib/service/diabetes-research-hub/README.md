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

# Try It Out in This Repo (For Development Activities)

### Reference Sample Files

The following sample files are available in the repository:

- `/service/diabetes-research-hub/study-files.zip`
- `/service/diabetes-research-hub/ctr-study-files.zip`
- `/service/diabetes-research-hub/de-trended-analysis-files.zip`

Each of these folders contains different datasets.

### Preparing the Directory

First, prepare the directory by copying or extracting the required sample files into the appropriate folder:

```bash
$ cd service/diabetes-research-hub
```

Next, download and install [Surveilr](https://docs.opsfolio.com/surveilr/how-to/installation-guide/) into this directory, then ingest and transform the data.

### Removing the Old RSSD

When switching between different datasets, be sure to remove the old RSSD before ingesting the new dataset:

```bash
$ rm resource-surveillance.sqlite.db
```

### Ingesting and Transforming Data

Depending on the dataset you're working with, use the appropriate folder name in the `surveilr ingest` command. Below are examples for each dataset:

```bash
# Ingest and transform the CSV files in the "study-files/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r study-files/ && surveilr orchestrate transform-csv

# Ingest and transform the CSV files in the "ctr-study-files/" directory
$ surveilr ingest files -r ctr-study-files/ && surveilr orchestrate transform-csv

# Ingest and transform the CSV files in the "de-trended-analysis-files/" directory
$ surveilr ingest files -r de-trended-analysis-files/ && surveilr orchestrate transform-csv
```

### Special Instructions for the First Dataset (Study-Files)

For the first dataset, you need to generate the combined CGM tracing. Use the following command:

```bash
# Generate the combined CGM tracing for the first dataset
$ deno run -A ./combined-cgm-tracing-generator.ts
```

### De-identification and Validation & Verification (V&V)

The de-identification and V&V scripts are specific to the first dataset (`study-files`). For other datasets, this step should be skipped. V&V is incorporated through `package.sql.ts`, so there's no need to call it separately.

```bash
# Apply de-identification (only for the first dataset)
$ cat de-identification/drh-deidentification.sql | surveilr orchestrate -n "deidentification"
```

For other datasets, such as `ctr-study-files` or `de-trended-analysis-files`, use the corresponding SQL packages:

```bash
# Example for "ctr-study-files" dataset
statelessAndersonSQL within package.sql.ts

# Example for "de-trended-analysis-files" dataset
statelessdetrendedAnalysisSQL within package.sql.ts
```

### DRH Metrics SQL

```bash
# Use this only after running the combined CGM tracing generator for the first dataset
metricsDRHSQL within package.sql.ts generates metrics views.
```

### Running the SQL Package and Web UI

After processing the relevant SQL in `package.sql.ts`, proceed with one of the following commands to load the console and web UI:

```bash
# Option 1 (may have issues; see Option 2)
$ deno run -A ./package.sql.ts | surveilr shell

# Option 2 (preferred)
$ surveilr shell ./package.sql.ts
```

To enable "watch" mode, which automatically reloads `package.sql.ts`:

```bash
# Start Surveilr Web UI in "watch" mode
$ ../../std/surveilrctl.ts dev
```

You can now browse the Surveilr Web UI:

- **http://localhost:9000/**: Main Surveilr Web UI
- **http://localhost:9000/drh/index.sql**: DRH-specific UI
