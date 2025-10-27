---
FII: "TC-HTML-0009"
groupId: "GRP-0008"
title: "Ingest Large HTML Page"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify Surveilr ingests large HTML pages without timeout or errors.

### Test Steps
1. Provide an HTML page larger than 5MB.  
2. Trigger ingestion.  
3. Monitor logs for ingestion progress and completion.

### Expected Result
- HTML page ingested successfully.  
- No timeout or errors encountered.
