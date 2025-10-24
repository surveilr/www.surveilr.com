---
FII: "TC-GIT-0064"
groupId: "GRP-0006"
title: "Massive Repository Ingest"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr ingests very large repositories without crashing.

### Test Steps
1. Run file ingest on a repo with millions of files and commits.  
2. Monitor CPU, memory, and DB usage.  
3. Observe session completion and DB consistency.

### Expected Result
- Ingest completes or fails gracefully.  
- System resources remain stable.  
- Session logs reflect success or controlled failure.
