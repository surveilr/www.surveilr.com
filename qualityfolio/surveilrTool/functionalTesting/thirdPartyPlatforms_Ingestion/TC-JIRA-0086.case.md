---
FII: "TC-JIRA-0086"
groupId: "GRP-0006"
title: "Permission-Protected Attachments"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate handling of inaccessible attachments in Jira exports.

### Test Steps
1. Run file ingest on Jira export with protected attachments.  
2. Check session logs and `uniform_resource` entries.

### Expected Result
- Metadata ingested.  
- Missing attachments flagged.  
- Session logs indicate errors for inaccessible attachments.
