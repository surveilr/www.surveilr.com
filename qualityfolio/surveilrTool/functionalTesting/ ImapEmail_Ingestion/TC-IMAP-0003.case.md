---
FII: "TC-IMAP-0003"
groupId: "GRP-0004"
title: "Ingest with status=all"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Validate ingestion of both read and unread emails.

### Preconditions

- Gmail IMAP enabled.
- Mix of read and unread mails present in inbox.

### Test Steps

1. Provide valid Gmail IMAP configuration.
2. Run ingestion with the flag --status all:
surveilr ingest imap \
  -a "imap.gmail.com" \
  -u "<email>" \
  -p "<app-password>" \
  --status all \
  --progress
3. Observe ingestion output.

### Expected Result

- Both read and unread messages are ingested.