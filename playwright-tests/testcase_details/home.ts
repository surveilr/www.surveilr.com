export const testcaseDetails: any = [
  {
    id: "TC-0001",
    run_id: "TR-0001",
    title: "URL Load Validation",
    description:
      "Verify that the page loads for the url : https://eg.surveilr.com/",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-0002",
    run_id: "TR-0002",
    title: "Dashboard Load Validation",
    description: "Verify that the Dashboard loads properly",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-0003",
    run_id: "TR-0003",
    title: "RSSD Logo Visibility",
    description: "Ensure that RSSD logo visible on the left top of the site",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-0004",
    run_id: "TR-0004",
    title: "Title Validation",
    description:
      "Ensure that text -Resource Surveillance State Database (RSSD) visible on the top of the home page",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-0005",
    run_id: "TR-0005",
   title: "Dashboard Menus Check",
   description: "Ensure that all the following tabs are visible on the top of the home page\n1. Home\n2. Docs\n3. Uniform Resource\n4. Console\n5. Orchestration",
    "test_type": ["smoke-high"]
    },
  {
    id: "TC-0006",
    run_id: "TR-0006",
    title: "Home Page Loading",
    description: "Ensure that the Home  tab navigation is proper",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-0007",
    run_id: "TR-0007",
    title: "Docs Page Loading",
    description: "TR-0007",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-0008",
    run_id: "TR-0008",
    description: "TR-0008",
    title: "Uniform Dropdown Validation",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-0009",
    run_id: "TR-0009",
    description: "TR-0009",
    title: "Uniform Resource (IMAP) Navigation",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0010",
    run_id: "TR-0010",
    description: "TR-0010",
    title: "Uniform Resource (File) Navigation",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0011",
    run_id: "TR-0011",
    title: "Uniform Resource Tables & Views Navigation",
    description: "TR-0011",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0012",
    run_id: "TR-0012",
    description: "TR-0012",
    title: "Console Dropdown Validation",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0058",
    run_id: "TR-0058",
    description:
      "Verify that the 'RSSD SQLPage Files' tab link navigations works properly",
    title: "RSSD SQL Page Files Navigation",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0059",
    run_id: "TR-0059",
    description:
      "Verify that the navigations of the link provided in the footer of the page is correct",
    title: "RSSD SQL Page Files footer check",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0060",
    run_id: "TR-0060",
    description:
      "Verify that the 'RSSD Data Tables Content SQLPage Files  ' tab link navigations works properly",
    title: "RSSD Data Tables Content SQLPage Files",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0061",
    run_id: "TR-0061",
    description:
      "Verify that the navigations of the link provided in the footer of the RSSD Data Tables Content SQLPage Files page is correct",
    title: "RSSD Data Tables Content SQLPage Files footer check",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0062",
    run_id: "TR-0062",
    description:
      "Verify that the 'RSSD SQLPage Navigation ' tab link navigations works properly",
    title: "RSSD SQL page Navigation",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  {
    id: "TC-0063",
    run_id: "TR-0063",
    description:
      "Verify that the breadcrumbs on the RSSD SQLPage Navigation Page  navigate correctly.",
    title: "RSSD SQL page breadcrumb links  Navigation check",
    test_type: ["smoke-high", "smoke-low", "regression-high"],
  },
  // Site Quality Explorer
  {
    id: "TC-SQE-0001",
    run_id: "TR-SQE-0001",
    title: "Site Quality Explorer logo  and header visibility check",
    description:
      "Verify that 'Site Quality Explorer' logo and header is visible on the top of the page",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-SQE-0002",
    run_id: "TR-SQE-0002",
    title: "Site Quality Explorer logo  and header visibility check",
    description:
      "Verify there is 4 controls loaded in the page :/n1. Orchestration /n2. Site Quality  /n3. Uniform Resource n/4. RSSD Console",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-SQE-0005",
    run_id: "TR-SQE-0005",
    title: "Website Resources-'eg.surveilr.com site navigation check",
    description:
      "Verify that the navigations of the Website Resources-'eg.surveilr.com is proper",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-SQE-0006",
    run_id: "TR-SQE-0006",
    title: "Website Resources-'surveilr.com site navigation check",
    description:
      "Verify that the navigations of the Website Resources-'surveilr.com is proper",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-SQE-0007",
    run_id: "TR-SQE-0007",
    title: "Website Resources-'surveilr.com site navigation check",
    description:
      "Verify that the navigations of the Website Resources-'surveilr.com is proper",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-SQE-0009",
    run_id: "TR-SQE-0009",
    title: "Orchestration footer navigation check",
    description:
      "Verify that footer links on Orchestration page navigate properly",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-SQE-0010",
    run_id: "TR-SQE-0010",
    title: "Uniform resource footer navigation check",
    description:
      "Verify that footer links on Uniform resource(IMAP) page navigate properly",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-SQE-0011",
    run_id: "TR-SQE-0011",
    title: "RSSD console footer navigation check",
    description:
      "Verify that footer links on RSSD Console page navigate properly",
    tags: "Site Quality Explorer",
    test_type: ["smoke-low"],
  },
  // Compliance Explorer
  {
    id: "TC-CEP-0001",
    run_id: "TR-CEP-0001",
    title: "Compliance explorer logo visibility check",
    description:
      "Verify that Compliance explorer logo is visible on the left top of Direct messaging service page",
    tags: "Compliance Explorer",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0002",
    run_id: "TR-CEP-0002",
    title: "Compliance Explorer Dashboard Load Validation",
    description:
      "Verify there are 4 controls loaded on the page:\n1. SCF Controls\n2. Orchestration\n3. Uniform Resource\n4. RSSD Console",
    tags: "Compliance Explorer",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0003",
    run_id: "TR-CEP-0003",
    title: "SCF Controls menu navigation check",
    tags: "Compliance Explorer",
    description: "Verify that the SCF Controls menu navigation is proper",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0004",
    run_id: "TR-CEP-0004",
    title: "SCF Control page breadcrumb navigation check",
    tags: "Compliance Explorer",
    description:
      "Verify that the breadcrumbs on the SCF Control page navigate correctly.",
    test_type: ["smoke-high"],
  },
   {
    id: "TC-CEP-0005",
    run_id: "TR-CEP-0005",
    title: "SCF Control page footer navigation check",
    tags: "Compliance Explorer",
    description:
      "Verify that the navigations of the link provided in the footer of the SCF control page is correct",
    test_type: ["smoke-low"],
  },
  {
    id: "TC-CEP-0006",
    run_id: "TR-CEP-0006",
    title: "Verify US HIPAA Section Data",
    tags: "Compliance Explorer",
    description:
      'Verify that the "US HIPAA" block is displayed with the following details:\nGeography: US\nSource: Federal\nAct: Health Insurance Portability and Accountability Act (HIPAA)\nPublished/Last Reviewed Date/Year: 2022-10-20 00:00:00+00',
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0007",
    run_id: "TR-CEP-0007",
    title: "Verify NIST Section Data",
    tags: "Compliance Explorer",
    description:
      "Check that the NIST block is displayed with the following details:\nGeography: Universal\nSource: SCF\nAct: Health Insurance Portability and Accountability Act (HIPAA)\nVersion: 2024\nPublished/Last Reviewed Date/Year: 2024-04-01 00:00:00+00",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0008",
    run_id: "TR-CEP-0008",
    title: "US HIPAA Detail View Links navigation check",
    tags: "Compliance Explorer",
    description:
      'Verify that US HIPAA Detail View Links navigate properly and verify that the title "US HIPAA Controls" is visible on the US HIPAA Detail View Links navigation page.',
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0009",
    run_id: "TR-CEP-0009",
    title: "US HIPAA Controls SearchBar check",
    tags: "Compliance Explorer",
    description:
      "Ensure that search bar working properly on US HIPAA Controls page",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0010",
    run_id: "TR-CEP-0010",
    title: "US HIPAA Controls Tables-Title title check",
    tags: "Compliance Explorer",
    description:
      "Ensure that control code, title, domain, control description, requirement are displayed on US HIPAA Controls page as table title",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0011",
    run_id: "TR-CEP-0011",
    title: "US HIPAA Controls Tables-Title sorting check",
    tags: "Compliance Explorer",
    description:
      "Ensure that sorting functionality associated with control code, title, domain, control description, requirement are functioning properly on US HIPAA Controls page",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0012",
    run_id: "TR-CEP-0012",
    title: "Control code links navigation check",
    tags: "Compliance Explorer",
    description:
      "Ensure that while clicking on each control code on US HIPAA Controls page will navigate to Control Details page properly",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0013",
    run_id: "TR-CEP-0013",
    title: "US HIPAA control code Detail Check",
    tags: "Compliance Explorer",
    description:
      "Make sure on US HIPAA Controls page, each control detail page includes the following information:\nControl Question\nControl Description\nControl ID\nControl Domain\nSCF Control",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0014",
    run_id: "TR-CEP-0014",
    title: "NIST Detail View Links navigation check",
    tags: "Compliance Explorer",
    description:
      'Verify that NIST Detail View Links navigate properly and the title "NIST Controls" is visible on the NIST Controls Detail View Links navigation page.',
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0015",
    run_id: "TR-CEP-0015",
    title: "NIST Controls SearchBar check",
    tags: "Compliance Explorer",
    description:
      "Ensure that search bar working properly on NIST Controls page",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0016",
    run_id: "TR-CEP-0016",
    title: "NIST Controls Tables-Title title check",
    tags: "Compliance Explorer",
    description:
      "Ensure that control code, title, domain, control description, requirement are displayed on NIST Controls page",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0017",
    run_id: "TR-CEP-0017",
    title: "NIST Controls Tables-Title sorting check",
    tags: "Compliance Explorer",
    description:
      "Ensure that sorting functionality associated with control code, title, domain, control description, requirement are functioning properly on NIST Controls page",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0018",
    run_id: "TR-CEP-0018",
    title: "NIST Control code links navigation check",
    tags: "Compliance Explorer",
    description:
      "Ensure that while clicking on each control code on NIST Controls page will navigate to Control Details page properly",
    test_type: ["smoke-high"],
  },
  {
    id: "TC-CEP-0019",
    run_id: "TR-CEP-0019",
    title: "NIST control code Detail Check",
    tags: "Compliance Explorer",
    description:
      "Make sure on NIST Controls page, each control detail page includes the following information:\nControl Question\nControl Description\nControl ID\nControl Domain\nSCF Control",
    test_type: ["smoke-high"],
  },
  // direct-messaging Tests
  {
    id: "TC-DMS-0002",
    run_id: "TR-DMS-0002",
    description:
      "Verify there are 4 controls loaded on the page:\n1. Direct Protocol Email System\n2. Orchestration\n3. Uniform Resource\n4. RSSD Console",
    title: "DMS Dashboard Loading Check",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
  {
    id: "TC-DMS-0003",
    run_id: "TR-DMS-0003",
    description:
      "Verify that the 'Direct Protocol Email System'  tab navigation is proper",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    title: "Direct Protocol Email System Navigation Check",
    test_type: ["smoke-high"],
  },
   {
    id: "TC-DMS-0004",
    run_id: "TR-DMS-0004",
    description:
      "Ensure that the 'Direct Protocol Email System' page displays three controls:\n1.Inbox\n2. Dispatched \n3. Failed",
    title: "Direct Protocol Email System Page Dashboard Menu Check",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
  {
    id: "TC-DMS-0005",
    run_id: "TR-DMS-0005",
    description:
      "Verify that the navigations of the link provided in the footer of the page is correct",
    title: "Inbox footer link navigation check",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
  {
    id: "TC-DMS-0006",
    run_id: "TR-DMS-0006",
    description: "Verify that the ' Inbox ' menu  navigation is proper",
    title: "Direct Protocol Email System Page Inbox menu Navigation",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
  {
    id: "TC-DMS-0008",
    run_id: "TR-DMS-0008",
    description:
      "Verify that the all 'SUBJECT' colum data  in Inbox page navigation is proper",
    title: "'SUBJECT' column data in Inbox control link navigation check",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
   {
    id: "TC-DMS-0009",
    run_id: "TR-DMS-0009",
    description:
      "Verify that the navigation of attachements files in the Subject data link page is proper",
    title: "Subject data attachment file navigation check",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
  {
    id: "TC-DMS-0011",
    run_id: "TR-DMS-0011",
    description: "Verify that the ' Dispatched' menu  navigation is proper",
    title: "Direct Protocol Email System Page Dispatched menu Navigation",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
  {
    id: "TC-DMS-0014",
    run_id: "TR-DMS-0014",
    description: "Verify that the ' Failed ' menu  navigation is proper",
    title: "Direct Protocol Email System Page Failed menu Navigation",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
  {
    id: "TC-DMS-0015",
    run_id: "TR-DMS-0015",
    description: "Verify that the breadcrumbs on the Failed  page navigate correctly.",
    title: "Failed page breadcrumb navigation check",
    tags: ["Direct Messaging Services", "Direct Protocol Email System"],
    test_type: ["smoke-high"],
  },
];

export const testTypeToTagMap: { [key: string]: string } = {
  "smoke-high": "@smoke-high",
  "smoke-low": "@smoke-low",
  "regression-high": "@regression-high",
};
