---
FII: "TC-AWS-005"
groupId: "GRP-0006"
title: "Validate Rate Limit Handling (Normal Load)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Confirm that Surveilr can send 1000 API calls per minute without triggering AWS throttling.

### Test Steps
1. Initiate batch ingestion sending 1000 API calls/minute.  
2. Monitor Surveilr logs for rate limit events.  
3. Validate data responses are successful.  
4. Review performance metrics.

### Expected Result
- No “RateLimitExceeded” messages appear.  
- All API calls complete successfully.  
- Surveilr shows stable request throughput.
