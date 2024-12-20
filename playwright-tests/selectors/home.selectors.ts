class HomeSelectors {
  public static logoImg = "//img[@alt='Direct Messaging Service']";
  public static title = "//a[@class='text-decoration-none text-body']";
  public static HomeTab = "//a[normalize-space(text())='Home']";
  public static tabIcons = "//div[@id='navbar-menu']/ul[1]/li";
  public static docsTab = "//a[normalize-space(text())='Docs']";
  public static uniformresourceTab =
    "(//a[@class='nav-link dropdown-toggle'])[1]";
  public static consoleTab = "(//a[@class='nav-link dropdown-toggle'])[2]";
  public static OrchestrationTab =
    "(//a[@class='nav-link dropdown-toggle'])[3]";
  public static dashboardmenu = "//div[@class='col text-truncate']";
  public static dpesControls = "(//div[@class='col text-truncate'])[1]";
  public static Orchestration = "//div[contains(text(),'Orchestration')]";
  public static uniformresource = "//div[contains(text(),'Uniform Resource')]";
  public static RSSDconsole = "//div[contains(text(),'RSSD Console')]";
  public static URtableandviewtitle =
    '//h1[normalize-space(text())="Uniform Resource Tables and Views"]';
  public static uniformresourceIMAP =
    '//*[@id="navbar-menu"]/ul/li[3]/div/a[2]';
  public static uniformresourcetableandview =
    '//*[@id="navbar-menu"]/ul/li[3]/div/a[3]';
  public static infoschema = '//*[@id="navbar-menu"]/ul/li[4]/div/a[1]';
  public static migrations = '//*[@id="navbar-menu"]/ul/li[4]/div/a[2]';
  public static codenotebooks = '//*[@id="navbar-menu"]/ul/li[4]/div/a[3]';
  public static sqlpagefiles = '//*[@id="navbar-menu"]/ul/li[4]/div/a[4]';
  public static contentsqlpagefiles =
    '//*[@id="navbar-menu"]/ul/li[4]/div/a[5]';
  public static sqlpagenavigations = '//*[@id="navbar-menu"]/ul/li[4]/div/a[6]';
  public static Orchestration_topbar = '//*[@id="navbar-menu"]/ul/li[5]/a';
  public static Orchestrationtablesandviews =
    '//*[@id="navbar-menu"]/ul/li[5]/div/a';
  public static indexsql_link = '//*[@id="sqlpage_footer"]/p/a';
  // public static docs = '//*[@id="navbar-menu"]/ul/li[2]/a';
  public static uniformresource_topbar = '//*[@id="navbar-menu"]/ul/li[3]/a';
  public static uniformresourcefile =
    '//*[@id="navbar-menu"]/ul/li[3]/div/a[1]';

  public static URfiletitle =
    '//h1[normalize-space(text())="Uniform Resources (Files)"]';

  public static mailboxtitle = '//h1[normalize-space(text())="Mailbox"]';
  public static uniformresourcefile1 = "(//a[@class='dropdown-item'])[1]";

  public static uniformresourceIMAP1 = "(//a[@class='dropdown-item'])[2]";
  public static RSSDSQLcrumb = "//nav[@aria-label='breadcrumb']";
  // RSSD Data Tables Content SQLPage Files
  public static RSSDDataTablelink =
    "//div[contains(text(),'Explore auto-generated')]";
  public static RSSDDataTableTitle =
    "//main[@id='sqlpage_main_wrapper']//h1[1]";
  public static RSSDdataTableFooterLink =
    "//a[contains(text(),'console/sqlpage-files/content.sql')]";
  public static RSSDDataTableFootertitle =
    "//nav[@aria-label='breadcrumb']/following-sibling::h1[1]";
  // RSSD SQLPage Files
  public static RSSDSQLPageFileslink =
    "//div[normalize-space(text())='Explore RSSD SQLPage Files which govern the content of the web-UI']";
  // "//div[contains(text(),'Explore RSSD SQLPage Files']";
  public static RSSDSQLPageFilesTitle =
    "//h1[normalize-space(text())='SQLPage pages in sqlpage_files table']";
  public static RSSDSQLPageFilesFooterLink =
    "//footer[@id='sqlpage_footer']//a[1]";
  public static RSSDSQLPageFilesFootertitle =
    "//h1[contains(text(),'console/sqlpage-files/')]";
  // Input Variables

  public static titleTxt = "Direct Messaging Service";
  public static RSSDSQLTitle =
    "SQLPage navigation in sqlpage_aide_navigation table";
  public static RSSDDataTableTitleText =
    "SQLPage pages generated from tables and views";
  public static RRSSDSQLPageFilesTitleText =
    "SQLPage pages in sqlpage_files table";
  public static RSSDDataTableFootertitleTxt =
    "console/sqlpage-files/content.sql";
  public static RSSDSQLPageFilesFootertitleTxt =
    "console/sqlpage-files/index.sql";
  public static expectedUrllink = "http://localhost:9000/";
  public static loginUrl = "http://localhost:9000/index.sql";
  public static expectedUrllink_docs = "http://localhost:9000/docs/";

  public static docs = "//a[normalize-space(text())='Docs']";
  public static Orchestrationsubpagetitlecontent =
    "//div[@class='d-block text-muted text-truncate mt-n1' and normalize-space(text())='Information Schema documentation for orchestrated objects']";
  public static Orchestrationtable_type =
    "//button[normalize-space(text())='Type']";
  public static Orchestrationtable_name =
    "//button[normalize-space(text())='Name']";
  public static Orchestrationtable_namehyperlinkvalue =
    "//a[normalize-space(text())='orchestration_nature']";
  public static Orchestrationtable_namevaluepagecontent_check =
    "//h1[normalize-space(text())='orchestration_nature']";
  public static Orchestrationtable_columncount =
    "//button[normalize-space(text())='Column Count']";

  // Hyperlink selectors for Uniform Resource top bar

  public static ur_uniform_resource_files_sql_link =
    "//a[normalize-space(text())='ur/uniform-resource-files.sql']";
  public static ur_uniform_resource_files_sql_text =
    "//h1[normalize-space(text())='ur/uniform-resource-files.sql']";
  public static ur_uniform_resource_files_sql_path =
    "//a[normalize-space(text())='ur/uniform-resource-files.sql Path']";

  // Common breadcrumbs and their content check
  public static SQLPagefiles_breadcrump =
    "(//li[@class='breadcrumb-item']//a)[3]";
  public static SQLPagefiles_content_check =
    "//h1[normalize-space(text())='SQLPage pages in sqlpage_files table']";
  public static console_breadcrump = "(//li[@class='breadcrumb-item']//a)[2]";
  public static console_content_check =
    "//h2[normalize-space(text())='Resource Surveillance State Database (RSSD) Console']";
  public static Home_breadcrump = "(//li[@class='breadcrumb-item']//a)[1]";
  public static home_content_check =
    "//p[normalize-space(text())='Resource Surveillance Web UI (v0.29.0) ']";

  public static ur_uniform_resource_imap_account_sql_link =
    "//a[normalize-space(text())='ur/uniform-resource-imap-account.sql']";
  public static ur_uniform_resource_imap_account_sql_text =
    "//h1[normalize-space(text())='ur/uniform-resource-imap-account.sql']";
  public static ur_uniform_resource_imap_account_sql_path =
    "//a[normalize-space(text())='ur/uniform-resource-imap-account.sql Path']";

  public static ur_info_schema_sql_link =
    "//a[normalize-space(text())='ur/info-schema.sql']";
  public static ur_info_schema_sql_path =
    "//a[normalize-space(text())='ur/info-schema.sql Path']";
  public static ur_info_schema_sql_text =
    "//h1[normalize-space(text())='ur/info-schema.sql']";

  public static uniformresourcesubfilemenu =
    "//div[normalize-space(text())='Files ingested into the `uniform_resource` table']";
  public static uniformresourcepagetab =
    "//div[normalize-space(text())='Explore ingested resources']";

  public static uniformresource_title =
    "//h2[normalize-space(text())='Uniform Resource']";
  public static uniformresourcefile_title =
    "//h1[normalize-space(text())='Uniform Resources (Files)']";
  public static uniformresourceTandV_title =
    "//h1[normalize-space(text())='Uniform Resource Tables and Views']";
  public static uniformresourcesubpagetitlecontent =
    "//div[normalize-space(text())='Files ingested into the `uniform_resource` table']";
  public static uniformresourcesubpagetitlecontent1 =
    "//div[normalize-space(text())='Easily access and view your emails with our Uniform Resource (IMAP) system. Ingested from various mail sources, this feature organizes and displays your messages directly in the Web UI, ensuring all your communications are available in one convenient place.']";
  public static uniformresourcesubpagetitlecontent2 =
    "//div[normalize-space(text())='Information Schema documentation for ingested Uniform Resource database objects']";

  public static RSSDconsolesubpagetitlecontent =
    "//div[@class='d-block text-muted text-truncate mt-n1' and normalize-space(text())='Explore RSSD tables, columns, views, and other information schema documentation']";
  public static RSSDconsolesubpagetitlecontent1 =
    "//div[@class='d-block text-muted text-truncate mt-n1' and normalize-space(text())='Explore RSSD Migrations to determine what was executed and not']";
  public static RSSDconsolesubpagetitlecontent2 =
    "//div[@class='d-block text-muted text-truncate mt-n1' and normalize-space(text())='Explore RSSD Code Notebooks which contain reusable SQL and other code blocks']";
  public static RSSDconsolesubpagetitlecontent3 =
    "//div[@class='d-block text-muted text-truncate mt-n1' and normalize-space(text())='Explore RSSD SQLPage Files which govern the content of the web-UI']";
  public static RSSDconsolesubpagetitlecontent4 =
    "//div[@class='d-block text-muted text-truncate mt-n1' and normalize-space(text())='Explore auto-generated RSSD SQLPage Files which display content within tables']";
  public static RSSDconsolesubpagetitlecontent5 =
    "//div[@class='d-block text-muted text-truncate mt-n1' and normalize-space(text())='See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table']";

  // Common selector
  public static console_sqlpage_files_sqlpage_file_link =
    "//a[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";
  public static onsole_sqlpage_files_sqlpage_file_title =
    "//h1[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";
  public static console_sqlpage_files_sqlpage_file_sql_Path_breadcrump =
    "//a[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql Path']";

  // RSSD Information schema column (Table)
  public static RSSDinfoschema_column_value_assurance_schema_link =
    "//a[normalize-space(text())='assurance_schema']";
  public static RSSDinfoschema_column_value_assurance_schema_title =
    "//h1[normalize-space(text())='assurance_schema']";

  // RSSD Information schema column (views)
  public static RSSDinfoschema_views_column_value_link =
    "//a[normalize-space(text())='code_notebook_cell_latest']";
  public static RSSDinfoschema_views_column_value_title =
    "//h1[normalize-space(text())='code_notebook_cell_latest']";

  // RSSD Information schema Footer link and breadcrumbs
  public static Info_Schema_breadcrump =
    "(//li[@class='breadcrumb-item']//a)[3]";
  public static console_info_schema_link =
    "//a[normalize-space(text())='console/info-schema/']";
  public static console_info_schema_title =
    "//h1[normalize-space(text())='console/info-schema/']";
  public static console_sqlpage_files_sqlpage_file_sql_link =
    "//a[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";
  public static console_sqlpage_files_sqlpage_file_sql_title =
    "//h1[normalize-space(text())='console/sqlpage-files/sqlpage-file.sql']";

  // RSSD Lifecycle(Migration) footer links
  public static console_migrations_link =
    "//a[normalize-space(text())='console/migrations/']";
  public static console_migrations_link_title =
    "//h1[normalize-space(text())='console/migrations/']/migrations/";

  // RSSD CodeNotebooks footer links
  public static console_notebooks_link =
    "//a[normalize-space(text())='console/notebooks/']";
  public static console_notebooks_link_title =
    "//h1[normalize-space(text())='console/notebooks/']";

  // RSSD SQLPage Files footer

  // RSSD SQLPage Navigation
  public static RSSDSQLNavigation = "//div[contains(text(),'See all')]";

  public static RSSDSqlTitle =
    "//h1[contains(text(),'SQLPage navigation in sqlpage_aide_navigation tabl')]";
}
export { HomeSelectors };
