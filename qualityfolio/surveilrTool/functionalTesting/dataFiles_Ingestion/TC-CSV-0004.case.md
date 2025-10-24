---
FII: "TC-CSV-0004"
groupId: "GRP-0002"
title: "Check - CSV with Mixed Header Casing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure Surveilr correctly processes CSV headers that use different casing styles (upper/lower/mixed).

### Test Steps
1. Create a CSV file with headers in mixed case (e.g., `Name,AGE,City`).  
2. Run `surveilr ingest files --input mixedcase.csv`.  
3. Check field mapping consistency in parsed output.

### Expected Result
- Field names are correctly mapped regardless of case.  
- No duplication or mapping mismatch occurs.
