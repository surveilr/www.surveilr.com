---
FII: "TC-AWS-013"
groupId: "GRP-0006"
title: "Data Corruption during Sync"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["AWS"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Simulate data corruption during ingestion to verify checksum validation.

### Test Steps
1. Upload corrupted binary files into S3.  
2. Trigger Surveilr ingestion.  
3. Observe Surveilr’s error detection and alert generation.

### Expected Result
- Corrupted files flagged during checksum validation.  
- Alert generated in Surveilr dashboard.  
- Ingestion stops for affected files.
