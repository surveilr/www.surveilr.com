---
FII: "TC-CSV-0020"
groupId: "GRP-0002"
title: "Check - Empty CSV File Behavior"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveilr handles empty CSV files gracefully.

### Test Steps
1. Prepare an empty CSV file.  
2. Run `surveilr ingest files --input empty.csv`.  
3. Observe CLI output and logs.  

### Expected Result
- Surveilr logs a warning and skips ingestion.  
- Exit code indicates handled exception (non-zero or warning state).  
- No crash or unhandled error.
