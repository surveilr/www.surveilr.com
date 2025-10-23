---
FII: "TC-ZIP-0068"
groupId: "GRP-0002"
title: "Upload valid ZIP file locally"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["ZIP"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
- Validate that Surveiler can successfully upload and extract a valid ZIP file through the local upload interface.

### Test Steps
1. Navigate to the Surveiler Upload section.  
2. Select a valid ZIP file from local storage.  
3. Click the Upload button.  
4. Observe the file extraction process and verify the extracted file list.

### Expected Result
- ZIP file uploads successfully.  
- All contained files are extracted and listed.  
- No errors displayed.
