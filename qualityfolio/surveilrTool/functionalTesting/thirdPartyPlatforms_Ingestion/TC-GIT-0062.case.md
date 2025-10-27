---
FII: "TC-GIT-0062"
groupId: "GRP-0006"
title: "Network Interruption During Ingest"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr handles network interruptions during file ingest.

### Test Steps
1. Start file ingest on a repo.  
2. Simulate network drop mid-process.  
3. Observe session logs and DB state.

### Expected Result
- Ingest fails gracefully or marks partial ingestion.  
- Partial or corrupt entries are avoided.  
- Session logs indicate network error.
