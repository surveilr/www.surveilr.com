---
FII: "TC-IMAP-0028"
groupId: "GRP-0004"
title: "VS Code crashes unexpectedly during IMAP watch"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "Watch"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate Surveilr process behavior when VS Code crashes unexpectedly.

### Preconditions
- IMAP watch is active.

### Test Steps
1. Start IMAP watch.
2. Force-crash VS Code (kill process).

### Expected Result
- No zombie Surveilr process remains.
- IMAP session closes safely without partial ingestion.
