---
FII: "TC-GIT-0056"
groupId: "GRP-0006"
title: "Idempotent Ingest"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that repeated ingestion of the same repo does not create duplicate records.

### Test Steps
1. Run file ingest on a repo.  
2. Re-run the same file ingest command.  
3. Query `uniform_resource` for duplicate records.

### Expected Result
- No duplicate entries created.  
- Session logs reflect repeated run.
