---
FII: "TC-SRV-0002"
groupId: "GRP-0001"
title: "Validate - running surveilr admin without arguments"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["admin", "cli", "error-handling"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Ensure that when the user runs the `surveilr admin` command without any subcommands or arguments, the CLI handles it gracefully and displays a helpful usage message instead of failing silently.

### Test Steps

1. Open a terminal or command prompt.  
2. Execute the command `surveilr admin`.  
3. Review the output in the console.

### Expected Result

- The CLI displays a usage message or help output indicating that a required subcommand is missing, such as “missing subcommand” or similar guidance.