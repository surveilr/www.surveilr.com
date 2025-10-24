---
FII: "TC-API-0005"
groupId: "GRP-0008"
title: "Ingest API with Network Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["API"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify behavior when API endpoint is unreachable or times out.

### Test Steps
1. Provide API URL that is slow or unreachable.  
2. Trigger ingestion.  
3. Monitor logs for timeout or connection errors.

### Expected Result
- Ingestion fails gracefully.  
- Logs indicate timeout or network error.  
- System continues ingesting other APIs.
