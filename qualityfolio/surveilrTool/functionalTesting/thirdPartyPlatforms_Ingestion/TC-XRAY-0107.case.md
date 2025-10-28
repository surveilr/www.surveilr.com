---
FII: "TC-XRAY-0107"
groupId: "GRP-0006"
title: "Corrupted Xray Export"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["XRAY"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveiler handles corrupted or malformed Xray export files.

### Test Steps
1. Prepare Xray export with invalid JSON structure.  
2. Trigger ingestion process.  
3. Monitor logs for parsing errors.

### Expected Result
- Ingestion fails gracefully.  
- Error logged: “Unable to parse Xray response.”  
- Surveiler does not crash.
