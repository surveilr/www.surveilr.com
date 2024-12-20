import { surveilr } from "../fixture/fixtures";
import { logger } from "../utils/test-utils";
import DirectMessagingPage from "../pages/direct-messaging.page";
import { testcaseDetails, testTypeToTagMap } from "../testcase_details/home";

const url = process.env.url;

console.log("Url is ", url);

surveilr.describe("direct-messaging Tests", () => {
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
        const dp = new DirectMessagingPage(page);

        switch (testCase.id) {
          case "TC-DMS-0002":
            await dp.dmsNavigationCheck();
            await dp.dmsDashboardLoadingCheck();
            break;
          case "TC-DMS-0003":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            break;
          case "TC-DMS-0004":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.dpesPageDashboardMenuCheck();
            break;
          case "TC-DMS-0005":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.ValidateDPESinboxNavigation();
            await dp.inboxFooterLinkNavigationcheck();
            break;
          case "TC-DMS-0006":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.ValidateDPESinboxNavigation();
            break;
          case "TC-DMS-0008":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.ValidateDPESinboxNavigation();
            await dp.SubjectClmdataLinkNavigation();
            break;
          case "TC-DMS-0009":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.ValidateDPESinboxNavigation();
            await dp.attachmentFileNavigationcheck();
            break;
          case "TC-DMS-0011":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.ValidateDPESdispatchedNavigation();
            break;
          case "TC-DMS-0014":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.ValidateDPESfailedNavigation();
            break;
          case "TC-DMS-0015":
            await dp.dmsNavigationCheck();
            await dp.validateDPESpageNavigationCheck();
            await dp.ValidateDPESfailedNavigation();
            await dp.DPESfailedpageCrumbCheck();
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
