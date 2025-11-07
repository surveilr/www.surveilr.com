---
FII: "TC-SRV-0022"
groupId: "GRP-0001"
title: "Validate - missing UDI configuration scenario"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["udi", "cli", "error-handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Validate that the CLI displays an appropriate error when UDI configuration is missing or invalid.

### Test Steps

1. Temporarily remove or unset the UDI configuration file or environment variable.  
2. Run the command `surveilr udi connect`.  
3. Observe the console output.

### Expected Result

- The CLI displays an error message such as “configuration missing or invalid” and halts connection attempts gracefully.