---
FII: "TC-CSV-0008"
groupId: "GRP-0002"
title: "Check - String Value Parsing with Special Characters"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate that string fields containing special characters or line breaks are parsed properly.

### Test Steps
1. Create a CSV file containing commas, quotes, and newline characters inside text fields.  
2. Execute `surveilr ingest files --input special_chars.csv`.  
3. Check parsing logs and output data.

### Expected Result
- Strings are parsed correctly, respecting escape sequences and quotes.  
- No row splitting or data corruption occurs.
