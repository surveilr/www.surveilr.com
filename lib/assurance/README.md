# `surveilr` End-to-End Quality Assurance Patterns

Welcome to the Quality Assurance (QA) guide for `surveilr`. This guide provides comprehensive end-to-end tests that help verify and validate the functionality of `surveilr`. These tests not only ensure that `surveilr` operates correctly under various conditions but also serve as practical examples for users on how to use `surveilr` in real-world scenarios. Moreover, they include stress tests that demonstrate `surveilr`'s ability to handle ingestions of over 10,000 records and files, transform CSVs, and execute queries effectively.

## Files and Their Purposes

### 1. [File Ingestions with Multitenancy](./ingest_test.ts)

This test script demonstrates the file ingestion capabilities of `surveilr` in a standalone and multitenant environment. It verifies the correctness of file ingestions by using [SQL views](./ingest-files.sql) and checks the automatic transformations that occur post-ingestion.

### 2. [Orchestration](./orchestration_test.ts)

This script showcases the `surveilr orchestrate` command along with its various subcommands. It demonstrates different orchestration methods, including:

- **CSV Transformation (`transform-csv`)**: Transforms CSV data for ingestion and processing.
- **Script Execution**: Shows how to pass scripts through standard input (stdin) or using the `-s` flag.
- **Remote Script Usage**: Explains how to use scripts from remote locations.


### 3. [Functions](./functions_test.ts)

This test script focuses on all current SQLite-specific functions provided by `surveilr`. It demonstrates how to effectively use these functions within the `surveilr` environment. 

### 3. [Admin](./admin_test.ts)

This test script shows the administrative capabilities of `surveilr`, including, but not limited to:
- Initializing and empty RSSD
- Merging multiple RSSDs
- Getting the current schema of all tables in the `surveilr`.

## Prerequisites

To run these tests, ensure that you have the following installed on your system:

1. **[Deno](https://deno.com/)**: A modern runtime for JavaScript and TypeScript that is used to execute the test scripts.
2. [Download `surveilr` binary](https://docs.opsfolio.com/surveilr/how-to/installation-guide/)

## How to Run the Tests

To execute all tests and ensure that `surveilr` is functioning correctly:

1. Run the tests using Deno:

    ```bash
    deno test -A ./lib/assurance/ --fail-fast # Executes all tests
    ```

The `-A` flag provides all necessary permissions for the tests to run, including file system access and network permissions.
