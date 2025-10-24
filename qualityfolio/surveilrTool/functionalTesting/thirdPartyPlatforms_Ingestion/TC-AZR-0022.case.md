---
FII: "TC-AZR-0022"
groupId: "GRP-0006"
title: "Verify Log Integration (Azure Monitor Logs)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Azure"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify Azure Monitor logs are correctly ingested line-by-line into Surveilr.

### Test Steps
1. Configure Surveilr to fetch Azure Monitor logs.  
2. Start ingestion process.  
3. Compare ingested log entries with source logs.  
4. Verify timestamps and metadata.

### Expected Result
- Each log entry correctly ingested with accurate timestamps.  
- No parsing or formatting errors.  
- Count of ingested logs matches source.
