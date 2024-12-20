import { Page } from "@playwright/test";
import HomeSection from "../sections/home.section";

export default class HomePage {
  page: Page;
  homeSection: HomeSection;

  constructor(page: Page) {
    this.page = page;
    this.homeSection = new HomeSection(this.page);
  }
  public async urlLoadingFnCheck() {
    return await this.homeSection.urlLoadingCheck();
  }
  public async RSSDlogoVisibilityCheck() {
    return await this.homeSection.RSSDlogovisibility();
  }
  public async PageTitleValidationCheck() {
    return await this.homeSection.PageTitleVisibilityCheck();
  }
  public async dashboardLoadingFnCheck() {
    return await this.homeSection.dashboardLoadingCheck();
  }
  public async dashboardMenuFnCheck() {
    return await this.homeSection.dashboardMenuCheck();
  }

  public async validateUniformDropdown() {
    return await this.homeSection.validateUniformDropdownfn();
  }
  public async validateconsoleDropdown() {
    return await this.homeSection.validateConsoleDropdownfn();
  }

  public async validateOrchestrationDropdown() {
    return await this.homeSection.validateOrchestrationDropdownfn();
  }

  public async validateUniformIMAPNavigation() {
    return await this.homeSection.validateUniformIMAPNavigationFn();
  }

  public async validateUniformfilePNavigation() {
    return await this.homeSection.validateUniformFileNavigationFn();
  }

  public async validateUniformtableandviewNavigation() {
    return await this.homeSection.validateUniformtableandviewNavigationFn();
  }

  public async validateHomepageNavigation() {
    return await this.homeSection.validateHomepageNavigationfn();
  }
  public async RSSDSQLPageNavigation() {
    return await this.homeSection.RSSDSQLPageNavigationCheck();
  }
  public async RSSDSQLCrumbNavigation() {
    return await this.homeSection.RSSDSQLCrumbNavigationCheck();
  }
  public async RSSDDataTablesNavigation() {
    return await this.homeSection.RSSDDataTablesNavigationCheck();
  }
  public async RSSDDataTablesContentSQLPageFilesfootercheck() {
    return await this.homeSection.RSSDDataTablesContentSQLPagefootercheck();
  }
  public async RSSDSQLPageFilesNavigation() {
    return await this.homeSection.RSSDSQLPageFilesNavigationCheck();
  }
  public async RSSDSQLPageFilesfootercheck() {
    return await this.homeSection.RSSDSQLPageFilesFooterNavigationcheck();
  }
  public async validateDocspageNavigation() {
    return await this.homeSection.validateDocspageNavigationfn();
  }
}
