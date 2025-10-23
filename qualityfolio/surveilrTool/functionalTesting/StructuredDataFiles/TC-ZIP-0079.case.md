---
FII: "TC-ZIP-0079"
groupId: "GRP-0002"
title: "Deeply nested archive extraction"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveiler handles archives with deeply nested files (10+ levels) correctly.

### Test Steps
1. Prepare a ZIP archive with files nested 10+ levels deep.  
2. Upload the archive via the Surveiler interface.  
3. Trigger extraction and observe the extracted file structure.

### Expected Result
- All files are extracted if supported.  
- If nesting exceeds limits, an appropriate error is shown.  
- No system crash occurs.
