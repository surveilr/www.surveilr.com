---
FII: "TC-IMAP-0007"
groupId: "GRP-0004"
title: "HTML-only email ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description

- Validate HTML-only email parsing.

### Preconditions

- An HTML-only test email exists.

### Test Steps

1. Ensure HTML email is received.
2. Run the IMAP ingest command.
3. Review parsed contents.

### Expected Result

- HTML content is parsed and stored correctly.