---
FII: "TC-CSV-0003"
groupId: "GRP-0002"
title: "Check - CSV with Extra Empty Columns"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Verify Surveilr handles CSV files containing trailing empty columns correctly.

### Test Steps
1. Create a CSV file with trailing commas indicating empty columns.  
2. Run `surveilr ingest files --input extra_columns.csv`.  
3. Observe CLI logs for parsing behavior.

### Expected Result
- Empty columns are treated as null values.  
- Parsing completes without errors or misalignment.
