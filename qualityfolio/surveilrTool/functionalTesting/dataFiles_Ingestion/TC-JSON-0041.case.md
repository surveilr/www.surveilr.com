---
FII: "TC-JSON-0041"
groupId: "GRP-0002"
title: "Multi-Document JSON Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Test multiple JSON objects in a single file ingested sequentially.

### Test Steps
1. Prepare file with multiple JSON objects separated by newline.  
2. Run `surveilr ingest files --input multi_objects.json`.  

### Expected Result
- Exit code `0`.  
- Each object parsed correctly.  
- Logs show all objects processed successfully.
