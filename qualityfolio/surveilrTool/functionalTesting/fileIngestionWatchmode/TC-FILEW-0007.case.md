---
FII: "TC-FILEW-0007"
groupId: "GRP-0010"
title: "Corrupted file ingestion failure"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode", "File Validation"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy"
---
### Description

- Validate that Surveilr handles ingestion failure correctly when a corrupted or unreadable file of any type is added to the watch folder.

### Preconditions

- File-watch mode enabled.
- Watch folder accessible and monitored.

### Test Steps

1. Add a corrupted or unreadable file (any supported type) into the watch folder.
2. Allow Surveilr to detect and attempt ingestion.
3. Observe system logs and diagnostic outputs.

### Expected Result

- Ingestion fails safely without crashing.
- A clear error diagnostic is produced and logged.
- Surveilr continues watching for subsequent files without interruption.

