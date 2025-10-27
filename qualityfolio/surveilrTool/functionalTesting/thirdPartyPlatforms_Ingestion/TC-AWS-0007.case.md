---
FII: "TC-AWS-007"
groupId: "GRP-0006"
title: "Invalid AWS Credential Authentication"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Attempt authentication with incorrect or expired AWS credentials.

### Test Steps
1. Configure Surveilr with invalid Access Key and Secret.  
2. Attempt connection to AWS API.  
3. Observe error message in logs.  
4. Verify integration status in dashboard.

### Expected Result
- Authentication fails with 403 error.  
- Error logged as “Invalid Credentials.”  
- No retry attempts until credentials corrected.
