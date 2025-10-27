---
FII: "TC-OPEN-0100"
groupId: "GRP-0006"
title: "Schema Mismatch in Task Data"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description
- Validate ingestion behavior when field data types differ from expected schema.

### Test Steps
1. Modify OpenProject task payloads with incorrect data types (e.g., due date as text).  
2. Run ingestion.  
3. Observe ingestion validation and logs.  

### Expected Result
- Tasks with invalid schema are rejected or flagged.  
- Surveilr logs type mismatch errors.  
- Valid tasks are still processed normally.
