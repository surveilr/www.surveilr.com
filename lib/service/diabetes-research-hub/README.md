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
2. **Deno Runtime** (requires `deno2.0` ):
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

1. **Perform Ingestion and transformation**

```bash
# Execute the command below if the files in the study folder are of the CSV format.
surveilr ingest files -r `study-files-folder-name`/ && surveilr orchestrate transform-csv
```

- Replace `study-files-folder-name` with the name of your folder containing all CSV files to
  be converted.

**Example:**

```bash
surveilr ingest files -r study-files/ && surveilr orchestrate transform-csv
```

2. **SQL Transformation process**

Example: Considering the Dataset pattern is 'UVA DCLP1'

```bash
  surveilr shell ./dataset-specific-package/dclp1-uva-study.sql.ts
```

3. **Server UI execution**

execute

```bash
  SQLPAGE_SITE_PREFIX="" surveilr web-ui --port 9000

```

- After the above command completes execution launch your browser and go to
  [http://localhost:9000/drh/index.sql](http://localhost:9000/drh/index.sql).

This method provides a streamlined approach to complete the process and see
the results quickly.

Note: Based on the dataset pattern,the steps 1 and 2 will change in the foldername as well as in the .sql.ts file to be invoked.

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

# Using the Automation Script

The automation script currently assumes the dataset pattern is UVA DCLP1. If your dataset pattern differs, the automation script must invoke the SQL package specific to that pattern.

**Clear Cache and Execute Command**

Clear the cache by running the following command:

```bash
deno cache --reload https://raw.githubusercontent.com/surveilr/www.surveilr.com/main/lib/service/diabetes-research-hub/drhctl.ts
```

**Single execution process**

After clearing the cache, run the single execution command:

```bash
deno run -A https://raw.githubusercontent.com/surveilr/www.surveilr.com/main/lib/service/diabetes-research-hub/drhctl.ts 'foldername'
```

Replace `foldername` with the name of your folder containing all CSV files to be converted.

**Example:**

```bash
deno run -A https://raw.githubusercontent.com/surveilr/www.surveilr.com/main/lib/service/diabetes-research-hub/drhctl.ts study-files
```

After the above command completes execution, launch your browser and go to [http://localhost:9000/drh/index.sql](http://localhost:9000/drh/index.sql).

---

# Package Changes for `eg.surveilr.com`

The Diabetes Research Hub (DRH) handles various datasets, and compared to other patterns like **Direct Messaging Service** and **Content Assembler**, DRH requires a different `package.sql.ts` for each dataset.

In the case of `eg.surveilr.com`:

- The script picks up `package.sql.ts` from each pattern or service build and runs the **SQLPage UI** accordingly.
- Unlike other patterns, for DRH in `eg.surveilr.com`, we have renamed our `package.sql.ts` to **`drh-basepackage.sql.ts`**.
- The `package.sql.ts` now invokes the code for a specific study dataset package.

### Dataset Preparation

For proper execution:

1. The corresponding dataset must be unzipped and utilized.
2. We have set the **DCLP1 study with multiple CGM tracing** as the base dataset.

### Required Files

The folder to unzip is:

```
/service/diabetes-research-hub/datasets-transformed-archive/study-files.zip
```

### Steps to Perform

1. **Unzip the Folder:**

   - Extract the contents of the specified `.zip` file.

2. **Ingest and Transform Files:**
   Execute the following command to ingest and transform the CSV files in the `study-files/` directory (specific to the DCLP1 study with multiple CGM tracing):

   ```bash
   # Ingest and transform the CSV files, creating resource-surveillance.sqlite.db
   surveilr ingest files -r study-files/ && surveilr orchestrate transform-csv
   ```

   _(Option can be used without a Tenant ID.)_

3. **Execute the Shell:**
   Run the `package.sql.ts` script for the DCLP1 dataset:

   ```bash
   # For DCLP1 (multiple CGM tracing) study dataset
   surveilr shell ./package.sql.ts
   ```

### eg.surveilr.com-prepare.ts

```bash
  deno run -A ./eg.surveilr.com-prepare.ts  rssdPath='dbfolder/resource-surveillance.sqlite.db'
```

# Try It Out in This Repo (For Development Activities)

Each new dataset type requires manual review to assess study files, determine the mode of ingestion through Surveilr, and prepare a transformation SQL for DRH views. For every dataset, a new transform sql for the study, a combinedTracingView generator, and <studyName>.sql.ts must be created and maintained.

The process isn’t automated, the appropriate ingestion and transformation commands in Surveilr need to be manually selected based on the file types in the dataset folder

### Reference Sample Files

The following sample files are available in the repository:

- `/service/diabetes-research-hub/datasets-transformed-archive/study-files.zip`
- `/service/diabetes-research-hub/datasets-transformed-archive/ctr-study-files.zip`
- `/service/diabetes-research-hub/datasets-transformed-archive/de-trended-analysis-files.zip`
- `/service/diabetes-research-hub/datasets-transformed-archive/dclp1.zip`
- `/service/diabetes-research-hub/datasets-transformed-archive/dclp3.zip`
- `/service/diabetes-research-hub/datasets-transformed-archive/dss1.zip`
- `/service/diabetes-research-hub/datasets-transformed-archive/ntlt.zip`

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
# Ingest and transform the CSV files in the "study-files/" directory(dclp1 study files with multiple CGM tracing), creating resource-surveillance.sqlite.db
$ surveilr ingest files -r study-files/ --tenant-id UVA001 --tenant-name "UVA001" && surveilr orchestrate transform-csv  # (option 1)
$ surveilr ingest files -r study-files/ && surveilr orchestrate transform-csv # (option 2 without Tenant ID)

```

```bash
# Ingest and transform the CSV files in the "ctr-study-files/" directory(from Awesome CGM)
$ surveilr ingest files -r ctr-study-files/ --tenant-id CTR001 --tenant-name "CTR001" && surveilr orchestrate transform-csv
$ surveilr ingest files -r ctr-study-files/ && surveilr orchestrate transform-csv # (option 2 without Tenant ID)

```

```bash
# Ingest and transform the CSV files in the "de-trended-analysis-files/" directory(from Awesome CGM)
$ surveilr ingest files -r de-trended-analysis-files/ --tenant-id DFA001 --tenant-name "DFA001" && surveilr orchestrate transform-csv
$ surveilr ingest files -r de-trended-analysis-files/ && surveilr orchestrate transform-csv # (option 2 without Tenant ID)

```

```bash
# Ingest and transform the CSV files in the "dclp1/" directory(dclp1 study files with single CGM tracing), creating resource-surveillance.sqlite.db
$ surveilr ingest files -r dclp1/ --tenant-id UVA001 --tenant-name "UVA001" && surveilr orchestrate transform-csv  # (option 1)
$ surveilr ingest files -r dclp1/ && surveilr orchestrate transform-csv # (option 2 without Tenant ID)

```

```bash
# Ingest and transform the CSV files in the "dclp3/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r dclp3/ --tenant-id UVA001 --tenant-name "UVA001" && surveilr orchestrate transform-csv  # (option 1)
$ surveilr ingest files -r dclp3/ && surveilr orchestrate transform-csv # (option 2 without Tenant ID)

```

```bash

# Ingest and transform the CSV files in the "dss1/" directory
$ surveilr ingest files -r dss1/ --tenant-id UVA001 --tenant-name "UVA001" && surveilr orchestrate transform-csv
$ surveilr ingest files -r dss1/ && surveilr orchestrate transform-csv # (option 2 without Tenant ID)

```

```bash
# Ingest and transform the CSV files in the "ntlt/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r ntlt/ --tenant-id UVA001 --tenant-name "UVA001" && surveilr orchestrate transform-csv  # (option 1)
$ surveilr ingest files -r ntlt/ && surveilr orchestrate transform-csv # (option 2 without Tenant ID)

```

```bash
# Ingest and transform the CSV files in the "direc-net-inPt-exercise/" directory(Tsalikian (2005 from Awesome CGM)), creating resource-surveillance.sqlite.db
$ surveilr ingest files -r direc-net-inPt-exercise/ --tenant-id JAEB001 --tenant-name "JAEB001" && surveilr orchestrate transform-csv

```bash
# Ingest and transform the CSV files in the "wadwa/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r wadwa/ --tenant-id JAB001 --tenant-name "JAB001" && surveilr orchestrate transform-csv
```

```bash
# Ingest and transform the CSV files in the "RT-CGM-Randomized-Clinical-Trial/" directory(Tamborlane from Awesome CGM), creating resource-surveillance.sqlite.db
$ surveilr ingest  files -r RT-CGM-Randomized-Clinical-Trial/ --tenant-id JAEB001 --tenant-name "JAEB001" && surveilr orchestrate transform-csv
```

```bash
# Ingest and transform the CSV files in the "illinois-institute/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r illinois-institute/ --tenant-id IL0001 --tenant-name "IL0001" && surveilr orchestrate transform-csv
```
```bash
# Ingest and transform the CSV files in the "hupa-cgm-mealfitness/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r hupa-cgm-mealfitness --tenant-id SPRA --tenant-name "SPRA"  && surveilr orchestrate transform-csv
```
```bash
# Ingest and transform the CSV files in the "glucdict/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r glucdict/ --tenant-id BGU2021 --tenant-name "BGU2021" && surveilr orchestrate transform-csv
```

### Running the SQL Package and Web UI

For each Dataset a custom <packagefilename>.sql.ts will be created that perfoms the custom file transformation SQL generation and sqlpage setup

```bash
# For DCLP1 (multiple CGM tracing)study Dataset
$ surveilr shell ./dataset-specific-package/dclp1-uva-study.sql.ts
```

```bash
# For CTR Anderson(2016) study Dataset
$ surveilr shell ./dataset-specific-package/anderson.sql.ts
```

```bash
# For Detrended Fluctuation Analysis (colas 2019) study Dataset
$ surveilr shell ./dataset-specific-package/detrended-analysis.sql.ts
```

```bash
# For DCLP1 (Single CGM tracing)study Dataset
$ surveilr shell ./dataset-specific-package/dclp1-singlecgm-study.sql.ts
```

```bash
# For DCLP3 (Single CGM tracing)study Dataset
$ surveilr shell ./dataset-specific-package/dclp3-stateless.sql.ts
```

```bash
# For DSS1 (Single CGM tracing)study Dataset
$ surveilr shell ./dataset-specific-package/dss1-stateless.sql.ts
```

```bash
# For NTLT (Single CGM tracing)study Dataset
$ surveilr shell ./dataset-specific-package/ntlt-stateless.sql.ts
```

```bash
# For (Tsalikian (2005 from Awesome CGM))
$ surveilr shell ./dataset-specific-package/ieogc-package.sql.ts
```

```bash
# For (Wadwa (2021 from Awesome CGM))
$ surveilr shell ./dataset-specific-package/wadwa-package.sql.ts
```

```bash
# Tamborlane from Awesome CGM)
$ deno run -A ./study-specific-stateless/rtccgm-cgm-metadata-generator.ts processCgmFiles
$ deno run -A ./study-specific-stateless/generate-cgm-combined-sql.ts savertccgmJsonCgm
$ surveilr shell ./dataset-specific-package/rtccgm-package.sql.ts
```

```bash
# For (Illionis institute CGM)
$ surveilr shell ./dataset-specific-package/illinois-package.sql.ts
```


```bash
# HUPA CGM data(meal and fitness data)
$ deno run -A ./study-specific-stateless/generate-cgm-combined-sql.ts saveJsonCgm
$ deno run -A ./study-specific-stateless/generate-cgm-combined-sql.ts generateMealFitnessJson
$ surveilr shell ./dataset-specific-package/hupa-cgm-package.sql.ts
```

```bash
# Glucdict CGM data(meal and fitness data)
$ deno run -A ./study-specific-stateless/generate-cgm-combined-sql.ts saveJsonCgm
$ deno run -A ./study-specific-stateless/generate-cgm-combined-sql.ts transformToMealsAndFitnessJson
$ surveilr shell ./dataset-specific-package/glucdict-cgm-package.sql.ts
```

# Start the server

```bash
$ SQLPAGE_SITE_PREFIX="" surveilr web-ui --port 9000
```

You can now browse the Surveilr Web UI:

- **http://localhost:9000/**: Main Surveilr Web UI
- **http://localhost:9000/drh/index.sql**: DRH-specific UI
