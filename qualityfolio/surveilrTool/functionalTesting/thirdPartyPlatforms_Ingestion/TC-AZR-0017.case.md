---
FII: "TC-AZR-0017"
groupId: "GRP-0006"
title: "Validate Azure API Credential Authentication"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify that Surveilr can connect to Azure API using valid Service Principal credentials (Client ID, Secret, Tenant ID).

### Test Steps
1. Configure Surveilr with valid Azure Service Principal credentials.  
2. Initiate API connection to Azure.  
3. Monitor Surveilr logs for authentication response.  
4. Confirm session established successfully.

### Expected Result
- Surveilr authenticates with Azure successfully.  
- Session token and identity confirmed in logs.  
- Integration status shows “Connected”.
