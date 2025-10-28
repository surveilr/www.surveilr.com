---
FII: "TC-GCP-0037"
groupId: "GRP-0006"
title: "Validate Large Dataset Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify ingestion of a large dataset (10GB+) from GCP Bucket into Surveilr database.

### Test Steps
1. Upload a 10GB+ dataset to GCP Bucket.  
2. Trigger Surveilr ingestion process.  
3. Monitor ingestion logs for errors and performance.  
4. Validate final record count in Surveilr.

### Expected Result
- All records ingested successfully.  
- No corruption or timeout occurs.  
- Surveilr performs ingestion efficiently.
