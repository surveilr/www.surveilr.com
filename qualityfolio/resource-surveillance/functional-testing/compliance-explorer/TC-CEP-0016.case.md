---
  FII: "TC-CEP-0016"
  groupId: GRP-001
  title: "NIST Controls Tables-Title title check"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Ensure that control code, title, domain, control description, requirement are displayed on NIST Controls page

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/).
  2. Navigate to compliance explorer link.
  3. Starting SCF controlmenu Navigation Check.
  4. Capture navigated page title text.
  5. Navigate to the US HIPAA Detail View page.
  6. Check table title: Control Code.
  7. Check table title: Title.
  8. Check table title: Domain.
  9. Check table title: Control Description.
  10.Check table title: Requirements
  11.Close-browser

  ### Expected Outcome
  -   All control information should be displayed accurately and completely.