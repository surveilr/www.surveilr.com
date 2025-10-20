---
id: PLN-001
name: "Functional Test Plan"
description: "The test plan establishes a standardized, repeatable, and automated CLI-based regression testing workflow for Surveilr releases (starting with version 3.x), ensuring that all critical functionalities, including CSV transformations, are validated across environments before deployment."
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-31"
tags: ["Functional testing"]
---

# CLI Test Plan for Surveilr

## 1. Objective

To establish a standardized, repeatable, and automated CLI-based regression testing workflow for Surveilr releases (starting v3.x), ensuring all critical functionalities, including CSV transformations, are validated across environments before deployment.

## 2. Scope

**Application Under Test:** Surveilr CLI

**Test Types Covered:**

* Functional CLI Regression
* CSV and File Transformation Validation
* Parameter/Flag Handling Validation
* Output Verification
* Environment Compatibility (Dev, QA, Staging)
* Negative and Error Handling Scenarios

## 3. Test Execution Workflow

### 3.1 Environment Setup Checklist

| Step                            |
| ------------------------------- |
| Clone/pull latest Surveilr code |
| Install dependencies            |
| Verify environment variables    |
| Prepare input datasets          |

### 3.2 Command Execution Pattern

**Example Standard Command Structure:**

```bash
surveilr ingest files [OPTIONS]
```

All test cases should follow a documented command template with:

* Defined input files
* Expected output location
* Log capture
* Exit code validation

## 4. Regression Test Case Categories

| Test Category                | Example Command                   | Expected Output                               |
| ---------------------------- | --------------------------------- | --------------------------------------------- |
| Basic run validation         | `surveilr ingest files [OPTIONS]` | Exit code `0`, log status `OK`                |
| CSV and file transformations | Run with sample datasets          | Exact column mappings & value validation      |
| CLI flags validation         | `--help`, `--version`, `--mode=`  | Correct flag output and syntax help           |
| Error handling               | Invalid input file path           | Graceful error message and non-zero exit code |
| Multi-environment execution  | Run same command on QA/Staging    | Output consistency via checksum match         |

## 5. Automation Framework

* All CLI commands to be wrapped into batch / shell / PowerShell scripts
* Optional CI/CD integration to auto-trigger regression on code freeze or release tag (Jenkins / GitLab CI)
* Logs automatically pushed to a central regression results folder
* Output comparison automated via checksum or row-count validation scripts

## 6. Qualityfolio Integration Step

After each regression run, upload the following to Qualityfolio:

* Commands executed
* Logs and output CSVs
* Screenshots or checksum results

Then:

1. Mark PASS/FAIL status per module
2. Assign review to ODC QA resource
3. ODC QA must acknowledge and close findings prior to release approval

## 7. Roles & Ownership

| Role                | Responsibility                                                                                                   |
| ------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Mukhtar        | Executes CLI scripts and uploads initial results                                                                 |
| ODC QA Resource | 1. Validates outputs, updates Qualityfolio, flags gaps <br> 2. Provides final sign-off before release deployment |
