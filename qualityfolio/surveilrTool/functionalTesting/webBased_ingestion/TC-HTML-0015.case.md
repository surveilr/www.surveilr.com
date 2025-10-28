---
FII: "TC-HTML-0015"
groupId: "GRP-0008"
title: "Ingest HTML with Network Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["HTML"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify behavior when HTML URL is unreachable or slow.

### Test Steps
1. Provide URL that is unreachable or responds very slowly.  
2. Trigger ingestion.  
3. Monitor logs for timeout or error messages.

### Expected Result
- Ingestion fails gracefully with timeout or error message.  
- System logs issue without crashing.
