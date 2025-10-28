---
FII: "TC-GIT-0061"
groupId: "GRP-0006"
title: "Repo Not Found"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr handles non-existent or deleted GitHub repos gracefully.

### Test Steps
1. Provide a non-existent or renamed repo URL.  
2. Run file ingest command.  
3. Monitor session logs for errors.

### Expected Result
- Ingest fails gracefully.  
- No resource entries created.  
- Session marked failed with clear error.
