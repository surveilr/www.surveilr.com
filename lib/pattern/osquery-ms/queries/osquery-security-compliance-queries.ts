#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * osquery-security-compliance-queries.ts - Security Controls and Compliance Monitoring
 * ====================================================================================
 *
 * Monitors security controls, authentication mechanisms, access policies, and compliance
 * configurations on Linux systems. Provides comprehensive security posture assessment
 * for regulatory compliance (SOX, PCI DSS, HIPAA, ISO 27001) and security auditing.
 *
 * Security Compliance Monitoring Capabilities:
 * - Multi-Factor Authentication (MFA) validation through PAM Google Authenticator detection
 * - SSH security configuration monitoring (root login restrictions, key-based authentication)
 * - User account management and disabled account tracking for access control validation
 * - Password policy enforcement monitoring (encryption, expiry, complexity requirements)
 * - Antivirus deployment validation through ClamAV daemon and update service detection
 * - Cryptographic key management and SSH public key infrastructure monitoring
 * - Authentication process monitoring and PAM module configuration analysis
 * - Account lockout policy validation and brute force protection assessment
 * - Audit logging system monitoring for compliance and forensic capabilities
 *
 * Regulatory Compliance Features:
 * - Access control validation for segregation of duties and least privilege principles
 * - Authentication strength assessment through MFA and key-based authentication monitoring
 * - Password policy compliance validation for regulatory requirements
 * - Audit trail integrity monitoring through syslog and logging service validation
 * - Endpoint protection compliance through antivirus status verification
 * - Cryptographic control validation through SSH key management monitoring
 * - Account lifecycle management through disabled account and expiry tracking
 *
 * Code Architecture:
 * - OsquerySecurityComplianceQueries class extends cnb.TypicalCodeNotebook for SQL generation
 * - @osQueryMsCell decorator registers methods with 60-second execution intervals
 * - Constructor sets "rssd-security-compliance" notebook identifier for categorization
 * - Query methods target osQuery tables: augeas, users, hash, processes, file, shadow
 * - Platform targeting: ["linux"] for Linux-specific security configuration monitoring
 *
 * Query Methods:
 * 1. MFA Enabled - Google Authenticator PAM module detection in SSH configuration
 * 2. Deny Root Login - SSH root login restriction validation
 * 3. Removed User Accounts - Disabled user account tracking for access control
 * 4. Encrypted Passwords - Password file integrity and encryption validation
 * 5. Antivirus Status - ClamAV daemon and freshclam service operational verification
 * 6. Asymmetric Cryptography - SSH public key and authorized_keys file monitoring
 * 7. Password Expiry Configurations - Password policy and expiration tracking
 * 8. Authentication Related Processes - Authentication service and PAM process monitoring
 * 9. Account Lockout Configurations - Brute force protection and lockout policy validation
 * 10. Audit Logging Configurations - Syslog service monitoring for audit trail integrity
 */

import { codeNB as cnb } from "../deps.ts";
import { osQueryMsCell } from "../decorators.ts";

export class OsquerySecurityComplianceQueries extends cnb.TypicalCodeNotebook {
  constructor() {
    super("rssd-security-compliance");
  }

  @osQueryMsCell({
    description: "Osquery Mfa Enabled.",
  }, ["linux"])
  "Osquery Mfa Enabled"() {
    // Note: Google Authenticator PAM module detection in SSH configuration
    return `SELECT  node, value, label, path FROM augeas WHERE path='/etc/pam.d/sshd' AND value like '%pam_google_authenticator.so%';`;
  }

  @osQueryMsCell({
    description: "Osquery Deny Root Login.",
  }, ["linux"])
  "Osquery Deny Root Login"() {
    // Note: SSH root login restriction validation
    return `SELECT node, value, label, path FROM augeas WHERE path='/etc/ssh/sshd_config' AND label like 'PermitRootLogin' AND value like 'no';`;
  }

  @osQueryMsCell({
    description: "Osquery Removed User Accounts.",
  }, ["linux"])
  "Osquery Removed User Accounts"() {
    // Note: Disabled user account tracking for access control
    return `SELECT * FROM users WHERE shell = 'disabled';`;
  }

  @osQueryMsCell({
    description: "Osquery Encrypted Passwords.",
  }, ["linux"])
  "Osquery Encrypted Passwords"() {
    // Note: Password file integrity and encryption validation
    return `SELECT md5, sha1, sha256 from hash where path = '/etc/passwd';`;
  }

  @osQueryMsCell({
    description: "Osquery Antivirus Status.",
  }, ["linux"])
  "Osquery Antivirus Status"() {
    // Note: ClamAV daemon and freshclam service operational verification
    return `SELECT score FROM (SELECT case when COUNT(*) = 2 then 1 ELSE 0 END AS score FROM processes WHERE (name = 'clamd') OR (name = 'freshclam')) WHERE score == 1;`;
  }

  @osQueryMsCell({
    description: "Asymmetric Cryptography.",
  }, ["linux"])
  "Asymmetric Cryptography"() {
    // Note: SSH public key and authorized_keys file monitoring
    return `SELECT 
          path,
          directory,
          filename,
          inode,
          uid,
          gid,
          mode,
          device,
          size,
          block_size,
          atime,
          mtime,
          ctime,
          btime,
          hard_links,
          symlink,
          type
        FROM file WHERE (path LIKE '/home/%/.ssh/%.pub' OR path LIKE '/home/%/.ssh/authorized_keys');`;
  }

  @osQueryMsCell({
    description: "Password expiry configuration from /etc/shadow",
  }, ["linux"])
  "Password Expiry Configurations"() {
    // Note: Password policy and expiration tracking
    return `
          SELECT 
            username, 
            last_change, 
            max, 
            datetime(last_change + max * 86400, 'unixepoch') AS password_expiry
          FROM shadow;
        `;
  }

  @osQueryMsCell({
    description: "Authentication-related processes (e.g., sshd, pam, login)",
  }, ["linux"])
  "Authentication Related Processes"() {
    // Note: Authentication service and PAM process monitoring
    return `
          SELECT 
            name, 
            pid, 
            path
          FROM processes
          WHERE 
            name LIKE '%auth%' 
            OR path LIKE '%pam%' 
            OR path LIKE '%sshd%' 
            OR path LIKE '%login%' 
            OR path LIKE '%sshd_config%';
        `;
  }

  @osQueryMsCell({
    description:
      "Account lockout configuration files (e.g., pam_tally, faillock, pam_faillock) in /etc/pam.d/",
  }, ["linux"])
  "Account Lockout Configurations"() {
    // Note: Brute force protection and lockout policy validation
    return `
          SELECT 
            path, 
            mode, 
            size, 
            mtime, 
            atime, 
            ctime
          FROM file 
          WHERE path LIKE '/etc/pam.d/%'
            AND (
              path LIKE '%pam_tally%' 
              OR path LIKE '%faillock%' 
              OR path LIKE '%pam_faillock%'
            );
        `;
  }

  @osQueryMsCell({
    description:
      "Audit logging configurations — checks for active syslog processes like syslog, rsyslog, and syslog-ng",
  }, ["linux"])
  "Audit Logging Configurations"() {
    // Note: Syslog service monitoring for audit trail integrity
    return `
          SELECT 
            pid, 
            name, 
            path, 
            cmdline
          FROM processes
          WHERE 
            name LIKE '%syslog%' 
            OR name LIKE '%rsyslog%' 
            OR name LIKE '%syslog-ng%';
        `;
  }
}
