---
FII: "TC-PPT-0013"
groupId: "GRP-0005"
title: "Handle PowerPoint File with Multiple Slides and Embedded Objects"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["PowerPoint"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Validate Surveilr’s ability to process PowerPoint files with multiple slides and embedded media (images, charts, videos).

### Test Steps
1. Upload a `.pptx` file containing 10+ slides with embedded content.  
2. Wait for the parsing process to complete.  
3. Review extracted metadata and content preview.  

### Expected Result
- All slides are detected correctly.  
- Embedded media does not cause parsing or display issues.  
- Metadata shows slide count and embedded object presence.
