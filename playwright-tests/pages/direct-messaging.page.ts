import { Page } from "@playwright/test";
import DirectMessagingSection from "../sections/direct-messaging.section";

export default class DirectMessagingPage {
  page: Page;
  directmessagingSection: DirectMessagingSection;

  constructor(page: Page) {
    this.page = page;
    this.directmessagingSection = new DirectMessagingSection(this.page);
  }
  public async dmsNavigationCheck() {
    return await this.directmessagingSection.dmsNavigationFnCheck();
  }
  public async validateDPESpageNavigationCheck() {
    return await this.directmessagingSection.validateDPESpageNavigation();
  }
  public async dmsDashboardLoadingCheck() {
    return await this.directmessagingSection.dmsDashboardLoadingFnCheck();
  }
  public async dpesPageDashboardMenuCheck() {
    return await this.directmessagingSection
      .dpesPageDashboardMenuVisibilityCheck();
  }
  public async ValidateDPESinboxNavigation() {
    return await this.directmessagingSection.dpesInboxNavigationCheck();
  }
  public async ValidateDPESdispatchedNavigation() {
    return await this.directmessagingSection.dpesDispatchedNavigationCheck();
  }
  public async ValidateDPESfailedNavigation() {
    return await this.directmessagingSection.dpesFailedNavigationCheck();
  }
  public async SubjectClmdataLinkNavigation() {
    return await this.directmessagingSection
      .SubjectClmdataLinkNavigationCheck();
  }
  public async attachmentFileNavigationcheck() {
    return await this.directmessagingSection.ValidateAttachmentFileNavigation();
  }
  public async inboxFooterLinkNavigationcheck() {
    return await this.directmessagingSection.ValidateInboxFooterLink();
  }
  public async DPESfailedpageCrumbCheck() {
    return await this.directmessagingSection
      .DPESfailedpageCrumbNavigationCheck();
  }
}
