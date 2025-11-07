---
FII: "TC-SRV-0034"  
groupId: "GRP-0001"  
title: "Verify surveilr osquery-ms --help displays monitoring help"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["osquery-ms"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate help information for the `osquery-ms` command.

### Test Steps
1. Open terminal.  
2. Run `surveilr osquery-ms --help`.  
3. Observe the output.

### Expected Result
- CLI displays available monitoring utilities and options.