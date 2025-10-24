---
FII: "TC-CSV-0005"
groupId: "GRP-0002"
title: "Check - CSV File with Duplicate Headers"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate how Surveilr handles CSV files that contain duplicate header names.

### Test Steps
1. Create a CSV file with duplicate column names (e.g., `Name,Name,Email`).  
2. Execute `surveilr ingest files --input duplicate_headers.csv`.  
3. Review logs for warnings or errors.

### Expected Result
- Surveilr warns about duplicate columns or renames automatically.  
- Parsing continues successfully without breaking the structure.
