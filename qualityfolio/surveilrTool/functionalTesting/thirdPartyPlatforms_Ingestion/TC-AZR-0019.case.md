---
FII: "TC-AZR-0019"
groupId: "GRP-0006"
title: "Validate Webhook Trigger from Azure Functions"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Ensure that Azure Function triggers Surveilr webhook on data upload events.

### Test Steps
1. Deploy Azure Function with webhook configured to Surveilr.  
2. Upload data to monitored Blob container.  
3. Monitor Surveilr event logs.  
4. Confirm event ingestion and timestamp accuracy.

### Expected Result
- Webhook received within 1 second.  
- JSON payload parsed and stored in Surveilr.  
- Event visible in dashboard.
