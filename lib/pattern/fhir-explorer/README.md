# `surveilr` Digital Health Patterns

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
# then run the ingestion of files downloaded above
$ surveilr ingest files -r ingest/

# use SQLPage to preview content (be sure `deno` v1.40 or above is installed)
$ surveilr https://surveilr.com/pattern/fhir-explorer/pattern.sql
$ surveilr web-ui --port 9000
# launch a browser and go to http://localhost:9000/fhir/index.sql
```

Once you ingest all the JSON using `surveilr`, apply
`orchestrate-stateful-fhir.surveilr.sql` and `stateless-fhir.surveilr.sql` all
content will be accessed through views or `*.cached` tables in
`resource-surveillance.sqlite.db`.

At this point you can rename the SQLite database file, archive it, use in
reporting tools, DBeaver, DataGrip, or any other SQLite data access tools.

## Try it out in this repo (if you're developing SQL scripts)

First prepare the directory with sample files:

```bash
$ cd pattern/fhir-explorer
$ wget https://synthetichealth.github.io/synthea-sample-data/downloads/latest/synthea_sample_data_fhir_latest.zip
$ wget https://synthetichealth.github.io/synthea-sample-data/downloads/10k_synthea_covid19_csv.zip
$ mkdir ingest && cd ingest && unzip ../synthea_sample_data_fhir_latest.zip ../10k_synthea_covid19_csv.zip && cd ..
```

The directory should look like this now:

```
.
├── ingest
│   ├── Abe604_Runolfsdottir785_3718b84e-cbe9-1950-6c6c-e6f4fdc907be.json
│   ├── ...(many more files)
│   └── Yon80_Kiehn525_54fe5c50-37cc-930b-8e3a-2c4e91bb6eec.json
├── orchestrate-stateful-fhir.surveilr.sql
├── stateless-fhir.surveilr.sql
└── synthea_sample_data_fhir_latest.zip
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
# load the "Console" and other menu/routing utilities plus FHIR Web UI
$ deno run -A ./ux.sql.ts | sqlite3 resource-surveillance.sqlite.db

# if you want to start surveilr embedded SQLPage in "watch" mode to re-load files automatically
$ ../../support/bin/sqlpagectl.ts dev --watch . --watch ../core
# browse http://localhost:9000/ to see web UI

# if you want to start a standalone SQLPage in "watch" mode to re-load files automatically
$ ../../support/bin/sqlpagectl.ts dev --watch . --watch ../core --standalone
# browse http://localhost:9000/ to see web UI

# browse http://localhost:9000/fhir/info-schema.sql to see FHIR-specific
```

Once you apply `orchestrate-stateful-fhir.surveilr.sql` and
`stateless-fhir.surveilr.sql` you can ignore those files and all content will be
accessed through views or `*.cached` tables in
`resource-surveillance.sqlite.db`. At this point you can rename the SQLite
database file, archive it, use in reporting tools, DBeaver, DataGrip, or any
other SQLite data access tools.

## Installing SQLite 3.46.0 on Ubuntu

To install SQLite 3.46.0 on Ubuntu, follow these steps:

### Update and Install Dependencies

Ensure your package lists are up-to-date and install the necessary tools to
build software from source:

```bash
sudo apt update
sudo apt install -y build-essential libreadline-dev wget
```

### Download SQLite 3.46.0

Navigate to the directory where you want to download the SQLite source code and
then download it:

```bash
cd /usr/local/src
sudo wget https://www.sqlite.org/2024/sqlite-autoconf-3460000.tar.gz
```

### Extract the Downloaded Tarball

```bash
sudo tar -xzf sqlite-autoconf-3460000.tar.gz
cd sqlite-autoconf-3460000
```

### Build and Install SQLite

Configure, build, and install SQLite:

```bash
sudo ./configure --prefix=/usr/local
sudo make
sudo make install
```

### Verify the Installation

After installation, open a new terminal and verify that SQLite 3.46.0 is
installed correctly by checking its version:

```bash
sqlite3 --version
```

## Automatically reloading SQL when it changes

On sandboxes during development and editing of `.sql` or `.sql.ts` you may want
to automatically re-load the contents into SQLite regularly. Since it can be
time-consuming to re-run the same command in the CLI manually each time a file
changes, you can use _watch mode_ instead.

See: [`sqlpagectl.ts`](../../support/bin/sqlpagectl.ts).

## TODO

- [ ] Review and consider language-agnostic
      [SQL-on-FHIR](https://build.fhir.org/ig/FHIR/sql-on-fhir-v2) _View
      Definitions_ as an approach to auto-generate _SQL views_. In GitHub see
      [SQL-on-FHIR Repo](https://github.com/FHIR/sql-on-fhir-v2)
      [Reference implementation of the SQL on FHIR spec in JavaScript](https://github.com/FHIR/sql-on-fhir-v2/tree/master/sof-js)
      for a technique to parse the _SQL-on-FHIR View Definitions_.
