---
FII: "TC-AZR-0021"
groupId: "GRP-0006"
title: "Validate Rate Limit Handling (Normal Load)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Confirm that Surveilr handles 1000 API calls/minute without throttling errors.

### Test Steps
1. Trigger batch API calls from Surveilr to Azure.  
2. Monitor logs for rate limit messages.  
3. Validate successful responses and ingestion.

### Expected Result
- All API calls succeed without throttling.  
- Logs show stable request processing.  
- Surveilr performance remains stable.
