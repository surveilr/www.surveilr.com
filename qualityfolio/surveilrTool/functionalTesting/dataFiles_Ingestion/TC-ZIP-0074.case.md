---
FII: "TC-ZIP-0074"
groupId: "GRP-0002"
title: "File type recognition inside archive – mixed types"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveiler correctly recognizes different file types (PDF, CSV, JSON, etc.) inside an uploaded archive.

### Test Steps
1. Prepare a ZIP archive containing files of multiple types.  
2. Upload the archive via the Surveiler interface.  
3. Observe the extracted file list and type classification.

### Expected Result
- All file types inside the archive are identified correctly.  
- No errors are displayed.
