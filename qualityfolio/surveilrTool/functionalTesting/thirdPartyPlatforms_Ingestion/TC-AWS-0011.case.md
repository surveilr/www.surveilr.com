---
FII: "TC-AWS-011"
groupId: "GRP-0006"
title: "Rate Limit Throttling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr’s handling of AWS rate limit throttling.

### Test Steps
1. Send 10,000 API requests per minute via Surveilr.  
2. Observe system logs and throttling responses.  
3. Review cooldown behavior and retry logic.

### Expected Result
- “RateLimitExceeded” detected and logged.  
- Surveilr applies cooldown automatically.  
- No request flooding or instability.
