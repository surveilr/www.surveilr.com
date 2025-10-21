---
FII: "TC-SRV-0015"
groupId: "GRP-0001"
title: "Extreme input length"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Parameter and Flag Handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description

- Test behavior with excessively long flag input values.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute `surveilr scan --target <very long string> --mode quick`.  
3. Observe the CLI output for errors or truncation.  
4. Close the terminal.

### Expected Result

- CLI returns error or gracefully truncates input with warning.
