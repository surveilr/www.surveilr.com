---
FII: "TC-JIRA-0080"
groupId: "GRP-0006"
title: "Ingest with Custom Fields"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of Jira exports containing custom fields.

### Test Steps
1. Run file ingest on Jira export with custom fields.  
2. Verify custom fields are stored in `uniform_resource`.  

### Expected Result
- All custom fields correctly mapped and ingested.  
- Metadata complete and session marked success.
