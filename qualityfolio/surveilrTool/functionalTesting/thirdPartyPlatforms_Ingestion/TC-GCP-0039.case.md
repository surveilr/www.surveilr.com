---
FII: "TC-GCP-0039"
groupId: "GRP-0006"
title: "Verify Line-Based Log Integration (Cloud Logging)"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-23"
test_type: "Automation"
tags: ["Google Cloud Platform"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---
### Description
- Verify Cloud Logging logs are ingested line-by-line into Surveilr database.

### Test Steps
1. Configure Surveilr to fetch Cloud Logging entries.  
2. Start ingestion process.  
3. Compare ingested log lines with source logs.  
4. Validate timestamps and metadata.

### Expected Result
- Each log line ingested correctly with accurate timestamps.  
- No parsing or formatting errors.  
- Log count in Surveilr matches GCP source.
