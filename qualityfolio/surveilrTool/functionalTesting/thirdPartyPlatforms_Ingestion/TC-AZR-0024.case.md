---
FII: "TC-AZR-0024"
groupId: "GRP-0006"
title: "Irrecoverable API Key Blacklist"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr response when Azure API key is blacklisted for excessive requests.

### Test Steps
1. Trigger excessive API requests from Surveilr.  
2. Observe API key blacklisting by Azure.  
3. Monitor Surveilr alerting and integration status.

### Expected Result
- Surveilr disables integration automatically.  
- Alert sent to admin.  
- Integration halted until manual reset.
