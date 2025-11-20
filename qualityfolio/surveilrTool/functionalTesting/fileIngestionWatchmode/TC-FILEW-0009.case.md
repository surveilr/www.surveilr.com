---
FII: "TC-FILEW-0009"
groupId: "GRP-0010"
title: "Watch folder without sufficient permissions"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Permissions"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate error handling when Surveilr is started with a watch directory lacking read permissions.

### Preconditions
- Restricted-access folder exists.

### Test Steps
1. Start file-watch mode pointing to a folder without read permissions.
2. Observe system output.

### Expected Result
- Surveilr fails to start watch and returns: “Permission denied”.
