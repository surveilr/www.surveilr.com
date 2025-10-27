---
FII: "TC-ZIP-0078"
groupId: "GRP-0002"
title: "Upload empty ZIP archive"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "unhappy path"
---

### Description
- Validate that Surveiler handles empty ZIP archives appropriately.

### Test Steps
1. Prepare an empty ZIP file.  
2. Upload the empty ZIP via the Surveiler interface.  
3. Observe system behavior and messages.

### Expected Result
- System shows a warning or error message.  
- No extraction occurs.  
- System remains stable.
