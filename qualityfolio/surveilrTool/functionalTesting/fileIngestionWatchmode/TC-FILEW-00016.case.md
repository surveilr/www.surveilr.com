---
FII: "TC-FILEW-0016"
groupId: "GRP-0010"
title: "Modify ignored file then rename to allowed extension"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Extensions"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate behavior when a file first ignored becomes eligible after renaming.

### Preconditions
- Ignored file exists (e.g., .tmp).

### Test Steps
1. Modify ignored file.
2. Rename from `.tmp` to `.pdf`.

### Expected Result
- File is ignored initially.
- After rename, Surveilr ingests `.pdf` successfully.
