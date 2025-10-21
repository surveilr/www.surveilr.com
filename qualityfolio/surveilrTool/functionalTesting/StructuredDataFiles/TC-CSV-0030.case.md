---

FII: "TC-CSV-0030"
groupId: "GRP-0002"
title: "Multi-Environment Execution"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-21"
test_type: "Automation"
tags: ["CSV"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Run the same CSV ingestion process in QA and Staging environments and compare results.

### Test Steps
1. Ingest the same CSV file in QA environment.  
2. Ingest the same CSV file in Staging environment.  
3. Compare output files and checksums across environments.  

### Expected Result
- Outputs are identical.  
- Checksums match across environments.