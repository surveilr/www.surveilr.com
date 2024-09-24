# Resource Surveillance Commons Prime

`RSC` Prime houses reusable and common
[Resource Surveillance](https://www.opsfolio.com/surveilr) (`surveilr`)
"primary" (universal) patterns such as "Console", general navigation, and other
"universal helpers" (content and pages that work across `surveilr`-based
applications)

You can load these into any `surveilr` RSSD:

```bash
$ deno run https://raw.githubusercontent.com/opsfolio/resource-surveillance-commons/main/prime/ux.sql.ts | sqlite3 resource-surveillance.sqlite.db
$ surveilr web-ui --port 9000
# open the page at http://localhost:9000/
```

Ease development using `watch` mode:

```bash
$ ../support/bin/sqlpagectl.ts dev --watch . --standalone
```

The above would start a standalone SQLPage instance and automatically reload all
`*.sql*` files so you can just save from your IDE and refresh the web page to
see changes.

## Orchestration

Orchestration can be broken down into different natures.

1. Verification and Validation
2. De-Identification
3. Transformation

In these examples, de-identification and transformation will be shown

```bash
$ cd prime
```

Now, [Download `surveilr` binary](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)
into this directory, then ingest emails:

1. First prepare the RSSD with sample emails for deidentification:

   ```bash
   # ingest emails from IMAP boxes
   $ surveilr ingest imap -u surveilrregression@gmail.com --password '' -a "imap.gmail.com" -b 20 -s "all" --extract-attachments "yes"
   ```

   or using synthetic data

   ```bash
       # initialize and empty resource-surveillance.sqlite.db
       $ surveilr admin init
       # put data into the RSSD
       $ cat ../pattern/privacy/anonymize-sample/de-identification/sample-imap-rssd.sql | sqlite3 resource-surveillance.sqlite.db
   ```

   execute the orchestration script

   ```bash
   $ curl -L https://raw.githubusercontent.com/opsfolio/resource-surveillance-commons/main/pattern/privacy/anonymize-sample/de-identification/deidentification.sql | \
           surveilr orchestrate -n "deidentification"
   $ surveilr orchestrate -n "deidentification" -s https://raw.githubusercontent.com/opsfolio/resource-surveillance-commons/main/pattern/privacy/anonymize-sample/de-identification/deidentification.sql -s ../pattern/privacy/anonymize-sample/de-identification/deidentification_without_orchestration.sql
   ```

2. Add data to be transformed to the RSSD:
   ```bash
        $ wget https://synthetichealth.github.io/synthea-sample-data/downloads/10k_synthea_covid19_csv.zip
        $ mkdir ingest && cd ingest && unzip ../10k_synthea_covid19_csv.zip && cd ..
        # seeing that there are now csv files to work with in the RSSD, we can orchestrate on them by converting them to tables
        $ surveilr ingest files -r ./ingest && surveilr orchestrate transform-csv
   ```

Post-orchestration, `surveilr` is no longer required, only `sqlite3` is required because all content is in the
`resource-surveillance.sqlite.db` SQLite database which does not require any
other dependencies.

```bash
# load the "Console" and other menu/routing utilities
$ deno run ./ux.sql.ts | sqlite3 resource-surveillance.sqlite.db

# if you want to start surveilr embedded SQLPage in "watch" mode to re-load files automatically
$ ../support/bin/sqlpagectl.ts dev --watch .
# browse http://localhost:9000/ to see web UI

# if you want to start a standalone SQLPage in "watch" mode to re-load files automatically
$ ../support/bin/sqlpagectl.ts dev --watch . --standalone
# browse http://localhost:9000/ to see web UI
```
