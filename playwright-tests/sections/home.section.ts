import { expect, Page, test } from "@playwright/test";
import { HomeSelectors as hs } from "../selectors/home.selectors";
import * as dotenv from "dotenv";
import Logger from "../utils/logger-util";
import { getTextContent, waitForSelectorWithMinTime } from "../utils/utils-fns";
dotenv.config({ path: ".env" });

const logger = new Logger();


const errors: string[] = [];
export default class HomeSection {
  page: Page;

  constructor(page: Page) {
    this.page = page;
  }
  public async urlLoadingCheck() {
    const url = "https://eg.surveilr.com/";
    const expectedTitle =
      "Resource Surveillance & Integration Engine (surveilr) Live Examples";

    try {
      await test.step("Navigate to URL", async () => {
        logger.info("Navigating to the URL...");
        await this.page.goto(url);
        logger.info(`Navigated to ${url}`);
      });

      await test.step("Wait for page load", async () => {
        logger.info("Waiting for the page to load...");
        await this.page.waitForLoadState("load");
        logger.info("Page loaded successfully.");
      });

      const titleMatches = await test.step("Verify page title", async () => {
        logger.info("Verifying the page title...");
        const actualTitle = await this.page.title();
        console.log(actualTitle);
        logger.info(`Page title retrieved: ${actualTitle}`);
        return actualTitle === expectedTitle;
      });

      if (titleMatches) {
        logger.info("Page title matches the expected value.");
      } else {
        logger.error(
          `Page title does not match. Expected: "${expectedTitle}", Found: "${await this
            .page.title()}"`,
        );
        throw new Error("Page title mismatch");
      }
    } catch (error) {
      throw error;
    } finally {
      logger.info("Test execution completed.");
    }
  }

  public async RSSDlogovisibility() {
    try {
      await test.step("Waiting for the logo to load", async () => {
        await waitForSelectorWithMinTime(this.page, hs.logoImg);
      });

      const headerLogo =
        await test.step("Verify app logo visibility", async () => {
          return await this.page.locator(hs.title).isVisible();
        });
      if (headerLogo) {
        logger.info("App logo is visible properly");
      } else {
        logger.error("App logo is not visible properly");
        errors.push("App logo is not is not visible properly");
      }

      await test.step("Checking for error occurrence", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });
    } catch (error) {
      throw error;
    }
  }

  public async PageTitleVisibilityCheck() {
    try {
      await test.step("Waiting for text - Resource Surveillance State Database (RSSD) to load", async () => {
        await waitForSelectorWithMinTime(this.page, hs.title);
      });

      const text =
        await test.step("Verify text - Resource Surveillance State Database (RSSD) visibility", async () => {
          return await this.page.locator(hs.title).isVisible();
        });

      await test.step("Log visibility status", async () => {
        if (text) {
          logger.info(
            "Text - Resource Surveillance State Database (RSSD) is visible properly",
          );
        } else {
          logger.error(
            "Text - Resource Surveillance State Database (RSSD) is not visible properly",
          );
          errors.push(
            "Text - Resource Surveillance State Database (RSSD) is not visible properly",
          );
        }
      });

      await test.step("Verify the text content of the selected element", async () => {
        const element = await this.page.waitForSelector(hs.title);
        const gettext = await element?.textContent();

        if (gettext) {
          const trimmedText = gettext.trim();
          expect(trimmedText).toBe(hs.titleTxt);
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
      throw error;
    }
  }

  public async dashboardMenuCheck() {
    try {
      await test.step("Count the number of tab icons", async () => {
        const count = await this.page.locator(hs.tabIcons).count();
        // console.log(count);
        logger.info(`Number of tab icons: ${count}`);
      });

      const tabTexts = [
        "Home",
        "Docs",
        "Uniform Resource",
        "Console",
        "Orchestration",
      ];

      const tabSelectors = [
        { selector: hs.HomeTab },
        { selector: hs.docsTab },
        { selector: hs.uniformresourceTab },
        { selector: hs.consoleTab },
        { selector: hs.OrchestrationTab },
      ];

      for (let i = 0; i < tabSelectors.length; i++) {
        const { selector } = tabSelectors[i];
        const tabText = tabTexts[i];

        const gettext =
          await test.step(`Check the text on tab ${tabText}`, async () => {
            const element = await this.page.waitForSelector(selector);
            const gettext = await element?.textContent();
            return gettext;
          });

        if (gettext) {
          const trimmedText = gettext.trim();
          await test.step(`Trim and compare text for - ${tabText}`, async () => {
            try {
              expect(trimmedText).toBe(tabText);
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
      logger.error(`Error in dashboardMenuCheck: ${error.message}`);
      throw error;
    }
  }
  public async dashboardLoadingCheck() {
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
        { selector: hs.dpesControls },
        { selector: hs.Orchestration },
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

  public async validateHomepageNavigationfn(): Promise<any[]> {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Starting Home Page Navigation Check", async () => {
        const title = "Home page navigation check";
        steps.push({ step: 0, result: "info", message: title });
      });

      await test.step("Capture current URL", async () => {
        const expectedUrl = await this.page.url();
        logger.info(`Current URL: ${expectedUrl}`);
        await this.page.waitForSelector(hs.HomeTab);
      });

      await test.step("Clicking the Home tab and waiting for navigation", async () => {
        await this.page.click(hs.HomeTab);
        await this.page.waitForLoadState("networkidle");
        const finalUrl = await this.page.url();
        logger.info(`Final URL after navigation: ${finalUrl}`);

        if (finalUrl.trim() === hs.expectedUrllink) {
          logger.info("URL changed as expected.");
          steps.push({
            step: 1,
            result: "pass",
            message: "URL changed as expected.",
          });
        } else {
          logger.error("URL did not change as expected.");
          errors.push(
            `Expected URL: ${hs.expectedUrllink}, but got: ${finalUrl.trim()}`,
          );
          steps.push({
            step: 2,
            result: "fail",
            message: "URL did not change as expected.",
          });
        }
      });

      await test.step("Checking for errors during navigation", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during home tab navigation: ${err.message}`);
      steps.push({
        step: 3,
        result: "fail",
        message: `Error during navigation: ${err.message}`,
      });
    }

    return steps;
  }

  public async validateUniformDropdownfn(): Promise<any[]> {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Waiting for the Uniform Dropdown Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.uniformresourceTab);
      });

      await test.step("Clicking the Uniform Resource Tab", async () => {
        await this.page.click(hs.uniformresourceTab);
      });

      const expectedOptions: string[] = [
        hs.uniformresourceIMAP,
        hs.uniformresourcefile,
        hs.uniformresourcetableandview,
      ];

      const missingOptions: string[] = [];

      await test.step("Checking visibility of expected options", async () => {
        for (const option of expectedOptions) {
          const isVisible = await this.page.isVisible(option);
          if (!isVisible) missingOptions.push(option);
        }
      });

      if (missingOptions.length > 0) {
        logger.error(
          "Missing options in the dropdown: " + missingOptions.join(", "),
        );
        errors.push(`Missing options: ${missingOptions.join(", ")}`);
      } else {
        logger.info("All expected options are visible in the dropdown.");
      }

      await test.step("Checking for error occurrence", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });

      steps.push({ result: missingOptions.length === 0 ? "pass" : "fail" });
      if (missingOptions.length > 0) {
        steps.push({ missingOptions });
      }
    } catch (error) {
      steps.push({ result: "fail", error: error.message });
      logger.error(`Error during dropdown validation: ${error.message}`);
    }

    return steps;
  }

  public async validateOrchestrationDropdownfn(): Promise<any[]> {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Waiting for the Orchestration Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.Orchestration_topbar);
      });

      await test.step("Clicking the Orchestration Tab", async () => {
        await this.page.click(hs.Orchestration_topbar);
      });

      const expectedOptions: string[] = [hs.Orchestrationtablesandviews];

      const missingOptions: string[] = [];

      await test.step("Checking visibility of expected options", async () => {
        for (const option of expectedOptions) {
          const isVisible = await this.page.isVisible(option);
          if (!isVisible) missingOptions.push(option);
        }
      });

      if (missingOptions.length > 0) {
        logger.error(
          "Missing options in the dropdown: " + missingOptions.join(", "),
        );
        errors.push(`Missing options: ${missingOptions.join(", ")}`);
      } else {
        logger.info("All expected options are visible in the dropdown.");
      }

      await test.step("Checking for error occurrence", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });

      steps.push({ result: missingOptions.length === 0 ? "pass" : "fail" });
      if (missingOptions.length > 0) {
        steps.push({ missingOptions });
      }
    } catch (error) {
      steps.push({ result: "fail", error: error.message });
      logger.error(`Error during dropdown validation: ${error.message}`);
    }

    return steps;
  }

  public async validateConsoleDropdownfn(): Promise<any[]> {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Waiting for the Console Dropdown Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.consoleTab);
      });

      await test.step("Clicking the console Tab", async () => {
        await this.page.click(hs.consoleTab);
      });

      const expectedOptions: string[] = [
        hs.infoschema,
        hs.migrations,
        hs.codenotebooks,
        hs.sqlpagefiles,
        hs.contentsqlpagefiles,
        hs.sqlpagenavigations,
      ];

      const missingOptions: string[] = [];

      await test.step("Checking visibility of expected options", async () => {
        for (const option of expectedOptions) {
          const isVisible = await this.page.isVisible(option);
          if (!isVisible) missingOptions.push(option);
        }
      });

      if (missingOptions.length > 0) {
        logger.error(
          "Missing options in the dropdown: " + missingOptions.join(", "),
        );
        errors.push(`Missing options: ${missingOptions.join(", ")}`);
      } else {
        logger.info("All expected options are visible in the dropdown.");
      }

      await test.step("Checking for error occurrence", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });

      steps.push({ result: missingOptions.length === 0 ? "pass" : "fail" });
      if (missingOptions.length > 0) {
        steps.push({ missingOptions });
      }
    } catch (error) {
      steps.push({ result: "fail", error: error.message });
      logger.error(`Error during dropdown validation: ${error.message}`);
    }

    return steps;
  }

  public async validateUniformIMAPNavigationFn(): Promise<any[]> {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Waiting for the Uniform resource Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.uniformresource_topbar);
      });

      await test.step("Clicking the Uniform resource Tab", async () => {
        await this.page.click(hs.uniformresource_topbar);
      });

      await test.step("Waiting for the Uniform resource (IMAP) Dropdown Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.uniformresourceIMAP1);
      });

      await test.step("Clicking the Uniform Resources (IMAP) link", async () => {
        await this.page.click(hs.uniformresourceIMAP1);
      });

      await test.step("Waiting for the Mailbox title to be visible", async () => {
        await this.page.waitForSelector(hs.mailboxtitle);
      });

      const imapVisible =
        await test.step("Check if the Mailbox title is visible", async () => {
          return await this.page.isVisible(hs.mailboxtitle);
        });

      if (imapVisible) {
        logger.info("Mailbox title is visible after clicking the IMAP link.");
        steps.push({ result: "pass" });
      } else {
        logger.error(
          "Mailbox title is not visible after clicking the IMAP link.",
        );
        errors.push(
          "Mailbox title is not visible after clicking the IMAP link.",
        );
        steps.push({ result: "fail" });
      }

      await test.step("Checking for errors during IMAP navigation", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });
    } catch (error) {
      steps.push({ result: "fail", error: error.message });
      logger.error(`Error during IMAP navigation: ${error.message}`);
    }

    return steps;
  }

  public async validateUniformFileNavigationFn(): Promise<any[]> {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Waiting for the Uniform resource Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.uniformresource_topbar);
      });

      await test.step("Clicking the Uniform resource Tab", async () => {
        await this.page.click(hs.uniformresource_topbar);
      });

      await test.step("Waiting for the Uniform resource (file) Dropdown Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.uniformresourcefile1);
      });

      await test.step("Clicking the Uniform Resources (file) link", async () => {
        await this.page.click(hs.uniformresourcefile1);
      });

      await test.step("Waiting for the Page title to be visible", async () => {
        await this.page.waitForSelector(hs.URfiletitle);
      });

      const imapVisible =
        await test.step("Check if the page title is visible", async () => {
          return await this.page.isVisible(hs.URfiletitle);
        });

      if (imapVisible) {
        logger.info("The title is visible after clicking the IMAP link.");
        steps.push({ result: "pass" });
      } else {
        logger.error("The title is not visible after clicking the IMAP link.");
        errors.push("The title is not visible after clicking the IMAP link.");
        steps.push({ result: "fail" });
      }

      await test.step("Checking for errors during IMAP navigation", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });
    } catch (error) {
      steps.push({ result: "fail", error: error.message });
      logger.error(`Error during IMAP navigation: ${error.message}`);
    }

    return steps;
  }

  public async validateUniformtableandviewNavigationFn(): Promise<any[]> {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Waiting for the Uniform resource Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(this.page, hs.uniformresource_topbar);
      });

      await test.step("Clicking the Uniform resource Tab", async () => {
        await this.page.click(hs.uniformresource_topbar);
      });

      await test.step("Waiting for the Uniform resource tables and views Dropdown Tab to be clickable", async () => {
        await waitForSelectorWithMinTime(
          this.page,
          hs.uniformresourcetableandview,
        );
      });

      await test.step("Clicking the Uniform Resources tables and views link", async () => {
        await this.page.click(hs.uniformresourcetableandview);
      });

      await test.step("Waiting for the page title to be visible", async () => {
        await this.page.waitForSelector(hs.URtableandviewtitle);
      });

      const imapVisible =
        await test.step("Check if the Mailbox title is visible", async () => {
          return await this.page.isVisible(hs.URtableandviewtitle);
        });

      if (imapVisible) {
        logger.info("The title is visible after clicking the IMAP link.");
        steps.push({ result: "pass" });
      } else {
        logger.error("The title is not visible after clicking the IMAP link.");
        errors.push("The title is not visible after clicking the IMAP link.");
        steps.push({ result: "fail" });
      }

      await test.step("Checking for errors during IMAP navigation", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });
    } catch (error) {
      steps.push({ result: "fail", error: error.message });
      logger.error(`Error during IMAP navigation: ${error.message}`);
    }

    return steps;
  }
  public async RSSDSQLPageNavigationCheck() {
    try {
      await this.page.waitForSelector(hs.RSSDconsole);
      await this.page.click(hs.RSSDconsole);
      await this.page.waitForLoadState("networkidle");
      await test.step("Starting RSSD SQL Navigation Check", async () => {
        logger.info("Starting RSSD SQl navigation.");
        await this.page.waitForSelector(hs.RSSDSQLNavigation);
        await this.page.click(hs.RSSDSQLNavigation);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the RSSD SQ subtitle and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(hs.RSSDSqlTitle);
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(hs.RSSDSQLTitle);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during RSSD SQL navigation: ${err.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  public async RSSDDataTablesNavigationCheck() {
    try {
      await this.page.waitForSelector(hs.RSSDconsole);
      await this.page.click(hs.RSSDconsole);
      await this.page.waitForLoadState("networkidle");
      await test.step("Starting RSSD Data Tables Content SQLPage Files Navigation Check", async () => {
        logger.info(
          "Starting RSSD Data Tables Content SQLPage Files navigation.",
        );
        await this.page.waitForSelector(hs.RSSDDataTablelink);
        await this.page.click(hs.RSSDDataTablelink);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the RSSD Data Tables Content SQLPage Files subtitle and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(hs.RSSDDataTableTitle);
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(hs.RSSDDataTableTitleText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during RSSD Data Tables Content SQLPage Files navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  public async RSSDSQLPageFilesNavigationCheck() {
    try {
      await this.page.waitForSelector(hs.RSSDconsole);
      await this.page.click(hs.RSSDconsole);
      await this.page.waitForLoadState("networkidle");
      await test.step("Starting RSSD SQL Page Files Navigation Check", async () => {
        logger.info("Starting RSSD SQL Page Files navigation.");
        await this.page.waitForSelector(hs.RSSDSQLPageFileslink);
        await this.page.click(hs.RSSDSQLPageFileslink);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the RSSD SQL Page Files subtitle and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(
          hs.RSSDSQLPageFilesTitle,
        );
        const gettext = await element?.textContent();
        console.log(gettext);
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(hs.RRSSDSQLPageFilesTitleText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during RSSD SQL Page Files navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  public async RSSDDataTablePageNavigationCheck() {
    try {
      await this.page.waitForSelector(hs.RSSDconsole);
      await this.page.click(hs.RSSDconsole);
      await this.page.waitForLoadState("networkidle");
      await test.step("Starting RSSD SQL Navigation Check", async () => {
        logger.info("Starting RSSD SQl navigation.");
        await this.page.waitForSelector(hs.RSSDSQLNavigation);
        await this.page.click(hs.RSSDSQLNavigation);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the RSSD SQ subtitle and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(hs.RSSDSqlTitle);
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(hs.RSSDSQLTitle);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during RSSD SQL navigation: ${err.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  public async RSSDDataTablesContentSQLPagefootercheck() {
    try {
      await this.page.waitForSelector(hs.RSSDconsole);
      await this.page.click(hs.RSSDconsole);
      await this.page.waitForLoadState("networkidle");
      await test.step("Starting RSSD Data Tables Content SQLPage Files Navigation Check", async () => {
        logger.info(
          "Starting RSSD Data Tables Content SQLPage Files navigation.",
        );
        await this.page.waitForSelector(hs.RSSDDataTablelink);
        await this.page.click(hs.RSSDDataTablelink);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the RSSD Data Tables Content SQLPage Files and waited for page to load.",
        );
      });
      await this.page.waitForSelector(hs.RSSDdataTableFooterLink);
      await this.page.click(hs.RSSDdataTableFooterLink);

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(
          hs.RSSDDataTableFootertitle,
        );
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        console.log(gettext);
        await this.page.waitForTimeout(3000);

        expect(gettext).toBe(hs.RSSDDataTableFootertitleTxt);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during RSSD Data Tables Content SQLPage Files navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }

  public async validateDocspageNavigationfn() {
    const steps: any[] = [];
    const errors: string[] = [];

    try {
      await test.step("Starting Docs Page Navigation Check", async () => {
        const title = "Home page navigation check";
      });

      await test.step("Capture current URL", async () => {
        const expectedUrllink_docs = await this.page.url();
        logger.info(`Current URL: ${expectedUrllink_docs}`);
        await this.page.waitForSelector(hs.docs);
      });

      await test.step("Clicking the Home tab and waiting for navigation", async () => {
        await this.page.click(hs.docs);
        await this.page.waitForLoadState("networkidle");
        const finalUrl = await this.page.url();
        logger.info(`Final URL after navigation: ${finalUrl}`);

        if (finalUrl.trim() === hs.expectedUrllink_docs) {
          logger.info("URL changed as expected.");
        } else {
          logger.error("URL did not change as expected.");
          errors.push(
            `Expected URL: ${hs.expectedUrllink_docs}, but got: ${finalUrl.trim()}`,
          );
        }
      });

      await test.step("Checking for errors during navigation", async () => {
        if (errors.length > 0) {
          throw new Error(`Errors encountered:\n${errors.join("\n")}`);
        }
        expect(errors.length).toBe(0);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during home tab navigation: ${err.message}`);
    }
  }

  public async RSSDSQLPageFilesFooterNavigationcheck() {
    try {
      await this.page.waitForSelector(hs.RSSDconsole);
      await this.page.click(hs.RSSDconsole);
      await this.page.waitForLoadState("networkidle");
      await test.step("Starting RSSD  SQLPage Files Navigation Check", async () => {
        logger.info("Starting RSSD SQLPage Files navigation.");
        await this.page.waitForSelector(hs.RSSDSQLPageFileslink);
        await this.page.click(hs.RSSDSQLPageFileslink);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the RSSD SQLPage Files and waited for page to load.",
        );
      });
      await this.page.waitForSelector(hs.RSSDSQLPageFilesFooterLink);
      await this.page.click(hs.RSSDSQLPageFilesFooterLink);

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(
          hs.RSSDSQLPageFilesFootertitle,
        );
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        console.log(gettext);
        await this.page.waitForTimeout(3000);

        expect(gettext).toBe(hs.RSSDSQLPageFilesFootertitleTxt);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during RSSD SQLPage Files navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  public async RSSDSQLCrumbNavigationCheck() {
    try {
      await test.step("Verify Breadcrumb Container is Visible", async () => {
        const breadcrumb = await this.page.locator(hs.RSSDSQLcrumb);
        const breadcrumbVisible = await breadcrumb.isVisible();
        logger.info(`Breadcrumb container visible: ${breadcrumbVisible}`);
        expect(breadcrumbVisible).toBe(true);
      });

      const breadcrumbItems =
        await test.step("Capture Breadcrumb Items", async () => {
          const items = await this.page.locator(
            '//nav[@aria-label="breadcrumb"]//a | //nav[@aria-label="breadcrumb"]//span',
          );
          const count = await items.count();
          logger.info(`Number of breadcrumb items: ${count}`);

          const breadcrumbTexts: { text: string; clickable: boolean }[] = [];
          for (let i = 0; i < count; i++) {
            const item = items.nth(i);
            const text = await item.textContent();
            const isClickable = await item.evaluate(
              (el) => el.tagName.toLowerCase() === "a",
            );
            if (text) {
              breadcrumbTexts.push({
                text: text.trim(),
                clickable: isClickable,
              });
            }
          }
          logger.info(
            `Breadcrumb items: ${
              breadcrumbTexts
                .map((b) => b.text)
                .join(" > ")
            }`,
          );
          return breadcrumbTexts;
        });

      for (const breadcrumbItem of breadcrumbItems) {
        const { text: breadcrumbText, clickable } = breadcrumbItem;

        if (breadcrumbText === "Console" && clickable) {
          await test.step("Navigate to Console", async () => {
            const consoleBreadcrumb = await this.page.locator(
              "//nav[@aria-label=\"breadcrumb\"]//a[text()='Console']",
            );

            await consoleBreadcrumb.waitFor({
              state: "visible",
              timeout: 5000,
            });
            const isVisible = await consoleBreadcrumb.isVisible();
            logger.info(`Breadcrumb "Console" is visible: ${isVisible}`);
            expect(isVisible).toBe(true);

            await consoleBreadcrumb.click();
            await this.page.waitForLoadState("networkidle");

            const currentUrl = this.page.url();
            logger.info(`Navigated to: ${currentUrl}`);
            expect(currentUrl).toContain("http://localhost:9000/console/");
          });
        }

        if (breadcrumbText === "Home" && clickable) {
          await test.step("Navigate to Home", async () => {
            const homeBreadcrumb = await this.page.locator(
              "//nav[@aria-label=\"breadcrumb\"]//a[text()='Home']",
            );

            await homeBreadcrumb.waitFor({ state: "visible", timeout: 5000 });
            const isVisible = await homeBreadcrumb.isVisible();
            logger.info(`Breadcrumb "Home" is visible: ${isVisible}`);
            expect(isVisible).toBe(true);

            await homeBreadcrumb.click();
            await this.page.waitForLoadState("networkidle");

            const currentUrl = this.page.url();
            logger.info(`Navigated to: ${currentUrl}`);
            expect(currentUrl).toContain(
              "https://eg.surveilr.com/lib/pattern/direct-messaging-service/index.sql",
            );
          });
          break;
        }
      }
    } catch (error) {
      logger.error(`Error during breadcrumb navigation: ${error.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
}
