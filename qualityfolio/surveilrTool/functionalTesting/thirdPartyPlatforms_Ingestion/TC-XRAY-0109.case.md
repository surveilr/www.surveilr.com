---
FII: "TC-XRAY-0109"
groupId: "GRP-0006"
title: "Surveiler Database Unavailable"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["XRAY"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveiler behavior when database is unavailable during ingestion.

### Test Steps
1. Trigger ingestion while DB connection is down.  

### Expected Result
- Tasks are not saved.  
- Error logged: “Database connection failed.”  
- Session ends without crashing.
