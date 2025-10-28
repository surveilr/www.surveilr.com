---
FII: "TC-AWS-012"
groupId: "GRP-0006"
title: "Credential Compromise or Revocation Mid-Session"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Test Surveilr’s behavior when AWS credentials are revoked during an active sync session.

### Test Steps
1. Start a running ingestion job with valid credentials.  
2. Revoke the IAM credentials mid-process.  
3. Monitor Surveilr response and session termination.

### Expected Result
- Surveilr terminates session safely.  
- “Credential revoked” error logged.  
- No further API calls executed post-revocation.
