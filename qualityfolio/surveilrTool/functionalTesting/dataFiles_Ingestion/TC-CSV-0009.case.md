---
FII: "TC-CSV-0009"
groupId: "GRP-0002"
title: "Check - Boolean Field Recognition in CSV Files"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure Surveilr recognizes boolean fields represented as `true/false` or `1/0` in CSV.

### Test Steps
1. Create a CSV file containing boolean-like columns (`Active, true, false, 1, 0`).  
2. Run `surveilr ingest files --input boolean_fields.csv`.  
3. Verify interpreted values in logs or database.

### Expected Result
- Boolean values are correctly recognized and stored as logical fields.  
- No misinterpretation or conversion issues occur.
