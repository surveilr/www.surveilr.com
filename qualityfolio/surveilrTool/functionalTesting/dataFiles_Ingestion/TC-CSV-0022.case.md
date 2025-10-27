---
FII: "TC-CSV-0022"
groupId: "GRP-0002"
title: "Check - Corrupted CSV File Behavior"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveilr throws a descriptive error when processing a corrupted CSV (non-UTF or binary data inside).

### Test Steps
1. Prepare a corrupted CSV with invalid byte sequences.  
2. Run `surveilr ingest files --input corrupted.csv`.  
3. Review logs and exit status.  

### Expected Result
- Surveilr stops ingestion and logs “Invalid file encoding” or similar error.  
- Exit code ≠ `0`.
