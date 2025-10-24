---
FII: "TC-AWS-014"
groupId: "GRP-0006"
title: "Webhook Payload Tampering"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr’s security when webhook payload signatures are modified.

### Test Steps
1. Trigger AWS SNS event with altered signature.  
2. Observe Surveilr’s webhook validation process.  
3. Check ingestion and alert logs.

### Expected Result
- Signature verification fails.  
- Payload rejected securely.  
- “Signature verification failed” logged and alert generated.
