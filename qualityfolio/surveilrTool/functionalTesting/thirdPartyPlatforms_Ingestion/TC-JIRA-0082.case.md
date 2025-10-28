---
FII: "TC-JIRA-0082"
groupId: "GRP-0006"
title: "Invalid File Format"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr fails gracefully with a non-CSV/JSON file.

### Test Steps
1. Run file ingest on an unsupported file format.  
2. Observe session logs for errors.

### Expected Result
- Ingest fails gracefully.  
- No partial entries.  
- Session marked failed with clear error.
