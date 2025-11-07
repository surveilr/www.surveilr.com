---
FII: "TC-SRV-0017"
groupId: "GRP-0001"
title: "Verify - surveilr web-ui --help displays configuration options"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["web-ui", "cli", "help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate that the `surveilr web-ui --help` command displays usage and configuration options for the SQLPage webserver.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr web-ui --help`.  
3. Review the output in the console.  
4. Verify that it lists configuration flags, startup parameters, and environment options.

### Expected Result

- The CLI displays configuration options and usage information for the webserver setup and management.