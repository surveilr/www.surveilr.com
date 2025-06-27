#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * osquery-network-monitoring-queries.ts - Network Security and Service Monitoring
 * ===============================================================================
 *
 * Monitors network services, security protocols, VPN connections, and firewall configurations
 * on Linux systems. Provides comprehensive network security monitoring for threat detection,
 * compliance validation, and operational oversight of critical network infrastructure.
 *
 * Network Monitoring Capabilities:
 * - HTTPS service monitoring through port 443 listening service detection
 * - VPN service monitoring (OpenVPN, IPSec) via port and process analysis
 * - Secure file transfer monitoring (FTPS, SFTP) for data protection compliance
 * - SSH daemon monitoring for remote access security and authentication tracking
 * - Firewall rule analysis through iptables configuration monitoring
 * - Network service process tracking for security and performance analysis
 *
 * Security and Compliance Features:
 * - Encrypted communication service validation (HTTPS, VPN, SFTP)
 * - Remote access monitoring and authentication service tracking
 * - Firewall policy compliance and rule effectiveness analysis
 * - Network service security posture assessment and vulnerability detection
 * - Data transfer security monitoring for regulatory compliance (PCI DSS, HIPAA)
 * - Network intrusion detection through service and port monitoring
 *
 * Code Architecture:
 * - OsqueryNetworkMonitoringQueries class extends cnb.TypicalCodeNotebook for SQL generation
 * - @osQueryMsCell decorator registers methods with 60-second execution intervals
 * - Constructor sets "rssd-network-monitoring" notebook identifier for categorization
 * - Query methods target osQuery tables: listening_ports, processes, iptables
 * - Platform targeting: ["linux"] for Linux-specific network and firewall monitoring
 *
 * Query Methods:
 * 1. Listening Ports 443 - HTTPS service monitoring and SSL/TLS endpoint detection
 * 2. VPN Listening Ports - VPN service discovery (OpenVPN, IPSec ports 1194, 443, 500, 4500)
 * 3. Monitor VPN Processes - OpenVPN process monitoring and configuration tracking
 * 4. Monitor SSHD Processes - SSH daemon monitoring for remote access security
 * 5. FTPS/SFTP Listening Ports - Secure file transfer service detection (ports 22, 990)
 * 6. Running FTP/SFTP Processes - File transfer service process monitoring
 * 7. List Iptables Rules - Firewall configuration and rule analysis
 */

import { codeNB as cnb } from "../deps.ts";
import { osQueryMsCell } from "../decorators.ts";

export class OsqueryNetworkMonitoringQueries extends cnb.TypicalCodeNotebook {
  constructor() {
    super("rssd-network-monitoring");
  }

  @osQueryMsCell({
    description: "List services listening on port 443 (HTTPS)",
  }, ["linux"])
  "Osquery Listening Ports 443"() {
    // Note: Port 443 is primarily HTTPS but can also be used for VPN (SSL VPN)
    return `SELECT port,protocol,family,address,fd,socket,path,net_namespace FROM listening_ports WHERE port = 443;`;
  }

  @osQueryMsCell({
    description:
      "Check if common VPN service ports (443, 1194, 500, 4500) are listening",
  }, ["linux"])
  "Osquery VPN Listening Ports"() {
    // Note: Port 443 can be both HTTPS and VPN (SSL VPN), 1194 is OpenVPN, 500/4500 are IPSec
    // Use process correlation to distinguish between HTTPS web servers and VPN services on port 443
    return `SELECT port,protocol,family,address,fd,socket,path,net_namespace FROM listening_ports WHERE port IN (1194, 443, 500, 4500);`;
  }

  @osQueryMsCell({
    description: "Monitor VPN-related processes (e.g., OpenVPN)",
  }, ["linux"])
  "Monitor VPN Processes"() {
    return `SELECT pid, name, path, cmdline FROM processes WHERE cmdline LIKE '%openvpn%';`;
  }

  @osQueryMsCell({
    description: "Monitor network-related processes like SSH daemon (sshd)",
  }, ["linux"])
  "Monitor SSHD Processes"() {
    // Note: SSH daemon is a network service for remote access and authentication, process monitoring can track SSH connections
    return `SELECT pid, name, path, cmdline FROM processes WHERE cmdline LIKE '%sshd%';`;
  }

  @osQueryMsCell({
    description: "Check if FTPS (port 990) or SFTP (port 22) are listening",
  }, ["linux"])
  "FTPS/SFTP Listening Ports"() {
    // Note: Port 22 is primarily SSH but also handles SFTP connections, port 990 is dedicated FTPS
    // SSH daemon on port 22 provides both shell access and SFTP file transfer capabilities
    return `
          SELECT port, protocol, pid
          FROM listening_ports
          WHERE port IN (22, 990);
        `;
  }

  @osQueryMsCell({
    description:
      "List running FTP/SFTP related processes (vsftpd, proftpd, sshd)",
  }, ["linux"])
  "Running FTP/SFTP Processes"() {
    // Note: sshd provides SFTP capability in addition to shell access, vsftpd/proftpd are dedicated FTP servers
    // This query captures both dedicated FTP servers and SSH daemons that handle SFTP connections
    return `
          SELECT pid, name, cmdline
          FROM processes
          WHERE name LIKE '%vsftpd%' OR name LIKE '%proftpd%' OR name LIKE '%sshd%';
        `;
  }

  @osQueryMsCell({
    description: "List current iptables firewall rules",
  }, ["linux"])
  "List Iptables Rules"() {
    // Note: iptables is a firewall configuration, this query lists current firewall rules
    return `SELECT 
            filter_name,
            chain,
            policy,
            target,
            protocol,
            src_port,
            dst_port,
            src_ip,
            src_mask,
            iniface,
            iniface_mask,
            dst_ip,
            dst_mask,
            outiface,
            outiface_mask,
            match,
            packets,
            bytes
          FROM iptables;`;
  }
}
