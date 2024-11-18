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

```bash
# ingest the files in the "ingest/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files --csv-transform-auto -r ingest
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
