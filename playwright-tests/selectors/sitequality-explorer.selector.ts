class SQESelectors {
  public static sqeNavigationLink =
    "//b[normalize-space(text())='lib/pattern/site-quality-explorer/package.sql.ts']";
  public static sqeHeader =
    '//a[@class="text-decoration-none text-body" and @href="index.sql" and text()="Site Quality Explorer"]';
  public static sqeLogoImg = "//img[@alt='Site Quality Explorer']";
  public static siteQuality = "(//div[@class='row align-items-center']//a)[2]";
  public static siteQualitytab = "(//div[@class='col text-truncate'])[2]";
  public static sitequality_brdcrmb =
    "//a[normalize-space(text())='Site Quality']";
  public static sitequality_title =
    "//a[normalize-space(text())='Site Quality']";
  public static egsurvilerLink = "(//div[@class='card-body ']//h2)[1]";
  public static survilerLink = "//h2[normalize-space(text())='surveilr.com']";
  public static Footer = "//footer[@id='sqlpage_footer']//a[1]";
  public static sqeFooterlinkNavTextSel1 = "//h1[normalize-space(text())='sq/index.sql']";
  public static sqeFooterlinkNavTextSel2 = "//h1[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";
  public static uniResourceFootNavTextSel1 = "//h1[normalize-space(text())='ur/index.sql']";
  public static uniResourceFootNavTextSel2 = "//h1[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";
  public static RSSDConsoleFootNavTextSel1 = "//main[@id='sqlpage_main_wrapper']//h1[1]";
  public static RSSDConsoleFootNavTextSel2 = "//h1[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";
  public static OrchestrationFootNavTextSel1 = "//h1[normalize-space(text())='orchestration/index.sql']";
  public static OrchestrationFootNavTextSel2 = "//h1[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";
  // Input variable
  public static sqePageHeaderTxt = "Site Quality Explorer";
  public static egsurvilerLinkUrl =
    "https://eg.surveilr.com/lib/pattern/site-quality-explorer/sq/missing-meta-information.sql?hostname=eg.surveilr.com";
  public static survilerLinkUrl =
    "https://eg.surveilr.com/lib/pattern/site-quality-explorer/sq/missing-meta-information.sql?hostname=surveilr.com";
    public static sqeFooterlinkNavText1 = "sq/index.sql";
    public static sqeFooterlinkNavText2 = "console/sqlpage-files/sqlpage-file.sql";
    public static uniResourceFooterlinkNavText1 = "ur/index.sql";
    public static uniResourceFooterlinkNavText2= "console/sqlpage-files/sqlpage-file.sql";
    public static RSSDConsoleFootNavText1 = "console/index.sql";
    public static RSSDConsoleFootNavText2 = "console/sqlpage-files/sqlpage-file.sql";
    public static OrchestrationFootNavText1 = "orchestration/index.sql";
    public static OrchestrationFootNavText2 = "console/sqlpage-files/sqlpage-file.sql";
  }
export { SQESelectors };
