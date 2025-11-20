---
FII: "TC-FILEW-0001"
groupId: "GRP-0010"
title: "Start basic watch mode"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate that the basic file-watch mode starts successfully.

### Preconditions
- Surveilr CLI installed.
- Watch directory exists and is accessible.

### Test Steps
1. Run command: `surveilr ingest files --watch`.
2. Observe terminal output.

### Expected Result
- Watcher starts successfully.

