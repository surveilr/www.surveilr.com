---
FII: "TC-HTML-0007"
groupId: "GRP-0008"
title: "Ingest Valid HTML Page"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify Surveilr successfully ingests and parses a standard HTML page.

### Test Steps
1. Provide a valid HTML page with proper <html>, <head>, and <body> tags.  
2. Trigger ingestion in Surveilr.  
3. Monitor logs for ingestion status.

### Expected Result
- HTML page ingested successfully.  
- All content accessible and stored correctly.  
- No errors or warnings logged.
