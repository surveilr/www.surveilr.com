---
FII: "TC-JSON-0040"
groupId: "GRP-0002"
title: "JSON with Comments"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "Low"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate handling of comments in JSON files (// or /* */ style) if allowed.

### Test Steps
1. Prepare JSON file with comments.  
2. Run `surveilr ingest files --input comments.json`.  

### Expected Result
- Comments ignored or error raised (per CLI spec).  
- Exit code reflects handling.  
- Logs indicate parsing outcome.
