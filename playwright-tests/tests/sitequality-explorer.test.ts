import { surveilr } from "../fixture/fixtures";
import { logger } from "../utils/test-utils";
import { testcaseDetails, testTypeToTagMap } from "../testcase_details/home";
import SiteQualityPage from "../pages/sitequality-explorer.page";
const url = process.env.url;
console.log("Url is ", url);

surveilr.describe("Home Tests", () => {
  surveilr.beforeEach("Opening URL", async ({ page }, testInfo) => {
    surveilr.setTimeout(240000);
    if (url) {
      await page.goto(url);

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
        surveilr.setTimeout(240000);
        const sp = new SiteQualityPage(page);

        switch (testCase.id) {
          case "TC-SQE-0001":
            await sp.sqeNavigationCheck();
            await sp.SiteQualityExplorerlogoCheck();
            break;
          case "TC-SQE-0002":
            await sp.sqeNavigationCheck();
            await sp.sqeDashboardLoadingFnCheck();
            break;
          case "TC-SQE-0005":
            await sp.sqeNavigationCheck();
            await sp.SQEtabnavigationFn();
            await sp.egsurveilrsiteNavCheck();
            break;
          case "TC-SQE-0006":
            await sp.sqeNavigationCheck();
            await sp.SQEtabnavigationFn();
            await sp.surveilrsiteNavCheck();
            break;
          case "TC-SQE-0007":
            await sp.sqeNavigationCheck();
            await sp.SQEtabnavigationFn();
            await sp.sqeFooterLinkNavCheck();
            break;
          case "TC-SQE-0009":
            await sp.sqeNavigationCheck();
            await sp.OrchestrationFooterLinkNavCheck();
            break;
          case "TC-SQE-0010":
            await sp.sqeNavigationCheck();
            await sp.UniResourceFooterLinkNavCheck();
            break;
          case "TC-SQE-0011":
            await sp.sqeNavigationCheck();
            await sp.RSSDConsoleFooterLinkNavCheck();
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
