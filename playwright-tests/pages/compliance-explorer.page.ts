import { Page } from "@playwright/test";
import ComplianceExplorerSection from "../sections/compliance-explorer.section";

export default class ComplianceExplorerPage {
  page: Page;
  complianceexplorersection: ComplianceExplorerSection;

  constructor(page: Page) {
    this.page = page;
    this.complianceexplorersection = new ComplianceExplorerSection(this.page);
  }
  public async CElogoVisibilityCheck() {
    return await this.complianceexplorersection.CElogovisibility();
  }
  public async ceDashboardLoadingCheck() {
    return await this.complianceexplorersection.ceDashboardLoadingFnCheck();
  }
  public async scfControlsMenuNavigationCheck() {
    return await this.complianceexplorersection.scfControlsMenuNavigation();
  }
  public async SCFControlpageCrumbCheck() {
    return await this.complianceexplorersection.SCFControlCrumbCheck();
  }
  public async verifyUSHIPAASectionData() {
    return await this.complianceexplorersection.verifyUSHIPAASection();
  }
  public async verifyNISTSectionData() {
    return await this.complianceexplorersection.verifyNISTSection();
  }
  public async USHIPAADetailViewavigationCheck() {
    return await this.complianceexplorersection.USHIPAADetailViewCheck();
  }
  public async NISTDetailViewavigationCheck() {
    return await this.complianceexplorersection.NISTDetailViewCheck();
  }
  public async USHIPAAcontrolsSearchBarCheck() {
    return await this.complianceexplorersection.HIPAAcontrolsSearchBarFnCheck();
  }
  public async NISTcontrolsSearchBarCheck() {
    return await this.complianceexplorersection.NISTcontrolsSearchBarFnCheck();
  }
  public async USHIPAAcontrolsTitleSortCheck() {
    return await this.complianceexplorersection
      .USHIPAAcontrolsTitleSortFnCheck();
  }
  public async NISTcontrolsTitleSortCheck() {
    return await this.complianceexplorersection.NISTcontrolsTitleSortFnCheck();
  }
  public async USHIPAAcontrolsTitleSCheck() {
    return await this.complianceexplorersection
      .USHIPAAcontrolsTitleSortFnCheck();
  }
  public async USHIPAAcontrolcodeDetailCheck() {
    return await this.complianceexplorersection.HIPAAcontrolcodeDetailsCheck();
  }
  public async NISTcontrolcodeDetailCheck() {
    return await this.complianceexplorersection.NISTcontrolDetailsCheck();
  }
  public async NISTcontrolsTitleSCheck() {
    return await this.complianceexplorersection.NISTcontrolsTableTitleCheck();
  }
  public async USHIPAAControlsTableTitleVisibilityCheck() {
    return await this.complianceexplorersection
      .USHIPAAControlsTableTitleCheck();
  }
  public async HIPAAcontrolcodeLinksNavigationFnCheck() {
    return await this.complianceexplorersection
      .HIPAAcontrolcodeLinksNavigationCheck();
  }
  public async NISTcontrolcodeLinksNavigationFnCheck() {
    return await this.complianceexplorersection
      .NISTcontrolcodeLinksNavigationCheck();
  }
  public async scfControlsFooterNavigationCheck() {
    return await this.complianceexplorersection
      .scfControlsFooterNavigationFnCheck();
  }
}
