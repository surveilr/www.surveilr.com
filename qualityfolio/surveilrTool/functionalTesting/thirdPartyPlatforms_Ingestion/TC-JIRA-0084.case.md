---
FII: "TC-JIRA-0084"
groupId: "GRP-0006"
title: "Missing Mandatory Fields"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate handling of Jira exports missing required fields like Issue ID or Project Key.

### Test Steps
1. Run file ingest on export missing mandatory fields.  
2. Monitor session logs and resource table.

### Expected Result
- Rows with missing fields skipped or ingest fails.  
- Session logs clearly indicate missing fields.
