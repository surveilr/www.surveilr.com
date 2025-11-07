---
FII: "TC-SRV-0004"
groupId: "GRP-0001"
title: "Verify - surveilr ask-ai --help displays AI query help"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["ask-ai", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr ask-ai --help` command correctly displays help information and usage instructions for natural language database queries.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr ask-ai --help`.  
3. Observe the output in the console.  
4. Verify that usage syntax, command description, and AI query examples are displayed.

### Expected Result

- The CLI should list the help menu for the `ask-ai` utility, including usage examples and supported options for natural language database queries.