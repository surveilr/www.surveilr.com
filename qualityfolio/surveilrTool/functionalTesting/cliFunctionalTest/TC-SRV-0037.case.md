---
FII: "TC-SRV-0037"
groupId: "GRP-0001"
title: "Verify surveilr osqueryctl --help displays help information"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["osqueryctl"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that `surveilr osqueryctl --help` lists available config and runtime options.

### Test Steps
1. Open terminal.  
2. Run `surveilr osqueryctl --help`.  
3. Observe the CLI output.

### Expected Result
- CLI displays configuration and run options for osqueryctl.