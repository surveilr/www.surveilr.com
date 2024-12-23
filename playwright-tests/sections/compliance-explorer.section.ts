import { expect, Page, test } from "@playwright/test";
import { ComplianceExplorerSelectors as cs } from "../selectors/compliance-explorer.selector";
import * as dotenv from "dotenv";
import { HomeSelectors as hs } from "../selectors/home.selectors";
import Logger from "../utils/logger-util";
import { waitForSelectorWithMinTime } from "../utils/utils-fns";
dotenv.config({ path: ".env" });

const logger = new Logger();


const errors: string[] = [];
export default class ComplianceExplorerSection {
  page: Page;

  constructor(page: Page) {
    this.page = page;
  }
  // Compliance explorer logo visibility Check
  public async CElogovisibility() {
    try {
      await test.step("Waiting for the compliance explorer logo to load", async () => {
        await waitForSelectorWithMinTime(this.page, cs.CELogo);
      });

      const headerLogo =
        await test.step("Verify compliance explorer logo visibility", async () => {
          return await this.page.locator(hs.title).isVisible();
        });
      if (headerLogo) {
        logger.info("compliance explorer logo is visible properly");
      } else {
        logger.error("compliance explorer logo is not visible properly");
        errors.push("compliance explorer logo is not is not visible properly");
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
  // Compliance explorer dashboard loading functionality Check
  public async ceDashboardLoadingFnCheck() {
    try {
      await test.step("Count dashboard menu items", async () => {
        const count = await this.page.locator(hs.dashboardmenu).count();
        logger.info(`Dashboard menu count: ${count}`);
        console.log(count);
      });

      const tabTexts = [
        "SCF Controls",
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
  // Compliance explorer SCF Controls menu navigation check
  public async scfControlsMenuNavigation() {
    try {
      await test.step("Starting SCF controlmenu Navigation Check", async () => {
        logger.info("Starting SCF controlmenu navigation.");
        await this.page.waitForSelector(hs.dpesControls);
        await this.page.click(hs.dpesControls);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the SCF control menu subtitle and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(cs.complianceExplorer);
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(cs.complianceExplorerText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during SCF control menu navigation: ${err.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // Compliance explorer SCF Controls page footer link  navigation check
  public async scfControlsFooterNavigationFnCheck() {
    try {
      logger.info("Starting SCF controls footer navigation check.");

      await test.step("Verify SCF Controls Footer 1 navigation", async () => {
        logger.info("Waiting for SCF Controls Footer 1 selector.");
        await this.page.waitForSelector(cs.ScfControlsFooter1);
        logger.info("Clicking SCF Controls Footer 1.");
        await this.page.click(cs.ScfControlsFooter1);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of Footer 1 link navigation.",
        );
        const Element1 = await this.page.waitForSelector(
          cs.ScfFooterlinkNavTextSel1,
        );
        const getHIPAAtext1 = await Element1?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext1}`);
        expect(getHIPAAtext1).toBe(cs.ScfFooterlinkNavText1);
      });

      await test.step("Verify SCF Controls Footer 2 navigation", async () => {
        logger.info("Waiting for SCF Controls Footer 2 selector.");
        await this.page.waitForSelector(cs.ScfControlsFooter2);
        logger.info("Clicking SCF Controls Footer 2.");
        await this.page.click(cs.ScfControlsFooter2);
        logger.info("Waiting for network to be idle.");
        await this.page.waitForLoadState("networkidle");

        logger.info(
          "Waiting for and retrieving text of Footer 2 link navigation.",
        );
        const Element2 = await this.page.waitForSelector(
          cs.ScfFooterlinkNavTextSel2,
        );
        const getHIPAAtext2 = await Element2?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext2}`);
        expect(getHIPAAtext2).toBe(cs.ScfFooterlinkNavText2);
      });

      logger.info(
        "SCF controls footer navigation check completed successfully.",
      );
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during SCF control menu navigation: ${err.message}`);
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  // Compliance explorer SCF Controls page breadcrumb navigation check
  public async SCFControlCrumbCheck() {
    try {
      await test.step("Verify Breadcrumb Container is Visible", async () => {
        const breadcrumb = await this.page.locator(cs.homeScfCrumb);
        const breadcrumbVisible = await breadcrumb.isVisible();
        logger.info(`Breadcrumb visible: ${breadcrumbVisible}`);
        expect(breadcrumbVisible).toBe(true);
      });

      const breadcrumbItems =
        await test.step("Capture Breadcrumb Items", async () => {
          const items = await this.page.locator(cs.homeScfCrumb);
          const count = await items.count();
          console.log(count);
          const breadcrumbTexts: string[] = [];
          for (let i = 0; i < count; i++) {
            const itemText = await items.nth(i).textContent();
            if (itemText) {
              breadcrumbTexts.push(itemText.trim());
            }
          }
          logger.info(`Breadcrumb items: ${breadcrumbTexts.join(" > ")}`);
          return breadcrumbTexts;
        });

      for (let i = 0; i < breadcrumbItems.length; i++) {
        const breadcrumbText = breadcrumbItems[i];
        await test.step(
          `Check Breadcrumb Item ${i + 1}: ${breadcrumbText}`,
          async () => {
            const breadcrumbItem = await this.page.locator(
              `${cs.homeScfCrumb} >> nth=${i}`,
            );
            await expect(breadcrumbItem.isVisible()).resolves.toBeTruthy();
            logger.info(
              `Breadcrumb ${breadcrumbText} is visible and clickable.`,
            );

            await breadcrumbItem.click();
            await this.page.waitForLoadState("networkidle");
            const currentUrl = this.page.url();
            console.log(currentUrl);
            logger.info(`Navigated to: ${currentUrl}`);
            expect(currentUrl).not.toBe("about:blank");
            expect(currentUrl).toContain(
              "https://eg.surveilr.com/lib/pattern/compliance-explorer/ce/index.sql",
            );
            await this.page.goBack();
          },
        );
      }
    } catch (error) {
      logger.error(`Error during breadcrumb navigation: ${error.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // verify USHIPAA Section
  public async verifyUSHIPAASection() {
    try {
      logger.info("Starting US HIPAA Section verification");

      await test.step("Verify US HIPAA Block title Visibility", async () => {
        logger.info("Step: Verify US HIPAA Block title Visibility");
        const HIPAAElement = await this.page.waitForSelector(cs.HIPAA);
        const getHIPAAtext = await HIPAAElement?.textContent();
        logger.info(`Retrieved text: ${getHIPAAtext?.trim()}`);
        expect(getHIPAAtext?.trim()).toBe(cs.HipaaText.trim());
      });

      await test.step("Verify US HIPAA Block Visibility", async () => {
        logger.info("Step: Verify US HIPAA Block Visibility");
        const element = await this.page.waitForSelector(cs.HIPAAData);
        const gettext = await element?.textContent();
        logger.info(`Retrieved data block text: ${gettext?.trim()}`);
        expect(gettext?.trim()).toBe(cs.HipaaData.trim());
      });

      logger.info("Successfully verified US HIPAA Section");
    } catch (error) {
      const err = error as Error;
      logger.error(`Error verifying US HIPAA section: ${err.message}`);
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  // verify NIST Section
  public async verifyNISTSection() {
    try {
      logger.info("Starting NIST Section verification");

      await test.step("Verify NIST Block title Visibility", async () => {
        logger.info("Step: Verify NIST Block title Visibility");
        const NISTElement = await this.page.waitForSelector(cs.HIPAA);
        const getNISTtext = await NISTElement?.textContent();
        logger.info(`Retrieved text: ${getNISTtext?.trim()}`);
        expect(getNISTtext?.trim()).toBe(cs.HipaaText.trim());
      });

      await test.step("Verify NIST Block Visibility", async () => {
        logger.info("Step: Verify NIST Block Visibility");
        const element = await this.page.waitForSelector(cs.NISTData);
        const gettext = await element?.textContent();
        logger.info(`Retrieved data block text: ${gettext?.trim()}`);
        expect(gettext?.trim()).toBe(cs.NistData.trim());
      });

      logger.info("Successfully verified NIST Section");
    } catch (error) {
      const err = error as Error;
      logger.error(`Error verifying NIST section: ${err.message}`);
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  // USHIPAA Detail View Check
  public async USHIPAADetailViewCheck() {
    try {
      await test.step("Starting US HIPAA Detail View Navigation Check", async () => {
        logger.info("StartingUS HIPAA Detail View navigation.");
        await this.page.waitForSelector(cs.detailViewHIPAA);
        await this.page.click(cs.detailViewHIPAA);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the US HIPAA Detail View and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(cs.USHIPAAControls);
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(cs.USHIPAACLText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during US HIPAA Detail View navigation: ${err.message}`,
      );
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // HIPAA controls SearchBar functionality Check
  public async HIPAAcontrolsSearchBarFnCheck() {
    try {
      await test.step("Starting US HIPAA Detail View Navigation Check", async () => {
        logger.info("Starting US HIPAA Detail View navigation.");
        await this.page.waitForSelector(cs.detailViewHIPAA);
        logger.info("Detail view HIPAA selector is visible.");
        await this.page.click(cs.detailViewHIPAA);
        logger.info("Clicked on the US HIPAA Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Waited for the page to load completely.");
      });

      await test.step("Validating Search Bar Visibility", async () => {
        const searchBar = this.page.locator(cs.searchBarSelector);
        await expect(searchBar).toBeVisible();
        logger.info("Search bar is visible.");
      });

      await test.step("Filling the Search Bar and Checking Results", async () => {
        const searchBar = this.page.locator(cs.searchBarSelector);
        await searchBar.fill(cs.searchKeyword);
        logger.info(
          `Filled the search bar with keyword: "${cs.searchKeyword}".`,
        );

        const searchResults = this.page.locator(cs.searchResultsSelector);
        await expect(searchResults).toBeVisible();
        logger.info("Search results are visible.");

        const resultsText = await searchResults.textContent();
        logger.info(`Search results text: "${resultsText}".`);
        expect(resultsText).toContain(cs.searchKeyword);
        logger.info(
          `Search results contain the keyword: "${cs.searchKeyword}".`,
        );
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during US HIPAA Controls Page test: ${err.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // HIPAA controls titles sort functionality Check
  public async USHIPAAcontrolsTitleSortFnCheck() {
    try {
      await test.step("Navigate to the US HIPAA Detail View page", async () => {
        logger.info("Navigating to the US HIPAA Detail View page.");
        await this.page.waitForSelector(cs.detailViewHIPAA);
        logger.info("US HIPAA Detail View selector is visible.");
        await this.page.click(cs.detailViewHIPAA);
        logger.info("Clicked on the US HIPAA Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      await test.step("Sort the Title column in ascending order", async () => {
        const columnHeader = this.page.locator(cs.titleHeader);
        logger.info("Located the Title column header.");
        await columnHeader.click();
        logger.info("Clicked to sort the Title column in ascending order.");

        const rows = this.page.locator(cs.titleColnData);
        const rowTexts = await rows.allTextContents();
        const columnData = rowTexts.map((row) => row.split("\t")[0]);
        const sortedData = [...columnData].sort();

        logger.info("Validating ascending order sorting.");
        expect(columnData).toEqual(sortedData);
        logger.info("Title column sorted in ascending order successfully.");
      });

      await test.step("Sort the Title column in descending order", async () => {
        const columnHeader = this.page.locator(cs.titleHeader);
        await columnHeader.click();
        logger.info("Clicked to sort the Title column in descending order.");

        const rows = this.page.locator(cs.titleColnData);
        const rowTextsDesc = await rows.allTextContents();
        const columnDataDesc = rowTextsDesc.map((row) => row.split("\t")[0]);
        const sortedDataDesc = [...columnDataDesc].sort().reverse();

        logger.info("Validating descending order sorting.");
        expect(columnDataDesc).toEqual(sortedDataDesc);
        logger.info("Title column sorted in descending order successfully.");
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during US HIPAA Title Sort Functionality Test: ${err.message}`,
      );
      throw new Error(`Test failed: ${err.message}`);
    }
  }
  // USHIPAA Controls Table Title Check
  public async USHIPAAControlsTableTitleCheck() {
    try {
      await test.step("Navigate to the US HIPAA Detail View page", async () => {
        logger.info("Navigating to the US HIPAA Detail View page.");
        await this.page.waitForSelector(cs.detailViewHIPAA);
        logger.info("US HIPAA Detail View selector is visible.");
        await this.page.click(cs.detailViewHIPAA);
        logger.info("Clicked on the US HIPAA Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      const tabTexts = [
        "Control Code",
        "Title",
        "Domain",
        "Control Description",
        "Requirements",
      ];

      for (let i = 0; i < tabTexts.length; i++) {
        const tabText = tabTexts[i];

        const gettext =
          await test.step(`Check table title: ${tabText}`, async () => {
            console.log("Selector being used:", cs.HIPAATableTitle(i));
            const element = await this.page.waitForSelector(
              cs.HIPAATableTitle(i + 1),
            );
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
      logger.error(
        `Error in US HIPAA Controls Table Title Check: ${error.message}`,
      );
      throw error;
    }
  }
  // HIPAA control code Links Navigation Check
  public async HIPAAcontrolcodeLinksNavigationCheck() {
    try {
      await test.step("Navigate to the US HIPAA Detail View page", async () => {
        logger.info("Navigating to the US HIPAA Detail View page.");
        await this.page.waitForSelector(cs.detailViewHIPAA);
        logger.info("US HIPAA Detail View selector is visible.");
        await this.page.click(cs.detailViewHIPAA);
        logger.info("Clicked on the US HIPAA Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      const count = await this.page.locator(cs.controlCodeColnData).count();
      logger.info(`Found ${count} control codes to validate.`);

      for (let i = 1; i <= count; i++) {
        await test.step(`Validate control code #${i}`, async () => {
          const data = await this.page.waitForSelector(
            cs.controlCodeColnDataLink(i),
          );
          logger.info(`Found control code link #${i}.`);

          const gettext = (await data?.textContent())?.trim();
          logger.info(`Control code text: ${gettext}`);

          await test.step(`Click on control code link #${i}`, async () => {
            logger.info(`Clicking on control code link #${i}.`);
            await data.click();
            logger.info(`Clicked on control code link #${i}.`);
          });

          await this.page.waitForLoadState("networkidle");
          const data1 = await this.page.waitForSelector(
            cs.controlCodeColnDataDetail,
          );
          const linkText1 = (await data1?.textContent())?.trim();
          logger.info(`Link text captured on detail page: ${linkText1}`);

          await test.step(`Verify if the link texts match for control code #${i}`, async () => {
            logger.info(
              `Verifying that text '${gettext}' matches with detail page text '${linkText1}'.`,
            );
            expect(gettext).toBe(linkText1);
            logger.info(`Link texts match for control code #${i}.`);
          });

          await test.step(`Go back to the HIPAA detail view page after control code #${i}`, async () => {
            await this.page.goBack();
            logger.info(`Navigated back to the US HIPAA Detail View page.`);
            await this.page.waitForLoadState("networkidle");
          });
        });
      }
    } catch (error) {
      logger.error(
        `Error in US HIPAA Controls Table Title Check: ${error.message}`,
      );
      throw error;
    }
  }
  // NIST control code Links Navigation Check
  public async NISTcontrolcodeLinksNavigationCheck() {
    try {
      await test.step("Navigate to the NIST Detail View page", async () => {
        logger.info("Navigating to the NIST Detail View page.");
        await this.page.waitForSelector(cs.detailViewNIST);
        logger.info("NIST Detai Detail View selector is visible.");
        await this.page.click(cs.detailViewNIST);
        logger.info("Clicked on the NIST Detai Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      const count = await this.page.locator(cs.controlCodeColnData).count();
      logger.info(`Found ${count} control codes to validate.`);

      for (let i = 1; i <= count; i++) {
        await test.step(`Validate control code #${i}`, async () => {
          const data = await this.page.waitForSelector(
            cs.controlCodeColnDataLink(i),
          );
          logger.info(`Found control code link #${i}.`);

          const gettext = (await data?.textContent())?.trim();
          logger.info(`Control code text: ${gettext}`);

          await test.step(`Click on control code link #${i}`, async () => {
            logger.info(`Clicking on control code link #${i}.`);
            await data.click();
            logger.info(`Clicked on control code link #${i}.`);
          });

          await this.page.waitForLoadState("networkidle");
          const data1 = await this.page.waitForSelector(
            cs.controlCodeColnDataDetail,
          );
          const linkText1 = (await data1?.textContent())?.trim();
          logger.info(`Link text captured on detail page: ${linkText1}`);

          await test.step(`Verify if the link texts match for control code #${i}`, async () => {
            logger.info(
              `Verifying that text '${gettext}' matches with detail page text '${linkText1}'.`,
            );
            expect(gettext).toBe(linkText1);
            logger.info(`Link texts match for control code #${i}.`);
          });

          await test.step(`Go back to the NIST detail view page after control code #${i}`, async () => {
            await this.page.goBack();
            logger.info(`Navigated back to the NIST Detail View page.`);
            await this.page.waitForLoadState("networkidle");
          });
        });
      }
    } catch (error) {
      logger.error(`Error in NIST Detail page links Check: ${error.message}`);
      throw error;
    }
  }
  // HIPAA control code Details Check
  public async HIPAAcontrolcodeDetailsCheck() {
    try {
      await test.step("Navigate to the US HIPAA Detail View page", async () => {
        logger.info("Navigating to the US HIPAA Detail View page.");
        await this.page.waitForSelector(cs.detailViewHIPAA);
        logger.info("US HIPAA Detail View selector is visible.");
        await this.page.click(cs.detailViewHIPAA);
        logger.info("Clicked on the US HIPAA Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      const checkElementTextNotBlank = async (
        selector: string,
        stepDescription: string,
      ) => {
        try {
          logger.info(`Checking the visibility of ${stepDescription} element.`);
          await this.page.waitForSelector(selector, { state: "visible" });
          const element = this.page.locator(selector);
          const text = await element.textContent();
          logger.info(`Text content of ${stepDescription}: ${text}`);
          expect(text).not.toBe("about:blank");
          logger.info(`${stepDescription} has valid content.`);
        } catch (error) {
          logger.error(
            `Error in checking ${stepDescription}: ${error.message}`,
          );
          throw error;
        }
      };

      await test.step("Check Control Code Link", async () => {
        await checkElementTextNotBlank(cs.controlCodelink, "Control Code Link");
        await this.page.locator(cs.controlCodelink).click();
      });

      await test.step("Check Control Question", async () => {
        await checkElementTextNotBlank(cs.controlQuestion, "Control Question");
      });

      await test.step("Check Control Description", async () => {
        await checkElementTextNotBlank(
          cs.controlDescription,
          "Control Description",
        );
      });

      await test.step("Check Control ID", async () => {
        await checkElementTextNotBlank(cs.controlId, "Control ID");
      });

      await test.step("Check Control Domain", async () => {
        await checkElementTextNotBlank(cs.controlDomain, "Control Domain");
      });

      await test.step("Check Control SCF", async () => {
        await checkElementTextNotBlank(cs.controlSCF, "Control SCF");
      });
    } catch (error) {
      logger.error(
        `Error in US HIPAA Controls Table Title Check: ${error.message}`,
      );
      throw error;
    }
  }
// NIST control Details Check
  public async NISTcontrolDetailsCheck() {
    try {
      await test.step("Navigate to the NIST Detail View page", async () => {
        logger.info("Navigating to the NIST Detail View page.");
        await this.page.waitForSelector(cs.detailViewNIST);
        logger.info("NIST Detail View selector is visible.");
        await this.page.click(cs.detailViewNIST);
        logger.info("Clicked on the NIST Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      const checkElementTextNotBlank = async (
        selector: string,
        stepDescription: string,
      ) => {
        try {
          logger.info(`Checking the visibility of ${stepDescription} element.`);
          await this.page.waitForSelector(selector, { state: "visible" });
          const element = this.page.locator(selector);
          const text = await element.textContent();
          logger.info(`Text content of ${stepDescription}: ${text}`);
          expect(text).not.toBe("about:blank");
          logger.info(`${stepDescription} has valid content.`);
        } catch (error) {
          logger.error(
            `Error in checking ${stepDescription}: ${error.message}`,
          );
          throw error;
        }
      };

      await test.step("Check Control Code Link", async () => {
        await checkElementTextNotBlank(
          cs.controlCodelinkNIST,
          "Control Code Link",
        );
        await this.page.locator(cs.controlCodelinkNIST).click();
      });

      await test.step("Check Control Question", async () => {
        await checkElementTextNotBlank(cs.controlQuestion, "Control Question");
      });

      await test.step("Check Control Description", async () => {
        await checkElementTextNotBlank(
          cs.controlDescription,
          "Control Description",
        );
      });

      await test.step("Check Control ID", async () => {
        await checkElementTextNotBlank(cs.controlId, "Control ID");
      });

      await test.step("Check Control Domain", async () => {
        await checkElementTextNotBlank(cs.controlDomain, "Control Domain");
      });

      await test.step("Check Control SCF", async () => {
        await checkElementTextNotBlank(cs.controlSCF, "Control SCF");
      });
    } catch (error) {
      logger.error(
        `Error in US HIPAA Controls Table Title Check: ${error.message}`,
      );
      throw error;
    }
  }
// NIST DetailView functionality Check
  public async NISTDetailViewCheck() {
    try {
      await test.step("Starting NIST Detail View Navigation Check", async () => {
        logger.info("StartingUS NIST Detail View navigation.");
        await this.page.waitForSelector(cs.detailViewNIST);
        await this.page.click(cs.detailViewNIST);
        await this.page.waitForLoadState("networkidle");
        logger.info(
          "Clicked on the NIST Detail View and waited for page to load.",
        );
      });

      await test.step("Capture navigated page title text", async () => {
        logger.info("Capturing navigated page title.");
        const element = await this.page.waitForSelector(cs.NISTControls);
        const gettext = await element?.textContent();
        if (gettext) {
          logger.info("Navigated page title captured successfully.");
        }
        expect(gettext).toBe(cs.NISTCLText);
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during NIST Detail View navigation: ${err.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // NIST controls SearchBar Functionality Check
  public async NISTcontrolsSearchBarFnCheck() {
    try {
      await test.step("Starting NIST Detail View Navigation Check", async () => {
        logger.info("Starting NIST Detail View navigation.");
        await this.page.waitForSelector(cs.detailViewNIST);
        logger.info("Detail view NIST selector is visible.");
        await this.page.click(cs.detailViewNIST);
        logger.info("Clicked on the NIST Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Waited for the page to load completely.");
      });

      await test.step("Validating Search Bar Visibility", async () => {
        const searchBar = this.page.locator(cs.searchBarSelector);
        await expect(searchBar).toBeVisible();
        logger.info("Search bar is visible.");
      });

      await test.step("Filling the Search Bar and Checking Results", async () => {
        const searchBar = this.page.locator(cs.searchBarSelector);
        await searchBar.fill(cs.searchKeywordNIST);
        logger.info(
          `Filled the search bar with keyword: "${cs.searchKeywordNIST}".`,
        );

        const searchResults = this.page.locator(cs.searchResultsSelectorNIST);
        await expect(searchResults).toBeVisible();
        logger.info("Search results are visible.");

        const resultsText = await searchResults.textContent();
        logger.info(`Search results text: "${resultsText}".`);
        expect(resultsText).toContain(cs.searchKeywordNIST);
        logger.info(
          `Search results contain the keyword: "${cs.searchKeywordNIST}".`,
        );
      });
    } catch (error) {
      const err = error as Error;
      logger.error(`Error during NIST Controls Page test: ${err.message}`);
      throw new Error(`Test failed: ${error.message}`);
    }
  }
  // NIST controls Tables Title Check
  public async NISTcontrolsTableTitleCheck() {
    try {
      await test.step("Navigate to the US HIPAA Detail View page", async () => {
        logger.info("Navigating to the US HIPAA Detail View page.");
        await this.page.waitForSelector(cs.detailViewNIST);
        logger.info("US HIPAA Detail View selector is visible.");
        await this.page.click(cs.detailViewNIST);
        logger.info("Clicked on the US HIPAA Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      const tabTexts = [
        "Control Code",
        "Title",
        "Domain",
        "Control Description",
        "Requirements",
      ];

      for (let i = 0; i < tabTexts.length; i++) {
        const tabText = tabTexts[i];

        const gettext =
          await test.step(`Check table title: ${tabText}`, async () => {
            console.log("Selector being used:", cs.HIPAATableTitle(i));
            const element = await this.page.waitForSelector(
              cs.HIPAATableTitle(i + 1),
            );
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
      logger.error(
        `Error in NIST Controls Table Title Check: ${error.message}`,
      );
      throw error;
    }
  }
  // NISTcontrols Titles Sorting functionality Check
  public async NISTcontrolsTitleSortFnCheck() {
    try {
      await test.step("Navigate to the NIST Detail View page", async () => {
        logger.info("Navigating to the NIST Detail View page.");
        await this.page.waitForSelector(cs.detailViewNIST);
        logger.info("NIST Detail View selector is visible.");
        await this.page.click(cs.detailViewNIST);
        logger.info("Clicked on the NIST Detail View.");
        await this.page.waitForLoadState("networkidle");
        logger.info("Page fully loaded after navigation.");
      });

      await test.step("Sort the Title column in ascending order", async () => {
        const columnHeader = this.page.locator(cs.titleHeader);
        logger.info("Located the Title column header.");
        await columnHeader.click();
        logger.info("Clicked to sort the Title column in ascending order.");
        const rows = this.page.locator(cs.titleColnData);
        const rowTexts = await rows.allTextContents();
        const columnData = rowTexts.map((row) => row.split("\t")[0].trim()); // Trim spaces
        const sortedData = [...columnData].sort((a, b) =>
          a.toLowerCase().localeCompare(b.toLowerCase())
        );
        console.log("Expected Sorted Data: ", sortedData);
        logger.info("Validating ascending order sorting.");
        expect(columnData).toEqual(sortedData); // Check if the data is sorted correctly
        logger.info("Title column sorted in ascending order successfully.");
      });

      await test.step("Sort the Title column in descending order", async () => {
        const columnHeader = this.page.locator(cs.titleHeader);
        await columnHeader.click();
        logger.info("Clicked to sort the Title column in descending order.");
        const rows = this.page.locator(cs.titleColnData);
        const rowTextsDesc = await rows.allTextContents();
        const columnDataDesc = rowTextsDesc.map((row) =>
          row.split("\t")[0].trim()
        );
        const sortedDataDesc = [...columnDataDesc]
          .sort((a, b) => a.toLowerCase().localeCompare(b.toLowerCase()))
          .reverse();
        console.log("Expected Sorted Data (Descending): ", sortedDataDesc);
        logger.info("Validating descending order sorting.");
        expect(columnDataDesc).toEqual(sortedDataDesc);
        logger.info("Title column sorted in descending order successfully.");
      });
    } catch (error) {
      const err = error as Error;
      logger.error(
        `Error during NIST Title Sort Functionality Test: ${err.message}`,
      );
      throw new Error(`Test failed: ${err.message}`);
    }
  }
}
