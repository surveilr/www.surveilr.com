---
FII: "TC-XRAY-0106"
groupId: "GRP-0006"
title: "Missing Attachments and Linked Issues"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["XRAY"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveiler behavior when Jira exports reference missing attachments or linked issues.

### Test Steps
1. Run file ingest on Jira export with missing attachments or broken links.  
2. Check session logs and `uniform_resource` entries.  

### Expected Result
- Metadata ingested successfully.  
- Missing references flagged in logs.  
- Session completes without crashing.
