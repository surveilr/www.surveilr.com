---
title: Technical Writers
description: explanation on how technical writers  make use of surveilr.
---



<!-- 
DevOps engineers are responsible for ensuring the smooth deployment and operation of applications. This includes preparing environments, managing CI/CD pipelines, performing database migrations, and monitoring application performance. `Surveilr` helps DevOps engineers validate adherence to these processes by extracting compliance evidence from machine attestation artifacts, simplifying the process of maintaining compliance without the need for manual documentation.

### Ensuring Compliance

DevOps engineers can execute a [file ingestion command](/surveilr/reference/ingest/files#ingest-files) to ingest all files in the current working directory. These files are stored in a [Resource Surveillance State Database (RSSD)](/surveilr/reference/concepts/resource-surveillance) named `resource-surveillance.sqlite.db`, under the [uniform_resource](/surveilr/reference/db/surveilr-state-schema/uniform_resource) table.

### Evidence Types

- **Compliance Evidence**: Shows adherence to policies.
- **Non-Compliance Evidence**: Highlights deviations from policies.

### Common Commands

To ingest files in the current directory:

```bash
surveilr ingest files
```

To run queries in [RSSDs](/surveilr/reference/concepts/resource-surveillance):

```bash
$ sqlite3 resource-surveillance.sqlite.db "SELECT * FROM..."
```

## Examples of Work Product Artifacts (WPAs)

### Environment Preparation

A company's policy might state: **"All production and staging environments must be prepared and configured according to best practices before deployment."** This policy includes the following requirements:

- Ensure infrastructure readiness.
- Configure environments properly.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies. `Surveilr` captures relevant data and stores it under the appropriate tables in the RSSD.

#### SQL Query for Verification of Environment Preparation

```sql
SELECT
    d.state_sysinfo -> 'host_name' AS 'Host Name',
    e.environment AS 'Environment',
    e.status AS 'Status',
    e.last_check_date AS 'Last Check Date'
FROM
    environment_preparation e
JOIN
    device d ON e.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Environment | Status | Last Check Date |
| ---------- | ----------- | ------ | --------------- |
| HostName_1 | Production  | Ready  | 2024-06-01      |
| HostName_2 | Staging     | Ready  | 2024-06-10      |

#### Non-compliance Evidence

| Host Name  | Environment | Status    | Last Check Date |
| ---------- | ----------- | --------- | --------------- |
| HostName_1 | Production  | Not Ready | 2024-05-15      |
| HostName_2 | Staging     | Not Ready | 2024-06-01      |

### Application Packaging

A company's policy might state: **"All applications and their dependencies must be packaged into deployable artifacts."** This policy includes the following requirements:

- Use Docker containers, WAR files, or executable binaries.
- Ensure all dependencies are included.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies and query the RSSD for compliance proofs.

#### SQL Query for Verification of Application Packaging

```sql
SELECT
    d.name AS 'Host Name',
    a.artifact_name AS 'Artifact Name',
    a.artifact_type AS 'Artifact Type',
    a.compliance_status AS 'Compliance Status',
    a.creation_date AS 'Creation Date'
FROM
    application_packaging a
JOIN
    device d ON a.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Artifact Name | Artifact Type | Compliance Status | Creation Date |
| ---------- | ------------- | ------------- | ----------------- | ------------- |
| HostName_1 | AppContainer  | Docker        | Compliant         | 2024-06-01    |
| HostName_2 | AppBinary     | Executable    | Compliant         | 2024-06-10    |

#### Non-compliance Evidence

| Host Name  | Artifact Name | Artifact Type | Compliance Status | Creation Date |
| ---------- | ------------- | ------------- | ----------------- | ------------- |
| HostName_1 | AppContainer  | Docker        | Non-Compliant     | 2024-05-15    |
| HostName_2 | AppBinary     | Executable    | Non-Compliant     | 2024-06-01    |

### CI/CD Pipeline Configuration

A company's policy might state: **"All code deployments must go through a CI/CD pipeline."** This policy includes the following requirements:

- Use tools like Jenkins, GitLab CI, or GitHub Actions.
- Automate build, testing, and deployment processes.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies and query the RSSD for compliance proofs.

#### SQL Query for Verification of CI/CD Pipeline

```sql
SELECT
    d.name AS 'Host Name',
    c.pipeline_name AS 'Pipeline Name',
    c.status AS 'Pipeline Status',
    c.last_run_date AS 'Last Run Date',
    c.security_scan_passed AS 'Security Scan Passed'
FROM
    cicd_compliance c
JOIN
    device d ON c.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Pipeline Name     | Pipeline Status | Last Run Date | Security Scan Passed |
| ---------- | ----------------- | --------------- | ------------- | -------------------- |
| HostName_1 | Build and Deploy  | Successful      | 2024-06-01    | Yes                  |
| HostName_2 | Integration Tests | Successful      | 2024-06-10    | Yes                  |

#### Non-compliance Evidence

| Host Name  | Pipeline Name     | Pipeline Status | Last Run Date | Security Scan Passed |
| ---------- | ----------------- | --------------- | ------------- | -------------------- |
| HostName_1 | Build and Deploy  | Failed          | 2024-05-15    | No                   |
| HostName_2 | Integration Tests | Failed          | 2024-06-01    | No                   |

### Database Migrations

A company's policy might state: **"All database schema changes or migrations required for new releases must be performed carefully to ensure data integrity and consistency."** This policy includes the following requirements:

- Perform necessary schema changes.
- Ensure data integrity and consistency.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies and query the RSSD for compliance proofs.

#### SQL Query for Verification of Database Migrations

```sql
SELECT
    d.name AS 'Host Name',
    m.migration_id AS 'Migration ID',
    m.status AS 'Status',
    m.execution_date AS 'Execution Date'
FROM
    database_migrations m
JOIN
    device d ON m.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Migration ID  | Status     | Execution Date |
| ---------- | ------------- | ---------- | -------------- |
| HostName_1 | 2024_06_01_01 | Successful | 2024-06-01     |
| HostName_2 | 2024_06_10_02 | Successful | 2024-06-10     |

#### Non-compliance Evidence

| Host Name  | Migration ID  | Status | Execution Date |
| ---------- | ------------- | ------ | -------------- |
| HostName_1 | 2024_05_15_01 | Failed | 2024-05-15     |
| HostName_2 | 2024_06_01_02 | Failed | 2024-06-01     |

### Rollout Strategy

A company's policy might state: **"All application deployments must follow a planned rollout strategy to minimize downtime and mitigate risks."** This policy includes the following requirements:

- Plan phased deployments, canary releases, or blue-green deployments.
- Minimize downtime and mitigate risks.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies and query the RSSD for compliance proofs.

#### SQL Query for Verification of Rollout Strategy

```sql
SELECT
    d.name AS 'Host Name',
    r.strategy AS 'Rollout Strategy',
    r.status AS 'Status',
    r.execution_date AS 'Execution Date'
FROM
    rollout_strategy r
JOIN
    device d ON r.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Rollout Strategy | Status    | Execution Date |
| ---------- | ---------------- | --------- | -------------- |
| HostName_1 | Blue-Green       | Completed | 2024-06-01     |
| HostName_2 | Canary Release   | Completed | 2024-06-10     |

#### Non-compliance Evidence

| Host Name  | Rollout Strategy | Status | Execution Date |
| ---------- | ---------------- | ------ | -------------- |
| HostName_1 | Blue-Green       | Failed | 2024-05-15     |
| HostName_2 | Canary Release   | Failed | 2024-06-01     |

### Post-Deployment Verification

A company's policy might state: **"All deployments must include post-deployment verification to ensure that the application is operational."** This policy includes the following requirements

:

- Conduct smoke tests.
- Verify basic functionality.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies and query the RSSD for compliance proofs.

#### SQL Query for Verification of Post-Deployment

```sql
SELECT
    d.name AS 'Host Name',
    p.test_name AS 'Test Name',
    p.status AS 'Status',
    p.execution_date AS 'Execution Date'
FROM
    post_deployment_verification p
JOIN
    device d ON p.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Test Name  | Status | Execution Date |
| ---------- | ---------- | ------ | -------------- |
| HostName_1 | Smoke Test | Passed | 2024-06-01     |
| HostName_2 | Smoke Test | Passed | 2024-06-10     |

#### Non-compliance Evidence

| Host Name  | Test Name  | Status | Execution Date |
| ---------- | ---------- | ------ | -------------- |
| HostName_1 | Smoke Test | Failed | 2024-05-15     |
| HostName_2 | Smoke Test | Failed | 2024-06-01     |

### Monitoring and Alerting

A company's policy might state: **"All deployed applications must have monitoring and alerting systems in place to track performance and notify stakeholders of issues."** This policy includes the following requirements:

- Set up monitoring and alerting systems.
- Track application performance, resource utilization, and health indicators.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies and query the RSSD for compliance proofs.

#### SQL Query for Verification of Monitoring and Alerting

```sql
SELECT
    d.name AS 'Host Name',
    m.monitoring_tool AS 'Monitoring Tool',
    m.alerting_tool AS 'Alerting Tool',
    m.alerts_enabled AS 'Alerts Enabled',
    m.last_check_date AS 'Last Check Date'
FROM
    monitoring_alerting m
JOIN
    device d ON m.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Monitoring Tool | Alerting Tool | Alerts Enabled | Last Check Date |
| ---------- | --------------- | ------------- | -------------- | --------------- |
| HostName_1 | Prometheus      | Grafana       | Yes            | 2024-06-01      |
| HostName_2 | ELK Stack       | PagerDuty     | Yes            | 2024-06-10      |

#### Non-compliance Evidence

| Host Name  | Monitoring Tool | Alerting Tool | Alerts Enabled | Last Check Date |
| ---------- | --------------- | ------------- | -------------- | --------------- |
| HostName_1 | Prometheus      | None          | No             | 2024-05-15      |
| HostName_2 | None            | PagerDuty     | No             | 2024-06-01      |

### Rollback Plan

A company's policy might state: **"All deployments must include a rollback plan to minimize disruption in case of failures."** This policy includes the following requirements:

- Develop a rollback plan.
- Ensure rollback procedures are in place.

Use `surveilr` to [ensure compliance](/surveilr/disciplines/devops-engineer#ensuring-compliance) with these policies and query the RSSD for compliance proofs.

#### SQL Query for Verification of Rollback Plan

```sql
SELECT
    d.name AS 'Host Name',
    r.rollback_plan AS 'Rollback Plan',
    r.status AS 'Status',
    r.last_updated_date AS 'Last Updated Date'
FROM
    rollback_plans r
JOIN
    device d ON r.device_id = d.device_id;
```

#### Compliance Evidence

| Host Name  | Rollback Plan | Status | Last Updated Date |
| ---------- | ------------- | ------ | ----------------- |
| HostName_1 | Plan A        | Ready  | 2024-06-01        |
| HostName_2 | Plan B        | Ready  | 2024-06-10        |

#### Non-compliance Evidence

| Host Name  | Rollback Plan | Status    | Last Updated Date |
| ---------- | ------------- | --------- | ----------------- |
| HostName_1 | Plan A        | Not Ready | 2024-05-15        |
| HostName_2 | Plan B        | Not Ready | 2024-06-01        |

By following these structured queries and ensuring the storage of evidence in the RSSD, DevOps engineers can systematically monitor and ensure adherence to company policies using `surveilr`. -->
