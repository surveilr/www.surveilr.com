---
FII: "TC-CSV-0002"
groupId: "GRP-0002"
title: "Check - CSV File Without Headers Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate how Surveilr handles CSV files that lack headers.

### Test Steps
1. Create a CSV file without any header row.  
2. Run `surveilr ingest files --input no_header.csv`.  
3. Review the output and log files.

### Expected Result
- Surveilr either auto-generates default headers or logs a warning.  
- File ingestion completes successfully without crash or misalignment.
