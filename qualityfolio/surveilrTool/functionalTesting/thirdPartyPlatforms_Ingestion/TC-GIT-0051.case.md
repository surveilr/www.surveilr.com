---
FII: "TC-GIT-0051"
groupId: "GRP-0006"
title: "Incremental Ingest of Updated Repo"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Validate that Surveilr only ingests new or updated commits on re-running file ingest.

### Test Steps
1. Perform initial file ingest on GitHub repo.  
2. Push new commits to the repository.  
3. Re-run file ingest command.  
4. Verify new commits and files in `uniform_resource`.

### Expected Result
- Only new/updated files added.  
- Previous records preserved.  
- Session logs reflect incremental ingest.
