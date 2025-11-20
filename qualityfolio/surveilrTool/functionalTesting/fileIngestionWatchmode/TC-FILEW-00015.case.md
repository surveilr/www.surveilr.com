---
FII: "TC-FILEW-0015"
groupId: "GRP-0010"
title: "VS Code window reload resets watcher"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "VSCode"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate watcher behavior when VS Code window reloads.

### Preconditions
- Active file watch running.

### Test Steps
1. Start file watch mode.
2. Initiate VS Code reload (Ctrl+Shift+P → Reload Window).

### Expected Result
- Terminal resets.
- Surveilr watcher stops immediately.
