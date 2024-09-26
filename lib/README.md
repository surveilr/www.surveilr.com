# `surveilr` Standard Library and Patterns

`surveilr`'s Standard Library (`std`) and Patterns are written in Deno-flavored TypeScript and **require Deno 1.40+** to run.

To understand terminology, see http://surveilr.com/blog/surveilr-core-vs-patterns/.

![lib content access points](./endpoints.drawio.png)

```mermaid
flowchart LR

%% Combine Industries, Patterns, and Disciplines into single boxes with their instances listed inside
IndustriesBox["Industries:
Digital Health, Diabetes Research, IT Asset Management, Cybersecurity, Compliance, Quality Metrics"]

PatternsBox["Patterns:
Operational Portfolios, Infrastructure Catalogs, IT Asset Management Patterns, Research Data Patterns, Clinical Data Patterns"]

DisciplinesBox["Disciplines:
Data Scientists, Cybersecurity Experts, Healthcare Professionals, IT Managers, Compliance Officers, QA Managers"]

%% Connect the combined boxes to SQL Inputs
IndustriesBox --> SQL_Inputs_Group["Custom SQL Code"]
PatternsBox --> SQL_Inputs_Group
DisciplinesBox --> SQL_Inputs_Group

%% Group for SQL input types
subgraph SQL_Inputs["SQL Inputs"]
    SQLa_Input["SQLa TypeScript-based SQL
      *.sql.ts"]
    CapExec_Input["SQL created by 
    other languages
      *.sql.py, *.sql.xyz"]
    Direct_SQL_Input["Direct (static) SQL
      *.sql"]
end

SQL_Inputs_Group --> SQL_Inputs["SQL Inputs"]

%% Process SQLa TypeScript SQL via SQL Assembler (Deno)
SQLa_Input --> SQL_Assembler_Deno["SQL Assembler (Deno)"]
CapExec_Input --> SQL_Assembler_Other["SQL Assembler
(Any Language)"]
SQL_Assembler_Deno --> SQL_Package["SQL Package"]
SQL_Assembler_Other --> SQL_Package["SQL Package"]

%% Direct SQL bypasses the assembler and goes directly to SQL Package
Direct_SQL_Input --> SQL_Package["package.sql"]

%% SQL Package flows into Surveilr Binary and RSSD Database
SQL_Package --> Surveilr_Binary["surveilr shell
(multi-OS executable)"]
Surveilr_Binary --> RSSD_DB["RSSD SQLite
 (single file database)"]

%% Portable output
RSSD_DB --> Target_System["Integrate anywhere SQLite
 is available"]
```

## `lib` Structure

```md
lib/
├── assurance/              Quality Assurance for surveilr
├── pattern/                All public patterns (composable)
│   ├── fhir-explorer/        FHIR Explorer Pattern
│   ├── osquery/              osQuery Integration pattern
│   └── (...)/                add more patterns above this one
├── service/                All public services (large combinations of patterns)
│   ├── drh/                  Diabetes Research Hub "Edge" Service
│   ├── opsfolio/             Opsfolio
│   └── (...)/                add more services above this one
├── std/                    surveilr Standard Library (used by all patterns)
│   ├── models/               RSSD schemas
│   ├── notebook/             Notebook schemas
│   ├── web-ui-content/       SQLPage content for Shell, Console, etc.
│   ├── deps.ts               Common Deno dependencies (used by all patterns)
│   └── package.sql.ts        Module to include in all other patterns
└── universal/              Universally applicable modules (can be used anywhere)
```

## Serving through `surveilr.com/lib/*`

The `src/pages/lib/[...slug].js` Astro endpoint serves all the content in this
directory as `/lib/*`:

- Any file can be served as-is by using it's direct relative path
- If a file name is of the format `*.sql.*` (ends in `.sql` plus another 
  extension like `*.sql.ts` or `.sql.sh`) then can be accessed without the
  second extension via just `*.sql`:
  - If the file has its executable bit set, it is executed and the result of
    STDOUT is returned as the URL's content
  - If the file does not have its executable bit set but ends in `.sql.ts`, it
    is executed via `deno -A <file>` and the result of STDOUT is captured an
    is returned as the URL's content

The `surveilr.com/lib/*` serving capability allows the following `surveilr` usage:

```bash
# if a file named `lib/pattern/fhir-explorer/package.sql.ts` is available then
# calling `package.sql` "executes" the `package.sql.ts` and returns just SQL
$ surveilr shell https://surveilr.com/lib/pattern/fhir-explorer/package.sql
```

You can also import `*.ts` files directly:

```bash
# if a file named `lib/pattern/fhir-explorer/package.sql.ts` is available then
# calling `package.sql.ts` allows importing in any Deno module:
$ deno run -A https://surveilr.com/lib/pattern/fhir-explorer/package.sql.ts
```

In summary:

- Using `https://surveilr.com/lib/pattern/fhir-explorer/package.sql.ts` emits
  the **TypeScript _source code_** (for example so it can be `import`ed into Deno).
- Using `https://surveilr.com/lib/pattern/fhir-explorer/package.sql` emits the
  the **SQL generated from executing TypeScript**.

## Automatically reloading SQL when it changes

On sandboxes during development and editing of `.sql` or `.sql.ts` you may want
to automatically re-load the contents into SQLite regularly. Since it can be
time-consuming to re-run the same command in the CLI manually each time a file
changes, you can use _watch mode_ instead.

See [`sqlpagectl.ts`](universal/sqlpagectl.ts) for usage instructions.