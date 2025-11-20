---
FII: "TC-IMAP-0017"
groupId: "GRP-0004"
title: "Attachment path permission issue"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "attachments", "permissions"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate behavior when attachment extraction path lacks write permissions.

### Preconditions
- Remove write permissions on configured attachment directory.

### Test Steps
1. Run ingestion with --extract-attachments.
2. Observe error handling when writing attachments fails.

### Expected Result
- Ingestion continues without crashing; proper permission error logged.