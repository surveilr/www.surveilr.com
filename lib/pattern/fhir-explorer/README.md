# `surveilr` FHIR Explorer Pattern

[Learn more about this pattern](https://surveilr.com/pattern/fhir-explorer) at
[`www.surveilr.com`](https://surveilr.com/pattern/fhir-explorer).

- `stateless-fhir.surveilr.sql` script focuses on creating views that define how
  to extract and present specific FHIR data from the `uniform_resource.content`
  JSONB column. It does not modify or store any persistent data; it only sets up
  views for querying.
- `orchestrate-stateful-fhir.surveilr.sql` script is responsible for creating
  tables that cache data extracted by views. These tables serve as "materialized
  views", allowing for faster access to the data but are static. When new data
  is ingested, the tables need to be dropped and recreated manually, and any
  changes in the source data will not be reflected until the tables are
  refreshed.
- `package.sql.ts` script is the entry point for loading typical database
  objects and Web UI content.

## Try it out on any device without this repo (if you're just using the SQL scripts)

Prepare the directory with sample files, download Synthea samples, download
`surveilr`, and create `resource-surveillance.sqlite.db` RSSD file that will
contain queryable FHIR data.

```bash
# prepare a working directory with files
$ mkdir -p /tmp/fhir-query
$ cd /tmp/fhir-query

# download and unzip sample Synthea FHIR JSON files
$ wget https://synthetichealth.github.io/synthea-sample-data/downloads/latest/synthea_sample_data_fhir_latest.zip
$ mkdir ingest && cd ingest && unzip ../synthea_sample_data_fhir_latest.zip && cd ..

# download surveilr using instructions at https://docs.opsfolio.com/surveilr/how-to/installation-guide
# making sure surveilr is in your path, then run the ingestion of files downloaded above
$ surveilr ingest files -r ingest/

# use SQLPage to preview content (be sure `deno` v1.40 or above is installed)
$ surveilr https://surveilr.com/pattern/fhir-explorer/package.sql
$ surveilr web-ui --port 9000
# launch a browser and go to http://localhost:9000/fhir/index.sql
```

Running `surveilr ingest` and `surveilr .../package.sql` will automatically
create `resource-surveillance.sqlite.db` in your current directory. At this
point you can rename the SQLite database file, archive it, use in reporting
tools, DBeaver, DataGrip, or any other SQLite data access tools.

The typical `pattern/fhir-explorer/package.sql` will only create simple SQL
convenience views on top of ingested data. On fast machines the simple SQL views
will perform well. However, if performance is slow, you can apply
`orchestrate-stateful-fhir.surveilr.sql` which will add denormalized `*_cached`
tables in `resource-surveillance.sqlite.db`.

## Try it out in this repo (if you're developing SQL scripts)

First prepare the directory with sample files:

```bash
$ cd lib/pattern/fhir-explorer
$ wget https://synthetichealth.github.io/synthea-sample-data/downloads/latest/synthea_sample_data_fhir_latest.zip
$ wget https://synthetichealth.github.io/synthea-sample-data/downloads/10k_synthea_covid19_csv.zip
$ mkdir ingest && cd ingest && unzip ../synthea_sample_data_fhir_latest.zip && unzip ../10k_synthea_covid19_csv.zip && cd ..
$ rm -f synthea_sample_data_fhir_latest.zip 10k_synthea_covid19_csv.zip
```

The directory should look like this now:

```
.
├── ingest
│   ├── Abe604_Runolfsdottir785_3718b84e-cbe9-1950-6c6c-e6f4fdc907be.json
│   ├── ...(many more files)
│   └── Yon80_Kiehn525_54fe5c50-37cc-930b-8e3a-2c4e91bb6eec.json
├── orchestrate-stateful-fhir.surveilr.sql
├── package.sql.ts
└── stateless-fhir.surveilr.sql
```

Now
[Download `surveilr` binary](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into this directory, then ingest and query the data:

```bash
# ingest the files in the "ingest/" directory, creating resource-surveillance.sqlite.db
$ surveilr ingest files -r ingest/
```

After ingestion, you will only work with these files:

```
├── orchestrate-stateful-fhir.surveilr.sql
├── stateless-fhir.surveilr.sql 
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

# if you want to start surveilr embedded SQLPage in "watch" mode to re-load files automatically
$ ../../universal/sqlpagectl.ts dev --watch . --watch ../../std
# browse http://localhost:9000/ to see web UI

# if you want to start a standalone SQLPage in "watch" mode to re-load files automatically
$ ../../universal/sqlpagectl.ts dev --watch . --watch ../../std --standalone
# browse http://localhost:9000/ to see web UI

# browse http://localhost:9000/fhir/info-schema.sql to see FHIR-specific views and tables
```

## TODO

- [ ] Review and consider language-agnostic
      [SQL-on-FHIR](https://build.fhir.org/ig/FHIR/sql-on-fhir-v2) _View
      Definitions_ as an approach to auto-generate _SQL views_. In GitHub see
      [SQL-on-FHIR Repo](https://github.com/FHIR/sql-on-fhir-v2)
      [Reference implementation of the SQL on FHIR spec in JavaScript](https://github.com/FHIR/sql-on-fhir-v2/tree/master/sof-js)
      for a technique to parse the _SQL-on-FHIR View Definitions_.
