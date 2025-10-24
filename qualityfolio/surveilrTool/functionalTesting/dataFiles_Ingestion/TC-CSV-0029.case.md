---

FII: "TC-CSV-0029"
groupId: "GRP-0002"
title: "Data Integrity Validation"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Ensure 100% data preservation by comparing record counts before and after ingestion.

### Test Steps
1. Count records in the source CSV.  
2. Ingest CSV into Surveilr.  
3. Compare record counts in the output or analytics module.  

### Expected Result
- Record counts match exactly.  
- 100% data preservation confirmed.