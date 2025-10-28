---
FII: "TC-SRV-0023"
groupId: "GRP-0001"
title: "Validate logging under full disk condition"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["Log Outputs"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description

- Verify CLI behavior and logging when disk space is insufficient.

### Preconditions

- CLI installed.  
- Disk full scenario simulated.

### Test Steps

1. Open terminal.  
2. Fill disk space to simulate full disk.  
3. Run a CLI command.  
4. Observe CLI behavior and logs.  
5. Close terminal.

### Expected Result

- CLI reports inability to write logs gracefully.  
- System logs capture the failure if possible.
