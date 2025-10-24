---
FII: "TC-OPEN-0093"
groupId: "GRP-0006"
title: "Ingest Tasks with Partial Data"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Verify ingestion of tasks from OpenProject where optional fields are missing.

### Test Steps
1. Prepare OpenProject tasks missing non-critical fields (e.g., description).  
2. Trigger task ingestion in Surveilr.  
3. Check whether ingestion completes without interruption.  

### Expected Result
- Tasks are ingested successfully even with missing optional fields.  
- Missing values are represented as null or defaults in Surveilr.  
- No ingestion process errors are logged.
