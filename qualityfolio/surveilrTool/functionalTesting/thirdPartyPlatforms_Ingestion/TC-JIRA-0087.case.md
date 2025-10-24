---
FII: "TC-JIRA-0087"
groupId: "GRP-0006"
title: "Massive Jira Export"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr ingests very large Jira exports with hundreds of thousands of issues.

### Test Steps
1. Run file ingest on a massive Jira export file.  
2. Monitor memory, CPU, and database performance.  
3. Verify session completion and data integrity in `uniform_resource`.

### Expected Result
- Ingest completes or fails gracefully.  
- System resources remain stable.  
- All ingested data is consistent.
