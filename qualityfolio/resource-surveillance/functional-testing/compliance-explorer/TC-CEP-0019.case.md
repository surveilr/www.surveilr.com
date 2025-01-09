---

FII: "TC-CEP-0019"
groupId: GRP-001
title: "NIST control code Detail Check"
created_by: "arun-ramanan@netspective.in"
created_at: "2024-12-31"
test_type: "Automation"
tags: ["Compliance Explorer"]
priority: "High"

---

### Description

Make sure on NIST Controls page, each control detail page includes the following information:

- Control Question
- Control Description
- Control ID
- Control Domain
- SCF Control

### Steps

1. Check whether the URL get loaded (https://www.surveilr.com/pattern/) then select compliance explorer pattern and click on 'Live demo' button.
2. Wait for page load.
3. Starting SCF control menu Navigation Check.
4. Capture navigated page title text.
5. Navigate to the NIST Detail View page.
6. Check Control Code Link.
7. Check Control Question.
8. Check Control Description.
9. Check Control ID.
10. Check Control Domain.
11. Check Control SCF.
12. Close-browser.

### Expected Outcome

- All specified control details should be present and accurate on the Control Details page.
