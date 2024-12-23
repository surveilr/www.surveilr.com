import { expect, Page, test } from "@playwright/test";
import { DirectMessagingSelectors as ds } from "../selectors/direct-messaging.selectors";
import * as dotenv from "dotenv";
import Logger from "../utils/logger-util";
import { HomeSelectors as hs } from "../selectors/home.selectors";
import { waitForSelectorWithMinTime } from "../utils/utils-fns";
dotenv.config({ path: ".env" });
const url = process.env.url;
const logger = new Logger();

const errors: string[] = [];
export default class DirectMessagingSection {
  page: Page;

  constructor(page: Page) {
    this.page = page;
  }
  // Direct messaging services Navigation check
  public async dmsNavigationFnCheck() {
    await test.step("Click the compliance explorer link", async () => {
      try {
        await this.page.waitForTimeout(2000);
        await this.page.waitForSelector(ds.DMSselector, { timeout: 10000 });
        logger.info("Clicking the direct meaasging sevice link...");
        await this.page.click(ds.DMSselector);
        await this.page.waitForTimeout(3000);
        logger.info("Successfully clicked the direct meaasging sevice link.");
      } catch (error) {
        logger.error(
          `Failed to click the direct meaasging sevice link: ${error.message}`,
        );
        throw new Error(
          `Failed to click the compliance explorer link: ${error.message}`,
        );
      }
    });
  }
  catch(error) {
    throw error;
  }
  // Direct messaging services Dashboard Loading functionality check
  public async dmsDashboardLoadingFnCheck() {
    try {
      await test.step("Count dashboard menu items", async () => {
        const count = await this.page.locator(hs.dashboardmenu).count();
        logger.info(`Dashboard menu count: ${count}`);
        console.log(count);
      });

      const tabTexts = [
        "Direct Protocol Email System",
        "Orchestration",
        "Uniform Resource",
        "Console",
      ];
      const tabSelectors = [
        { selector: ds.dpesSubtitle },
        { selector: hs.Orchestration },
        { selector: hs.uniformresource },
        { selector: hs.RSSDconsole },
      ];

      for (let i = 0; i < tabSelectors.length; i++) {
        const { selector } = tabSelectors[i];
        const tabText = tabTexts[i];

        const gettext =
          await test.step(`Check the presence of ${tabText} menu`, async () => {
            const element = await this.page.waitForSelector(selector);
            const gettext = await element?.textContent();
            return gettext;
          });

        if (gettext) {
          const trimmedText = gettext.trim();
          await test.step(`Verify the text of ${tabText} menu`, async () => {
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
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  //  Direct Protocol Email System page navigation Check
  public async validateDPESpageNavigation() {
    try {
      logger.info("Waiting for the dashboard to load.");
      await waitForSelectorWithMinTime(this.page, ds.dpesSubtitle);
      logger.info("Dashboard loaded successfully.");
      await test.step("Click on the Direct Protocol Email System Page Navigation link", async () => {
        logger.info("Starting Direct Protocol Email System page navigation.");
        await this.page.waitForSelector(ds.dpesSubtitle);
        await this.page.click(ds.dpesSubtitle);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the Direct Protocol Email System subtitle and waited for page to load.",
        );
      });

      await test.step("Verify navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(ds.dpesText);
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(ds.dpesTextcontent);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during Direct Protocol Email System page navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  //  Direct Protocol Email System Dashboard Menu Visibility check
  public async dpesPageDashboardMenuVisibilityCheck() {
    try {
      await test.step("Count- Direct Protocol Email System page menu items", async () => {
        const count = await this.page.locator(hs.dashboardmenu).count();
        logger.info(
          `Direct Protocol Email System Page Dashboard menu count: ${count}`,
        );
        console.log(count);
      });

      const menuTexts = ["Inbox", "Dispatched", "Failed"];
      const menuSelectors = [
        { selector: ds.inboxlink },
        { selector: ds.Dispatchedlink },
        { selector: ds.failedLink },
      ];

      for (let i = 0; i < menuSelectors.length; i++) {
        const { selector } = menuSelectors[i];
        const menuText = menuTexts[i];

        const gettext = await test.step(`Check menu: ${menuText}`, async () => {
          const element = await this.page.waitForSelector(selector);
          const gettext = await element?.textContent();
          return gettext;
        });
        console.log(gettext);
        if (gettext) {
          const trimmedText = gettext.trim();
          await test.step(`Trim and compare text for - ${menuText}`, async () => {
            try {
              expect(trimmedText).toContain(menuText);
              logger.info(
                `Text for ${menuText} matches expected value: ${trimmedText}`,
              );
            } catch (error) {
              logger.error(
                `Text for ${menuText} does not match expected value. Expected: ${menuText}, but got: ${trimmedText}`,
              );
              throw error;
            }
          });
        } else {
          const errorMessage = `${menuText} element not found or empty.`;
          logger.error(errorMessage);
          throw new Error(errorMessage);
        }
      }
    } catch (error) {
      logger.error(
        `Error in  Direct Protocol Email System page menu items Check: ${error.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  //  Direct Protocol Email System inbox navigation check
  public async dpesInboxNavigationCheck() {
    try {
      await test.step("Starting Direct Protocol Email System Page-inbox Navigation Check", async () => {
        logger.info(
          "Starting Direct Protocol Email System page-inbox navigation",
        );
        await this.page.waitForSelector(ds.inboxlink);
        await this.page.click(ds.inboxlink);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the Direct Protocol Email System inbox link and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(ds.inboxText);
        const gettext = await element?.textContent();
        console.log(gettext);
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toContain(ds.inboxLinkText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during Direct Protocol Email System inbox link navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  //  Direct Protocol Email System Dispatched page navigation check
  public async dpesDispatchedNavigationCheck() {
    try {
      await test.step("Starting Direct Protocol Email System Page-Dispatched Navigation Check", async () => {
        logger.info(
          "Starting Direct Protocol Email System page-Dispatched navigation",
        );
        await this.page.waitForSelector(ds.Dispatchedlink);
        await this.page.click(ds.Dispatchedlink);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the Direct Protocol Email System Dispatched link and waited for page to load.",
        );
      });
      //  Direct Protocol Email System Dispatched link navigation check
      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(ds.Dispatchedtext);
        const gettext = await element?.textContent();
        console.log(gettext);
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toContain(ds.DispatchedlinkText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during Direct Protocol Email System Dispatched link navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // Direct Protocol Email System failed link navigation check
  public async dpesFailedNavigationCheck() {
    try {
      await test.step("Starting Direct Protocol Email System Page-Failed Navigation Check", async () => {
        logger.info(
          "Starting Direct Protocol Email System page-Failed navigation",
        );
        await this.page.waitForSelector(ds.failedLink);
        await this.page.click(ds.failedLink);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the Direct Protocol Email System Failed link and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(ds.failedText);
        const gettext = await element?.textContent();
        console.log(gettext);
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(ds.failedLinkText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during Direct Protocol Email System Failed link navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // Subject Coulmn metadata Link Navigation Check
  public async SubjectClmdataLinkNavigationCheck() {
    try {
      const count = await test.step("Count Subject Column Links", async () => {
        const count = await this.page.locator(ds.subjectDatacount).count();
        logger.info(`Total links under 'Subject' column: ${count}`);
        return count;
      });

      for (let i = 1; i <= count; i++) {
        await test.step(`Check navigation for link ${i}`, async () => {
          logger.info(
            `Starting navigation check for link ${i} in 'Subject' column.`,
          );

          const data = await this.page.waitForSelector(ds.subjectData(i));
          const gettext = (await data?.textContent())?.trim();
          logger.info(`Link text captured: ${gettext}`);
          await expect(data.isVisible()).resolves.toBeTruthy();
          logger.info(`Link ${i} is visible. Clicking it.`);

          await data.click();
          await this.page.waitForLoadState("networkidle");

          const inboxSub = await this.page.waitForSelector(ds.subjectName);
          const inboxSubgettext = (await inboxSub?.textContent())?.trim();
          logger.info(`Page navigated to: ${inboxSubgettext}`);
          expect(inboxSubgettext).toBe(gettext);
          logger.info(`Link ${i} navigated to the correct page.`);
          await this.page.goBack();

          logger.info(`Returned to the inbox page after verifying link ${i}.`);
        });
      }
    } catch (error) {
      logger.error(
        `Error in SubjectClmdataLinkNavigationCheck: ${error.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // Attachment File Navigation check
  public async ValidateAttachmentFileNavigation() {
    try {
      const count = await test.step("Count Subject Column Links", async () => {
        const count = await this.page.locator(ds.subjectDatacount).count();
        logger.info(`Total links under 'Subject' column: ${count}`);
        return count;
      });

      for (let i = 1; i <= count; i++) {
        const data = await test.step(`Capture Link ${i} Text`, async () => {
          const data = await this.page.waitForSelector(ds.subjectData(i));
          const gettext = (await data?.textContent())?.trim();
          logger.info(`Link text captured for subject ${i}: ${gettext}`);
          return gettext;
        });

        await test.step(`Ensure Link ${i} is Visible`, async () => {
          await expect(
            this.page.locator(ds.subjectData(i)).isVisible(),
          ).resolves.toBeTruthy();
          logger.info(`Link ${i} is visible. Clicking it.`);
        });

        await test.step(`Click Link ${i}`, async () => {
          const data = await this.page.locator(ds.subjectData(i));
          await data.click();
          await this.page.waitForLoadState("networkidle");
          logger.info(`Clicked on link ${i} and waited for page to load.`);
        });

        const attachmentCount =
          await test.step(`Count Attachments for Subject ${data}`, async () => {
            const count = await this.page.locator(ds.attachmentcount).count();
            logger.info(`Total attachments for subject ${data}: ${count}`);
            return count;
          });

        for (let j = 1; j <= attachmentCount; j++) {
          await test.step(`Click Attachment ${j} for Subject ${data}`, async () => {
            const attachmentFile = await this.page.waitForSelector(
              ds.attachment(j),
            );
            logger.info(`Clicking attachment ${j} for subject ${data}.`);
            await attachmentFile.click();
            await this.page.waitForLoadState("domcontentloaded");
          });

          await test.step(`Validate Attachment ${j} Content`, async () => {
            const pageContent = await this.page.content();
            logger.info(`Validating content for attachment ${j}.`);
            expect(pageContent.trim().length).toBeGreaterThan(0);
          });

          await test.step(`Go Back to Inbox after Attachment ${j}`, async () => {
            await this.page.goBack();
            await this.page.waitForSelector(ds.inboxCrumb);
            await this.page.click(ds.inboxCrumb);
            logger.info(`Navigating back to the inbox after attachment ${j}.`);
          });
        }
      }
    } catch (error) {
      logger.error(
        `Error in ValidateAttachmentFileNavigation: ${error.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // Direct Protocol Email System failed page breadcrumb navigation check
  public async DPESfailedpageCrumbNavigationCheck() {
    try {
      logger.info("Starting DPESfailedpageCrumbNavigationCheck test");

      const breadcrumbSelectorsAndUrls = [
        {
          selector: ds.FailedCrumb,
          expectedUrl: ds.FailedUrl,
        },
        {
          selector: ds.DPESCrumb,
          expectedUrl: ds.DPESUrl,
        },
        {
          selector: ds.HOMECrumb,
          expectedUrl: ds.HomeUrl,
        },
      ];

      for (const { selector, expectedUrl } of breadcrumbSelectorsAndUrls) {
        await test.step(`Check Breadcrumb Navigation for ${selector}`, async () => {
          logger.info(
            `Starting breadcrumb navigation check for selector: ${selector}`,
          );

          const breadcrumb = await this.page.locator(selector);

          logger.info(
            `Checking visibility for breadcrumb with selector: ${selector}`,
          );
          await expect(breadcrumb).toBeVisible();

          logger.info(`Clicking breadcrumb with selector: ${selector}`);
          await breadcrumb.click();

          logger.info("Waiting for network to be idle");
          await this.page.waitForLoadState("networkidle");

          const currentUrl = this.page.url();
          logger.info(`Navigated to URL: ${currentUrl}`);

          logger.info(
            `Validating URL: Expected = ${expectedUrl}, Actual = ${currentUrl}`,
          );
          expect(currentUrl).toBe(expectedUrl);

          logger.info("Waiting for network to be idle after URL validation");
          await this.page.waitForLoadState("networkidle");
        });
      }

      logger.info(
        "DPESfailedpageCrumbNavigationCheck test completed successfully",
      );
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during breadcrumb navigation: ${err.message}`);
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  // Inbox footer link navigation check
  public async ValidateInboxFooterLink() {
    try {
      await test.step("Inbox footerlink Navigation Check", async () => {
        logger.info("Starting Inbox footer link navigation");
        await this.page.waitForSelector(ds.inboxFooter);
        await this.page.click(ds.inboxFooter);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the Inbox footerlink link and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(ds.dmsinboxText);
        const gettext = await element?.textContent();
        console.log(gettext);
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(ds.dmsinboxlinkText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during Inbox footer link navigation: ${err.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
}
