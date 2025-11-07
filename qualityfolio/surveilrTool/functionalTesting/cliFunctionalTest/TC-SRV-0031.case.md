---
FII: "TC-SRV-0031"  
groupId: "GRP-0001"  
title: "Verify surveilr shell --help displays shell help"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["shell"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that running `surveilr shell --help` displays available SQLite/DuckDB shell options.

### Test Steps
1. Open terminal.  
2. Run `surveilr shell --help`.  
3. Observe the output.

### Expected Result
- CLI lists SQLite and DuckDB shell command options.