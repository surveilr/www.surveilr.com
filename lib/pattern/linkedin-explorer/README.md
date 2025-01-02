# `surveilr` LinkedIn Explorer Pattern

The LinkedIn Explorer pattern is a Web UI integration in Surveilr that enables seamless ingestion, organization, and analysis of LinkedIn data. This pattern allows users to manually export LinkedIn data from their profiles, automatically ingest it into Surveilr, and utilize SQL views and Web UI components for efficient querying and interpretation of LinkedIn datasets.

## Workflow Steps

### Step 1: Export LinkedIn Data

1. Log into your LinkedIn account.
2. Navigate to Settings & Privacy > Data Privacy > Get a copy of your data.
3. Select All Data or specific data types like Connections, Skills, or Positions.
4. Click Request archive and download the ZIP file once available.

### Step 2: Prepare Data

1. Move all CSV files from the LinkedIn archive to a folder named linkedin-export.
2. Compress the linkedin-export folder into a ZIP file.

### Step 3: Create resource-surveillance.sqlite.db

Run the following command in the terminal to process the data:

```bash
deno run -A ./eg.surveilr.com-prepare.ts
```

- `stateless.sql` script focuses on creating views that define how to extract
  and present specific controls data from the `uniform_resource.csv` tables.

- `package.sql.ts` script is the entry point for loading typical database
  objects and Web UI content.

  ## Try it out on any device without this repo (if you're just using the SQL scripts)

  The directory should look like this now:

```bash
├── stateless.sql 
└── resource-surveillance.sqlite.db            # SQLite database
```

Post-ingestion, `surveilr` is no longer required, the `ingest` directory can be
ignored, only `sqlite3` is required because all content is in the
`resource-surveillance.sqlite.db` SQLite database which does not require any
other dependencies.

```bash
# load the "Console" and other menu/routing with sql package utilities plus ic Web UI (both are same, just run one)
$ SURVEILR_SQLPKG=~/.sqlpkg surveilr shell ./package.sql.ts
# load the "Console" and other menu/routing utilities plus ic Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts                 # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ SQLPAGE_SITE_PREFIX=/lib/pattern/lie ../../std/surveilrctl.ts dev
$ ../../std/surveilrctl.ts dev
# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/info-assurance-controls/info-schema.sql to see ic-specific views and tables
```

## How to Run the Tests

To execute test and ensure that `surveilr` is functioning correctly:

1. Run the tests using Deno:

   ```bash
   deno test -A  # Executes test
   ```

   This process will create an 'assurance' folder, where you can find the files
   related to the test, including the database and ingestion folder

The `-A` flag provides all necessary permissions for the tests to run, including
file system access and network permissions.

## How to Run the Tap Tests

### RUN THIS TEST this using CLI

`rm -f tap.sql &&  deno run -A ./tap.sql.ts > tap.sql`

This will generate a tap.sql file from tap.sql.ts

`cat tap.sql | sqlite3 resource-surveillance.sqlite.db && sqlite3 resource-surveillance.sqlite.db -cmd "
SELECT * FROM synthetic_test_suite;"`

This script demonstrates how to create a Test Anything Protocol (TAP) report
using SQLite, following TAP version 14. It includes multiple test cases, and
subtests are formatted with indentation per TAP 14's subtest style.
