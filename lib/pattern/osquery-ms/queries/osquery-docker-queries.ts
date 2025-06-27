#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * osquery-docker-queries.ts - Docker Container Infrastructure Monitoring
 * =======================================================================
 *
 * Monitors Docker container infrastructure, images, networks, and daemon processes
 * on Linux and macOS systems. Provides comprehensive visibility into containerized
 * workloads for security monitoring, compliance validation, and operational oversight.
 *
 * Docker Monitoring Capabilities:
 * - Container lifecycle tracking (running, stopped, created containers)
 * - Image management monitoring (available images, tags, sizes, creation dates)
 * - Network configuration analysis (container networks, IP assignments, port mappings)
 * - Volume and storage monitoring (mount points, volume usage)
 * - Docker daemon process monitoring (resource usage, configuration, health)
 * - Host system integration (Docker host information, version tracking)
 *
 * Security and Compliance Features:
 * - Container security posture assessment through process and network monitoring
 * - Image vulnerability surface analysis via image metadata tracking
 * - Network segmentation validation through container network mapping
 * - Resource usage monitoring for capacity planning and anomaly detection
 * - Audit trail generation for container lifecycle events and configuration changes
 *
 * Code Architecture:
 * - OsqueryDockerQueries class extends cnb.TypicalCodeNotebook for SQL generation
 * - @osQueryMsCell decorator registers methods with 60-second execution intervals
 * - Constructor sets "rssd-docker" notebook identifier for categorization
 * - Query methods target osQuery docker_* tables (containers, images, networks, volumes)
 * - Platform targeting: ["linux"] primary, ["darwin", "linux"] for version/ports
 *
 * Query Methods:
 * 1. List Containers - Active container inventory and status
 * 2. List Container Images - Available images and metadata
 * 3. Container Network Information - Network configuration and IP assignments
 * 4. List Container Volumes - Storage mount points and volume management
 * 5. Container Daemon Info - Docker daemon process monitoring
 * 6. Docker Host Info - Host system Docker configuration
 * 7. Docker Image (Filtered) - Recent images with tag filtering
 * 8. Docker Network (Specific) - Appliance network configuration
 * 9. Docker Version Information - Docker installation version tracking
 * 10. Docker Container Ports - Port mapping and exposure analysis
 */

import { codeNB as cnb } from "../deps.ts";
import { osQueryMsCell } from "../decorators.ts";

export class OsqueryDockerQueries extends cnb.TypicalCodeNotebook {
    constructor() {
        super("rssd-docker");
    }

    @osQueryMsCell({ description: "List Containers." }, ["linux"])
    "List Containers"() {
        return `SELECT id, name, image, image_id, status, state, created, pid FROM docker_containers;`;
    }

    @osQueryMsCell({
        description: "List Container Images.",
    }, ["linux"])
    "List Container Images"() {
        return `SELECT * FROM docker_images;`;
    }

    @osQueryMsCell({
        description: "Container Network Information.",
    }, ["linux"])
    "Container Network Information"() {
        return `SELECT id, ip_address FROM docker_container_networks;`;
    }

    @osQueryMsCell({
        description: "List Container Volumes.",
    }, ["linux"])
    "List Container Volumes"() {
        return `SELECT mount_point, name FROM docker_volumes;`;
    }

    @osQueryMsCell({
        description: "Container Daemon Info.",
    }, ["linux"])
    "Container Daemon Info"() {
        // Note: Queries processes table instead of docker_info to get detailed daemon process metrics
        // including resource usage, permissions, and runtime statistics for the dockerd process
        return `SELECT
                  cgroup_path,
                  cmdline,
                  cwd,
                  disk_bytes_read,
                  disk_bytes_written,
                  egid,
                  euid,
                  gid,
                  name,
                  nice,
                  on_disk,
                  parent,
                  path,
                  pgroup,
                  pid,
                  root,
                  sgid,
                  strftime('%Y-%m-%d', datetime(start_time, 'unixepoch')) AS start_time,
                  state,
                  suid,
                  threads,
                  total_size,
                  uid,
                  wired_size
                FROM processes WHERE name = 'dockerd';`;
    }

    @osQueryMsCell({
        description: "Docker host Info.",
    }, ["linux"])
    "Docker host Info"() {
        return `SELECT os, os_type, architecture, cpus, memory FROM docker_info;`;
    }

    @osQueryMsCell({
        description: "Docker Image.",
    }, ["linux"])
    "Docker Image"() {
        // Note: Filters for meaningful image tags (excludes empty, none, and long tags) and limits to 5 recent images
        // Truncates IDs to 8 characters for readability and formats creation date as DD-MM-YYYY
        return `SELECT SUBSTR(id, 0, 8) AS id, strftime('%d-%m-%Y ', datetime(created, 'unixepoch')) AS created, size_bytes, tags FROM docker_images WHERE LENGTH(tags) < 20 AND tags <> '' AND tags != '<none>:<none>' LIMIT 5;`;
    }

    @osQueryMsCell({
        description: "Docker Network.",
    }, ["linux"])
    "Docker Network"() {
        // Note: Specifically filters for 'appliance' container networks and truncates IDs for readability
        // Useful for monitoring specific application or service container network configurations
        return `SELECT SUBSTR(id, 0, 8) AS container, name, SUBSTR(network_id, 0, 8) AS network, gateway, ip_address FROM docker_container_networks WHERE name = 'appliance';`;
    }

    @osQueryMsCell({
        description: "Docker version information.",
    }, ["darwin", "linux"])
    "Docker Version Information"() {
        return `select * from docker_version;`;
    }

    @osQueryMsCell({
        description: "Docker Container Ports.",
    }, ["darwin", "linux"])
    "Docker Container Ports"() {
        // Note: Excludes IPv6 wildcard addresses (::) to focus on IPv4 and specific IPv6 bindings
        // Helps filter out default IPv6 bindings that may not be relevant for monitoring
        return `select id,type,port,host_ip,host_port from docker_container_ports WHERE host_ip != '::';`;
    }
}
