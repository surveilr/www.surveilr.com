---
FII: "TC-AZR-0018"
groupId: "GRP-0006"
title: "Test Azure Blob Data Sync using rclone"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate sync operation between Azure Blob container and Surveilr’s local storage using rclone.

### Test Steps
1. Configure Azure Blob container in Surveilr.  
2. Trigger rclone sync through Surveilr connector.  
3. Monitor ingestion logs for completion.  
4. Verify all files appear in Surveilr database.

### Expected Result
- Files are mirrored accurately from Azure Blob to local storage.  
- No data loss or corruption occurs.  
- Logs show “sync completed successfully”.
