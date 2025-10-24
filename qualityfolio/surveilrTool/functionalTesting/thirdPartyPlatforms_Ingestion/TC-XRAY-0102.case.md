---
FII: "TC-XRAY-0102"
groupId: "GRP-0006"
title: "Successful Task Ingestion from Xray"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["XRAY"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate Surveiler successfully ingests tasks from Xray under normal conditions.

### Test Steps
1. Connect Surveiler to Xray using valid credentials.  
2. Trigger task ingestion process.  
3. Verify tasks appear in Surveiler with correct fields.

### Expected Result
- All tasks from Xray ingested successfully.  
- Task metadata (ID, summary, assignee, status) matches source.  
- No duplicates or errors in session logs.
