---
FII: "TC-SRV-0043"
groupId: "GRP-0001"
title: "Verify surveilr help shows global help"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["help"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that the `surveilr help` command displays global CLI help.

### Test Steps
1. Run `surveilr help`.  
2. Observe the output.  

### Expected Result
- CLI prints the same general help output as `surveilr --help`.