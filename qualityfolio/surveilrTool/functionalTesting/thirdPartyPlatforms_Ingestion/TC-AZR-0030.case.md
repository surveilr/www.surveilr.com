---
FII: "TC-AZR-0030"
groupId: "GRP-0006"
title: "Data Corruption During Sync"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr’s detection of corrupted files during Blob ingestion.

### Test Steps
1. Upload corrupted files to Azure Blob.  
2. Trigger Surveilr ingestion.  
3. Monitor logs and error alerts.

### Expected Result
- Corrupted files flagged by checksum validation.  
- Alert generated in Surveilr.  
- Ingestion stops for affected files.
