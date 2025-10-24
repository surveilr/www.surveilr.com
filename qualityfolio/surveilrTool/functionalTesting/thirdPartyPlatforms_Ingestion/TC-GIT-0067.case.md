---
FII: "TC-GIT-0067"
groupId: "GRP-0006"
title: "Force-Push / Rewritten History"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Github"]
priority: "Critical"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---
### Description
- Validate Surveilr detects force-push or history rewrites during file ingest.

### Test Steps
1. Run file ingest on a repo.  
2. Force-push rewritten history upstream.  
3. Re-run file ingest command.  
4. Observe session logs and `uniform_resource` entries.

### Expected Result
- Surveilr detects divergence.  
- Previous entries marked superseded or updated.  
- Provenance maintained accurately.
