---
FII: "TC-API-0006"
groupId: "GRP-0008"
title: "Ingest API with Unauthorized Access"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["API"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Verify Surveilr behavior when API returns 401 Unauthorized or 403 Forbidden.

### Test Steps
1. Provide API endpoint requiring authentication without credentials.  
2. Trigger ingestion.  
3. Monitor logs for authorization errors.

### Expected Result
- Ingestion fails gracefully.  
- Logs indicate unauthorized or forbidden error.  
- System does not crash.
