---
FII: "TC-AWS-009"
groupId: "GRP-0006"
title: "Webhook Endpoint Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate retry behavior when webhook endpoint times out.

### Test Steps
1. Configure Surveilr webhook target to respond with delay (504).  
2. Trigger AWS Lambda event.  
3. Observe retry mechanism and intervals.  
4. Review Surveilr retry logs.

### Expected Result
- Surveilr retries up to 3 times with exponential backoff.  
- Successful retry logs message “Delivered after retry.”  
- No data duplication.
