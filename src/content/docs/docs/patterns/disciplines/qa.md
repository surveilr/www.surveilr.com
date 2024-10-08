---
title: Quality Assurance Engineers
description: explanation on how quality assurance engineers make use of surveilr.
---

:::tip[Tip]
- **SQLite3 CLI Tool**: The example queries on this page use **`SQLite v3.45`**. There may be slight differences if you're using an older version.
:::

## Introduction

Quality Engineers play an essential role in ensuring that software products meet the highest quality standards. Their responsibilities include creating comprehensive test plans, designing test cases, setting up test environments, executing tests, and more. This document outlines the key activities and best practices for Quality Engineers to ensure thorough and efficient testing processes.

## Capturing Compliance Evidence with `surveilr` 

Resource surveillance (`surveilr`)  provides the [file ingestion](/surveilr/reference/ingest/files#ingest-files) [command](/surveilr/reference/cli/commands/) for QA engineers to execute. This command captures compliance evidence from [Work Product Artifacts (WPAs)](/surveilr/reference/concepts/work-product-artifacts/) and store them in a [Resource Surveillance State Database (RSSD)](/surveilr/reference/concepts/resource-surveillance) named `resource-surveillance.sqlite.db`, under the [uniform_resource](/surveilr/reference/db/surveilr-state-schema/uniform_resource) table. 

### Evidence Types

- **Compliance Evidence**: Shows adherence to policies.
- **Non-Compliance Evidence**: Indicates violations of policies.

### Common Commands

- To [ingest files](/surveilr/reference/ingest/files#ingest-files) in the current directory:
  ```bash
  $ surveilr ingest files
  ```

- To run queries in RSSDs:
  ```sql
  sqlite3 resource-surveillance.sqlite.db "SELECT * FROM..."
  ```


## Examples of Work Product Artifacts (WPAs)

### Creating a Test Plan
 
A company’s policy might state: **“All quality engineers must create a detailed test plan for each project.”** This policy can be broken down into the following requirements:

- Outline the testing approach, objectives, scope, resources, and timelines.
- Ensure the test plan is documented and accessible to all stakeholders.


#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/qa#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Test Plan Compliance

```sql
SELECT 
    d.state_sysinfo -> 'host_name' AS "Host Name",
    tp.content -> 'test_plan' AS "Test Plan"
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%test_plan.json';

```

#### Compliance Evidence

| Host Name | Test Plan       |
|-----------|-----------------|
| HostName_1| Detailed Plan 1 |
| HostName_2| Detailed Plan 2 |

#### Non-compliance Evidence

| Host Name  | Test Plan |
| ---------- | --------- |
| HostName_1 |           |
| HostName_2 |           |


### Designing Test Cases

A company's policy might state: **“All quality engineers must design test cases based on functional and non-functional requirements.”** This policy can be broken down into the following requirements:

- Base test cases on user stories and acceptance criteria.
- Ensure test cases cover all relevant functionalities.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/qa#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Designing Test Cases 

```sql
SELECT 
    ur.content -> 'name' AS "Project Name",
    ur.content -> 'test_cases' AS "Test Cases"
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%test_cases.json';
```
  
#### Compliance Evidence

| Host Name  | Project Name             | Test Cases       |
|------------|--------------------------|------------------|
| HostName_1 | project-1                | Comprehensive    |
| HostName_2 | project-2                | Comprehensive    |

###$ Non-compliance Evidence

| Host Name  | Project Name | Test Cases |
| ---------- | ------------ | ---------- |
| HostName_1 | project-1    |            |
| HostName_2 | project-2    |            |


### Setting Up Test Environments

A company’s policy might state: **“All quality engineers must set up test environments that closely resemble the production environment.”** This policy can be broken down into the following requirements:

- Set up staging environments for testing activities.
- Ensure environments are regularly updated and maintained.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/qa#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Setting Test Environments

```sql
SELECT 
    ur.content -> 'name' AS "Environment Name",
    ur.content -> 'setup_details' AS "Setup Details"
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%environment_setup.json';
```

#### Compliance Evidence

| Host Name  | Environment Name         | Setup Details     |
|------------|--------------------------|-------------------|
| HostName_1 | staging-1                | Detailed Setup 1  |
| HostName_2 | staging-2                | Detailed Setup 2  |

#### Non-compliance Evidence

| Host Name  | Environment Name | Setup Details |
| ---------- | ---------------- | ------------- |
| HostName_1 | staging-1        |               |
| HostName_2 | staging-2        |               |


### Manually Executing Test Cases

A company’s policy might state: **“All quality engineers must manually execute test cases to validate functionality, usability, and user interface.”** This policy can be broken down into the following requirements:

- Execute test cases manually.
- Document the results of each test execution.
  
#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/qa#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.
#### SQL Query for Verification of Manual Test Execution

```sql
SELECT 
    ur.content -> 'name' AS "Test Case Name",
    ur.content -> 'execution_results' AS "Execution Results"
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%manual_tests.json';
```

#### Compliance Evidence

| Host Name  | Test Case Name           | Execution Results |
|------------|--------------------------|-------------------|
| HostName_1 | test-case-1              | Pass              |
| HostName_2 | test-case-2              | Pass              |

### Non-compliance Evidence

| Host Name  | Test Case Name           | Execution Results |
|------------|--------------------------|-------------------|
| HostName_1 | test-case-1              | Fail              |
| HostName_2 | test-case-2              | Not Executed      |

### Developing and Executing Automated Test Scripts

A company’s policy might state: **“All quality engineers must develop and execute automated test scripts to improve efficiency.”** This policy can be broken down into the following requirements:

- Automate repetitive and time-consuming testing tasks.
- Increase test coverage with automated scripts.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/qa#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Automated Test Scripts

```sql
SELECT 
    ur.content -> 'name' AS "Project Name",
    ur.content -> 'scripts' -> 'test:automation' AS "Automation Script"
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%automation_tests.json';
```

#### Compliance Evidence

| Host Name  | Project Name             | Automation Script |
|------------|--------------------------|-------------------|
| HostName_1 | automation-project-1     | Pass              |
| HostName_2 | automation-project-2     | Pass              |

#### Non-compliance Evidence

| Host Name  | Project Name             | Automation Script |
|------------|--------------------------|-------------------|
| HostName_1 | automation-project-1     | Fail              |
| HostName_2 | automation-project-2     | Not Executed      |

### Performing Regression Testing

A company’s policy might state: **“All quality engineers must perform regression testing to ensure new changes do not affect existing functionality.”** This policy can be broken down into the following requirements:

- Execute regression tests after every code change.
- Document any issues found during regression testing.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/qa#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Regression Testing

```sql
SELECT 
    ur.content -> 'name' AS "Project Name",
    ur.content -> 'scripts' -> 'test:regression' AS "Regression Script"
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%regression_tests.json';
```

#### Compliance Evidence

| Host Name  | Project Name             | Regression Script |
|------------|--------------------------|-------------------|
| HostName_1 | regression-project-1     | Pass              |
| HostName_2 | regression-project-2     | Pass              |

#### Non-compliance Evidence

| Host Name  | Project Name             | Regression Script |
|------------|--------------------------|-------------------|
| HostName_1 | regression-project-1     | Fail              |
| HostName_2 | regression-project-2     | Not Executed      |

### Conducting Performance Testing

A company's policy might state: **“All quality engineers must conduct performance testing to evaluate the application's performance.”** This policy can be broken down into the following requirements:

- Use appropriate tools for performance testing.
- Document the performance benchmarks and test results.

#### Using `surveilr` for Policy Compliance and Evidence Capture
The next step is to use `surveilr` to ensure compliance with these policies, [capturing](/surveilr/disciplines/qa#capturing-compliance-evidence-with-surveilr) the necessary details and storing them under the database table.

#### SQL Query for Verification of Performance Testing

```sql
SELECT 
    ur.content -> 'name' AS "Project Name",
    ur.content -> 'scripts' -> 'test:performance' AS "Performance Script"
FROM 
    uniform_resource ur
JOIN 
    device d ON ur.device_id = d.device_id
WHERE 
    ur.uri LIKE '%performance_tests.json';
```

#### Compliance Evidence

| Host Name  | Project Name             | Performance Script |
|------------|--------------------------|--------------------|
| HostName_1 | performance-project-1    | Pass               |
| HostName_2 | performance-project-2    | Pass               |

#### Non-compliance Evidence

| Host Name  | Project Name             | Performance Script |
|------------|--------------------------|--------------------|
| HostName_1 | performance-project-1    | Fail               |
| HostName_2 | performance-project-2    | Not Executed       |
