# Surveilr Data Transformation and SQLPage Preview Guide

## Overview

Welcome to the Surveilr Data Transformation and SQLPage Preview guide! This tool
allows you to securely convert your CSV files, perform de-identification, and
conduct verification and validation (V&V) processes behind your firewall. You
can view the results directly on your local system. The following steps will
guide you through converting your files, performing de-identification, V&V, and
verifying the data all within your own environment.

# Try outside this repo

```bash
# prepare a working directory
$ mkdir -p /tmp/research-study
$ cd /tmp/research-study
```

Prepare the sample files for ingestion

```bash
# download the sample study zip file using the below command.
$ wget https://github.com/surveilr/www.surveilr.com/raw/main/lib/pattern/research-study-explorer/dclp1.zip
```

Extract the zip file

```bash
$ unzip ./dclp1.zip
```

Once unzipped, you should see the sample files in the study folder. The
'research-study' directory structure should look like this:

```bash

research-study
├── dclp1
    ├── study.csv
    ├── investigator.csv
    ├── author.csv
    └── cgm_tracing.csv
```

Now
[Download `surveilr` binary](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into 'research-study' directory, then ingest and query the data:

```bash
# ingest and transform the csv files in the "dclp1/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r dclp1/ --tenant-id UVA001 --tenant-name "UVA001" && surveilr orchestrate transform-csv
```

After ingestion and transformation , your directory structure should look like this

```
research-study
├── dclp1
    ├── study.csv
    ├── investigator.csv
    ├── author.csv
    └── cgm_tracing.csv
└── resource-surveillance.sqlite.db            # SQLite database
```

After data ingestion and transformation, we will execute package.sql against the RSSD. The package.sql.ts script will consolidate subsequent SQL files and the base package into a single SQL file for execution.

```bash
# use SQLPage to preview content (be sure `deno` v1.40 or above is installed)
$ surveilr shell https://surveilr.com/lib/pattern/research-study-explorer/package.sql

$ surveilr web-ui --port 9000
# launch a browser and go to http://localhost:9000/drh/index.sql
```

At this point you can rename the SQLite database file, archive it, use in
reporting tools, DBeaver, DataGrip, or any other SQLite data access tools.

## Try it out in this repo (if you're developing SQL scripts)

### Clone the Repository

- Clone the repository containing the necessary scripts:
  ```bash
  git clone https://github.com/surveilr/www.surveilr.com.git
  ```

### Change to the Cloned Directory

- After cloning, navigate to the repository folder:
  ```bash
  cd lib/pattern/research-study-explorer
  ```

### Prepare the Sample Files for Ingestion

wget
https://github.com/surveilr/www.surveilr.com/raw/main/lib/pattern/research-study-explorer/dclp1.zip

#### Extract the Zip File

Before beginning the ingestion process, extract the sample files from the zip
archive named `dclp1.zip`.

### Verify the Directory Structure

Once unzipped, you should see the sample files in the ingest folder. The
'research-study-explorer' directory structure should look like this:

```
research-study-explorer
├──dclp1
    ├── study.csv
    ├── investigator.csv
    ├── author.csv
    └── cgm_tracing.csv
├── d3-aide-component.js
├── drh-basepackage.sql.ts
├── drh-metrics.sql
├── metrics-explanation-dml.sql
├── package.sql.ts
└── stateless.sql
```

Now
[Download `surveilr` binary](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into 'research-study-explorer' directory, then ingest and query the data:

```bash
# ingest and transform the csv files in the "dclp1/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r dclp1/ --tenant-id UVA001 --tenant-name "UVA001" && surveilr orchestrate transform-csv
```

After ingestion and transformation , your directory structure should look like this

```
research-study-explorer
├── d3-aide-component.js
├── drh-basepackage.sql.ts
├── drh-metrics.sql
├── metrics-explanation-dml.sql
├── package.sql.ts
├── stateless.sql
└── resource-surveillance.sqlite.db            # SQLite database
```

After data ingestion and transformation, we will execute package.sql against the RSSD. The package.sql.ts script will consolidate subsequent SQL files and the base package into a single SQL file for execution.

```bash

$ surveilr shell ./package.sql.ts                 

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ SQLPAGE_SITE_PREFIX=/lib/pattern/research-study-explorer ../../std/surveilrctl.ts dev

```

You can now browse the Surveilr Web UI:

- **http://localhost:9000/**: Main Surveilr Web UI
- **http://localhost:9000/drh/index.sql**: DRH-specific UI

Once you apply `stateless.sql` you can ignore that files and all content will be
accessed through views or `*.cached` tables in
`resource-surveillance.sqlite.db`. At this point you can rename the SQLite
database file, archive it, use in reporting tools, DBeaver, DataGrip, or any
other SQLite data access tools.

## Automatically reloading SQL when it changes

On sandboxes during development and editing of `.sql` or `.sql.ts` you may want
to automatically re-load the contents into SQLite regularly. Since it can be
time-consuming to re-run the same command in the CLI manually each time a file
changes, you can use _watch mode_ instead.

See: [`surveilrctl.ts`](../../std/surveilrctl.ts).

