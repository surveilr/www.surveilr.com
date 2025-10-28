---
FII: "TC-CSV-0012"
groupId: "GRP-0002"
title: "Check - CSV Field Handling with Embedded Quotes"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that CSV fields containing quotes inside values are properly escaped and parsed.

### Test Steps
1. Create a CSV file with a field like `"He said ""Hello"""`.  
2. Execute the command `surveilr ingest files --input sample_quotes.csv`.  
3. Observe parsing logs and verify data interpretation.  

### Expected Result
- Surveilr correctly interprets inner quotes as literal characters.  
- Data structure remains consistent.  
- Exit code = `0`, log shows successful parsing.
