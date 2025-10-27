---
FII: "TC-GCP-0046"
groupId: "GRP-0006"
title: "Data Corruption During Sync"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr’s detection of corrupted files during GCP Bucket ingestion.

### Test Steps
1. Upload corrupted files to GCP Bucket.  
2. Trigger ingestion process in Surveilr.  
3. Monitor logs and alerting.

### Expected Result
- Corrupted files flagged via checksum validation.  
- Alert generated in Surveilr.  
- Ingestion stops for affected files.
