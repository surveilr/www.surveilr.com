---
FII: "TC-SRV-0024"  
groupId: "GRP-0001"  
title: "Validate - upgrade to latest version"
created_by: "arun-ramanan@netspective.in"
created_at: "2025-10-31"
test_type: "Automation"
tags: ["upgrade", "cli", "update"]
priority: "High"
test_cycles: ["1.0"]
scenario_type: "happy path"
---

### Description

- Verify that running the `surveilr upgrade` command upgrades the CLI to the latest available version.

### Test Steps

1. Open a terminal or command prompt.  
2. Run the command `surveilr upgrade`.  
3. Observe the console logs during the upgrade process.  
4. Confirm the version after completion using `surveilr --version`.

### Expected Result

- The CLI successfully updates to the latest version, displaying confirmation messages such as “Upgrade complete” and the new version number.