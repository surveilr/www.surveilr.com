---
FII: "TC-IMAP-0026"
groupId: "GRP-0004"
title: "HTML→text corruption"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["IMAP", "html", "text-extraction"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---
### Description
- Validate plain-text extraction from HTML does not corrupt formatting.

### Preconditions
- HTML email with nested elements exists.

### Test Steps
1. Run ingestion.
2. Review extracted text body.
3. Compare with expected plain-text output.

### Expected Result
- Text extraction is accurate and free of corruption.