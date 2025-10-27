---
FII: "TC-JSON-0032"
groupId: "GRP-0002"
title: "Nested Objects Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate parsing of deeply nested JSON objects.

### Test Steps
1. Prepare a JSON file with nested objects (3–4 levels deep).  
2. Run `surveilr ingest files --input nested.json`.  

### Expected Result
- Exit code `0`.  
- Nested structures correctly interpreted.  
- No parsing errors in logs.
