
The `Qualityfolio` specification introduces a structured, Markdown-driven approach to organizing, managing, and auditing test management artifacts. It is designed to integrate seamlessly with `surveilr`, allowing ingested content to be queried, tracked, and audited, while providing a web-based UI for dashboards and reporting similar to industry-standard test management systems.

- Qualityfolio is code-first ("test management as code" or TMaC)
- Qualityfolio supports GitOps and doing test management via CI/CD-based test automation
- Qualityfolio also supports manual executions of test cases
- Qualityfolio uses `surveilr` for RSSD-based content storage and Web UI

### Content Hierarchy

The `Qualityfolio` directory structure is designed to accommodate varying levels of complexity, from standalone test cases to hierarchical organizations with projects, suites, and test case groups.

#### Root Directory: `/qualityfolio`
- **Purpose**: Serves as the entry point for all test management content.
- **Contents**:
  - `README.md` *(optional)*: Provides a general description of the `Qualityfolio` directory's purpose and usage.
  - `<project>`: Subdirectories representing individual projects. If projects are not required, test cases can be placed directly under `/qualityfolio`.

### Project Structure: `/qualityfolio/<project>`
- **Purpose**: Represents a project, grouping related test suites and test cases.
- **Contents**:
  - `qf-project.md` *(optional)*: The project definition file containing metadata and descriptions. If absent, the directory name is used as the project name.
  - `<test-suite>`: Subdirectories representing test suites within the project. If suites are not required, test cases can be placed directly under `<project>`.

### Test Suite Structure: `/qualityfolio/<project>/<test-suite>`
- **Purpose**: Groups test cases and test case groups for modular testing.
- **Contents**:
  - `qf-suite.md` *(optional)*: The test suite definition file containing metadata and descriptions.
  - `<test-case-group>`: Subdirectories representing groups of test cases within the suite.
  - `<test-case>.case.md`: Individual test cases within the suite, described using Markdown.
  - `<test-case>_test.ts`: optional Deno-based unit test that can execute and produce results in TAP (for automation) or other formats. See `lib/assurance` examples.
  - `<test-case>.surveilr[json].sh`: optional executable which executes the test and generates capturable JSON when ingested by surveilr
  - `<test-case>.surveilr[tap].sh`: optional executable which executes the test and generates capturable TAP when ingested by surveilr

### Test Case Group Structure: `/qualityfolio/<project>/<test-suite>/<test-case-group>`
- **Purpose**: Allows further categorization of test cases within a suite.
- **Contents**:
  - `qf-case-group.md` *(optional)*: The test case group definition file containing metadata and descriptions.
  - `<test-case>.case.md`: Markdown files for individual test cases under the group.
  - `<test-case>.surveilr[json].sh`: optional executable which executes the test and generates capturable JSON when ingested by surveilr
  - `<test-case>.surveilr[tap].sh`: optional executable which executes the test and generates capturable TAP when ingested by surveilr

### Test Case Files Proposal (to be extensively edited by @arunqa and QA engineers)

1. **Test Case File**: `<test-case>.case.md`
   - **Purpose**: Defines a single test case, including test steps, expected outcomes, and metadata.
   - **Structure**:
     ```markdown
     ---
     FII: "TC-001"
     title: "Test Login Functionality"
     created_by: "tester@example.com"
     created_at: "2024-01-01"
     tags: ["authentication", "login"]
     priority: "High"
     ---
     ### Description
     Verifies that users can log in with valid credentials.

     ### Steps
     1. Navigate to the login page.
     2. Enter valid username and password.
     3. Click "Login."

     ### Expected Outcome
     - User is successfully logged in and redirected to the dashboard.

     ### Expected Results
     <query-result>select x from y</query-result>
     ```

The `<query-result>` assumes that test runs and results are ingested via `surveilr` and there are SQL views available to access the results in the RSSD.

2. **Test Run Summary**: `<test-case>.run.md`
   - **Purpose**: Captures the summary of all runs for a test case.
   - **Structure**:
     ```markdown
     ---
     FII: "TR-001"
     test_case_fii: "TC-001"
     run_date: "2024-01-15"
     environment: "Production"
     ---
     ### Run Summary
     - Status: Passed
     - Notes: All steps executed successfully.
     ```

3. **Test Result File**: `<test-case>.run-<run>.result.*`
   - **Purpose**: Stores results for specific runs of a test case.
   - **Formats**: JSON, TAP (Test Anything Protocol), or other structured formats.
   - **Example (JSON)**:
     ```json
     {
       "test_case_fii": "TC-001",
       "run_id": "TR-001",
       "result": "pass",
       "steps": [
         {"step": 1, "result": "pass"},
         {"step": 2, "result": "pass"},
         {"step": 3, "result": "pass"}
       ]
     }
     ```

### Web UI Integration with `surveilr`

The `Qualityfolio` content is ingested into `surveilr` for structured storage and analytics. The resulting data can then be accessed via a web-based dashboard with the following features:

#### Features of the Web UI
1. **Dashboard**:
   - **Metrics**: Displays pass/fail rates, defect counts, and test case coverage by project, suite, or individual cases.
   - **Filters**: Enables filtering by tags, priorities, or custom fields.
   - **Charts**: Visualizes trends in testing progress and defect discovery.

2. **Test Case Explorer**:
   - Allows navigation through the `Qualityfolio` hierarchy (projects, suites, groups, cases).
   - Provides detailed views for each test case, including steps, results, and run history.

3. **Test Execution Reports**:
   - Summarizes execution status for specific runs, showing failures, blocked cases, and defects linked to test results.

4. **Auditing and Traceability**:
   - Ensures full traceability of test cases to results using FII codes.
   - Enables querying historical data for compliance or debugging.

### Example Simplest Directory Structure

```bash
/qualityfolio
  my-test-case.case.md
```

Project structure

```bash
/qualityfolio
  /qualitfolio/my-project/my-test-case.case.md
```

Project and suite structure

```bash
/qualityfolio
  /qualitfolio/my-project-1/my-test-case.case.md
  /qualitfolio/my-project-2/my-test-suite-1/my-test-case.case.md
  /qualitfolio/my-project-2/my-test-suite-2/my-test-case.case.md
```

Project and suite with test case subgroups and subcase structure (arbitrary depth)

```bash
/qualityfolio
  /qualitfolio/my-project-1/my-test-case.case.md
  /qualitfolio/my-project-2/my-test-suite-1/my-test-case.case.md
  /qualitfolio/my-project-2/my-test-suite-2/my-test-case.case.md
  /qualitfolio/my-project-3/my-test-suite-3/my-suite-3-group-1/my-test-case.case.md
  /qualitfolio/my-project-3/my-test-suite-3/my-suite-3-group-2/my-test-case.case.md
```

### Example Full Project Structure

```bash
/qualityfolio
  /my-project
    qf-project.md
    /my-test-suite
      qf-suite.md
      /my-test-case-group
        qf-case-group.md
        test-login.case.md
        test-login.run.md
        test-login.run-1.result.json
```
## Commands

### Ingest Markdown Content
```bash
surveilr ingest files -r synthetic-asset-tracking
```
Post-ingestion, `surveilr` is no longer required, the `synthetic-asset-tracking` directory can be
ignored, only `sqlite3` is required because all content is in the
`resource-surveillance.sqlite.db` SQLite database which does not require any
other dependencies.

## Start surveilr Web UI
Post-ingestion, `surveilr` is no longer required, the `ingest` directory can be
ignored, only `sqlite3` is required because all content is in the
`resource-surveillance.sqlite.db` SQLite database which does not require any
other dependencies.

```bash
# load the "Console" and other menu/routing utilities plus FHIR Web UI (both are same, just run one)
$ deno run -A ./package.sql.ts | surveilr shell   # option 1 (same as option 2)
$ surveilr shell ./package.sql.ts                 # option 2 (same as option 1)

# start surveilr web-ui in "watch" mode to re-load package.sql.ts automatically
$ SQLPAGE_SITE_PREFIX="" ../../std/surveilrctl.ts dev
# browse http://localhost:9000/ to see surveilr web UI
# browse http://localhost:9000/qltyfolio/info-schema.sql to see DMS-specific schema
```

Once you apply `stateless.sql` you can ignore that files and all content will be
accessed through views or `*.cached` tables in
`resource-surveillance.sqlite.db`. At this point you can rename the SQLite
database file, archive it, use in reporting tools, DBeaver, DataGrip, or any
other SQLite data access tools.
