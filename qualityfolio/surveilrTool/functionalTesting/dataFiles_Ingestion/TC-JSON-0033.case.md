---
FII: "TC-JSON-0033"
groupId: "GRP-0002"
title: "Array Handling in JSON"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure arrays in JSON files are parsed correctly.

### Test Steps
1. Prepare a JSON file containing arrays of objects and primitive types.  
2. Run `surveilr ingest files --input array.json`.  

### Expected Result
- Exit code `0`.  
- All array elements are correctly parsed.  
- Logs indicate successful ingestion.
