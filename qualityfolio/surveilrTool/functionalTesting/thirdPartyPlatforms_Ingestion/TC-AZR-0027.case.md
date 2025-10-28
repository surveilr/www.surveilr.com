---
FII: "TC-AZR-0027"
groupId: "GRP-0006"
title: "Large Dataset Upload Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Simulate slow network during upload of large dataset (20GB) to test Surveilr retry.

### Test Steps
1. Upload 20GB dataset to Azure Blob.  
2. Introduce slow network conditions.  
3. Monitor Surveilr ingestion and retry behavior.  
4. Inspect logs and final data integrity.

### Expected Result
- Surveilr retries automatically.  
- No partial or corrupted data stored.  
- Upload completes successfully after network stabilization.
