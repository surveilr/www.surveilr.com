---
FII: "TC-GIT-0053"
groupId: "GRP-0006"
title: "Multi-Branch Ingest"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of all branches from a GitHub repository.

### Test Steps
1. Configure file ingest for all branches.  
2. Run file ingest command.  
3. Verify that all branches and commits appear in `uniform_resource`.

### Expected Result
- All branches ingested with correct commit histories.  
- Provenance accurately captures branch info.
