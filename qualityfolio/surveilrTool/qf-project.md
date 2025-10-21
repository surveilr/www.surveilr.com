---
id: "PRJ-0001"
name: "Surveilr CLI(Command-Line Interface) Functional Testing"
description: "A standardized, automated CLI functional testing framework focusing on validating critical functionalities including CLI commands, multi-environment execution, file ingestion, and error handling before deployment."
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-20"
last_updated_at: "2025-10-20"
status: "Active"
tags: ["CLI testing", "File validation"]
---

### Project Overview

This project defines a repeatable CLI functional testing process for the Surveilr platform. It ensures that all critical CLI functionalities are validated across environments (Dev, QA, Staging) before release. The testing workflow covers command execution, output validation, error handling, and integration with Qualityfolio for traceable results.

### Scope

The testing effort focuses on functional validation of the Surveilr CLI, ensuring consistent behavior across supported environments and input datasets.

Key testing areas include:

- **Functional CLI Testing**
  - Validate core CLI commands, including `ingest files` and other critical workflows.
  - Ensure proper handling of CLI parameters, flags, and options.
  - Validate command exit codes and log outputs for success or failure.

- **File Ingestion & Transformation Validation**
  - Test ingestion of supported file types and confirm proper parsing.  
    Supported file types include:
    - **Structured Data Files**: JSON (.json), YAML / YML (.yaml, .yml), XML (.xml), CSV (.csv)
    - **Text Files**: Plain text (.txt), Markdown (.md), Rich Text (.rtf)
    - **Office Documents**: Microsoft Word (.doc, .docx), Excel (.xls, .xlsx), PowerPoint (.ppt, .pptx), PDF (.pdf)
    - **Diagram / Design Files**: PlantUML (.puml), SVG (.svg), Visio (.vsd, .vsdx)
    - **Code / Script Files**: Source code (.py, .js, .ts, .java, .cpp, .c), Shell scripts (.sh, .bat), Configuration / manifest files (.ini, .cfg)
    - **Misc / Other Files**: Log files (.log), Compressed archives (.zip, .tar, .gz), Image files (.png, .jpg, .jpeg)  
  - Validate output consistency using row counts, metadata extraction, or logs.
  - Ensure configuration files and structured data are handled correctly.

- **Error Handling & Negative Scenarios**
  - Test invalid file paths, unsupported formats, incorrect flags, and missing arguments.
  - Verify graceful failure and appropriate exit codes.

- **Multi-Environment Execution**
  - Run the same CLI commands across Dev, QA, and Staging.
  - Confirm output and processing consistency across environments.

- **Automation & CI/CD Integration**
  - Wrap CLI commands in batch/shell/PowerShell scripts.
  - Optionally trigger automated functional testing runs on code freeze or release tags.
  - Automatically capture logs, output files, and validation results.

- **Output Validation & Qualityfolio Integration**
  - Compare outputs, validate logs, and record exit codes.
  - Upload results to Qualityfolio for PASS/FAIL marking.
  - Assign review to ODC QA resources and close gaps before release approval.
