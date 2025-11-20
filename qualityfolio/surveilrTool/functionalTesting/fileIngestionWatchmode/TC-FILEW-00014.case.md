---
FII: "TC-FILEW-0014"
groupId: "GRP-0010"
title: "Close only the terminal tab in VS Code"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "VSCode"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate watcher shutdown when the user manually kills the terminal tab.

### Preconditions
- File watch mode running in VS Code terminal.

### Test Steps
1. Start file watch mode.
2. Click the **Kill Terminal** button in VS Code.

### Expected Result
- Surveilr watcher stops immediately.
- Process exits cleanly without errors.
