---
FII: "TC-GCP-0043"
groupId: "GRP-0006"
title: "Large Dataset Upload Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Simulate slow network during upload of a large dataset (20GB) to GCP Bucket to test Surveilr retry mechanism.

### Test Steps
1. Upload a 20GB dataset to GCP Bucket.  
2. Introduce slow network conditions.  
3. Monitor Surveilr ingestion and retry behavior.  
4. Inspect logs and final data integrity.

### Expected Result
- Surveilr retries automatically.  
- No partial or corrupted data stored.  
- Upload completes successfully once network stabilizes.
