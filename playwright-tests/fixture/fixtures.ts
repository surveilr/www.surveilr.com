import {
  test as baseTest,
  expect,
  chromium,
  BrowserContext,
  Page,
} from "@playwright/test";

type AuthFixtures = {
  context: BrowserContext;
  page: Page;
};

const surveilr = baseTest.extend<AuthFixtures>({
  context: async ({}, use) => {
    const browser = await chromium.launch({ headless: false }); // Launch browser
    const context = await browser.newContext(); // Don't load storageState
    await use(context);
    await browser.close();
  },
  page: async ({ context }, use) => {
    const page = await context.newPage(); // Create a new page from the context
    await use(page);
    await page.close(); // Close the page after test
  },
});

export { surveilr, expect };
