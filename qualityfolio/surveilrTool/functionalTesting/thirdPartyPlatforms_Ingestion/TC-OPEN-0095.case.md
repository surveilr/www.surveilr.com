---
FII: "TC-OPEN-0095"
groupId: "GRP-0006"
title: "Invalid Credentials During Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate system behavior when incorrect API credentials are used for ingestion.

### Test Steps
1. Configure OpenProject connection with invalid API key.  
2. Attempt to ingest tasks from Surveilr.  
3. Monitor ingestion response.  

### Expected Result
- Ingestion fails with an authentication error.  
- Proper error message is displayed or logged.  
- No tasks are created in Surveilr.
