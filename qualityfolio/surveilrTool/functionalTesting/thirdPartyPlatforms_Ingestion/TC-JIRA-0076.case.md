---
FII: "TC-JIRA-0076"
groupId: "GRP-0006"
title: "Full Ingest of Jira CSV Export"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate Surveilr ingests all issues, fields, and metadata from a Jira CSV export.

### Test Steps
1. Execute file ingest command on Jira CSV export.  
2. Monitor ingestion for completion.  
3. Query `uniform_resource` for all issues and metadata.

### Expected Result
- All issues ingested successfully.  
- Metadata correctly populated.  
- Session marked as success.
