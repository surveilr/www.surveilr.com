---
FII: "TC-GCP-0040"
groupId: "GRP-0006"
title: "Invalid GCP Credential Authentication"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Attempt authentication with invalid or expired GCP Service Account credentials.

### Test Steps
1. Configure Surveilr with invalid credentials.  
2. Attempt to connect to GCP API.  
3. Observe error messages and integration status.

### Expected Result
- Authentication fails (401/403 error).  
- Error logged in Surveilr logs.  
- Integration remains inactive until valid credentials provided.
