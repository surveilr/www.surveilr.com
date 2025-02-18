---
FII: "TC-CEP-0013"
groupId: GRP-001
title: "US HIPAA control code Detail Check"
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-31"
test_type: "Automation"
tags: ["Compliance Explorer"]
priority: "High"
---

### Description

Make sure on the US HIPAA Controls page, each control detail page includes the following information:

- Control Question
- Control Description
- Control ID
- Control Domain
- SCF Control

### Steps

1. Check whether the URL gets loaded (https://www.surveilr.com/pattern/) and click on the "Live demo" button.
2. Wait for page load.
3. Start SCF control menu navigation check.
4. Capture the navigated page title text.
5. Navigate to the US HIPAA detail view page.
6. Check the Control Code link.
7. Check the Control Question.
8. Check the Control Description.
9. Check the Control ID.
10. Check the Control Domain.
11. Check the SCF Control.
12. Close the browser.

### Expected Outcome

- All specified control details should be present and accurate on the Control Details page.
