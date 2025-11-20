---
FII: "TC-IMAP-0016"
groupId: "GRP-0004"
title: "Invalid folder"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "folder"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate how system handles a non-existing IMAP folder.

### Preconditions
- Define a folder name that does not exist in the mailbox.

### Test Steps
1. Run ingestion with invalid -f "<unknown-folder>".
2. Inspect logs.

### Expected Result
- Clear and descriptive folder-not-found error is shown.

