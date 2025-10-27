---
FII: "TC-JIRA-0077"
groupId: "GRP-0006"
title: "Full Ingest of Jira JSON Export"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate Surveilr ingests all issues, comments, attachments, and metadata from a Jira JSON export.

### Test Steps
1. Run file ingest command on Jira JSON export.  
2. Monitor ingestion completion.  
3. Query `uniform_resource` for issues, comments, and attachments.

### Expected Result
- All issues, comments, and attachments ingested.  
- Metadata fields correctly populated.  
- Session marked as success.
