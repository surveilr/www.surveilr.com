---
FII: "TC-OPEN-0101"
groupId: "GRP-0006"
title: "Unauthorized Access Attempt During Ingestion"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description
- Validate that Surveilr properly restricts ingestion when the connected user lacks permissions.

### Test Steps
1. Configure a non-admin OpenProject account.  
2. Attempt to ingest tasks using its credentials.  
3. Observe response and system logs.  

### Expected Result
- Ingestion fails with a permission error.  
- Surveilr prevents unauthorized data access.  
- Logs capture the authorization failure clearly.
