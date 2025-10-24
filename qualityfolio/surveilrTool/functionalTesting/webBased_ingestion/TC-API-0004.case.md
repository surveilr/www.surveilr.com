---
FII: "TC-API-0004"
groupId: "GRP-0008"
title: "Ingest API Returning Empty Data"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["API"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify behavior when API response contains no records.

### Test Steps
1. Provide API returning empty JSON/XML array.  
2. Trigger ingestion.  
3. Monitor logs for system response.

### Expected Result
- Ingestion fails with “No data found” message.  
- System remains stable.
