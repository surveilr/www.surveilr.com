---
FII: "TC-SRV-0012"
groupId: "GRP-0001"
title: "Validate - ingestion with non-existent file"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ingest", "cli", "error-handling"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Verify that the CLI handles missing or non-existent files properly during ingestion.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr ingest /data/missing.csv`.  
3. Observe the console output.

### Expected Result

- The CLI should display an error message such as “file not found” and abort ingestion gracefully without crashing.