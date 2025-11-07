---
FII: "TC-SRV-0028"
groupId: "GRP-0001"  
title: "Verify surveilr doctor --help displays system inspection help"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["doctor"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that running the `surveilr doctor --help` command displays system inspection help.

### Test Steps
1. Open terminal.  
2. Run `surveilr doctor --help`.  
3. Observe the console output.

### Expected Result
- CLI lists available doctor inspection details and usage information.