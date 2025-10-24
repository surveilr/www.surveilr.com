---
FII: "TC-ZIP-0075"
groupId: "GRP-0002"
title: "File type recognition inside archive – unknown types"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveiler flags unrecognized or uncommon file types inside an archive without crashing.

### Test Steps
1. Prepare a ZIP archive containing files with unknown or uncommon extensions.  
2. Upload the archive via the Surveiler interface.  
3. Observe the extracted file list and system messages.

### Expected Result
- Unknown file types are flagged appropriately.  
- No system crash occurs; upload completes gracefully.
