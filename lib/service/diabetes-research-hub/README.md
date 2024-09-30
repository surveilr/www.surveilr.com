# Surveilr DRH Data Transformation and SQLPage Preview Guide for Developers

## Overview

Welcome to the Surveilr DRH Data Transformation and SQLPage Preview guide! This
tool allows you to securely convert your CSV files, perform de-identification,
and conduct verification and validation (V&V) processes behind your firewall.
You can view the results directly on your local system. The following steps will
guide you through converting your files, performing de-identification, V&V, and
verifying the data all within your own environment.

# Try it out in this repo

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
├── generate-raw-cgm-web-ui-pages.sql
```

Now
[Download `surveilr`](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into this directory, then ingest and query the data:

```bash
# ingest and transform the CSV files in the "study-files/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r study-files/ && surveilr orchestrate transform-csv
```


```bash
# Apply de-identification
$ cat de-identification/drh-deidentification.sql| surveilr orchestrate -n "deidentification"
````

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
