---
FII: "TC-FILEW-0020"
groupId: "GRP-0010"
title: "Multiple watchers running in parallel"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Parallel"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate system behavior when multiple watchers observe different folders.

### Preconditions
- Multiple watch commands can run simultaneously.

### Test Steps
1. Start two separate watchers on different directories.

### Expected Result
- Both watchers run independently.
- No cross-interference occurs.
