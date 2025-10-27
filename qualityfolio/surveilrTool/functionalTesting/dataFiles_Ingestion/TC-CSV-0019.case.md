---
FII: "TC-CSV-0019"
groupId: "GRP-0002"
title: "Check - Malformed CSV Structure Detection"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveilr identifies and logs errors when encountering rows with inconsistent column counts.

### Test Steps
1. Create a malformed CSV file where some rows have fewer or extra columns.  
2. Run `surveilr ingest files --input malformed.csv`.  
3. Review logs and exit code.  

### Expected Result
- Surveilr detects and reports malformed rows.  
- Logs show descriptive error message.  
- Exit code ≠ `0`.
