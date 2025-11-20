---
FII: "TC-FILEW-0004"
groupId: "GRP-0010"
title: "Use include filter for file types"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate that include filters restrict ingestion to the specified pattern.

### Preconditions
- Watch directory contains mixed file types.

### Test Steps
1. Run watcher with filter: `surveilr ingest files --watch --watch-include "*.pdf"'.
2. Add a PDF file and a non-PDF file.

### Expected Result
- Only PDF file is ingested.
- Other files are ignored.
