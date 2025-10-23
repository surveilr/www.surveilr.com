---
FII: "TC-EXL-0004"
groupId: "GRP-0005"
title: "Handle Excel File with Formulas and Charts"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-22"
test_type: "Automation"
tags: ["Excel"]
priority: "Medium"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description
Ensure Surveilr properly parses Excel files that include formulas, charts, and formatted cells.

### Test Steps
1. Prepare an Excel file with formulas, charts, and formatted text.  
2. Upload the file in Surveilr.  
3. Monitor the parsing process and validate the generated preview or metadata.  

### Expected Result
- Upload is successful.  
- File content (including formulas/charts) does not cause parsing failure.  
- Metadata displays formula and chart presence correctly.
