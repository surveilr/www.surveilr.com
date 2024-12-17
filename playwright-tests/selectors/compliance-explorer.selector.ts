class ComplianceExplorerSelectors {
  public static CELogo =
  "//img[@alt='Compliance Explorer']";
  public static CESelector =
    "//a[@href='/lib/pattern/compliance-explorer']/b";
  public static complianceExplorer =
    "//h1[normalize-space(text())='Compliance Explorer']";
  public static homeScfCrumb = "//nav[@aria-label='breadcrumb']//ol[1]";
  public static homeCrumb = "(//li[@class='breadcrumb-item']//a)[1]";
  public static HIPAA = "//h2[normalize-space(text())='US HIPAA']";
  public static HIPAAData =
    "(//div[@class='card-content remove-bottom-margin']//p)[1]";
    public static ScfControlsFooter1 ="//footer[@id='sqlpage_footer']//a[1]";
    public static ScfControlsFooter2 ="//footer[@id='sqlpage_footer']//a[1]";
    public static ScfFooterlinkNavTextSel1 ="//main[@id='sqlpage_main_wrapper']//h1[1]";
    public static ScfFooterlinkNavTextSel2 ="//main[@id='sqlpage_main_wrapper']//h1[1]";
  public static NIST = "//h2[normalize-space(text())='US HIPAA']";
  public static NISTData =
    "(//div[@class='card-content remove-bottom-margin']//p)[1]";
  public static detailViewHIPAA =
    "(//div[@class='card-content remove-bottom-margin']//a)[1]";

  public static detailViewNIST =
    "(//div[@class='card-content remove-bottom-margin']//a)[2]";
  public static USHIPAAControls =
    "(//main[contains(@class,'page-body container-xl')]//h1)[2]";
  public static NISTControls = "//h1[normalize-space(text())='NIST Controls']";
  public static searchBarSelector = "//input[@placeholder='Search…']";
  public static searchResultsSelector = "//p[contains(.,'FII-SCF-BCD-0008')]";
  public static searchResultsSelectorNIST =
    "//a[normalize-space(text())='FII-SCF-BCD-0011.4']";
  public static titleHeader =
    "(//button[contains(@class,'table-sort sort')])[2]";
  public static titleColnData = "(//td[@class='Title align-middle'])";
  public static controlCodeColnData = "(//td[@class='Title align-middle'])";
  public static controlCodeColnDataLink(id: any) {
    return `(//td[contains(@class,'Control Code')]//a)[${id}]`;
  }
  public static controlCodeColnDataDetail = "//div[@class='card-body ']//h2[1]";
  public static controlCodelink = "//a[text()='FII-SCF-AST-0002']";
  public static controlCodelinkNIST =
    "(//td[contains(@class,'Control Code')]//a)[1]";
  public static HIPAATableTitle(id: any) {
    return `(//button[contains(@class,'table-sort sort')])[${id}]`;
  }
  public static controlQuestion =
    "//p[contains(.,'Control Question: Does the organization')]";
  public static controlDescription =
    "//p[contains(.,'Control Description: Mechanisms exist ')]";

  public static controlId = "//p[contains(.,'Control Id: ')]";

  public static controlDomain =
    "//strong[normalize-space(text())='Control Domain:']";

  public static controlSCF = "//p[contains(.,'SCF Control:')]";

  // Input variable
  public static complianceExplorerText = "Compliance Explorer ";
  public static HipaaData = `
Geography: US
Source: Federal
Health Insurance Portability and Accountability Act (HIPAA)
Version: N/A
Published/Last Reviewed Date/Year: 2022-10-20 00:00:00+00
Detail View
`;
  public static HipaaText = "US HIPAA";
  public static NistData = `
  Geography: US
Source: Federal
Health Insurance Portability and Accountability Act (HIPAA)
Version: N/A
Published/Last Reviewed Date/Year: 2022-10-20 00:00:00+00
Detail View
  `;
  public static NistText = "NIST";
  public static USHIPAACLText = "US HIPAA Controls";
  public static NISTCLText = "NIST Controls";
  public static searchKeyword = "FII-SCF-BCD-0008";
  public static searchKeywordNIST = "FII-SCF-BCD-0011.4";
   public static ScfFooterlinkNavText1 ="lib/pattern/compliance-explorer/ce/index.sql";
   public static ScfFooterlinkNavText2 ="lib/pattern/compliance-explorer/console/sqlpage-files/sqlpage-file.sql";
}
export { ComplianceExplorerSelectors };
