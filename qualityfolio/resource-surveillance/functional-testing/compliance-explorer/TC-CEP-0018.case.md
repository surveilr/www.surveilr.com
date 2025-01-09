---
FII: "TC-CEP-0018"
groupId: GRP-001
title: "NIST Control code links navigation check"
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-12"
test_type: "Automation"
tags: ["Compliance Explorer"]
priority: "smoke-high"
---

### Description

Ensure that while clicking on each control code on NIST Controls page will navigate to Control Details page properly

### Steps

1. Check whether the URL get loaded (https://www.surveilr.com/pattern/) then select compliance explorer pattern and click on 'Live demo' button.
2. Wait for page load.
3. Starting SCF control menu Navigation Check.
4. Capture navigated page title text.
5. Navigate to the NIST Detail View page.
6. Checking the count of control codes.
7. Close-browser.

### Expected Outcome

- Clicking on a control code should open the corresponding Control Details page without errors.
