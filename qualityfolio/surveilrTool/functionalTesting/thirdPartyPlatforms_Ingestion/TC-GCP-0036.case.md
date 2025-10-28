---
FII: "TC-GCP-0036"
groupId: "GRP-0006"
title: "Validate Webhook Trigger from Cloud Function"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Ensure Cloud Function triggers Surveilr webhook on data update events.

### Test Steps
1. Deploy Cloud Function with webhook configured to Surveilr.  
2. Upload data to monitored GCP Bucket.  
3. Monitor Surveilr event logs.  
4. Confirm event ingestion and timestamp accuracy.

### Expected Result
- Webhook received within 1 second.  
- JSON payload parsed correctly and stored.  
- Event visible in Surveilr dashboard.
