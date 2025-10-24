---
FII: "TC-AWS-010"
groupId: "GRP-0006"
title: "Large Dataset Upload Timeout"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Simulate slow connection during large (20GB) dataset upload to test timeout handling.

### Test Steps
1. Start uploading 20GB dataset to S3.  
2. Introduce network latency.  
3. Monitor Surveilr’s timeout and retry behavior.  
4. Inspect logs and stored files after completion.

### Expected Result
- Surveilr detects timeout and retries automatically.  
- No partial or corrupted files stored.  
- Upload resumes after network stabilization.
