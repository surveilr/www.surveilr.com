---
FII: "TC-JIRA-0088"
groupId: "GRP-0006"
title: "Special Characters in Issue Fields"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate ingestion of Jira issues containing emojis, control characters, or unusual Unicode.

### Test Steps
1. Run file ingest on Jira export containing special characters.  
2. Inspect `uniform_resource` for correct field encoding.  

### Expected Result
- All fields ingested safely.  
- No encoding errors or data loss.  
- Session completes successfully.
