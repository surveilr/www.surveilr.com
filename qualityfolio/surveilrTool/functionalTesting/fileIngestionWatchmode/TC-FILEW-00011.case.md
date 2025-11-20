---
FII: "TC-FILEW-0011"
groupId: "GRP-0010"
title: "Ingestion of extremely large file (5GB)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Performance", "Large Files"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate ingestion behavior when an excessively large file is added.

### Preconditions
- File-watch mode running.

### Test Steps
1. Add a 5GB file into the watch folder.
2. Monitor processing.

### Expected Result
- Ingestion slows significantly.
- System may timeout or issue a warning.
- Surveilr remains stable.
