---
FII: "TC-GCP-0033"
groupId: "GRP-0006"
title: "Validate GCP API Credential Authentication"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify that Surveilr can connect to GCP API using a valid Service Account key JSON.

### Test Steps
1. Configure Surveilr with valid GCP Service Account JSON credentials.  
2. Initiate API connection to GCP.  
3. Monitor Surveilr logs for authentication response.  
4. Confirm session is established successfully.

### Expected Result
- Surveilr authenticates with GCP successfully.  
- Session token and identity validated in logs.  
- Integration status shows “Connected”.
