import { Page } from "@playwright/test";
import SQESection from "../sections/sitequality-explorer.section";

export default class SiteQualityPage {
  page: Page;
  sqeSection: SQESection;

  constructor(page: Page) {
    this.page = page;
    this.sqeSection = new SQESection(this.page);
  }
  public async sqeNavigationCheck() {
    return await this.sqeSection.sqeNavigationFnCheck();
  }
  public async SiteQualityExplorerlogoCheck() {
    return await this.sqeSection.SiteQualityExplorerlogoVisibilityCheck();
  }
  public async sqeDashboardLoadingFnCheck() {
    return await this.sqeSection.sqeDashboardLoadingCheck();
  }
  public async egsurveilrsiteNavCheck() {
    return await this.sqeSection.egsurveilrsiteNavigationCheck();
  }
  public async surveilrsiteNavCheck() {
    return await this.sqeSection.surveilrsiteNavigationCheck();
  }
  public async SQEtabnavigationFn() {
    return await this.sqeSection.SQEtabnavigationFnCheck();
  }
  public async sqeFooterLinkNavCheck() {
    return await this.sqeSection.sqeFooterLinkCheck();
  }
  public async UniResourceFooterLinkNavCheck() {
    return await this.sqeSection.UniResourceFooterLinkCheck();
  }
  public async RSSDConsoleFooterLinkNavCheck() {
    return await this.sqeSection.RSSDConsoleFooterLinkCheck();
  }
  public async OrchestrationFooterLinkNavCheck() {
    return await this.sqeSection.OrchestrationFooterLinkCheck();
  }
}
