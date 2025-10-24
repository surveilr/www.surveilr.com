---
FII: "TC-JSON-0037"
groupId: "GRP-0002"
title: "Special Characters in JSON"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify JSON files containing special characters (\n, \t, Unicode, quotes) are parsed correctly.

### Test Steps
1. Prepare JSON file with special characters.  
2. Run `surveilr ingest files --input special_chars.json`.  

### Expected Result
- Exit code `0`.  
- Characters parsed correctly; no data loss.  
- Logs indicate successful ingestion.
