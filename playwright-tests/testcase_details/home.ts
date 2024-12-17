export const testcaseDetails: any = [
  
    {
      id: "TC-0001",
      run_id: "TR-0001",
      title: "URL Load Validation",
      description: "Verify that the page loads for the URL: https://eg.surveilr.com/",
     result: "The page at https://eg.surveilr.com/ should load successfully without errors.",
      tags: "Home page",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-0002",
      run_id: "TR-0002",
      title: "Dashboard Load Validation",
      description: "Verify that the Dashboard loads properly.",
     result: "The Dashboard should load, displaying relevant widgets and information without any layout issues.",
     tags: "Home page",
     test_type: ["smoke-high"]
    },
    {
      id: "TC-0003",
      run_id: "TR-0003",
      title: "RSSD Logo Visibility",
      description: "Ensure that the RSSD logo is visible on the top left of the site.",
     result: "The RSSD logo should be clearly visible on the top left corner of the site.",
     tags: "Home page",
     test_type: ["smoke-low"]
    },
    {
      id: "TC-0004",
      run_id: "TR-0004",
      title: "Title Validation",
      description: "Ensure that the text 'Resource Surveillance State Database (RSSD)' is visible at the top of the homepage.",
     result: "The text 'Resource Surveillance State Database (RSSD)' should be clearly visible at the top of the homepage.",
     tags: "Home page",
     test_type: ["smoke-low"]
    },
    {
      id: "TC-0005",
      run_id: "TR-0005",
      title: "Dashboard Menus Check",
      description: "Ensure that all the following tabs are visible on the top of the homepage: Home, Docs, Uniform Resource, Console, Orchestration.",
     result: "All the tabs (Home, Docs, Uniform Resource, Console, Orchestration) should be visible on the top of the homepage.",
     tags: "Home page",
     test_type: ["smoke-high"]
    },
    {
      id: "TC-0006",
      run_id: "TR-0006",
      title: "Home Page Loading",
      description: "Ensure that the Home tab navigation is proper.",
     result: "The user should be navigated to the homepage.",
     tags: "Home page",
     test_type: ["smoke-high"]
    },
    {
      id: "TC-0007",
      run_id: "TR-0007",
      title: "Docs Page Loading",
      description: "Ensure that the Docs tab navigation is proper.",
     result: "The user should be navigated to the documentation page.",
     tags: "Home page",
     test_type: ["smoke-high"]
    },
    {
      id: "TC-0008",
      run_id: "TR-0008",
      title: "Uniform Dropdown Validation",
      description: "Ensure that the Uniform Resource dropdown shows the following options correctly: Uniform Resources (IMAP), Uniform Resources (Files), Uniform Resource Tables and Views.",
     result: "The dropdown should display the options: Uniform Resources (IMAP), Uniform Resources (Files), Uniform Resource Tables and Views.",
     tags: "Home page",
     test_type: ["smoke-high"]
    },
    {
      id: "TC-0009",
      run_id: "TR-0009",
      title: "Uniform Resource (IMAP) Navigation",
      description: "Ensure that navigation for Uniform Resource (IMAP) works properly.",
     result: "The user should be navigated to the Uniform Resource (IMAP) page.",
     tags: "Home page",
     test_type: ["smoke-high", "smoke-low", "regression-high"]
    },
    {
      id: "TC-0010",
      run_id: "TR-0010",
      title: "Uniform Resource (File) Navigation",
      description: "Ensure that navigation for Uniform Resource (File) works properly.",
     result: "The user should be navigated to the Uniform Resource (File) page.",
     tags: "Home page",
     test_type: ["smoke-high", "smoke-low", "regression-high"]
    },
    {
      id: "TC-0011",
      run_id: "TR-0011",
      title: "Uniform Resource Tables & Views Navigation",
      description: "Ensure that navigation for Uniform Resource Tables & Views works properly.",
     result: "The user should be navigated to the Uniform Resource Tables & Views page.",
     tags: "Home page",
     test_type: ["smoke-high", "smoke-low", "regression-high"]
    },
    {
      id: "TC-0012",
      run_id: "TR-0012",
      title: "Console Dropdown Validation",
      description: "Ensure that the Console dropdown displays options correctly.",
     result: "The dropdown should display the correct options as per the requirement.",
     tags: "Home page",
     test_type: ["smoke-high", "smoke-low", "regression-high"]
    },
    {
      id: "TC-0058",
      run_id: "TR-0058",
      title: "RSSD SQL Page Files Navigation",
      description: "Verify that the 'RSSD SQLPage Files' tab link navigation works properly.",
     result: "The user should be navigated to the correct page when clicking the 'RSSD SQLPage Files' tab link.",
     tags: "Home page",
     test_type: ["smoke-high", "smoke-low", "regression-high"]
    },
    {
      id: "TC-0059",
      run_id: "TR-0059",
      title: "RSSD SQL Page Files Footer Check",
      description: "Verify that the navigation of the links provided in the footer of the RSSD SQL Page Files is correct.",
     result: "The footer links should navigate to the correct pages.",
     tags: "Home page",
     test_type: [ "smoke-low"]
    },
    {
      id: "TC-0060",
      run_id: "TR-0060",
      title: "RSSD Data Tables Content SQLPage Files",
      description: "Verify that the 'RSSD Data Tables Content SQLPage Files' tab link navigation works properly.",
     result: "The user should be navigated to the correct page when clicking the 'RSSD Data Tables Content SQLPage Files' tab link.",
     tags: "Home page",
     test_type: ["smoke-high"]
    },
    {
      id: "TC-0061",
      run_id: "TR-0061",
      title: "RSSD Data Tables Content SQLPage Files Footer Check",
      description: "Verify that the navigation of the links provided in the footer of the RSSD Data Tables Content SQLPage Files page is correct.",
     result: "The footer links should navigate to the correct pages.",
     tags: "Home page",
     test_type: [ "smoke-low"]
    },
    {
      id: "TC-0062",
      run_id: "TR-0062",
      title: "RSSD SQL Page Navigation",
      description: "Verify that the 'RSSD SQLPage Navigation' tab link navigation works properly.",
     result: "The user should be navigated to the correct page when clicking the 'RSSD SQLPage Navigation' tab link.",
     tags: "Home page",
     test_type: ["smoke-high"]
    },
    {
      id: "TC-0063",
      run_id: "TR-0063",
      title: "RSSD SQL Page Breadcrumb Links Navigation Check",
      description: "Verify that the breadcrumbs on the RSSD SQLPage Navigation Page navigate correctly.",
     result: "The breadcrumbs should navigate to the correct pages.",
     tags: "Home page",
     test_type: [ "smoke-low"]
    },
  
   // Site Quality Explorer
   
    {
      id: "TC-SQE-0001",
      run_id: "TR-SQE-0001",
      title: "Site Quality Explorer Logo and Header Visibility Check",
      description: "Verify that 'Site Quality Explorer' logo and header is visible on the top of the page.",
     result: "The 'Site Quality Explorer' logo and header should be clearly visible at the top of the page.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    {
      id: "TC-SQE-0002",
      run_id: "TR-SQE-0002",
      title: "Site Quality Explorer Page Controls Validation",
      description: "Verify there are 4 controls loaded on the page: 1. Orchestration, 2. Site Quality, 3. Uniform Resource, 4. RSSD Console.",
     result: "All 4 controls (Orchestration, Site Quality, Uniform Resource, RSSD Console) should be visible and loaded properly.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    {
      id: "TC-SQE-0005",
      run_id: "TR-SQE-0005",
      title: "Website Resources Navigation Check (eg.surveilr.com)",
      description: "Verify that the navigation of the Website Resources - 'eg.surveilr.com' is proper.",
     result: "The 'eg.surveilr.com' site navigation should work correctly and navigate to the expected pages.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    {
      id: "TC-SQE-0006",
      run_id: "TR-SQE-0006",
      title: "Website Resources Navigation Check (surveilr.com)",
      description: "Verify that the navigation of the Website Resources - 'surveilr.com' is proper.",
     result: "The 'surveilr.com' site navigation should work correctly and navigate to the expected pages.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    {
      id: "TC-SQE-0007",
      run_id: "TR-SQE-0007",
      title: "Website Resources Navigation Check (surveilr.com)",
      description: "Verify that the navigation of the Website Resources - 'surveilr.com' is proper.",
     result: "The 'surveilr.com' site navigation should work correctly and navigate to the expected pages.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    {
      id: "TC-SQE-0009",
      run_id: "TR-SQE-0009",
      title: "Orchestration Footer Navigation Check",
      description: "Verify that footer links on the Orchestration page navigate properly.",
     result: "All footer links on the Orchestration page should navigate to the correct destinations.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    {
      id: "TC-SQE-0010",
      run_id: "TR-SQE-0010",
      title: "Uniform Resource Footer Navigation Check",
      description: "Verify that footer links on the Uniform Resource (IMAP) page navigate properly.",
     result: "All footer links on the Uniform Resource (IMAP) page should navigate to the correct destinations.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    {
      id: "TC-SQE-0011",
      run_id: "TR-SQE-0011",
      title: "RSSD Console Footer Navigation Check",
      description: "Verify that footer links on the RSSD Console page navigate properly.",
     result: "All footer links on the RSSD Console page should navigate to the correct destinations.",
      tags: "Site Quality Explorer",
      test_type: ["smoke-low"]
    },
    // compliance explorer
    {
      id: "TC-CEP-0001",
      run_id: "TR-CEP-0001",
      title: "Compliance Explorer Logo Visibility Check",
      description: "Verify that the Compliance Explorer logo is visible on the top left of the Direct Messaging Service page.",
     result: "The Compliance Explorer logo should be clearly visible on the top left of the Direct Messaging Service page.",
      tags: "Compliance Explorer",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0002",
      run_id: "TR-CEP-0002",
      title: "Compliance Explorer Dashboard Controls Validation",
      description: "Verify there are 4 controls loaded on the page: 1. SCF Controls, 2. Orchestration, 3. Uniform Resource, 4. RSSD Console.",
     result: "All 4 controls (SCF Controls, Orchestration, Uniform Resource, RSSD Console) should be visible and loaded properly.",
      tags: "Compliance Explorer",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0003",
      run_id: "TR-CEP-0003",
      title: "SCF Controls Menu Navigation Check",
      description: "Verify that the SCF Controls menu navigation is proper.",
     result: "The SCF Controls menu should navigate to the correct pages without errors.",
      tags: "Compliance Explorer",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0004",
      run_id: "TR-CEP-0004",
      title: "SCF Control Page Breadcrumb Navigation Check",
      description: "Verify that the breadcrumbs on the SCF Control page navigate correctly.",
     result: "The breadcrumbs on the SCF Control page should navigate to the correct pages.",
      tags: "Compliance Explorer",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0005",
      run_id: "TR-CEP-0005",
      title: "SCF Control Page Footer Navigation Check",
      description: "Verify that the navigation of the links provided in the footer of the SCF Control page is correct.",
     result: "All footer links on the SCF Control page should navigate to the correct destinations.",
      tags: "Compliance Explorer",
      test_type: ["smoke-low"]
    },
  
  
    {
      id: "TC-CEP-0006",
      run_id: "TR-CEP-0006",
      title: "Verify US HIPAA Section Data",
      tags: "Compliance Explorer",
      description: "Verify that the 'US HIPAA' block is displayed with the following details:\nGeography: US\nSource: Federal\nAct: Health Insurance Portability and Accountability Act (HIPAA)\nPublished/Last Reviewed Date/Year: 2022-10-20 00:00:00+00",
     result: "US HIPAA block displayed with correct details including geography, source, act, and published date.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0007",
      run_id: "TR-CEP-0007",
      title: "Verify NIST Section Data",
      tags: "Compliance Explorer",
      description: "Check that the NIST block is displayed with the following details:\nGeography: Universal\nSource: SCF\nAct: Health Insurance Portability and Accountability Act (HIPAA)\nVersion: 2024\nPublished/Last Reviewed Date/Year: 2024-04-01 00:00:00+00",
     result: "NIST block displayed with correct geography, source, act, version, and published date.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0008",
      run_id: "TR-CEP-0008",
      title: "US HIPAA Detail View Links navigation check",
      tags: "Compliance Explorer",
      description: "Verify that US HIPAA Detail View Links navigate properly and verify that the title 'US HIPAA Controls' is visible on the US HIPAA Detail View Links navigation page.",
     result: "US HIPAA Detail View Links navigate correctly, and title 'US HIPAA Controls' is visible.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0009",
      run_id: "TR-CEP-0009",
      title: "US HIPAA Controls SearchBar check",
      tags: "Compliance Explorer",
      description: "Ensure that search bar working properly on US HIPAA Controls page",
     result: "Search bar functions correctly on US HIPAA Controls page.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0010",
      run_id: "TR-CEP-0010",
      title: "US HIPAA Controls Tables-Title title check",
      tags: "Compliance Explorer",
      description: "Ensure that control code, title, domain, control description, requirement are displayed on US HIPAA Controls page as table title",
     result: "Table titles (control code, title, domain, description, requirement) are displayed correctly.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0011",
      run_id: "TR-CEP-0011",
      title: "US HIPAA Controls Tables-Title sorting check",
      tags: "Compliance Explorer",
      description: "Ensure that sorting functionality associated with control code, title, domain, control description, requirement are functioning properly on US HIPAA Controls page",
     result: "Sorting functionality works as expected for control code, title, domain, description, and requirement.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0012",
      run_id: "TR-CEP-0012",
      title: "Control code links navigation check",
      tags: "Compliance Explorer",
      description: "Ensure that while clicking on each control code on US HIPAA Controls page will navigate to Control Details page properly",
     result: "Control codes navigate to the correct detail pages.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0013",
      run_id: "TR-CEP-0013",
      title: "US HIPAA control code Detail Check",
      tags: "Compliance Explorer",
      description: "Make sure on US HIPAA Controls page, each control detail page includes the following information:\nControl Question\nControl Description\nControl ID\nControl Domain\nSCF Control",
     result: "Each control detail page includes all expected information (question, description, ID, domain, SCF Control).",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0014",
      run_id: "TR-CEP-0014",
      title: "NIST Detail View Links navigation check",
      tags: "Compliance Explorer",
      description: "Verify that NIST Detail View Links navigate properly and the title 'NIST Controls' is visible on the NIST Controls Detail View Links navigation page.",
     result: "NIST Detail View Links navigate correctly, and title 'NIST Controls' is visible.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0015",
      run_id: "TR-CEP-0015",
      title: "NIST Controls SearchBar check",
      tags: ["Compliance Explorer"],
      description: "Ensure that search bar working properly on NIST Controls page",
     result: "Expected Result: Search bar should filter results as per the entered query.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0016",
      run_id: "TR-CEP-0016",
      title: "NIST Controls Tables-Title title check",
      tags: ["Compliance Explorer"],
      description: "Ensure that control code, title, domain, control description, requirement are displayed on NIST Controls page",
     result: "Expected Result: All specified columns should display accurate data.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0017",
      run_id: "TR-CEP-0017",
      title: "NIST Controls Tables-Title sorting check",
      tags: ["Compliance Explorer"],
      description: "Ensure that sorting functionality associated with control code, title, domain, control description, requirement are functioning properly on NIST Controls page",
     result: "Expected Result: Sorting should work correctly for all specified columns.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0018",
      run_id: "TR-CEP-0018",
      title: "NIST Control code links navigation check",
      tags: ["Compliance Explorer"],
      description: "Ensure that while clicking on each control code on NIST Controls page will navigate to Control Details page properly",
     result: "Expected Result: Clicking on control codes should navigate to corresponding detail pages.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-CEP-0019",
      run_id: "TR-CEP-0019",
      title: "NIST control code Detail Check",
      tags: ["Compliance Explorer"],
      description: "Make sure on NIST Controls page, each control detail page includes the following information:\nControl Question\nControl Description\nControl ID\nControl Domain\nSCF Control",
     result: "Expected Result: All specified details should be present on each control detail page.",
      test_type: ["smoke-high"]
    },
    // Direct messaging service
    {
      id: "TC-DMS-0002",
      run_id: "TR-DMS-0002",
      title: "DMS Dashboard Loading Check",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify there are 4 controls loaded on the page:\n1. Direct Protocol Email System\n2. Orchestration\n3. Uniform Resource\n4. RSSD Console",
     result: "Expected Result: All 4 controls should be visible and properly loaded on the page.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0003",
      run_id: "TR-DMS-0003",
      title: "Direct Protocol Email System Navigation Check",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the 'Direct Protocol Email System' tab navigation is proper",
     result: "Expected Result: Navigation to 'Direct Protocol Email System' tab should work as intended.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0004",
      run_id: "TR-DMS-0004",
      title: "Direct Protocol Email System Page Dashboard Menu Check",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Ensure that the 'Direct Protocol Email System' page displays three controls:\n1.Inbox\n2. Dispatched \n3. Failed",
     result: "Expected Result: Inbox, Dispatched, and Failed controls should be displayed on the dashboard.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0005",
      run_id: "TR-DMS-0005",
      title: "Inbox footer link navigation check",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the navigations of the link provided in the footer of the page is correct",
     result: "Expected Result: Footer links should navigate to correct destinations.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0006",
      run_id: "TR-DMS-0006",
      title: "Direct Protocol Email System Page Inbox menu Navigation",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the ' Inbox ' menu navigation is proper",
     result: "Expected Result: Inbox menu navigation should work correctly.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0008",
      run_id: "TR-DMS-0008",
      title: "'SUBJECT' column data in Inbox control link navigation check",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the all 'SUBJECT' column data in Inbox page navigation is proper",
     result: "Expected Result: All SUBJECT column data links should navigate to corresponding pages.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0009",
      run_id: "TR-DMS-0009",
      title: "Subject data attachment file navigation check",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the navigation of attachments files in the Subject data link page is proper",
     result: "Expected Result: Attachment file links should navigate correctly.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0011",
      run_id: "TR-DMS-0011",
      title: "Direct Protocol Email System Page Dispatched menu Navigation",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the ' Dispatched' menu navigation is proper",
     result: "Expected Result: Dispatched menu navigation should work correctly.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0014",
      run_id: "TR-DMS-0014",
      title: "Direct Protocol Email System Page Failed menu Navigation",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the ' Failed ' menu navigation is proper",
     result: "Expected Result: Failed menu navigation should work correctly.",
      test_type: ["smoke-high"]
    },
    {
      id: "TC-DMS-0015",
      run_id: "TR-DMS-0015",
      title: "Failed page breadcrumb navigation check",
      tags: ["Direct Messaging Services", "Direct Protocol Email System"],
      description: "Verify that the breadcrumbs on the Failed page navigate correctly.",
     result: "Expected Result: Breadcrumbs should navigate to the correct pages.",
      test_type: ["smoke-high"]
    }
 ];

export const testTypeToTagMap: { [key: string]: string } = {
  "smoke-high": "@smoke-high",
  "smoke-low": "@smoke-low",
  "regression-high": "@regression-high",
};
