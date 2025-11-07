---
FII: "TC-SRV-0011"
groupId: "GRP-0001"
title: "Validate - ingestion of valid local data source"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ingest", "cli", "data-source"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the CLI correctly ingests a valid local data file from the filesystem.

### Test Steps

1. Open a terminal or command prompt.  
2. Ensure a valid md file exists at `/data/test.md`.  
3. Execute the command `surveilr ingest /data/test.md`.  
4. Observe the output logs and ingestion summary.

### Expected Result

- The CLI should successfully process the file, display ingestion progress, and confirm completion without errors.