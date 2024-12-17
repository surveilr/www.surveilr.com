class DirectMessagingSelectors {
  public static DMSselector =
    "//b[normalize-space(text())='lib/pattern/direct-messaging-service/package.sql.ts']";
  public static dpesSubtitle = "(//a[contains(@class,'col text-truncate')])[1]";
  public static dpesText =
    "//h2[normalize-space(text())='Direct Protocol Email System']";
  public static inboxlink = "(//div[@class='col text-truncate'])[1]";
  public static Dispatchedlink =
    "(//a[contains(@class,'col text-truncate')])[2]";
  public static failedLink = "(//div[@class='col text-truncate'])[3]";
  public static homeCrumb = "(//li[@class='breadcrumb-item']//a)[1]";
  public static dpesCrumb = "(//li[@class='breadcrumb-item'])[2]";
  public static inboxText = "//a[normalize-space(text())='Inbox']";
  public static inboxsearch = "//input[@placeholder='Search…']";
  public static inboxCrumb = "//a[normalize-space(text())='inbox']";
  public static FailedCrumb = "(//li[@class='breadcrumb-item']//a)[3]";
  public static DPESCrumb = "(//li[@class='breadcrumb-item']//a)[2]";
  public static HOMECrumb = "(//li[@class='breadcrumb-item']//a)[1]";
  public static inboxFooter =
    "//footer[contains(@class,'w-100 text-center')]//a[1]";
  public static dmsinboxText =
    "//h1[normalize-space(text())='lib/pattern/direct-messaging-service/dms/inbox.sql']";
  public static Dispatchedtext = "//a[normalize-space(text())='Dispatched']";
  public static failedText = "//a[normalize-space(text())='Failed']";
  public static subjectDatacount = "//td[@class='subject align-middle']";
  public static subjectData(id: any) {
    return `(//td[@class='subject align-middle'])[${id}]`;
  }
  public static subjectName = "(//div[@class='datagrid-content ']//span)[3]";
  public static attachmentcount = "//tbody[@class='table-tbody list']//tr";
  public static attachment(id: any) {
    return `(//a[@title='download'])[${id}]`;
  }

  // Input variable
  public static dpesTextcontent = "Direct Protocol Email System";
  public static inboxLinkText = "Inbox";
  public static DispatchedlinkText = "Dispatched";
  public static failedLinkText = "Failed";
  public static dmsinboxlinkText =
    "lib/pattern/direct-messaging-service/dms/inbox.sql";
  public static FailedUrl =
    "https://eg.surveilr.com/lib/pattern/direct-messaging-service/dms/failed.sql";
  public static DPESUrl =
    "https://eg.surveilr.com/lib/pattern/direct-messaging-service/dms/index.sql";
  public static HomeUrl =
    "https://eg.surveilr.com/lib/pattern/direct-messaging-service/index.sql";
}
export { DirectMessagingSelectors };
