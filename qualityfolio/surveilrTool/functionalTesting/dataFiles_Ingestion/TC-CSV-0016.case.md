---
FII: "TC-CSV-0016"
groupId: "GRP-0002"
title: "Check - UTF-8 Encoded CSV File Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify that Surveilr correctly parses UTF-8 encoded CSV files with special characters.

### Test Steps
1. Create a UTF-8 encoded CSV containing special characters (e.g., é, ü, ñ).  
2. Run `surveilr ingest files --input sample_utf8.csv`.  
3. Observe parsed output and logs.  

### Expected Result
- UTF-8 characters appear correctly in parsed data.  
- No encoding errors or garbled text.  
- Exit code = `0`.
