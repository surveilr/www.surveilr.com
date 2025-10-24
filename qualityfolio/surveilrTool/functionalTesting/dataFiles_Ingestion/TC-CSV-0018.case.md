---
FII: "TC-CSV-0018"
groupId: "GRP-0002"
title: "Check - Large CSV File Performance Validation"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate Surveilr’s performance and stability when processing a large CSV file (>100,000 rows).

### Test Steps
1. Generate a large CSV file with 100,000+ records.  
2. Run `surveilr ingest files --input large_dataset.csv`.  
3. Measure total ingestion time and monitor logs for memory or timeout errors.  

### Expected Result
- Ingestion completes successfully without memory overflow.  
- Exit code = `0`.  
- Execution time within acceptable performance threshold.
