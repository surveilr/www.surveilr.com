---
FII: "TC-GCP-0042"
groupId: "GRP-0006"
title: "Webhook Endpoint Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate retry mechanism when webhook endpoint response is delayed.

### Test Steps
1. Configure Surveilr webhook target to respond slowly (>5s).  
2. Trigger Cloud Function event.  
3. Observe Surveilr retries and backoff intervals.  
4. Review logs for successful ingestion or failure.

### Expected Result
- Surveilr retries up to 3 times using exponential backoff.  
- Payload ingested or logged as failed.  
- No duplicates created.
