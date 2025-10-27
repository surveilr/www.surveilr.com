---
FII: "TC-CSV-0023"
groupId: "GRP-0002"
title: "Check - Unsupported File Type Upload"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate CLI response when a file with unsupported extension (e.g., `.txt` or `.docx`) is provided instead of `.csv`.

### Test Steps
1. Run `surveilr ingest files --input test.txt`.  
2. Observe the console output and logs.  

### Expected Result
- CLI displays “Unsupported file type” message.  
- Exit code ≠ `0`.  
- Error logged appropriately in system logs.
