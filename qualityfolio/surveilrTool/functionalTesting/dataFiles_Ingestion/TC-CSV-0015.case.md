---
FII: "TC-CSV-0015"
groupId: "GRP-0002"
title: "Check - CSV Parsing with Alternate Delimiters"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate Surveilr’s ability to parse CSV files that use alternative delimiters like `;`, `\t`, or `|`.

### Test Steps
1. Prepare three CSV files: one with `;`, one with `|`, and one with tab as delimiter.  
2. Run `surveilr ingest files --input sample_semicolon.csv` etc.  
3. Check if data columns align correctly.  

### Expected Result
- All delimiter variations are parsed successfully.  
- Columns are identified correctly with no data corruption.
