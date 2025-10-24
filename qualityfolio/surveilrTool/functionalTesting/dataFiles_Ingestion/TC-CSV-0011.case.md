---
FII: "TC-CSV-0011"
groupId: "GRP-0002"
title: "Check - CSV Field Parsing with Commas Inside Quotes"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveilr correctly parses CSV fields containing commas inside double quotes as a single value.

### Test Steps
1. Prepare a CSV file with a field value like `"John, Doe"` in one column.  
2. Run the command `surveilr ingest files --input sample_commas.csv`.  
3. Observe how the CSV data is parsed and ingested.  
4. Review logs for parsing results.

### Expected Result
- The field `"John, Doe"` is recognized as a single cell value.  
- No column misalignment or parsing errors occur.  
- Log shows `Ingestion complete` with exit code `0`.
