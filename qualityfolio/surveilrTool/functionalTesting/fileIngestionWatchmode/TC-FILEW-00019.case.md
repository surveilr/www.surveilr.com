---
FII: "TC-FILEW-0019"
groupId: "GRP-0010"
title: "Case-sensitive vs case-insensitive extensions"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Extensions"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate whether `.PDF` is recognized depending on OS behavior.

### Preconditions
- OS must be known case-sensitive or insensitive.

### Test Steps
1. Add `.pdf` file.
2. Add `.PDF` file.

### Expected Result
- Behavior matches OS filesystem rules.
- Surveilr logs either ingestion or ignore accordingly.
