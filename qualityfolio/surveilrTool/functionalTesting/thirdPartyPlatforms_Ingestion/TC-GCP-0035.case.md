---
FII: "TC-GCP-0035"
groupId: "GRP-0006"
title: "Test GCP Bucket Data Sync using rclone"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate sync between GCP Bucket and Surveilr’s local storage using rclone.

### Test Steps
1. Configure GCP Bucket in Surveilr.  
2. Trigger rclone sync through Surveilr connector.  
3. Monitor ingestion logs for completion.  
4. Verify all files are ingested into Surveilr.

### Expected Result
- Files mirrored correctly from GCP Bucket to local storage.  
- No data loss or corruption occurs.  
- Logs show “sync completed successfully”.
