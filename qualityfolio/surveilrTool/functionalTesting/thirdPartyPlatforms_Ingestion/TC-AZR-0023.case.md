---
FII: "TC-AZR-0023"
groupId: "GRP-0006"
title: "Invalid Azure Credential Authentication"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Attempt authentication using invalid Azure Service Principal credentials.

### Test Steps
1. Configure Surveilr with incorrect credentials.  
2. Attempt connection to Azure API.  
3. Observe error messages and integration status.

### Expected Result
- Authentication fails with 401/403 error.  
- Error logged in Surveilr logs.  
- Integration remains inactive until valid credentials are provided.
