---
  FII: "TC-CEP-0006"
  groupId: GRP-001
  title: "Verify US HIPAA Section Data"
  created_by: "arun-ramanan@netspective.in"
  created_at:  "2024-12-31"
  test_type: "Automation"
  tags: ["Compliance Explorer"] 
  priority: "High"
  ---

  ### Description
  Verify that the "US HIPAA" block is displayed with the following details:
   Geography: US
   Source: Federal
   Act: Health Insurance Portability and Accountability Act (HIPAA)
   Published/Last Reviewed Date/Year: 2022-10-20 00:00:00+00

  ### Steps
  1. Check whether the URL get loaded (https://eg.surveilr.com/).
  2. Navigate to compliance explorer link.
  3. Wait for page load.
  4. Starting SCF controlmenu Navigation Check.
  5. Capture navigated page title text.
  6. Verify US HIPAA Block title Visibility.
  7. Verify US HIPAA Block Visibility.
  8. Close-browser

  ### Expected Outcome
  -   All information for "US HIPAA" should be displayed accurately.