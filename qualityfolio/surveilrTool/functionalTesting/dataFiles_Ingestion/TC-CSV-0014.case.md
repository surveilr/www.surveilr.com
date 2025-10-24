---
FII: "TC-CSV-0014"
groupId: "GRP-0002"
title: "Check - Multiline CSV Field Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate that Surveilr can correctly parse CSV fields containing line breaks enclosed in quotes.

### Test Steps
1. Create a CSV file where one field spans multiple lines:  
   `"Line1  
   Line2"`.  
2. Run `surveilr ingest files --input sample_multiline.csv`.  
3. Review ingestion logs and transformed output.  

### Expected Result
- Multiline content is treated as one cell.  
- No row split or data truncation occurs.  
- Log indicates successful ingestion.
