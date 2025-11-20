---
FII: "TC-FILEW-0003"
groupId: "GRP-0010"
title: "Ignore unsupported file extension"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate watcher skips unsupported file types.

### Preconditions
- Watch mode running.

### Test Steps
1. Add `file.exe` to the watch directory.
2. Observe log messages.

### Expected Result
- File is ignored.
- Watcher logs: **“ignored (unsupported type)”**.
