---
FII: "TC-PNG-008"
groupId: "GRP-0009"
title: "Upload PNG with special characters in filename"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-24"
test_type: "Automation"
tags: ["PNG"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy"
---

### Description
- Validate filename handling for PNG uploads containing special characters.

### Test Steps
1. Prepare a PNG file with special characters in the filename (e.g., `@image#$.png`).  
2. Upload it to Surveiler.  
3. Verify correct ingestion and display name in UI and logs.

### Expected Result
- Image is ingested successfully with filename preserved.  
- No encoding or display issues occur.
