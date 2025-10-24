---
FII: "TC-JIRA-0090"
groupId: "GRP-0006"
title: "Duplicate Issues in Export"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr handles duplicate issues in Jira export files.

### Test Steps
1. Run file ingest on Jira export containing duplicate rows.  
2. Inspect `uniform_resource` for duplicates.  

### Expected Result
- Deduplication works.  
- No duplicate entries created.  
- Session logs reflect duplicates skipped.
