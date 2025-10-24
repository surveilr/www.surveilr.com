---
FII: "TC-OPEN-0099"
groupId: "GRP-0006"
title: "Ingestion with Massive Task Volume"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description
- Evaluate system performance and stability when ingesting a very large number of tasks.

### Test Steps
1. Prepare 10,000+ tasks in OpenProject.  
2. Execute full ingestion process.  
3. Monitor Surveilr CPU, memory, and ingestion logs.  

### Expected Result
- Ingestion may slow but completes without crashing.  
- Partial ingestion handled with error logs for failures.  
- System remains responsive throughout.
