---
FII: "TC-XRAY-0105"
groupId: "GRP-0006"
title: "Incomplete Task Data"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["XRAY"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveiler handles tasks with missing mandatory fields.

### Test Steps
1. Ensure Xray has tasks missing mandatory fields (summary, assignee).  
2. Trigger ingestion process.  
3. Check session logs for skipped tasks.  

### Expected Result
- Tasks with missing fields skipped.  
- Warnings logged for each skipped task.  
- Session completes without crashing.
