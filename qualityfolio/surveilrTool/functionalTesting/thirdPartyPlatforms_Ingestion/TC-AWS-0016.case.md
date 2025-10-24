---
FII: "TC-AWS-016"
groupId: "GRP-0006"
title: "Irrecoverable Rate-Limit Blacklist"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr’s response when AWS API key is blacklisted for excessive requests.

### Test Steps
1. Exceed AWS rate limits continuously.  
2. Observe blacklisting response from AWS.  
3. Monitor Surveilr alerting and integration handling.

### Expected Result
- Surveilr disables AWS integration automatically.  
- “API key blacklisted” alert sent to admin.  
- Integration remains halted until manual reset.
