---
id: "GRP-0010"
suiteId: "SUT-0001"
planId: ["PLN-0001"]
name: "Surveilr Watch Mode Test Cases"
description: "Test group validating Surveilr's file-watch mode, ingestion workflow, filtering behavior, terminal lifecycle behavior, and system stability across happy, unhappy, and edge-case scenarios."
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
tags: ["watch-mode", "file-ingestion", "filters", "stability", "terminal-behavior"]
version: "1.0"
status: "Draft"
---

## Overview

This group covers behavioral, functional, and failure-path validations for Surveilr’s **file ingestion watch mode**.  
The scenarios confirm correct detection of filesystem changes, pattern filtering accuracy, error handling for corrupted or unsupported inputs, handling of known ingestion defects, and how the watch process responds when the host terminal or environment unexpectedly terminates.

The cases are divided into happy-path, unhappy-path, miserable/edge-case failures, VS Code terminal lifecycle behaviors, and additional functional scenarios involving renames, moves, and multi-watcher setups.

---

## Key Functional Areas

### 🔹 Watcher Initialization & Event Detection
- Validate that watch mode starts cleanly with the correct startup logs.
- Confirm ingestion events trigger on create/modify operations.
- Ensure multi-directory watch works as expected.

### 🔹 File Type Handling & Filtering
- Verify correct recognition of supported types (PDF, DOCX).
- Validate exclusion of unsupported extensions.
- Ensure include and ignore filters work individually and in combination.
- Check behavior when filters are misconfigured or malformed.

### 🔹 Error Handling & Diagnostics
- Ensure ingestion errors produce clear diagnostics for:
  - corrupted files
  - known DOCX graph/chart issues
  - permission problems
  - incorrect pattern syntax
  - large-file ingest issues
  - file disappearance during processing

### 🔹 Terminal & Environment Interruption Behavior
- Confirm watcher behavior when:
  - VS Code closes
  - terminal tab is killed
  - VS Code reloads or crashes
  - process is force-terminated

### 🔹 Additional Functional Behaviors
- Validate rename-based ingestion workflows.
- Confirm case sensitivity rules depending on OS.
- Ensure watchers behave independently when multiple sessions run in parallel.
- Verify handling of temporary extensions during file copy phases.

---
