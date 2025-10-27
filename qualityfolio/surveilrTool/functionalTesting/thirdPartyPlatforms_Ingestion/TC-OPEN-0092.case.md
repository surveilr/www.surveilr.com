---
FII: "TC-OPEN-0092"
groupId: "GRP-0006"
title: "Successful Task Ingestion from OpenProject"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["OpenProject"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate successful ingestion of tasks from OpenProject into Surveilr when all configurations and credentials are correct.

### Test Steps
1. Configure OpenProject API endpoint and valid credentials in Surveilr.  
2. Initiate task ingestion.  
3. Monitor logs for task retrieval and creation.  
4. Verify that ingested tasks appear in Surveilr with accurate details.  

### Expected Result
- All tasks from OpenProject are ingested successfully.  
- Fields like title, description, due date, and assignee match exactly.  
- Ingestion logs show no errors or warnings.
