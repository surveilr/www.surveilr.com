#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * osquery-user-process-mapping-queries.ts - User-Process Correlation and Access Control Monitoring
 * ================================================================================================
 *
 * Monitors user-process relationships, administrative access patterns, and privilege usage
 * on Linux systems. Provides identity and access management (IAM) visibility for security
 * monitoring, compliance validation, and privilege escalation detection.
 *
 * User-Process Mapping Capabilities:
 * - Critical service-user correlation (nginx, apache, postgres, mysql, ssh, vpn)
 * - Administrative privilege monitoring through root, admin, and sudo user tracking
 * - Network service process monitoring with user context for security validation
 * - Application-level access control validation for privileged user activities
 * - System administrator identification and privilege usage tracking
 * - Container process monitoring for containerized workload user context analysis
 *
 * Security and Compliance Features:
 * - Privilege escalation detection through administrative user process monitoring
 * - Service account validation ensuring proper separation of duties
 * - Access control effectiveness assessment through user-process correlation
 * - Compliance audit trail generation for SOX, PCI DSS, HIPAA requirements
 * - Insider threat detection through unusual user activity pattern identification
 * - Least privilege principle validation through service execution context analysis
 *
 * Code Architecture:
 * - OsqueryUserProcessMappingQueries class extends cnb.TypicalCodeNotebook for SQL generation
 * - @osQueryMsCell decorator registers methods with 60-second execution intervals
 * - Constructor sets "rssd-user-process-mapping" notebook identifier for categorization
 * - Query methods use JOIN operations between processes and users tables for correlation
 * - Platform targeting: ["linux"] for Linux-specific user and process monitoring
 *
 * Query Methods:
 * 1. User List by IT Layer - Critical service-user correlation for infrastructure monitoring
 * 2. Admin Network Services Processes - Privileged network service execution monitoring
 * 3. Admin Application Processes - Administrative application execution tracking
 * 4. Application Access Rights - Application-level access control validation
 * 5. OS Admin Users - System administrator identification and privilege tracking
 * 6. All Container Processes - Container process execution pattern monitoring
 */

import { codeNB as cnb } from "../deps.ts";
import { osQueryMsCell } from "../decorators.ts";

export class OsqueryUserProcessMappingQueries extends cnb.TypicalCodeNotebook {
  constructor() {
    super("rssd-user-process-mapping");
  }

  @osQueryMsCell({
    description:
      "User-Process Mapping: Get process info with associated user for OS, DB, App, and network services",
  }, ["linux"])
  "Osquery User List by IT Layer"() {
    // Note: Critical service-user correlation for infrastructure monitoring
    return `
          SELECT 
            p.pid, 
            p.name, 
            u.username, 
            p.path, 
            p.cmdline 
          FROM processes p
          JOIN users u ON p.uid = u.uid
          WHERE 
            p.name LIKE '%nginx%' OR 
            p.name LIKE '%apache%' OR 
            p.name LIKE '%postgres%' OR 
            p.name LIKE '%mysqld%' OR 
            p.name LIKE '%ssh%' OR 
            p.name LIKE '%vpn%';
        `;
  }

  @osQueryMsCell({
    description:
      "Admin Processes: List processes for network services run by superusers",
  }, ["linux"])
  "Osquery Admin Network Services Processes"() {
    // Note: Privileged network service execution monitoring
    return `
          SELECT 
            p.pid, 
            p.name, 
            u.username, 
            p.path, 
            p.cmdline 
          FROM processes p
          JOIN users u ON p.uid = u.uid
          WHERE 
            (p.name LIKE 'nginx%' OR p.name LIKE 'apache%' OR p.name LIKE 'postgres%' OR p.name LIKE 'mysqld%')
            AND (u.username LIKE 'root%' OR u.username LIKE 'admin%' OR u.username LIKE '%sudo%');
        `;
  }

  @osQueryMsCell({
    description:
      "Admin Processes: Identify apps run by administrator-level users",
  }, ["linux"])
  "Osquery Admin Application Processes"() {
    // Note: Administrative application execution tracking
    return `
          SELECT 
            p.pid, 
            p.name, 
            u.username, 
            p.path 
          FROM processes p
          JOIN users u ON p.uid = u.uid
          WHERE 
            (p.name LIKE 'nginx%' OR p.name LIKE 'apache%' OR p.name LIKE 'postgres%' OR p.name LIKE 'mysqld%')
            AND (u.username LIKE 'root%' OR u.username LIKE 'admin%' OR u.username LIKE '%sudo%');
        `;
  }

  @osQueryMsCell({
    description:
      "Security Groups: Application-level access by admin or elevated users",
  }, ["linux"])
  "Osquery Application Access Rights"() {
    // Note: Application-level access control validation
    return `
          SELECT 
            p.pid, 
            p.name, 
            u.username, 
            p.path 
          FROM processes p
          JOIN users u ON p.uid = u.uid
          WHERE 
            (p.name LIKE 'nginx%' OR p.name LIKE 'apache%' OR p.name LIKE 'postgres%' OR p.name LIKE 'mysqld%')
            AND (u.username LIKE 'root%' OR u.username LIKE 'admin%' OR u.username LIKE '%sudo%');
        `;
  }

  @osQueryMsCell({
    description: "Security Groups: List admin users for operating system layer",
  }, ["linux"])
  "Osquery OS Admin Users"() {
    // Note: System administrator identification and privilege tracking
    return `
          SELECT 
            username, 
            uid, 
            gid, 
            shell, 
            directory 
          FROM users 
          WHERE 
            username LIKE 'root%' OR 
            username LIKE 'admin%' OR 
            username LIKE '%sudo%';
        `;
  }

  @osQueryMsCell({
    description: "Osquery All Container Processes",
  }, ["linux"])
  "Osquery All Container Processes"() {
    // Note: Container process execution pattern monitoring
    return `SELECT
                      name,
                      path,
                      state,
                      strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) AS start_time
                    FROM
                      processes
                    WHERE
                      (strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')), name, path, start_time) IN (
                        SELECT
                          strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) AS day,
                          name,
                          path,
                          MAX(start_time)
                        FROM
                          processes
                        GROUP BY
                          day, name, path
                      );`;
  }
}
