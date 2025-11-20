---
FII: "TC-AWS-001"
groupId: "GRP-0006"
title: "Validate AWS API Credential Authentication"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Amazon Web Services"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify successful connection using valid AWS IAM credentials via API for Surveilr ingestion.

### Test Steps
1. Configure valid IAM Access Key and Secret in Surveilr.  
2. Initiate connection via API integration setup.  
3. Monitor Surveilr logs for authentication response.  
4. Verify session token or identity established successfully.

### Expected Result
- Surveilr authenticates successfully with AWS.  
- Connection status shows “Connected”.  
- Session token and identity validation confirmed in logs.
