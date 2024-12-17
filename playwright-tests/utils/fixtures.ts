// fixtures.ts
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

const testWithAuth = baseTest.extend<AuthFixtures>({
  context: async ({}, use) => {
    const browser = await chromium.launch();
    const context = await browser.newContext({ storageState: "auth.json" });
    await use(context);
    await browser.close();
  },
  page: async ({ context }, use) => {
    const page = await context.newPage();
    await use(page);
    await page.close();
  },
});

export { testWithAuth, expect };
