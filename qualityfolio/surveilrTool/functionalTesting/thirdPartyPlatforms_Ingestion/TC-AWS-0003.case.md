---
FII: "TC-AWS-003"
groupId: "GRP-0006"
title: "Validate Webhook Trigger from AWS Lambda"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Ensure that AWS Lambda triggers Surveilr webhook upon data update events.

### Test Steps
1. Deploy Lambda with webhook trigger configured for Surveilr endpoint.  
2. Execute Lambda function that updates monitored data.  
3. Observe Surveilr event logs for webhook receipt.  
4. Confirm event data ingestion and timestamp accuracy.

### Expected Result
- Webhook received within 1 second of Lambda execution.  
- JSON payload correctly parsed and stored in event schema.  
- Event count increases in Surveilr dashboard.
