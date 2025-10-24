---
FII: "TC-API-0003"
groupId: "GRP-0008"
title: "Ingest API Returning Invalid Format"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["API"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Verify behavior when API returns invalid or malformed data.

### Test Steps
1. Provide API returning invalid JSON/XML.  
2. Trigger ingestion.  
3. Monitor logs for parsing errors.

### Expected Result
- System logs parsing errors.  
- Ingestion fails gracefully without crashing.
