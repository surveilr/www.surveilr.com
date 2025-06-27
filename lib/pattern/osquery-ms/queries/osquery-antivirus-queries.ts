#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * osquery-antivirus-queries.ts - Antivirus and Security Software Monitoring
 * =========================================================================
 *
 * Monitors antivirus software, security tools, and critical services handling confidential data
 * across Windows, macOS, and Linux systems. Provides endpoint protection validation and compliance
 * monitoring for PCI DSS, HIPAA, and SOX regulatory requirements.
 *
 * Antivirus Monitoring Capabilities:
 * - Detects running antivirus processes by name patterns in osQuery processes table
 * - Covers major vendors: ClamAV, Sophos, Avast, McAfee, Windows Defender, chkrootkit
 * - Monitors critical services: MySQL, PostgreSQL, MongoDB, Apache, Nginx
 * - Validates security software deployment and operational status
 *
 * Code Architecture:
 * - OsqueryAntivirusQueries class extends cnb.TypicalCodeNotebook for SQL generation
 * - @osQueryMsCell decorator registers methods with 60-second execution intervals
 * - Constructor sets "rssd-antivirus-checks" notebook identifier for categorization
 * - Query methods return SQL SELECT statements targeting processes table
 * - Platform targeting: ["linux", "darwin", "windows"] for cross-platform support
 *
 * Query Methods:
 * 1. Basic Antivirus Process Check - Essential security software detection
 * 2. Extended Antivirus Process Check - Comprehensive vendor coverage
 * 3. Confidential Asset Service Check - Database and web server monitoring
 *
 * Security Benefits:
 * - Real-time endpoint protection status monitoring
 * - Privilege escalation and security gap detection
 * - Compliance audit trail generation
 * - Integration with SIEM and security operations workflows
 */

import { codeNB as cnb } from "../deps.ts";
import { osQueryMsCell } from "../decorators.ts";

export class OsqueryAntivirusQueries extends cnb.TypicalCodeNotebook {
  constructor() {
    super("rssd-antivirus-checks");
  }

  @osQueryMsCell({
    description:
      "Check for common running antivirus processes (ClamAV, Sophos, chkrootkit)",
  }, ["linux", "darwin", "windows"])
  "Basic Antivirus Process Check"() {
    return `
          SELECT pid, name, cmdline
          FROM processes
          WHERE name LIKE '%clamd%' OR name LIKE '%sophos%' OR name LIKE '%chkrootkit%';
        `;
  }

  @osQueryMsCell({
    description:
      "Extended check for antivirus processes (ClamAV, Sophos, Avast, McAfee, Windows Defender)",
  }, ["linux", "darwin", "windows"])
  "Extended Antivirus Process Check"() {
    return `
          SELECT pid, name, cmdline
          FROM processes
          WHERE name LIKE '%clamd%'
             OR name LIKE '%Sophos%'
             OR name LIKE '%avast%'
             OR name LIKE '%McAfee%'
             OR name LIKE '%defender%';
        `;
  }

  @osQueryMsCell({
    description:
      "Identify running services (databases/web servers) that may handle confidential data",
  }, ["linux", "darwin", "windows"])
  "Confidential Asset Service Check"() {
    // Note: Uses cmdline LIKE instead of name LIKE to catch services with different process names
    // but containing service identifiers in command line arguments (e.g., docker containers, custom builds)
    return `
          SELECT pid, name, cmdline
          FROM processes
          WHERE cmdline LIKE '%mysql%'
             OR cmdline LIKE '%apache%'
             OR cmdline LIKE '%postgresql%'
             OR cmdline LIKE '%nginx%'
             OR cmdline LIKE '%mongodb%';
        `;
  }
}
