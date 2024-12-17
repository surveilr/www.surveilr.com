import { surveilr } from "../fixture/fixtures";
import { logger } from "../utils/test-utils";
import HomePage from "../pages/home.page";
import DirectMessagingPage from "../pages/direct-messaging.page";
import { testcaseDetails, testTypeToTagMap } from "../testcase_details/home";

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
          `Test case ID not found in testcaseDetails: ${testInfo.title}`
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
        const hp = new HomePage(page);
        const dp = new DirectMessagingPage(page);
        switch (testCase.id) {
          case "TC-0001":
            await hp.urlLoadingFnCheck();
            break;
          case "TC-0002":
            await dp.dmsNavigationCheck();
            await hp.dashboardLoadingFnCheck();
            break;
          case "TC-0003":
            await dp.dmsNavigationCheck();
            await hp.RSSDlogoVisibilityCheck();
            break;
          case "TC-0004":
            await dp.dmsNavigationCheck();
            await hp.PageTitleValidationCheck();
            break;
          case "TC-0005":
            await dp.dmsNavigationCheck();
            await hp.dashboardMenuFnCheck();
            break;
          case "TC-0006":
            await dp.dmsNavigationCheck();
            await hp.validateHomepageNavigation();
            break;
          case "TC-0007":
            await dp.dmsNavigationCheck();
            logger.info("Docs page Navigation validation Test.");
            await hp.validateDocspageNavigation();
            break;
          case "TC-0008":
            await dp.dmsNavigationCheck();
            await hp.validateUniformDropdown();
            break;
          case "TC-0009":
            await dp.dmsNavigationCheck();
            await hp.validateUniformIMAPNavigation();
            break;
          case "TC-0010":
            await dp.dmsNavigationCheck();
            await hp.validateUniformfilePNavigation();
            break;
          case "TC-0011":
            await dp.dmsNavigationCheck();
            await hp.validateUniformtableandviewNavigation();
            break;
          case "TC-0012":
            await dp.dmsNavigationCheck();
            await hp.validateconsoleDropdown();
            break;
          case "TC-0058":
            await dp.dmsNavigationCheck();
            await hp.RSSDSQLPageFilesNavigation();
            break;
          case "TC-0059":
            await dp.dmsNavigationCheck();
            await hp.RSSDSQLPageFilesfootercheck();
            break;
          case "TC-0060":
            await dp.dmsNavigationCheck();
            await hp.RSSDDataTablesNavigation();
            break;
          case "TC-0061":
            await dp.dmsNavigationCheck();
            await hp.RSSDDataTablesContentSQLPageFilesfootercheck();
            break;
          case "TC-0062":
            await dp.dmsNavigationCheck();
            await hp.RSSDSQLPageNavigation();
            break;
          case "TC-0063":
            await dp.dmsNavigationCheck();
            await hp.RSSDSQLPageNavigation();
            await hp.RSSDSQLCrumbNavigation();
            break;
          default:
            logger.warn(`Test case ${testCase.id} not handled`);
            break;
        }
      }
    );
  });

  surveilr.afterEach("Closing Page", async ({ page }) => {
    await page.close();
    logger.info("Closing Page!");
  });
});
