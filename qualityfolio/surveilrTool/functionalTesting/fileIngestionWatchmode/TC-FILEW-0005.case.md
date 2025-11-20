---
FII: "TC-FILEW-0007"
groupId: "GRP-0010"
title: "Use ignore filter for specific file types"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-11-20"
test_type: "Automation"
tags: ["File-Watch Mode"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---
### Description
- Validate that ignore filters prevent ingestion of files matching specified patterns.

### Preconditions
- Watch directory contains mixed file types (e.g., PDF, TMP, LOG).

### Test Steps
1. Start watcher with ignore filter:
surveilr ingest files --watch --watch-ignore "*.pdf".
2. Add the following files into the watch directory:
sample.pdf
debug.tmp
runtime.log

### Expected Result
- sample.pdf is detected and ingested successfully.
- debug.tmp and runtime.log are ignored by the watcher.
- Logs clearly show skip events for ignored files.