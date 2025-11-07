---
FII: "TC-SRV-0013"
groupId: "GRP-0001"
title: "Validate - ingestion of unsupported file type"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ingest", "cli", "validation"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Ensure the CLI detects and rejects unsupported file types during ingestion.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr ingest file.exe`.  
3. Observe the output message in the console.

### Expected Result

- The CLI should show an error message such as “unsupported file type” and prevent ingestion from proceeding.