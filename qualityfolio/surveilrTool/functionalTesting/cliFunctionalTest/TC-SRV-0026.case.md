---
FII: "TC-SRV-0026"
groupId: "GRP-0001"  
title: "Validate orchestration execution with surveilr orchestrate run"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["orchestrate"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate successful execution of an orchestration job using the CLI.

### Test Steps
1. Open terminal.  
2. Run the command `surveilr orchestrate run`.  
3. Monitor the CLI output logs.  

### Expected Result
- CLI runs orchestration successfully, showing issue/warning logs and completion message.