import { Page } from "@playwright/test";
import { v4 as uuidv4 } from "uuid";

export async function getRandomNumberBetween(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

export async function digits(num: number, count = 0): Promise<any> {
  if (num) {
    return digits(Math.floor(num / 10), ++count);
  }
  return count;
}

export async function waitForSelectorWithMinTime(
  page: Page,
  selector,
  minWaitTime = 1000,
  timeout = 120000
) {
  const startTime = Date.now();
  await page.waitForLoadState("load");
  // await page.waitForSelector(as.spinner, {
  //   state: "hidden",
  // });
  // await page.waitForSelector(as.processing, {
  //   state: "hidden",
  // });
  await page
    .waitForSelector(selector, { timeout: timeout })
    .then(async () => {
      const elapsedTime = Date.now() - startTime;
      if (elapsedTime < minWaitTime) {
        await page.waitForTimeout(minWaitTime - elapsedTime);
      }
    })
    .catch(async () => {
      const elapsedTime = Date.now() - startTime;
      if (elapsedTime < minWaitTime) {
        await page.waitForTimeout(minWaitTime - elapsedTime);
      }
    });
}
export async function getTextContent(
page: Page, selector: string, expectedText: string): Promise<string> {
  
  try {
    const element = await this.page.waitForSelector(selector);
    const gettext = await element?.textContent();
    console.log(gettext);
    
    if (gettext) {
    const trimmedText = gettext.trim();
    expect(trimmedText).toBe(expectedText);
    console.log(trimmedText);
    return trimmedText;
    
    } else {
    throw new Error(`${expectedText} element not found or empty.`);
    }
  
  } catch (error) {
    throw error;
  }
  
}

export function generateUUID(): string {
  return uuidv4();
  
}
