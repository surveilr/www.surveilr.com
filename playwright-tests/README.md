# FOPC Automation Testing

## Overview

This repository contains an automated testing solution for FOPC. The framework is implemented in Node.js,Playwright and Typescript facilitating efficient testing based on specified criteria.

# Folder Structure

.
├── fixtures
│ └── _.ts # Contains fixture definitions for test setup and teardown
├── pages
│ └── _.page.ts # Page Object Model (POM) classes for interacting with web pages
├── sections
│ └── _.section.ts # Classes representing sections or components within pages
├── selectors
│ └── _.selectors.ts # CSS and XPath selectors for elements within the web application
├── sites
│ ├── role-handle.ts # Utility functions for switching user roles based on environment variables
│ ├── url-handle.ts # Utility functions for managing different site URLs
│ └── url.ts # Definitions of URLs for different sites
├── utils
│ └── _-utils.ts # Miscellaneous utility functions and classes used across the framework
├── tests
│ └── _.test.ts # Actual test scripts written using Playwright for automation testing

## Prerequisites

Before using the automation solution, ensure the following prerequisites are met:

- **Node.js and npm:** Install Node.js and npm on your machine. You can download them from [https://nodejs.org/](https://nodejs.org/).

## Installation

1. **Navigate to Repository:**

   ```bash
   cd fopc_automation
   ```

2. **Install Dependencies:**
   ```bash
   npm install
   ```

## Running Tests

1. **Run Individual Test:**
   Navigate to the root folder and Execute the following command to run an individual test script:

   ```cmd
   Tenant=<Tenant> role=<role> store=<store> npx playwright test <test_script_name>
   ```

2. **Parallel Execution:**
   For parallel execution of tests, use the following command:

   ```cmd
   npx playwright test
   ```

3. **Group-wise Execution:**
   You can run tests based on specific tags:

   Run High Priority Smoke Tests:

   ```cmd
   npx playwright test --grep "smoke-high"
   ```

   Run Low Priority Smoke Tests:

   ```cmd
   npx playwright test --grep "smoke-low"
   ```

   Run Regression Tests:

   ```cmd
   npx playwright test --grep "regression"
   ```

## Additional Notes

- **Test Results:**
  After execution of tests results will be available in `playwright-report` folder and if we want show the report by using following command

  ```cmd
  npx playwright show-report
  ```

- **Dependency Installation:**
  Ensure all required dependencies are installed before running commands.
