---
FII: "TC-JIRA-0081"
groupId: "GRP-0006"
title: "Idempotent Ingest"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate repeated ingestion does not create duplicates.

### Test Steps
1. Run file ingest on Jira export.  
2. Re-run same file ingest command.  
3. Query `uniform_resource` for duplicate entries.

### Expected Result
- No duplicates created.  
- Session logs reflect repeated run.
