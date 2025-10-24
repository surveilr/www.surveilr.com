---
FII: "TC-CSV-0025"
groupId: "GRP-0002"
title: "CLI Error Log Validation"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate logs after CSV ingestion failure.

### Test Steps
1. Prepare a corrupted or invalid CSV.  
2. Run `surveilr ingest files --input invalid.csv`.  
3. Review logs and exit status.  

### Expected Result
- Logs show “Error” or “Failed”.  
- Exit code ≠ `0`.
