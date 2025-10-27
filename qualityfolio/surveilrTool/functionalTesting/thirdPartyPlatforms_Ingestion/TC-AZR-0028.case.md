---
FII: "TC-AZR-0028"
groupId: "GRP-0006"
title: "Rate Limit Throttling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure", "API", "RateLimit", "Surveilr"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr’s handling of Azure API rate limit throttling.

### Test Steps
1. Send high-volume API requests (>10,000/min) from Surveilr.  
2. Monitor logs and responses.  
3. Review backoff and retry behavior.

### Expected Result
- Surveilr logs “RateLimitExceeded” events.  
- Applies automatic cooldown/backoff.  
- No flooding or instability occurs.
