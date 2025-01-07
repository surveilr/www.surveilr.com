---
  FII: "TC-CEP-0013"
  groupId: GRP-001
  title: "US HIPAA control code Detail Check"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Make sure on US HIPAA Controls page, each control detail page includes the following information:
  Control Question
  Control Description
  Control ID
  Control Domain
  SCF Control

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/)
  2. Navigate to compliance explorer link.
  3. Starting SCF controlmenu Navigation Check.
  4. Capture navigated page title text.
  5. Navigate to the US HIPAA Detail View page.
  6. Check Control Code Link.
  7. Check Control Question.
  8. Check Control Description.
  9. Check Control ID.
  10. Check Control Domain.
  11. Check SCF Control.
  12. Close-browser.

  ### Expected Outcome
  -  All specified control details should be present and accurate on the Control Details page.