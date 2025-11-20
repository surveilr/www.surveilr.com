---
FII: "TC-FILEW-0012"
groupId: "GRP-0010"
title: "File deleted during ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "Edge Case"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description
- Validate behavior when a file is removed from the watch directory while being processed.

### Preconditions
- File-watch mode running.

### Test Steps
1. Add a file to trigger ingestion.
2. Delete the file while it is mid-processing.

### Expected Result
- Surveilr logs: “file removed during ingestion”.
- No crash or corruption occurs.
