---
FII: "TC-SRV-0015"
groupId: "GRP-0001"
title: "Validate - listing of available notebooks"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["notebooks", "cli", "listing"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Verify that the `surveilr notebooks ls` command displays all available notebooks.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr notebooks ls`.  
3. Observe the console output.  
4. Confirm that notebook entries are displayed with relevant details.

### Expected Result

- The CLI should display all available notebooks in a structured list format (e.g., name, path, and last modified date).