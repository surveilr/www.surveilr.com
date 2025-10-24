---
FII: "TC-AZR-0029"
groupId: "GRP-0006"
title: "Credential Revocation Mid-Session"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Test Surveilr behavior when Azure Service Principal is revoked mid-session.

### Test Steps
1. Start ingestion using valid credentials.  
2. Revoke Service Principal mid-process.  
3. Monitor Surveilr session termination.

### Expected Result
- Session terminates safely.  
- No further API calls executed.  
- Error logged as “Credential revoked”.
