---
FII: "TC-GCP-0034"
groupId: "GRP-0006"
title: "Irrecoverable API Key Blacklist"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr response when GCP API key is blacklisted for excessive requests.

### Test Steps
1. Trigger excessive API requests from Surveilr.  
2. Observe API key blacklisting by GCP.  
3. Monitor Surveilr alerting and integration status.

### Expected Result
- Surveilr disables integration automatically.  
- Alert sent to admin.  
- Integration halted until manual reset.
