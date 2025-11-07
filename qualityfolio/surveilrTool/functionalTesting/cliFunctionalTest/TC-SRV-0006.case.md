---
FII: "TC-SRV-0006"
groupId: "GRP-0001"
title: "Validate - missing AI key configuration"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ask-ai", "cli", "error-handling"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Validate that the CLI properly handles cases when the AI key or configuration is missing or invalid during query execution.

### Test Steps

1. Unset or remove the AI configuration key.  
2. Run the command `surveilr ask-ai "select * from x"`.  
3. Observe the error message displayed on the console.

### Expected Result

- The CLI displays an appropriate error message such as “missing or invalid AI configuration” and halts further processing.