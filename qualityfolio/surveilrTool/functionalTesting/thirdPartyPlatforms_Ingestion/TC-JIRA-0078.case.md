---
FII: "TC-JIRA-0078"
groupId: "GRP-0006"
title: "Incremental Ingest"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate Surveilr ingests only new or updated issues from incremental Jira exports.

### Test Steps
1. Perform initial file ingest on Jira export.  
2. Add or update issues in Jira export.  
3. Re-run file ingest command.  
4. Verify only new or updated issues ingested.

### Expected Result
- Existing issues preserved.  
- Only new/updated issues ingested.  
- Session reflects incremental ingest.
