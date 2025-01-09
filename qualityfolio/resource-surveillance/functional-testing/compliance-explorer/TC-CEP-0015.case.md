---
FII: "TC-CEP-0015"
groupId: GRP-001
title: "NIST Controls SearchBar check"
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-31"
test_type: "Automation"
tags: ["Compliance Explorer"]
priority: "High"
---

### Description

Ensure that the search bar works properly on the NIST Controls page.

### Steps

1. Check whether the URL gets loaded (https://www.surveilr.com/pattern/) and click on the "Live demo" button.
2. Wait for page load.
3. Start SCF control menu navigation check.
4. Capture the navigated page title text.
5. Start NIST detail view navigation check.
6. Validate search bar visibility.
7. Fill the search bar and check results.
8. Close the browser.

### Expected Outcome

- The search bar should function correctly, allowing users to search for specific controls.
