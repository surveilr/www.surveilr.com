---
FII: "TC-JSON-0038"
groupId: "GRP-0002"
title: "Large JSON File Handling"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["JSON"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable"
---

### Description
- Validate Surveilr’s performance when processing large JSON files.

### Test Steps
1. Prepare JSON file with 100K+ records.  
2. Run `surveilr ingest files --input large.json`.  

### Expected Result
- Exit code `0`.  
- File processed within expected time.  
- No memory or performance errors.  
- Logs show successful ingestion.
