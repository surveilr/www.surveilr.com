---
FII: "TC-SRV-0010"
groupId: "GRP-0001"
title: "Verify - surveilr ingest --help displays ingestion options"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ingest", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr ingest --help` command displays available ingestion options and usage instructions.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr ingest --help`.  
3. Observe the output in the console.  
4. Verify that it includes ingestion options, file source details, and supported formats.

### Expected Result

- The CLI displays ingestion help content with proper usage examples and supported data source options.