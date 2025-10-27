---
FII: "TC-JIRA-0079"
groupId: "GRP-0006"
title: "Ingest with Attachments"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Jira"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate Surveilr ingests Jira attachments from export files.

### Test Steps
1. Run file ingest on Jira export containing attachments.  
2. Verify attachments exist in `uniform_resource`.  
3. Check metadata including size, MIME type, and checksum.

### Expected Result
- Attachments ingested successfully or pointers recorded.  
- Provenance fields reflect attachment info.
