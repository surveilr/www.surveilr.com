---
FII: "TC-CSV-0006"
groupId: "GRP-0002"
title: "Check - Numeric Value Parsing in CSV"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy Path"
---

### Description
- Validate that numeric values in CSV columns are correctly parsed and preserved during ingestion.

### Test Steps
1. Prepare a CSV file containing integer and float columns.  
2. Run `surveilr ingest files --input numeric_values.csv`.  
3. Verify parsed data in the output or logs.

### Expected Result
- Numeric data is parsed accurately with correct precision.  
- No conversion errors or truncation occur.
