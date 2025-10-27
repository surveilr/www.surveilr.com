---
FII: "TC-AZR-0031"
groupId: "GRP-0006"
title: "Webhook Payload Tampering"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr’s response to tampered webhook payload signatures.

### Test Steps
1. Modify webhook HMAC signature.  
2. Trigger Azure Function event.  
3. Observe ingestion and alerts in Surveilr.

### Expected Result
- Signature verification fails.  
- Payload rejected securely.  
- Security alert generated.
