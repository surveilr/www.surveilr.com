# Surveilr Automation Testing

## Overview

This repository contains an automated testing solution for Surveilr. The framework is implemented in Node.js,Playwright and Typescript facilitating efficient testing based on specified criteria.

# Folder Structure

.
├── fixtures
│ └── _.ts # Contains fixture definitions for test setup and teardown
├── pages
│ └── _.page.ts # Page Object Model (POM) classes for interacting with web pages
├── reporters
│ └── _-utils.ts # Miscellaneous utility functions and classes used across the framework
├── sections
│ └── _.section.ts # Classes representing sections or components within pages
├── selectors
│ └── _.selectors.ts # CSS and XPath selectors for elements within the web application
├── test-results
│ ├── _-.last-run file is used to store the timestamp or metadata of the most recent run
├── testcase-details
│ └── _- testcaseDetails file serves to define and store metadata for individual test cases
├── testcases
│ └── _-test case on a site is to verify that a specific feature or functionality works as expected
├── tests
│ └── _.test.ts # Actual test scripts written using Playwright for automation testing
├── utils
│ └── _-utils.ts # Miscellaneous utility functions and classes used across the framework

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
