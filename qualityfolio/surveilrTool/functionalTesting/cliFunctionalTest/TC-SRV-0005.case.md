---
FII: "TC-SRV-0005"
groupId: "GRP-0001"
title: "Validate - valid AI query execution"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ask-ai", "cli", "query"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Ensure that a valid AI-driven natural language query correctly translates into a SQL query and executes successfully.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute the command `surveilr ask-ai "list tables"`.  
3. Observe the console output.  
4. Confirm that the AI processes the request and returns the equivalent SQL query or result.

### Expected Result

- The CLI displays a properly formatted AI-translated SQL output or query result corresponding to the input prompt.