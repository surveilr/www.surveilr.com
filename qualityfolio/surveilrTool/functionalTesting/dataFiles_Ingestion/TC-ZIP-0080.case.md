---
FII: "TC-ZIP-0080"
groupId: "GRP-0002"
title: "Archive with invalid filenames"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description
- Validate that Surveiler handles files with unsupported or invalid characters in archive filenames gracefully.

### Test Steps
1. Prepare a ZIP archive with files containing invalid or unsupported characters in filenames.  
2. Upload the archive via the Surveiler interface.  
3. Observe extraction behavior and system messages.

### Expected Result
- Files with invalid names are flagged.  
- Extraction fails gracefully for problematic files.  
- System remains stable.
