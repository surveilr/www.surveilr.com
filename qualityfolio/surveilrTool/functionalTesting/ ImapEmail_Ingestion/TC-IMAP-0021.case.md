---
FII: "TC-IMAP-0021"
groupId: "GRP-0004"
title: "Folder name case bug"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "folder"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate folder case sensitivity issues.

### Preconditions
- Folder exists with case-sensitive name (e.g., "Inbox" vs "INBOX").

### Test Steps
1. Run ingestion using mismatched case in folder name.
2. Observe selected folder.

### Expected Result
- Correct folder is selected regardless of case mismatch.