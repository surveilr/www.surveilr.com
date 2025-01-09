---
FII: "TC-CEP-0014"
groupId: GRP-001
title: "NIST Detail View Links navigation check"
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-31"
test_type: "Automation"
tags: ["Compliance Explorer"]
priority: "High"
---

### Description

Verify that NIST Detail View Links navigate properly and the title "NIST Controls" is visible on the NIST Controls Detail View Links navigation page.

### Steps

1. Check whether the URL gets loaded (https://www.surveilr.com/pattern/) and click on the "Live demo" button.
2. Wait for page load.
3. Start SCF control menu navigation check.
4. Capture the navigated page title text.
5. Start NIST detail view navigation check.
6. Capture the navigated page title text.
7. Close the browser.

### Expected Outcome

- Clicking "Detail View" should open additional information or a new page with details for the NIST compliance standard.
