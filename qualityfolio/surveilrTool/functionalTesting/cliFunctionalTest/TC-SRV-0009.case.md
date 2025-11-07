---
FII: "TC-SRV-0009"
groupId: "GRP-0001"
title: "Validate - CE listing of registered executables"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["capturable-exec", "cli", "listing"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Verify that the CLI lists all registered Capturable Executables (CE) when the `list` subcommand is executed.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr capturable-exec list`.  
3. Observe the console output.  
4. Verify that the registered executables are displayed in a readable table or structured format.

### Expected Result

- The CLI should display a list of all registered Capturable Executables with proper formatting (e.g., table with columns like *Name*, *Path*, *Status*).