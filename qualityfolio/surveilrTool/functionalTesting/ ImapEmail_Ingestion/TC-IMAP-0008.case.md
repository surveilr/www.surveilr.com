---
FII: "TC-IMAP-0008"
groupId: "GRP-0004"
title: "Plain-text only email ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description

- Validate ingestion of text-only emails.

### Preconditions

- A plain-text email is present in the inbox.

### Test Steps

1. Confirm plain-text email exists.
2. Run ingestion.
3. Inspect stored content.

### Expected Result

- Plain-text content is ingested without any loss.