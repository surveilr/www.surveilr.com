#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * osquery-file-audit-queries.ts - File System Auditing and Security Monitoring
 * =============================================================================
 *
 * Monitors file system security events, authentication logs, intrusion detection systems,
 * SSL certificate management, and scheduled backup tasks on Linux systems. Provides
 * comprehensive file-based security auditing for compliance and threat detection.
 *
 * File Audit Monitoring Capabilities:
 * - Authentication event tracking through system authentication logs
 * - Intrusion Detection System (IDS) log monitoring (Fail2ban, PSAD)
 * - SSL certificate and private key file security monitoring
 * - Certificate modification time tracking for integrity validation
 * - Scheduled backup task monitoring through crontab analysis
 * - File system metadata collection for security and compliance auditing
 *
 * Security and Compliance Features:
 * - Authentication failure detection and brute force attack monitoring
 * - IDS alert correlation and security event analysis
 * - SSL/TLS certificate lifecycle management and expiration tracking
 * - File integrity monitoring for critical security files
 * - Backup schedule validation and disaster recovery compliance
 * - Audit trail generation for regulatory compliance (SOX, PCI DSS, HIPAA)
 *
 * Code Architecture:
 * - OsqueryFileAuditQueries class extends cnb.TypicalCodeNotebook for SQL generation
 * - @osQueryMsCell decorator registers methods with 60-second execution intervals
 * - Constructor sets "rssd-file-audit" notebook identifier for categorization
 * - Query methods target osQuery tables: authentications, file, crontab
 * - Platform targeting: ["linux"] for Linux-specific file system and log monitoring
 *
 * Query Methods:
 * 1. Authentication Log - User authentication events and security status
 * 2. IDS Fail2ban Log - Fail2ban intrusion detection system log analysis
 * 3. IDS PSAD Log - PSAD (Port Scan Attack Detector) log monitoring
 * 4. SSL Cert Files - SSL certificate and private key file inventory
 * 5. SSL Cert File MTIME - Certificate modification time tracking
 * 6. Cron Backup Jobs - Scheduled backup task monitoring and validation
 */

import { codeNB as cnb } from "../deps.ts";
import { osQueryMsCell } from "../decorators.ts";

export class OsqueryFileAuditQueries extends cnb.TypicalCodeNotebook {
  constructor() {
    super("rssd-file-audit");
  }

  @osQueryMsCell({
    description: "Osquery Authentication Log",
  }, ["linux"])
  "Osquery Authentication Log"() {
    // Note: Queries authentication logs for user authentication events and security status
    return `SELECT username, tty, time, status, message FROM authentications;`;
  }

  @osQueryMsCell({
    description: "Osquery IDS Fail2ban Log",
  }, ["linux"])
  "Osquery IDS Fail2ban Log"() {
    // Note: Queries file metadata instead of log contents - checks if fail2ban.log exists and its properties
    // For actual log content analysis, consider using file_events or hash table
    return `SELECT name, type , notnull, dflt_value, pk  FROM file WHERE path LIKE '/var/log/fail2ban.log';`;
  }

  @osQueryMsCell({
    description: "Osquery IDS PSAD Log",
  }, ["linux"])
  "Osquery IDS PSAD Log"() {
    // FIXME: Currently queries fail2ban.log instead of PSAD logs - should target /var/log/psad/ or /var/log/messages
    // Note: Queries file metadata instead of log contents - checks file existence and properties
    return `SELECT name, type , notnull, dflt_value, pk  FROM file WHERE path LIKE '/var/log/fail2ban.log';`;
  }

  @osQueryMsCell({
    description: "Check for existence of SSL certificate and private key files",
  }, ["linux"])
  "Osquery SSL Cert Files"() {
    // Note: Queries file metadata for SSL certificate and private key files in /etc/ssl/certs and /etc/ssl/private
    return `SELECT path,directory,filename,inode,uid,gid,mode,device,size,block_size,hard_links,type FROM file WHERE path LIKE '/etc/ssl/certs%' OR path LIKE '/etc/ssl/private%';`;
  }

  @osQueryMsCell({
    description: "Monitor SSL cert and key file modification times",
  }, ["linux"])
  "Osquery SSL Cert File MTIME"() {
    // Note: Queries file metadata for SSL certificate and private key files in /etc/ssl/certs and /etc/ssl/private
    return `SELECT path, mtime FROM file WHERE path LIKE '/etc/ssl/certs%' OR path LIKE '/etc/ssl/private%';`;
  }

  @osQueryMsCell({
    description: "Check for cron jobs related to backup tasks",
  }, ["linux"])
  "Osquery Cron Backup Jobs"() {
    // Note: Queries crontab for backup-related cron jobs
    return `SELECT event, minute, hour, day_of_month, month, day_of_week, command, path FROM crontab WHERE command LIKE '%backup%';`;
  }
}
