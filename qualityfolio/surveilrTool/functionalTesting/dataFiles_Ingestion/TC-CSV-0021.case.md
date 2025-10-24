---
FII: "TC-CSV-0021"
groupId: "GRP-0002"
title: "Check - CLI Behavior for Missing File Path"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate CLI error response when an invalid or missing file path is passed.

### Test Steps
1. Run `surveilr ingest files --input nonexistent.csv`.  
2. Observe the CLI output and logs.  

### Expected Result
- Surveilr displays “File not found” or similar message.  
- Exit code ≠ `0`.  
- No stack trace or unhandled exception.
