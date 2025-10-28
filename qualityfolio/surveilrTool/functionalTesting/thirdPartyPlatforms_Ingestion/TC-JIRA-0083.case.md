---
FII: "TC-JIRA-0083"
groupId: "GRP-0006"
title: "Malformed CSV / JSON"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr fails gracefully on malformed CSV/JSON Jira exports.

### Test Steps
1. Provide a malformed CSV or JSON export.  
2. Execute file ingest command.  
3. Observe session logs.

### Expected Result
- Ingest fails.  
- No incomplete data stored.  
- Error messages clearly indicate parsing issue.
