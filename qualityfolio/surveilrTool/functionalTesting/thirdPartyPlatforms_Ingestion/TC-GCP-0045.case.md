---
FII: "TC-GCP-0045"
groupId: "GRP-0006"
title: "Credential Revocation Mid-Session"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Test Surveilr behavior when GCP Service Account credentials are revoked during an active session.

### Test Steps
1. Start ingestion using valid Service Account credentials.  
2. Revoke Service Account mid-process via GCP IAM.  
3. Monitor Surveilr session termination and logs.

### Expected Result
- Session terminates safely.  
- No further API calls executed.  
- Error logged as “Credential revoked”.
