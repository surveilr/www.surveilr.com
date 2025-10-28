---
FII: "TC-CSV-0013"
groupId: "GRP-0002"
title: "Check - CSV Parsing with Backslashes and Special Characters"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate that special characters (e.g., `\n`, `\t`, `$`, `#`) within CSV fields are correctly parsed.

### Test Steps
1. Prepare a CSV file containing values like `"Path\\to\\file"`, `"Price: $100"`, `"Hash#Tag"`.  
2. Run `surveilr ingest files --input sample_specials.csv`.  
3. Monitor parsing logs and CLI output.

### Expected Result
- Backslashes and symbols are preserved accurately.  
- No parsing or escape errors are raised.  
- Log reports successful ingestion.
