---
FII: "TC-AZR-0026"
groupId: "GRP-0006"
title: "Webhook Endpoint Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate retry mechanism when webhook endpoint response is delayed.

### Test Steps
1. Configure Surveilr webhook to a target that delays response.  
2. Trigger Azure Function event.  
3. Observe Surveilr retries and intervals.  
4. Review logs for retry behavior.

### Expected Result
- Surveilr retries up to 3 times using exponential backoff.  
- Payload eventually ingested or logged failure.  
- No duplicates created.
