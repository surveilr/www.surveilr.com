---
FII: "TC-CSV-0001"
groupId: "GRP-0002"
title: "Check - CSV File with Headers is Parsed Correctly"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that a CSV file containing headers and multiple rows is correctly recognized and parsed by Surveilr CLI.

### Test Steps
1. Prepare a valid CSV file with headers and data rows.  
2. Run the command `surveilr ingest files --input sample.csv`.  
3. Observe log and console output.  
4. Verify header-to-column mapping and row count.

### Expected Result
- CLI ingests CSV successfully.  
- Headers are detected correctly.  
- Column mappings and data rows match expected output.
