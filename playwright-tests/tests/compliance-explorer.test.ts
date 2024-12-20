import { surveilr } from "../fixture/fixtures";
import { logger } from "../utils/test-utils";
import ComplianceExplorerPage from "../pages/compliance-explorer.page";
import { testcaseDetails, testTypeToTagMap } from "../testcase_details/home";
import { ComplianceExplorerSelectors as cs } from "../selectors/compliance-explorer.selector";

const url = process.env.url;

console.log("Url is ", url);

surveilr.describe("Compliance Explorer section Tests", () => {
  surveilr.beforeEach("Opening URL", async ({ page }, testInfo) => {
    surveilr.setTimeout(240000);

    if (url) {
      await page.goto(url);
      try {
        await page.waitForTimeout(2000);
        await page.waitForSelector(cs.CESelector, { timeout: 10000 });
        await page.click(cs.CESelector);
        await page.waitForTimeout(3000);
        logger.info("Successfully clicked the specified link.");
      } catch (error) {
        throw new Error(`Failed to click the specified link: ${error.message}`);
      }
      const testCase = testcaseDetails.find((tc) =>
        testInfo.title.includes(tc.id)
      );
      if (!testCase) {
        throw new Error(
          `Test case ID not found in testcaseDetails: ${testInfo.title}`,
        );
      }
    }
  });

  testcaseDetails.forEach((testCase) => {
    const testTypes = Array.isArray(testCase.test_type)
      ? testCase.test_type
      : [testCase.test_type];
    const tags = testTypes
      .map((type) => testTypeToTagMap[type] || "")
      .join(" ");

    surveilr(
      `[${testCase.id}] - ${testCase.description}`,
      { tag: tags },
      async ({ page }, testInfo) => {
        surveilr.setTimeout(500000);

        const cp = new ComplianceExplorerPage(page);

        switch (testCase.id) {
          case "TC-CEP-0001":
            await cp.CElogoVisibilityCheck();
            break;

          case "TC-CEP-0003":
            await cp.scfControlsMenuNavigationCheck();
            break;
          case "TC-CEP-0002":
            await cp.ceDashboardLoadingCheck();
            break;
          case "TC-CEP-0003":
            await cp.scfControlsMenuNavigationCheck();
            break;
          case "TC-CEP-0004":
            await cp.scfControlsMenuNavigationCheck();
            await cp.SCFControlpageCrumbCheck();
            break;
          case "TC-CEP-0005":
            await cp.scfControlsMenuNavigationCheck();
            await cp.scfControlsFooterNavigationCheck();
            break;
          case "TC-CEP-0006":
            await cp.scfControlsMenuNavigationCheck();
            await cp.verifyUSHIPAASectionData();
            break;
          case "TC-CEP-0007":
            await cp.scfControlsMenuNavigationCheck();
            await cp.verifyNISTSectionData();
            break;
          case "TC-CEP-0008":
            await cp.scfControlsMenuNavigationCheck();
            await cp.USHIPAADetailViewavigationCheck();
            break;
          case "TC-CEP-0009":
            await cp.scfControlsMenuNavigationCheck();
            await cp.USHIPAAcontrolsSearchBarCheck();
            break;
          case "TC-CEP-0010":
            await cp.scfControlsMenuNavigationCheck();
            await cp.USHIPAAControlsTableTitleVisibilityCheck();
            break;
          case "TC-CEP-0011":
            await cp.scfControlsMenuNavigationCheck();
            await cp.USHIPAAcontrolsTitleSortCheck();
            break;
          case "TC-CEP-0012":
            await cp.scfControlsMenuNavigationCheck();
            await cp.HIPAAcontrolcodeLinksNavigationFnCheck();
            break;
          case "TC-CEP-0013":
            await cp.scfControlsMenuNavigationCheck();
            await cp.USHIPAAcontrolcodeDetailCheck();
            break;
          case "TC-CEP-0014":
            await cp.scfControlsMenuNavigationCheck();
            await cp.NISTDetailViewavigationCheck();
            break;
          case "TC-CEP-0015":
            await cp.scfControlsMenuNavigationCheck();
            await cp.NISTcontrolsSearchBarCheck();
            break;
          case "TC-CEP-0016":
            await cp.scfControlsMenuNavigationCheck();
            await cp.NISTcontrolsTitleSCheck();
            break;
          case "TC-CEP-0017":
            await cp.scfControlsMenuNavigationCheck();
            await cp.NISTcontrolsTitleSortCheck();
            break;
          case "TC-CEP-0018":
            await cp.scfControlsMenuNavigationCheck();
            await cp.NISTcontrolcodeLinksNavigationFnCheck();
            break;
          case "TC-CEP-0019":
            await cp.scfControlsMenuNavigationCheck();
            await cp.NISTcontrolcodeDetailCheck();
            break;
          default:
            logger.warn(`Test case ${testCase.id} not handled`);
            break;
        }
      },
    );
  });

  surveilr.afterEach("Closing Page", async ({ page }) => {
    await page.close();
    logger.info("Closing Page!");
  });
});
