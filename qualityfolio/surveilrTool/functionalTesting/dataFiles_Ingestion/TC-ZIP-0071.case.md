---
FII: "TC-ZIP-0071"
groupId: "GRP-0002"
title: "Nested archive with mixed corrupted/non-corrupted files"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "miserable path"
---

### Description
- Validate that Surveiler extracts valid files and reports errors for corrupted files in nested archives.

### Test Steps
1. Prepare a ZIP archive containing nested archives, some corrupted, some valid.  
2. Upload the archive via the Surveiler interface.  
3. Trigger extraction and observe system messages and extracted files.

### Expected Result
- Valid files are extracted successfully.  
- Corrupted files are flagged.  
- System remains stable.
