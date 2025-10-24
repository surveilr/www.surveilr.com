---
FII: "TC-CSV-0007"
groupId: "GRP-0002"
title: "Check - Date Format Handling in CSV Files"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure Surveilr correctly parses multiple date formats within CSV files.

### Test Steps
1. Create a CSV with date columns using various formats (e.g., `YYYY-MM-DD`, `MM/DD/YYYY`).  
2. Run `surveilr ingest files --input date_formats.csv`.  
3. Review output for normalized date parsing.

### Expected Result
- All valid date formats are parsed correctly.  
- Invalid formats are logged with warnings, not failures.
