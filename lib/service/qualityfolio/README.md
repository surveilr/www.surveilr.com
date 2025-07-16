# Qualityfolio: Test Management as Code Platform

Qualityfolio is a modern test management platform built on surveilr that transforms traditional test management into a code-first, GitOps-enabled approach. Instead of using proprietary test management tools with complex interfaces, Qualityfolio uses structured Markdown files stored in Git repositories to manage test cases, execution results, and compliance reporting.

## What Qualityfolio Does

Qualityfolio enables organizations to:

- ✅ **Manage test cases as code** using Markdown files in version control systems
- ✅ **Execute tests via CI/CD pipelines** with automated result capture and reporting
- ✅ **Track test execution history** with full audit trails and traceability
- ✅ **Generate compliance reports** for quality assurance and regulatory requirements

## Key Benefits

🔹 **Version Control Integration**: Test cases live alongside your code in Git repositories
🔹 **CI/CD Automation**: Execute tests automatically through existing CI/CD pipelines
🔹 **Real-time Dashboards**: Track quality metrics and compliance with web-based reporting
🔹 **Audit & Compliance**: Maintain complete audit trails for regulatory and quality standards
🔹 **Developer-Friendly**: Uses familiar tools (Markdown, Git, SQL) that development teams already know

## Core Features

- **Code-First Approach**: "Test Management as Code" (TMaC) using structured Markdown files
- **GitOps Integration**: Full support for Git-based workflows and CI/CD automation
- **Flexible Execution**: Supports both manual test case execution and automated testing
- **surveilr Integration**: Uses surveilr for RSSD-based content storage and web UI
- **Complete Traceability**: Full audit trails and evidence collection for quality standards

## Getting Started

### Step 1: Set Up Example Test Structure

Before creating your own test cases, run the preparation script to see example structures and templates:

```bash
# Generate example Qualityfolio directory structure and test cases
deno run -A eg.surveilr.com-prepare.ts
```

**What this script creates:**

- Example `/qualityfolio` directory with proper structure
- Sample test cases in Markdown format (`.case.md` files)
- Example projects, test suites, and test case groups
- Templates for test runs and result files
- Demonstration of different test case complexity levels

### Step 2: Understand the Structure

After running the preparation script, explore the generated structure to understand how Qualityfolio organizes test content.

### Content Hierarchy

The `Qualityfolio` directory structure is designed to accommodate varying levels
of complexity, from standalone test cases to hierarchical organizations with
projects, suites, and test case groups.

#### Root Directory: `/qualityfolio`

- **Purpose**: Serves as the entry point for all test management content.
- **Contents**:
  - `README.md` _(optional)_: Provides a general description of the
    `Qualityfolio` directory's purpose and usage.
  - `<project>`: Subdirectories representing individual projects. If projects
    are not required, test cases can be placed directly under `/qualityfolio`.

### Project Structure: `/qualityfolio/<project>`

- **Purpose**: Represents a project, grouping related test suites and test
  cases.
- **Contents**:
  - `qf-project.md` _(optional)_: The project definition file containing
    metadata and descriptions. If absent, the directory name is used as the
    project name.
  - `<test-suite>`: Subdirectories representing test suites within the project.
    If suites are not required, test cases can be placed directly under
    `<project>`.

### Test Suite Structure: `/qualityfolio/<project>/<test-suite>`

- **Purpose**: Groups test cases and test case groups for modular testing.
- **Contents**:
  - `qf-suite.md` _(optional)_: The test suite definition file containing
    metadata and descriptions.
  - `<test-case-group>`: Subdirectories representing groups of test cases within
    the suite.
  - `<test-case>.case.md`: Individual test cases within the suite, described
    using Markdown.
  - `<test-case>_test.ts`: optional Deno-based unit test that can execute and
    produce results in TAP (for automation) or other formats. See
    `lib/assurance` examples.
  - `<test-case>.surveilr[json].sh`: optional executable which executes the test
    and generates capturable JSON when ingested by surveilr
  - `<test-case>.surveilr[tap].sh`: optional executable which executes the test
    and generates capturable TAP when ingested by surveilr

### Test Case Group Structure: `/qualityfolio/<project>/<test-suite>/<test-case-group>`

- **Purpose**: Allows further categorization of test cases within a suite.
- **Contents**:
  - `qf-case-group.md` _(optional)_: The test case group definition file
    containing metadata and descriptions.
  - `<test-case>.case.md`: Markdown files for individual test cases under the
    group.
  - `<test-case>.surveilr[json].sh`: optional executable which executes the test
    and generates capturable JSON when ingested by surveilr
  - `<test-case>.surveilr[tap].sh`: optional executable which executes the test
    and generates capturable TAP when ingested by surveilr

### Test Case Files Proposal (to be extensively edited by @arunqa and QA engineers)

1. **Test Case File**: `<test-case>.case.md`
   - **Purpose**: Defines a single test case, including test steps, expected
     outcomes, and metadata.
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

The `<query-result>` assumes that test runs and results are ingested via
`surveilr` and there are SQL views available to access the results in the RSSD.

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
   - **Formats**: JSON, TAP (Test Anything Protocol), or other structured
     formats.
   - **Example (JSON)**:

     ```json
     {
       "test_case_fii": "TC-001",
       "run_id": "TR-001",
       "result": "pass",
       "steps": [
         { "step": 1, "result": "pass" },
         { "step": 2, "result": "pass" },
         { "step": 3, "result": "pass" }
       ]
     }
     ```

### Web UI Integration with `surveilr`

The `Qualityfolio` content is ingested into `surveilr` for structured storage
and analytics. The resulting data can then be accessed via a web-based dashboard
with the following features:

#### Features of the Web UI

1. **Dashboard**:
   - **Metrics**: Displays pass/fail rates, defect counts, and test case
     coverage by project, suite, or individual cases.
   - **Filters**: Enables filtering by tags, priorities, or custom fields.
   - **Charts**: Visualizes trends in testing progress and defect discovery.

2. **Test Case Explorer**:
   - Allows navigation through the `Qualityfolio` hierarchy (projects, suites,
     groups, cases).
   - Provides detailed views for each test case, including steps, results, and
     run history.

3. **Test Execution Reports**:
   - Summarizes execution status for specific runs, showing failures, blocked
     cases, and defects linked to test results.

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

Project and suite with test case subgroups and subcase structure (arbitrary
depth)

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

### Step 3: Ingest Test Content into Database

Once you understand the structure, ingest your test content into the surveilr database:

```bash
# Ingest all Qualityfolio test content into surveilr database
surveilr ingest files -r qualityfolio
```

**What happens during ingestion:**

- Markdown test files are parsed and structured data extracted
- Test cases, suites, and projects are stored in the RSSD database
- Metadata and relationships between test components are established
- Content becomes queryable via SQL and accessible through the web UI

### Step 4: Launch Qualityfolio Web UI

After ingestion, start the web interface to manage and monitor your test cases:

```bash
# Load the Console and Qualityfolio Web UI components
deno run -A ./package.sql.ts | surveilr shell

# Alternative method (equivalent to above)
surveilr shell ./package.sql.ts

# Start surveilr web UI in development mode with auto-reload
SQLPAGE_SITE_PREFIX="" ../../std/surveilrctl.ts dev

# Access the web interface
# Main UI: http://localhost:9000/
# Qualityfolio Schema: http://localhost:9000/qltyfolio/info-schema.sql
```

## Web UI Features

The Qualityfolio web interface provides comprehensive test management capabilities:

### 📊 Dashboard

- **Test Metrics**: Pass/fail rates, defect counts, and test case coverage
- **Project Overview**: Status across projects, suites, and individual test cases
- **Trend Analysis**: Charts showing testing progress and defect discovery over time
- **Custom Filters**: Filter by tags, priorities, environments, or custom fields

### 🔍 Test Case Explorer

- **Hierarchical Navigation**: Browse through projects, suites, groups, and test cases
- **Detailed Views**: Complete test case information including steps, results, and history
- **Search & Filter**: Find specific test cases using various criteria
- **Execution History**: Track all test runs and results for each test case

### 📋 Test Execution Reports

- **Run Summaries**: Execution status for specific test runs
- **Failure Analysis**: Detailed information about failed, blocked, or skipped tests
- **Defect Tracking**: Link test results to defects and issues
- **Environment Comparison**: Compare test results across different environments

### 🔒 Auditing and Traceability

- **Complete Audit Trails**: Full traceability using FII (Functional Identifier Index) codes
- **Historical Data**: Query and analyze historical test data for compliance
- **Evidence Collection**: Maintain evidence for regulatory and quality standards
- **Change Tracking**: Monitor changes to test cases and execution results

## Quick Start Commands

### Complete Setup Workflow

```bash
# 1. Generate example test structure and templates
deno run -A eg.surveilr.com-prepare.ts

# 2. Ingest test content into database
surveilr ingest files -r qualityfolio

# 3. Load web UI components
deno run -A ./package.sql.ts | surveilr shell

# 4. Start web interface
SQLPAGE_SITE_PREFIX="" ../../std/surveilrctl.ts dev

# 5. Access Qualityfolio at http://localhost:9000/
```

## Database Access

After ingestion, all test management data is stored in `resource-surveillance.sqlite.db`. You can:

- **Use external tools**: Access with DBeaver, DataGrip, or any SQLite-compatible tool
- **Run SQL queries**: Query test data directly for custom reports and analysis
- **Archive databases**: Create timestamped backups for historical records
- **Export data**: Generate reports for external compliance and quality systems
