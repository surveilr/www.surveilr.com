---
FII: "TC-CSV-0010"
groupId: "GRP-0002"
title: "Check - Handling of Null and Empty Values in CSV"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate how Surveilr handles CSV fields that contain null or empty values.

### Test Steps
1. Create a CSV with some cells empty or containing the text `NULL`.  
2. Run `surveilr ingest files --input null_values.csv`.  
3. Review the parsed output or logs.

### Expected Result
- Empty or “NULL” fields are recognized as null values.  
- No ingestion failure or data shift occurs.
