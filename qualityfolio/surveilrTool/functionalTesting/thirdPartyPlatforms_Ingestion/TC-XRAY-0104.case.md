---
FII: "TC-XRAY-0104"
groupId: "GRP-0006"
title: "Invalid Xray Credentials"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["XRAY"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveiler behavior when connecting with invalid Xray credentials.

### Test Steps
1. Connect Surveiler to Xray with invalid API token.  
2. Trigger ingestion process.  

### Expected Result
- Ingestion fails.  
- Error message logged: “Authentication failed.”  
- No tasks imported.
