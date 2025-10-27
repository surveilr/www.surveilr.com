---
FII: "TC-AWS-004"
groupId: "GRP-0006"
title: "Validate Large Dataset Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify ingestion of a large dataset (10GB+) from AWS S3 into Surveilr database.

### Test Steps
1. Upload a 10GB+ dataset into an S3 bucket.  
2. Trigger Surveilr ingestion process.  
3. Monitor ingestion logs and resource usage.  
4. Validate final record count in Surveilr database.

### Expected Result
- All records successfully processed and stored.  
- No ingestion timeout or data corruption.  
- Surveilr performance remains stable.
