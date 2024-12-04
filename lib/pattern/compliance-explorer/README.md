# `surveilr` Information Controls Explorer Pattern

Information Controls, refer to specific security, compliance, or operational
measures that organizations put in place to manage risks related to information
systems and data handling.

- `stateless.sql` script focuses on creating views that define how to extract
  and present specific controls data from the `uniform_resource.csv` tables.

- `stateful.sql` script is responsible for creating tables that cache data
  extracted by views.

- `package.sql.ts` script is the entry point for loading typical database
  objects and Web UI content.

## Try it out on any device without this repo (if you're just using the SQL scripts)

```bash
# prepare a working directory
$ mkdir -p /tmp/compliance-explorer
$ cd /tmp/compliance-explorer
```

Prepare the sample files for ingestion

Place the control CSV files in the ingest folder. The directory structure of
`compliance-explorer` should look like this:

```bash
compliance-explorer
├── ingest
│   ├── SCF_2024.2.csv
├── package.sql.ts
└── stateless.sql
```

Now
[Download `surveilr` binary](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into 'compliance-explorer' directory, then ingest and query the data:

## Ingesting Data

Once you have downloaded the binary, you can ingest data and create the `resource-surveillance.sqlite.db` database using one of the two methods:

### Option 1: Using Surveilr Command
Run the following command to ingest files from the `ingest/` directory:

```bash
# Ingest files and create resource-surveillance.sqlite.db
$ surveilr ingest files --csv-transform-auto -r ingest
```
### Option 2: Using a Deno Script

Alternatively, you can use the provided Deno script to perform the ingest process. The rssdPath parameter specifies the destination path and name of the database:

```bash
# Ingest files and create resource-surveillance.sqlite.db
$ deno run -A eg.surveilr.com-prepare.ts rssdPath="resource-surveillance.sqlite.db"
```

After ingestion your directory structure should look like this

```
compliance-explorer
├── ingest
│   ├── SCF_2024.2.csv
├── package.sql.ts
└── stateless.sql
└── resource-surveillance.sqlite.db            # SQLite database
```

Post-ingestion, `surveilr` is no longer required, the `ingest` directory can be
ignored, only `sqlite3` is required because all content is in the
`resource-surveillance.sqlite.db` SQLite database which does not require any
other dependencies.

```bash
# load the "Console" and other menu/routing utilities plus FHIR Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts                 # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ ../../std/surveilrctl.ts dev
# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/dms/info-schema.sql to see DMS-specific schema
```

Once you apply `stateless.sql` you can ignore that files and all content will be
accessed through views or `*.cached` tables in
`resource-surveillance.sqlite.db`. At this point you can rename the SQLite
database file, archive it, use in reporting tools, DBeaver, DataGrip, or any
other SQLite data access tools.
