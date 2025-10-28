---
FII: "TC-JSON-0031"
groupId: "GRP-0002"
title: "Valid JSON Parsing"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify Surveilr can correctly parse a valid JSON file with multiple key-value pairs and nested objects.

### Test Steps
1. Prepare a valid JSON file with multiple key-value pairs and nested objects.  
2. Run `surveilr ingest files --input valid.json`.  

### Expected Result
- Exit code `0`.  
- JSON parsed successfully with correct structure.  
- Log status shows `OK`.
