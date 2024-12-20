import { defineConfig, devices } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";

// Get the current date in YYYY-MM-DD format
const currentDate = new Date().toISOString().split("T")[0];

export default defineConfig({
  testDir: "./tests",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: process.env.CI ? 5 : 5,

  reporter: [
    [
      "html",
      {
        outputFolder: `Playwright-report-${currentDate}`,
        open: "never",
      },
    ],
    ["line"],
    [
      "./reporters/custom-json-reporter.ts", // Include the custom JSON reporter
    ],
  ],

  use: {
    baseURL: "",
    trace: "on-first-retry",
  },
});
