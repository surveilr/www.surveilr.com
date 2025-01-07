---
  FII: "TC-CEP-0010"
  groupId: GRP-001
  title: "US HIPAA Controls Tables-Title title check"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Ensure that control code, title, domain, control description, requirement are displayed on US HIPAA Controls page as table title

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/)
  2. Navigate to compliance explorer link
  3. Wait for page load.
  4. Starting SCF controlmenu Navigation Check.     
  5. Capture navigated page title text.
  6. Navigate to the US HIPAA Detail View page.
  7. Check table title: Control Code.
  8. Check table title: Title
  9. Check table title: Domain
  10. Check table title: Control Description
  11. Check table title: Requirements
  12. Close-browser

  ### Expected Outcome
  -   All control information should be displayed accurately and completely.