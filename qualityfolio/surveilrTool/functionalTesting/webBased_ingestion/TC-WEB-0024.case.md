---
FII: "TC-WEB-0024"
groupId: "GRP-0008"
title: "Ingest Website with Network Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["WEB"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify behavior when some pages of the website are unreachable or respond very slowly.

### Test Steps
1. Provide website URL with slow or unreachable pages.  
2. Trigger crawling and ingestion.  
3. Monitor logs for timeout or error messages.

### Expected Result
- Ingestion fails gracefully for unreachable pages.  
- Errors logged for timeout pages.  
- System continues ingesting other accessible pages.
