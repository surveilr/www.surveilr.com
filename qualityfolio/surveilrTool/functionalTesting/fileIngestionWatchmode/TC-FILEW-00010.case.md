---
FII: "TC-FILEW-0010"
groupId: "GRP-0010"
title: "Incorrect watch-ignore pattern formatting"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Configuration"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate handling of incorrectly formatted ignore pattern.

### Preconditions
- File-watch mode active.

### Test Steps
1. Start Surveilr with:
--watch-ignore "*.log *.tmp"

markdown
Copy code
2. Review startup logs.

### Expected Result
- Surveilr warns user of invalid ignore pattern.
- File-watch does not start.
yaml
Copy code
