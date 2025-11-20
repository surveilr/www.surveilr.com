---
FII: "TC-FILEW-0013"
groupId: "GRP-0010"
title: "Close VS Code without closing terminal"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "VSCode"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate behavior when VS Code is closed but the integrated terminal was not manually stopped.

### Preconditions
- Surveilr watch mode is running inside VS Code integrated terminal.

### Test Steps
1. Start file watch mode inside VS Code.
2. Close VS Code application without stopping the terminal.

### Expected Result
- Terminal is killed automatically.
- Surveilr stops watching with a clean shutdown.
