---
FII: "TC-GCP-0048"
groupId: "GRP-0006"
title: "Total Network Outage"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Simulate a complete network outage during GCP ingestion.

### Test Steps
1. Start ingestion from GCP Bucket.  
2. Disconnect network completely.  
3. Reconnect after 5 minutes.  
4. Monitor ingestion retry in Surveilr.

### Expected Result
- Ingestion fails gracefully.  
- Queued data retries automatically post-reconnect.  
- No data loss or corruption occurs.
