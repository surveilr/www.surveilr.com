---
FII: "TC-AWS-015"
groupId: "GRP-0006"
title: "Total Network Outage"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Simulate total network outage during Surveilr ingestion process.

### Test Steps
1. Start ingestion from AWS S3.  
2. Disconnect network connection completely.  
3. Wait 5 minutes and reconnect.  
4. Observe Surveilr’s retry behavior.

### Expected Result
- Ingestion fails gracefully.  
- Queued data retried automatically after reconnection.  
- No data loss or corruption occurs.
