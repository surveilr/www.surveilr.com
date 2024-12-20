import { expect, Page, test } from "@playwright/test";
import { SQESelectors as ss } from "../selectors/sitequality-explorer.selector";
import * as dotenv from "dotenv";
import Logger from "../utils/logger-util";
import { HomeSelectors as hs } from "../selectors/home.selectors";
import { getTextContent, waitForSelectorWithMinTime } from "../utils/utils-fns";
dotenv.config({ path: ".env" });

const logger = new Logger();
const store: any = process.env.store;

const errors: string[] = [];
export default class SQESection {
  page: Page;

  constructor(page: Page) {
    this.page = page;
  }
  public async sqeNavigationFnCheck() {
    await test.step("Click the site quality explorer link", async () => {
      try {
        await this.page.waitForTimeout(2000);
        await this.page.waitForSelector(ss.sqeNavigationLink, {
          timeout: 10000,
        });
        logger.info("Clicking the site quality explorer link...");
        await this.page.click(ss.sqeNavigationLink);
        await this.page.waitForTimeout(3000);
        logger.info("Successfully clicked the site quality explorer link.");
      } catch (error) {
        logger.error(
          `Failed to click the site quality explorer link: ${error.message}`,
        );
        throw new Error(
          `Failed to click the site quality explorer link: ${error.message}`,
        );
      }
    });
  }
  catch(error) {
    throw error;
  }
  public async SiteQualityExplorerlogoVisibilityCheck() {
    try {
      await waitForSelectorWithMinTime(this.page, ss.sqeLogoImg);

      const headerLogo =
        await test.step("Ensure that Site Quality Explorer logo  is visible on the left top of the page", async () => {
          return await this.page.locator(ss.sqeLogoImg).isVisible();
        });

      if (headerLogo) {
        logger.info("Site Quality Explorer logo is visible properly");
      } else {
        logger.error("Site Quality Explorer logo is not visible properly");
        errors.push("Site Quality Explorer logo is not visible properly");
      }

      await waitForSelectorWithMinTime(this.page, ss.sqeHeader);

      const text =
        await test.step("Ensure that  header is visible on the left top of the page", async () => {
          return await this.page.locator(ss.sqeHeader).isVisible();
        });

      if (text) {
        logger.info("Text - Site Quality Explorer is visible properly");
      } else {
        logger.error("Text - Site Quality Explorer is not visible properly");
        errors.push("Text - Site Quality Explorer is not visible properly");
      }

      await test.step("Verify the text content of the selected element", async () => {
        const element = await this.page.waitForSelector(ss.sqeHeader);
        const gettext = await element?.textContent();
        console.log(gettext);
        if (gettext) {
          const trimmedText = gettext.trim();
          expect(trimmedText).toBe(ss.sqePageHeaderTxt);
          return trimmedText;
        } else {
          throw new Error(`${hs.title} element not found or empty.`);
        }
      });

      await test.step("Checking for error occurrence", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });
    } catch (error) {
      logger.error(`An error occurred: ${error.message}`);
      throw error;
    }
  }
  public async sqeDashboardLoadingCheck() {
    try {
      await test.step("Count site quality explorer dashboard menu items", async () => {
        const count = await this.page.locator(hs.dashboardmenu).count();
        logger.info(`Dashboard menu count: ${count}`);
        console.log(count);
      });

      const tabTexts = [
        "Orchestration",
        "Site Quality",
        "Uniform Resource",
        "Console",
      ];
      const tabSelectors = [
        { selector: hs.Orchestration },
        { selector: ss.siteQuality },
        { selector: hs.uniformresource },
        { selector: hs.RSSDconsole },
      ];

      for (let i = 0; i < tabSelectors.length; i++) {
        const { selector } = tabSelectors[i];
        const tabText = tabTexts[i];

        const gettext =
          await test.step(`Check subtitle: ${tabText}`, async () => {
            const element = await this.page.waitForSelector(selector);
            const gettext = await element?.textContent();
            console.log(gettext);
            return gettext;
          });

        if (gettext) {
          const trimmedText = gettext.trim();
          await test.step(`Trim and compare text for - ${tabText}`, async () => {
            try {
              expect(trimmedText).toContain(tabText);
              logger.info(
                `Text for ${tabText} matches expected value: ${trimmedText}`,
              );
            } catch (error) {
              logger.error(
                `Text for ${tabText} does not match expected value. Expected: ${tabText}, but got: ${trimmedText}`,
              );
              throw error;
            }
          });
        } else {
          const errorMessage = `${tabText} element not found or empty.`;
          logger.error(errorMessage);
          throw new Error(errorMessage);
        }
      }
    } catch (error) {
      logger.error(`Error in dashboardLoadingCheck: ${error.message}`);
      throw error;
    }
  }
  public async SQEtabnavigationFnCheck() {
    await test.step("Navigate to the Site Quality tab", async () => {
      try {
        await this.page.waitForTimeout(2000);
        await this.page.waitForSelector(ss.siteQualitytab, { timeout: 10000 });
        logger.info("Attempting to click the 'Site Quality' tab...");
        await this.page.click(ss.siteQualitytab);
        await this.page.waitForTimeout(3000);
        logger.info("Successfully clicked the 'Site Quality' tab.");
      } catch (error) {
        logger.error(
          `Failed to click the 'Site Quality' tab: ${error.message}`,
        );
        throw new Error(
          `Failed to click the 'Site Quality' tab: ${error.message}`,
        );
      }
    });
  }

  public async egsurveilrsiteNavigationCheck() {
    try {
      logger.info("Waiting for the Website Resources page to load.");
      await waitForSelectorWithMinTime(this.page, ss.egsurvilerLink);
      logger.info("Website Resources page loaded successfully.");

      await test.step("Click on the eg.surveilr.com Page Navigation link", async () => {
        logger.info("Starting eg.surveilr.com Page navigation.");
        await this.page.waitForSelector(ss.egsurvilerLink);
        await this.page.click(ss.egsurvilerLink);
        await this.page.waitForLoadState("networkidle");
      });

      const currentUrl = this.page.url();
      logger.info(`Navigated to URL: ${currentUrl}`);

      logger.info(
        `Validating URL: Expected = ${ss.egsurvilerLinkUrl}, Actual = ${currentUrl}`,
      );
      expect(currentUrl).toBe(ss.egsurvilerLinkUrl);
      logger.info("URL validation successful.");
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during eg.surveilr.com Page navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${err.message}`);
    }
  }

  public async surveilrsiteNavigationCheck() {
    try {
      logger.info("Waiting for the Website Resources page to load.");
      await waitForSelectorWithMinTime(this.page, ss.survilerLink);
      logger.info("Website Resources page loaded successfully.");

      await test.step("Click on the eg.surveilr.com Page Navigation link", async () => {
        logger.info("Starting eg.surveilr.com Page navigation.");
        await this.page.waitForSelector(ss.survilerLink);
        await this.page.click(ss.survilerLink);
        await this.page.waitForLoadState("networkidle");
      });

      const currentUrl = this.page.url();
      logger.info(`Navigated to URL: ${currentUrl}`);

      logger.info(
        `Validating URL: Expected = ${ss.survilerLinkUrl}, Actual = ${currentUrl}`,
      );
      expect(currentUrl).toBe(ss.survilerLinkUrl);
      logger.info("URL validation successful.");
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during eg.surveilr.com Page navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  public async sqeFooterLinkCheck() {
    try {
      logger.info("Starting site quality explorer footer navigation check.");

      await test.step("Verify site quality explorer Footer 1 navigation", async () => {
        logger.info("Waiting for site quality explorers Footer 1 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking site quality explorer Footer 1.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of site quality explorer Footer 1 link navigation.",
        );
        const Element1 = await this.page.waitForSelector(
          ss.sqeFooterlinkNavTextSel1,
        );
        const getHIPAAtext1 = await Element1?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext1}`);
        expect(getHIPAAtext1).toBe(ss.sqeFooterlinkNavText1);
      });

      await test.step("Verify site quality explorer Footer 2 navigation", async () => {
        logger.info("Waiting for site quality explorer Footer 2 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking site quality explorer Footer 2.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of site quality explorer Footer 2 link navigation.",
        );
        const Element2 = await this.page.waitForSelector(
          ss.sqeFooterlinkNavTextSel2,
        );
        const getHIPAAtext2 = await Element2?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext2}`);
        expect(getHIPAAtext2).toBe(ss.sqeFooterlinkNavText2);
      });

      logger.info(
        "SCF controls site quality explorer footer navigation check completed successfully.",
      );
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during SCF control menu navigation: ${err.message}`);
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  public async UniResourceFooterLinkCheck() {
    try {
      await this.page.waitForSelector(hs.uniformresource);
      logger.info("Clicking uniform resource menu.");
      await this.page.click(hs.uniformresource);
      await this.page.waitForLoadState("networkidle");
      logger.info("Starting uniform resource footer navigation check.");

      await test.step("Verify uniform resource Footer 1 navigation", async () => {
        logger.info("Waiting for uniform resource Footer 1 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking uniform resource Footer 1.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of uniform resource Footer 1 link navigation.",
        );
        const Element1 = await this.page.waitForSelector(
          ss.uniResourceFootNavTextSel1,
        );
        const getHIPAAtext1 = await Element1?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext1}`);
        expect(getHIPAAtext1).toBe(ss.uniResourceFooterlinkNavText1);
      });

      await test.step("Verify uniform resource Footer 2 navigation", async () => {
        logger.info("Waiting for uniform resource Footer 2 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking uniform resource Footer 2.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of uniform resource Footer 2 link navigation.",
        );
        const Element2 = await this.page.waitForSelector(
          ss.uniResourceFootNavTextSel2,
        );
        const getHIPAAtext2 = await Element2?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext2}`);
        expect(getHIPAAtext2).toBe(ss.uniResourceFooterlinkNavText2);
      });

      logger.info(
        "Site quality explorer- uniform resource footer navigation check completed successfully.",
      );
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during Site quality explorer- uniform resource footer navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  public async RSSDConsoleFooterLinkCheck() {
    try {
      logger.info("Starting RSSD console footer navigation check.");
      await this.page.waitForSelector(hs.RSSDconsole);
      logger.info("Clicking RSSD console Footer 1.");
      await this.page.click(hs.RSSDconsole);
      await test.step("Verify RSSD console Footer 1 navigation", async () => {
        logger.info("Waiting for RSSD console Footer 1 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking RSSD console Footer 1.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of RSSD console Footer 1 link navigation.",
        );
        const Element1 = await this.page.waitForSelector(
          ss.RSSDConsoleFootNavTextSel1,
        );
        const getHIPAAtext1 = await Element1?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext1}`);
        expect(getHIPAAtext1).toBe(ss.RSSDConsoleFootNavText1);
      });

      await test.step("Verify RSSD console Footer2 navigation", async () => {
        logger.info("Waiting for RSSD console Footer 2 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking RSSD console Footer 2.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of RSSD console Footer 2 link navigation.",
        );
        const Element2 = await this.page.waitForSelector(
          ss.RSSDConsoleFootNavTextSel2,
        );
        const getHIPAAtext2 = await Element2?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext2}`);
        expect(getHIPAAtext2).toBe(ss.RSSDConsoleFootNavText2);
      });

      logger.info(
        "Site quality explorer- RSSD console footer navigation check completed successfully.",
      );
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during Site quality explorer- RSSD console footer navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  public async OrchestrationFooterLinkCheck() {
    try {
      logger.info("Starting Orchestration footer navigation check.");
      await this.page.waitForSelector(hs.Orchestration);
      logger.info("Clicking Orchestration Footer 1.");
      await this.page.click(hs.Orchestration);
      await test.step("Verify Orchestration Footer 1 navigation", async () => {
        logger.info("Waiting for Orchestration Footer 1 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking Orchestration Footer 1.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of Orchestration Footer 1 link navigation.",
        );
        const Element1 = await this.page.waitForSelector(
          ss.OrchestrationFootNavTextSel1,
        );
        const getHIPAAtext1 = await Element1?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext1}`);
        expect(getHIPAAtext1).toBe(ss.OrchestrationFootNavText1);
      });

      await test.step("Verify Orchestration Footer 2 navigation", async () => {
        logger.info("Waiting for Orchestration Footer 2 selector.");
        await this.page.waitForSelector(ss.Footer);
        logger.info("Clicking Orchestration Footer 2.");
        await this.page.click(ss.Footer);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of Orchestration Footer 2 link navigation.",
        );
        const Element2 = await this.page.waitForSelector(
          ss.OrchestrationFootNavTextSel2,
        );
        const getHIPAAtext2 = await Element2?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext2}`);
        expect(getHIPAAtext2).toBe(ss.OrchestrationFootNavText2);
      });

      logger.info(
        "Site quality explorer - Orchestration footer navigation check completed successfully.",
      );
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during Site quality explorer - Orchestration footer navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${err.message}`);
    }
  }
}
