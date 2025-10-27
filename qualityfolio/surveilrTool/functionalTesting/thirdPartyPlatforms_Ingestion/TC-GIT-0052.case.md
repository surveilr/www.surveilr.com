---
FII: "TC-GIT-0052"
groupId: "GRP-0006"
title: "Branch-Specific Ingest"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate ingestion of a specific branch only.

### Test Steps
1. Configure file ingest to target a specific branch (e.g., main).  
2. Run the file ingest command.  
3. Check `uniform_resource` table for branch-specific files and commits.

### Expected Result
- Only the specified branch ingested.  
- Other branches ignored.  
- Metadata reflects correct branch association.
