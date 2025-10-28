---
FII: "TC-GCP-0041"
groupId: "GRP-0006"
title: "Partial Data Sync Interruption"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate that Surveilr resumes GCP Bucket sync correctly after interruption.

### Test Steps
1. Start Bucket → local sync using rclone in Surveilr.  
2. Interrupt network connection mid-sync.  
3. Reconnect and resume sync.  
4. Compare file hashes before and after.

### Expected Result
- Sync resumes from last checkpoint.  
- No duplicate or corrupted files.  
- Logs show “Resumed from checkpoint”.
