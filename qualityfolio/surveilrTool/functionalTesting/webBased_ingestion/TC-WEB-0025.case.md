---
FII: "TC-WEB-0025"
groupId: "GRP-0008"
title: "Ingest Website with Infinite Redirects"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["WEB"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify Surveilr handles pages that redirect in a loop without crashing.

### Test Steps
1. Provide website with pages that redirect infinitely.  
2. Trigger crawling and ingestion.  
3. Monitor logs for redirect handling.

### Expected Result
- System detects redirect loop.  
- Ingestion fails safely for looping pages.  
- Logs indicate redirect issue; no crash.
