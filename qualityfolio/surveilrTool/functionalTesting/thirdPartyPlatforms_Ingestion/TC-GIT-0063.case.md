---
FII: "TC-GIT-0063"
groupId: "GRP-0006"
title: "Corrupted Repository Data"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr detects and handles corrupted Git objects during file ingest.

### Test Steps
1. Run file ingest on a repo with intentionally corrupted commit objects.  
2. Observe session logs and `uniform_resource` entries.

### Expected Result
- Ingest fails gracefully.  
- Corrupted data not inserted.  
- Session logs clearly indicate the corruption.
