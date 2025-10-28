---
FII: "TC-AWS-002"
groupId: "GRP-0006"
title: "Test AWS S3 Data Sync using rclone"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate sync operation between AWS S3 and Surveilr’s local staging area using rclone.

### Test Steps
1. Configure S3 bucket in Surveilr with correct permissions.  
2. Initiate sync using rclone through Surveilr connector.  
3. Observe log entries for sync completion.  
4. Verify data appears correctly in Surveilr ingestion database.

### Expected Result
- Files are mirrored successfully from S3 to local storage.  
- No data loss or duplication occurs.  
- Surveilr ingestion log shows “sync completed successfully.”
