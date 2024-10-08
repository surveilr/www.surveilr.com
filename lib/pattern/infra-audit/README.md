# `surveilr` Information assurance Explorer Pattern

Information assurance is the practice of managing and protecting information
systems to ensure data integrity, availability, confidentiality, authentication,
and non-repudiation. It encompasses processes, policies, and tools aimed at
safeguarding digital and physical assets against threats like unauthorized
access, data breaches, and cyberattacks, ensuring that information remains
secure and trustworthy throughout its lifecycle.

- `stateless.sql` script focuses on creating views that define how to extract
  and present specific controls data from the `uniform_resource.csv` tables.

- `package.sql.ts` script is the entry point for loading typical database
  objects and Web UI content.

  ## Try it out on any device without this repo (if you're just using the SQL scripts)

  The directory should look like this now:

```
├── stateless.sql 
└── resource-surveillance.sqlite.db            # SQLite database
```

Post-ingestion, `surveilr` is no longer required, the `ingest` directory can be
ignored, only `sqlite3` is required because all content is in the
`resource-surveillance.sqlite.db` SQLite database which does not require any
other dependencies.

```bash
# load the "Console" and other menu/routing utilities plus info assurance Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts                 # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ ../../std/surveilrctl.ts dev
# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/infra-audit/info-schema.sql to see infra-audit views and tables
```

## How to Run the Tap Tests

### RUN THIS TEST this using CLI

`rm -f tap.sql &&  deno run -A ./tap.sql.ts > tap.sql`

This will generate a tap.sql file from tap.sql.ts

`cat tap.sql | sqlite3 resource-surveillance.sqlite.db && sqlite3 resource-surveillance.sqlite.db -cmd "
SELECT * FROM synthetic_test_suite;"`

This script demonstrates how to create a Test Anything Protocol (TAP) report
using SQLite, following TAP version 14. It includes multiple test cases, and
subtests are formatted with indentation per TAP 14's subtest style.
