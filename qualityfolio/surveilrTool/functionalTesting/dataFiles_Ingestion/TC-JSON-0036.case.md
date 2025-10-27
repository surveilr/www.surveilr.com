---
FII: "TC-JSON-0036"
groupId: "GRP-0002"
title: "Invalid JSON Syntax Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Check parser reaction to malformed JSON files.

### Test Steps
1. Prepare JSON file with syntax errors (missing braces, quotes, commas).  
2. Run `surveilr ingest files --input invalid.json`.  

### Expected Result
- Exit code ≠ 0.  
- Error logged with descriptive message.  
- CLI does not crash.
