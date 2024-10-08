---
title: Software Engineers
description: explanation on how how software engineers make use of surveilr.
---

:::tip[Tip]
- **SQLite3 CLI Tool**: The example queries on this page use **`SQLite v3.45`**. There may be slight differences if you're using an older version.
:::

## Introduction

Companies usually have security, privacy, safety and regulatory compliance policies that must be adhered to by their software engineering teams and the adherence to these policies can be validated by using `surveilr` agent to extract compliance evidence from machine attestation artifacts. `Surveilr` can help you retrieve compliance evidence from these artifacts without having to worry about filling compliance forms.


## Capturing Compliance Evidence with `surveilr` 

Resource surveillance (`surveilr`)  provides the [file ingestion](/surveilr/reference/ingest/files#ingest-files) [command](/surveilr/reference/cli/commands/) for software engineers to execute. This command captures compliance evidence from [Work Product Artifacts (WPAs)](/surveilr/reference/concepts/work-product-artifacts/) and store them in a [Resource Surveillance State Database (RSSD)](/surveilr/reference/concepts/resource-surveillance) named `resource-surveillance.sqlite.db`, under the [uniform_resource](/surveilr/reference/db/surveilr-state-schema/uniform_resource) table. 

### Evidence Types

- **Compliance Evidence**: This table shows compliance with policies
- **Non-Compliance Evidence**: This table shows non-compliance with policies. 

### Common commands 

- To [ingest files](/surveilr/reference/ingest/files#ingest-files) in the current directory:
  ```bash
  $ surveilr ingest files
  ```

- To run queries in RSSDs:
  ```sql
  sqlite3 resource-surveillance.sqlite.db "SELECT * FROM..."
  ```


## Examples of Work Product Artifacts (WPAs)

### Operating System

A company's policy might state: **"All software engineers/developers who are not working on Windows desktop or iOS native applications are required to use Debian-based Linux as their base operating system for code development."** This policy can be broken down into the following requirements:

- Use the latest stable version of Debian-based Linux as the base operating system.
- All development environments, tools, and libraries must be installed on the Linux OS.
- Regularly update the OS and development environment for compatibility and security.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies by [capturing evidence](/surveilr/disciplines/software-engineer#capturing-compliance-evidence-with-surveilr). After gathering evidence, `surveilr` captures the machine's operating system information and stores it in the [device](/surveilr/reference/db/surveilr-state-schema/device) table.


 #### SQL Query for Verification of Operating System Compliance

 ```sql
SELECT d.state_sysinfo -> 'host_name' AS 'Host Name',
       d.state_sysinfo -> 'name' AS 'OS Name',
       d.state_sysinfo -> 'distribution_id' AS 'Distribution Id',
       d.state_sysinfo -> 'kernel_version' AS 'Kernel Version',
       d.state_sysinfo -> 'os_version' AS 'OS Version',
       d.state_sysinfo -> 'long_os_version' AS 'Long OS Version'
FROM device d;


 ```

 #### Compliance Evidence

 | Host Name       | OS Name | Distribution Id | Kernel Version                     | OS Version | Long OS Version     |
|-----------------|---------|-----------------|------------------------------------|------------|---------------------|
| HostName_1  | Ubuntu  | ubuntu          | 5.15.133.1-microsoft-standard-WSL2 | 22.04      | Linux 22.04 Ubuntu  |
| HostName_2    | Ubuntu  | ubuntu          | 5.15.133.1-microsoft-standard-WSL2 | 22.04      | Linux 22.04 Ubuntu  |


 #### Non-compliance Evidence

| Host Name  | OS Name | Distribution Id | Kernel Version                    | OS Version | Long OS Version    |
| ---------- | ------- | --------------- | --------------------------------- | ---------- | ------------------ |
| HostName_1 | Ubuntu  | debian          | 4.4.0-19041-Microsoft             | 20.04      | Linux 20.04 Debian |
| HostName_2 | Fedora  | fedora          | 5.10.16.3-microsoft-standard-WSL2 | 33         | Linux 33 Fedora    |



### Unit Tests

A company's policy might state: **"All Software engineers/developers across all the projects must have a consistent code unit testing process."** This policy can be broken down into the following requirements:

- All developers who use ReactJS as programming language must use Jest and React Testing Library as the unit testing tools.
- All React developers must ensure they are following React reference Project for React code quality.


#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/software-engineer#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.


#### SQL Query for Verification of Packages Installation Compliance

 ```sql
SELECT 
    d.name AS 'Host Name',
    ur.content -> 'name' AS 'Project Name',
    ur.content -> 'devDependencies' -> 'jest' AS 'Jest With Version',
    ur.content -> 'devDependencies' -> 'jest-environment-jsdom' AS 'Jest-environment-jsdom With Version',
    ur.content -> 'devDependencies' -> '@testing-library/react' AS '@testing-library/react With Version',
    ur.content -> 'devDependencies' -> '@testing-library/jest-dom' AS '@testing-library/jest-dom With Version',
    ur.content -> 'devDependencies' -> 'ts-jest' AS 'Ts-Jest With Version'
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%package.json';
 ```

 #### Compliance Evidence

 | Host Name       | Project Name                        | Jest With Version | Jest-environment-jsdom With Version | @testing-library/react With Version | @testing-library/jest-dom With Version | Ts-Jest With Version |
|-----------------|--------------------------------------|-------------------|-------------------------------------|--------------------------------------|----------------------------------------|-----------------------|
| HostName_1  | react-code-quality-reference-project | ^29.6.2           | ^29.6.2                             | ^14.0.0                              | ^5.17.0                                | ^29.1.1               |
| HostName_2  | react-code-quality-reference-project | ^29.6.2           | ^29.6.2                             | ^14.0.0                              | ^5.17.0                                | ^29.1.1               |



#### Non-compliance Evidence

| Host Name  | Project Name                         | Jest With Version | Jest-environment-jsdom With Version | @testing-library/react With Version | @testing-library/jest-dom With Version | Ts-Jest With Version |
| ---------- | ------------------------------------ | ----------------- | ----------------------------------- | ----------------------------------- | -------------------------------------- | -------------------- |
| HostName_1 | react-code-quality-reference-project | ^26.6.0           | ^26.6.0                             | ^10.0.0                             | ^4.2.0                                 | ^26.5.0              |
| HostName_2 | react-code-quality-reference-project | ^26.6.0           | ^26.6.0                             | ^10.0.0                             | ^4.2.0                                 | ^26.5.0              |


#### SQL Query for Verification of Unit Test Script Compliance

 ```sql
SELECT 
    d.name AS 'Host Name',
    ur.content -> 'name' AS 'Project Name',
    ur.content -> 'scripts' -> 'test' AS 'Unit Test Script'
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%package.json';
 ```

#### Compliance Evidence

| Host Name      | Project Name                         | Unit Test Script |
| -------------- | ------------------------------------ | ---------------- |
| HostName_1 | react-code-quality-reference-project | jest --json      |
| HostName_2    | react-code-quality-reference-project | jest --json      |


#### Non-compliance Evidence

| Host Name  | Project Name                         | Unit Test Script |
| ---------- | ------------------------------------ | ---------------- |
| HostName_1 | react-code-quality-reference-project | mocha --reporter |
| HostName_2 | react-code-quality-reference-project | mocha --reporter |


### Code Coverage

A company's policy might state: **"All Software engineers/developers across all the projects must have a consistent code coverage process."** This policy can be broken down into the following requirements:

- All developers who use ReactJS as programming language must use Jest and React Testing Library as the coverage tools.
- All developers who use ReactJS as programming language must follow Code [Unit testing](/surveilr/disciplines/software-engineer#unit-tests) Policy.
- All React developers must ensure they are following React reference Project for React code quality.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/software-engineer#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Packages Installation Compliance

```sql
SELECT 
    d.name AS 'host name',
    ur.content -> 'name' AS 'project name',
    ur.content -> 'devDependencies' -> 'jest' AS 'jest with version',
    ur.content -> 'devDependencies' -> 'jest-environment-jsdom' AS 'jest-environment-jsdom with version',
    ur.content -> 'devDependencies' -> '@testing-library/react' AS '@testing-library/react with version',
    ur.content -> 'devDependencies' -> '@testing-library/jest-dom' AS '@testing-library/jest-dom with version',
    ur.content -> 'devDependencies' -> 'ts-jest' AS 'ts-jest with version'
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%package.json';
```

#### Compliance Evidence

 | Host Name  | Project Name                         | Jest With Version | Jest-environment-jsdom With Version | @testing-library/react With Version | @testing-library/jest-dom With Version | Ts-Jest With Version |
 | ---------- | ------------------------------------ | ----------------- | ----------------------------------- | ----------------------------------- | -------------------------------------- | -------------------- |
 | HostName_1 | react-code-quality-reference-project | ^29.6.2           | ^29.6.2                             | ^14.0.0                             | ^5.17.0                                | ^29.1.1              |
 | HostName_2 | react-code-quality-reference-project | ^29.6.2           | ^29.6.2                             | ^14.0.0                             | ^5.17.0                                | ^29.1.1              |

#### Non-compliance Evidence

| Host Name  | Project Name                         | Jest With Version | Jest-environment-jsdom With Version | @testing-library/react With Version | @testing-library/jest-dom With Version | Ts-Jest With Version |
| ---------- | ------------------------------------ | ----------------- | ----------------------------------- | ----------------------------------- | -------------------------------------- | -------------------- |
| HostName_1 | react-code-quality-reference-project | ^26.6.3           | ^26.6.3                             | ^9.0.0                              | ^4.0.0                                 | ^26.4.4              |
| HostName_2 | react-code-quality-reference-project | ^26.6.3           | ^26.6.3                             | ^9.0.0                              | ^4.0.0                                 | ^26.4.4              |



#### SQL Query for Verification of Coverage Script Compliance

```sql
SELECT 
    d.name AS 'host name', 
    ur.content -> 'name' AS 'project name', 
    ur.content -> 'scripts' -> 'test:coverage' AS 'test:coverage Script', 
    ur.content -> 'scripts' -> 'test:ci' AS 'test:ci Script'
FROM 
    uniform_resource ur
JOIN 
    device d 
ON 
    ur.device_id = d.device_id 
WHERE 
    ur.uri LIKE '%package.json';

```

#### Compliance Evidence

| Host Name  | Project Name                         | Test:coverage Script   | Test:ci Script                                                                       |
| ---------- | ------------------------------------ | ---------------------- | ------------------------------------------------------------------------------------ |
| HostName_1 | react-code-quality-reference-project | jest --coverage --json | npm run test -- --testResultsProcessor="jest-junit" --watchAll=false --ci --coverage |
| HostName_2 | react-code-quality-reference-project | jest --coverage --json | npm run test -- --testResultsProcessor="jest-junit" --watchAll=false --ci --coverage |

#### Non-compliance Evidence

| Host Name  | Project Name                         | Test:coverage Script | Test:ci Script                     |
| ---------- | ------------------------------------ | -------------------- | ---------------------------------- |
| HostName_1 | react-code-quality-reference-project | mocha --reporter     | npm test -- --reporter=mocha-junit |
| HostName_2 | react-code-quality-reference-project | mocha --reporter     | npm test -- --reporter=mocha-junit |


### E2E Testing

A company's policy might state: **"All Software engineers/developers across all the projects must have a consistent code e2e testing process."** This policy can be broken down into the following requirements:

- All developers who use ReactJS as programming language must use Playwright as the e2e testing tools.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/software-engineer#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Packages Installation Compliance

```sql
SELECT 
    d.name as 'Host Name',
    ur.content -> 'name' as 'Project Name',
    ur.content -> 'devDependencies' -> '@playwright/test' as '@playwright/test with Version'
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%package.json';
```

#### Compliance Evidence

| Host Name  | Project Name                         | @playwright/test With Version |
| ---------- | ------------------------------------ | ----------------------------- |
| HostName_1 | react-code-quality-reference-project | ^1.37.1                       |
| HostName_2 | react-code-quality-reference-project | ^1.37.1                       |


#### Non-compliance Evidence

| Host Name  | Project Name                         | @playwright/test With Version |
| ---------- | ------------------------------------ | ----------------------------- |
| HostName_1 | react-code-quality-reference-project | ^1.36.0                       |
| HostName_2 | react-code-quality-reference-project | ^1.36.0                       |



#### SQL Query for Verification of E2E Script Compliance

```sql
SELECT 
    d.name AS 'host name', 
    ur.content -> 'name' AS 'project name', 
    ur.content -> 'devDependencies' -> '@playwright/test' AS '@playwright/test with version' 
FROM 
    uniform_resource ur 
JOIN 
    device d ON ur.device_id = d.device_id 
WHERE 
    ur.uri LIKE '%package.json';
```

#### Compliance Evidence

| Host Name  | Project Name                           | E2E Script      | E2e:dot Script                              |
| ---------- | -------------------------------------- | --------------- | ------------------------------------------- |
| HostName_1 | "react-code-quality-reference-project" | playwright test | DEBUG=pw:api playwright test --reporter=dot |
| HostName_2 | "react-code-quality-reference-project" | playwright test | DEBUG=pw:api playwright test --reporter=dot |

#### Non-compliance Evidence

| Host Name  | Project Name                         | E2E Script  | E2e:dot Script                    |
| ---------- | ------------------------------------ | ----------- | --------------------------------- |
| HostName_1 | react-code-quality-reference-project | cypress run | DEBUG=cypress:cypress cypress run |
| HostName_2 | react-code-quality-reference-project | cypress run | DEBUG=cypress:cypress cypress run |


### Git Hooks
A company's policy might state: **"All Software engineers/developers across all the projects must have Githooks scripts that are executed by Git before or after certain Git events, such as committing or merging code."** This policy can be broken down into the following requirements:

- All Node.js projects must use Husky to manage Git hooks

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/software-engineer#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.


#### SQL Query for Verification of Husky Installation Compliance

```sql
SELECT 
    d.name as 'host name', 
    ur.content -> 'name' as 'project name', 
    ur.content -> 'devDependencies' -> 'husky' as 'Husky with version', 
    ur.content -> 'devDependencies' -> 'lint-staged' as 'lint-staged with version', 
    ur.content -> 'scripts' -> 'lint-staged' as 'Lint Staged Script', 
    ur.content -> 'devDependencies' -> '@commitlint/cli' as 'commitlint/cli with version', 
    ur.content -> 'devDependencies' -> '@commitlint/config-conventional' as 'commitlint/config-conventional with version' 
FROM 
    uniform_resource ur 
JOIN 
    device d 
ON 
    ur.device_id = d.device_id 
WHERE 
    ur.uri LIKE '%package.json';

```

#### Compliance Evidence

| Host Name  | Project Name                         | Husky With Version | Lint-staged With Version | Lint Staged Script                                                                             | Commitlint/cli With Version | Commitlint/config-conventional With Version |
| ---------- | ------------------------------------ | ------------------ | ------------------------ | ---------------------------------------------------------------------------------------------- | --------------------------- | ------------------------------------------- |
| HostName_1 | react-code-quality-reference-project | ^8.0.3             | ^13.2.0                  | eslint "src/**/*.{js,jsx,ts,tsx}" --quiet --fix && prettier "src/**/*.{js,jsx,ts,tsx}" --write | ^17.4.4                     | ^17.4.4                                     |
| HostName_2 | react-code-quality-reference-project | ^8.0.3             | ^13.2.0                  | eslint "src/**/*.{js,jsx,ts,tsx}" --quiet --fix && prettier "src/**/*.{js,jsx,ts,tsx}" --write | ^17.4.4                     | ^17.4.4                                     |

#### Non-compliance Evidence

| Host Name  | Project Name                         | Husky With Version | Lint-staged With Version | Lint Staged Script                                                                             | Commitlint/cli With Version | Commitlint/config-conventional With Version |
| ---------- | ------------------------------------ | ------------------ | ------------------------ | ---------------------------------------------------------------------------------------------- | --------------------------- | ------------------------------------------- |
| HostName_1 | react-code-quality-reference-project | ^7.5.0             | ^12.0.0                  | eslint "src/**/*.{js,jsx,ts,tsx}" --quiet --fix && prettier "src/**/*.{js,jsx,ts,tsx}" --write | ^16.0.0                     | ^16.0.0                                     |
| HostName_2 | react-code-quality-reference-project | ^7.5.0             | ^12.0.0                  | eslint "src/**/*.{js,jsx,ts,tsx}" --quiet --fix && prettier "src/**/*.{js,jsx,ts,tsx}" --write | ^16.0.0                     | ^16.0.0                                     |


### Code Formatting

A company's policy might state: **"All Software engineers/developers across all the projects must have a consistent code formatting process."** This policy can be broken down into the following requirements:

- All developers who use Node.js as a runtime for their programming language must use Prettier as the formatting tool. 
  
#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/software-engineer#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.


#### SQL Query for Verification of Code Formatter Installation Compliance

```sql
SELECT 
    d.name AS 'Host Name', 
    ur.content -> 'name' AS 'Project Name', 
    ur.content -> 'devDependencies' -> 'prettier' AS 'Prettier with Version', 
    ur.content -> 'devDependencies' -> 'prettier-eslint' AS 'Prettier-Eslint with Version', 
    ur.content -> 'scripts' -> 'format' AS 'Format Script' 
FROM 
    uniform_resource ur 
JOIN 
    device d ON ur.device_id = d.device_id 
WHERE 
    ur.uri LIKE '%package.json';

```

#### Compliance Evidence

| Host Name  | Project Name                           | Prettier With Version | Prettier-eslint With Version | Format Script                               |
| ---------- | -------------------------------------- | --------------------- | ---------------------------- | ------------------------------------------- |
| HostName_1 | "react-code-quality-reference-project" | ^2.8.4                | ^15.0.1                      | npx prettier --write "**/*.{js,jsx,ts,tsx}" |
| HostName_2 | "react-code-quality-reference-project" | ^2.8.4                | ^15.0.1                      | npx prettier --write "**/*.{js,jsx,ts,tsx}" |


#### Non-compliance Evidence

| Host Name  | Project Name                         | Prettier With Version | Prettier-eslint With Version | Format Script                                                                          |
| ---------- | ------------------------------------ | --------------------- | ---------------------------- | -------------------------------------------------------------------------------------- |
| HostName_1 | react-code-quality-reference-project | ^2.6.0                | ^14.0.0                      | npx eslint --fix "**/*.{js,jsx,ts,tsx}" && npx prettier --write "**/*.{js,jsx,ts,tsx}" |
| HostName_2 | react-code-quality-reference-project | ^2.6.0                | ^14.0.0                      | npx eslint --fix "**/*.{js,jsx,ts,tsx}" && npx prettier --write "**/*.{js,jsx,ts,tsx}" |


### Code Linting

A company's policy might state: **"All Software engineers/developers across all the projects must have a consistent code Linting process."** This policy can be broken down into the following requirements:

- All developers who use Node.js as a runtime for their programming language must use ESLint as the linting tool.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/software-engineer#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.


#### SQL Query for Verification of ESLint as Linting Tool Compliance

```sql
SELECT 
    d.name AS 'Host Name', 
    ur.content -> 'name' AS 'Project Name', 
    ur.content -> 'devDependencies' -> '@typescript-eslint/eslint-plugin' AS '@typescript-eslint/eslint-plugin with version', 
    ur.content -> 'devDependencies' -> '@typescript-eslint/parser' AS '@typescript-eslint/parser with version', 
    ur.content -> 'devDependencies' -> 'eslint' AS 'eslint with version', 
    ur.content -> 'devDependencies' -> 'eslint-config-prettier' AS 'eslint-config-prettier with version', 
    ur.content -> 'devDependencies' -> 'eslint-plugin-import' AS 'eslint-plugin-import with version', 
    ur.content -> 'devDependencies' -> 'eslint-plugin-prettier' AS 'eslint-plugin-prettier with version', 
    ur.content -> 'devDependencies' -> 'prettier-eslint' AS 'prettier-eslint with version', 
    ur.content -> 'devDependencies' -> 'typescript' AS 'typescript with version' 
FROM 
    uniform_resource ur 
JOIN 
    device d ON ur.device_id = d.device_id 
WHERE 
    ur.uri LIKE '%package.json';

```

#### Compliance Evidence

| Host Name  | Project Name                           | @typescript-eslint/eslint-plugin With Version | Lint-staged With Version | @typescript-eslint/parser With Version | Eslint With Version | Eslint-config-prettier With Version | Eslint-plugin-import With Version | Eslint-plugin-prettier With Version | Prettier-eslint With Version | Typescript With Version |
| ---------- | -------------------------------------- | --------------------------------------------- | ------------------------ | -------------------------------------- | ------------------- | ----------------------------------- | --------------------------------- | ----------------------------------- | ---------------------------- | ----------------------- |
| HostName_1 | "react-code-quality-reference-project" | ^5.57.0                                       | ^5.55.0                  | ^8.0.1                                 | ^8.7.0              | ^2.27.5                             | ^4.2.1                            | ^15.0.1                             | ^4.9.5                       | ^4.9.5                  |
| HostName_2 | "react-code-quality-reference-project" | ^5.57.0                                       | ^5.55.0                  | ^8.0.1                                 | ^8.7.0              | ^2.27.5                             | ^4.2.1                            | ^15.0.1                             | ^4.9.5                       | ^4.9.5                  |


#### Non-compliance Evidence

| Host Name  | Project Name                         | @typescript-eslint/eslint-plugin With Version | Lint-staged With Version | @typescript-eslint/parser With Version | Eslint With Version | Eslint-config-prettier With Version | Eslint-plugin-import With Version | Eslint-plugin-prettier With Version | Prettier-eslint With Version | Typescript With Version |
| ---------- | ------------------------------------ | --------------------------------------------- | ------------------------ | -------------------------------------- | ------------------- | ----------------------------------- | --------------------------------- | ----------------------------------- | ---------------------------- | ----------------------- |
| HostName_1 | react-code-quality-reference-project | ^6.0.0                                        | ^6.0.0                   | ^9.0.0                                 | ^9.0.0              | ^3.0.0                              | ^5.0.0                            | ^16.0.0                             | ^5.0.0                       | ^5.0.0                  |
| HostName_2 | react-code-quality-reference-project | ^6.0.0                                        | ^6.0.0                   | ^9.0.0                                 | ^9.0.0              | ^3.0.0                              | ^5.0.0                            | ^16.0.0                             | ^5.0.0                       | ^5.0.0                  |













