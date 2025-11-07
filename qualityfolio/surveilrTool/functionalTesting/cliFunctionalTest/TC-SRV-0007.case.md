---
FII: "TC-SRV-0007"
groupId: "GRP-0001"
title: "Validate - invalid query input for ask-ai"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ask-ai", "cli", "validation"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Verify that the `surveilr ask-ai` command properly validates input and handles empty or malformed queries gracefully.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute the command `surveilr ask-ai ""`.  
3. Observe the console output.  
4. Check if input validation triggers an appropriate error.

### Expected Result

- The CLI should display an input validation error message indicating that the query is empty or invalid, without crashing.