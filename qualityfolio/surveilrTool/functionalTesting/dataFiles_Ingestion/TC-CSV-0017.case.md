---
FII: "TC-CSV-0017"
groupId: "GRP-0002"
title: "Check - BOM-Prefixed CSV File Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate that Surveilr can handle CSV files containing a Byte Order Mark (BOM) without misinterpreting headers.

### Test Steps
1. Prepare a UTF-8 CSV file that includes a BOM prefix.  
2. Run `surveilr ingest files --input sample_bom.csv`.  
3. Review the ingestion logs.  

### Expected Result
- BOM is ignored; headers and rows parsed correctly.  
- No parsing or header recognition issues.
