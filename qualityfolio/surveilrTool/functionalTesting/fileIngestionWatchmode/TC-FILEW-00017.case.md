---
FII: "TC-FILEW-0017"
groupId: "GRP-0010"
title: "Temporary extension copied then replaced with valid extension"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate ingestion when a file first appears as a temp file.

### Preconditions
- Watched folder accessible.

### Test Steps
1. Copy file as `.tmp`.
2. Replace or rename to `.pdf`.

### Expected Result
- `.tmp` ignored.
- `.pdf` ingested immediately.
