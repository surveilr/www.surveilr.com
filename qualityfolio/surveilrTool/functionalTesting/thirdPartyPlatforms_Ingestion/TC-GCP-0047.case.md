---
FII: "TC-GCP-0047"
groupId: "GRP-0006"
title: "Webhook Payload Tampering"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr’s response to tampered webhook payload signatures from GCP Pub/Sub.

### Test Steps
1. Modify webhook HMAC signature.  
2. Trigger Cloud Function or Pub/Sub event.  
3. Observe ingestion and alerts in Surveilr.

### Expected Result
- Signature verification fails.  
- Payload rejected securely.  
- Security alert generated in Surveilr.
