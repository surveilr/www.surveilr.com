---

FII: "TC-CSV-0028"
groupId: "GRP-0002"
title: "Post-Ingestion Analytics Check"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that ingested CSV data appears correctly in the analytics module.

### Test Steps
1. Ingest CSV file into Surveilr.  
2. Open the analytics module.  
3. Query for the ingested dataset.  

### Expected Result
- Data is available for query and reporting