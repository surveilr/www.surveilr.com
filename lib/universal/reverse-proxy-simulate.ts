#!/usr/bin/env -S deno run --allow-net

/**
 * Simple Reverse Proxy for Local Testing
 *
 * Purpose:
 * This script acts as a lightweight HTTP reverse proxy, allowing you to test
 * services locally with simulated base URLs. It’s useful for testing service behavior
 * before setting up a full-fledged reverse proxy like NGINX.
 *
 * Usage:
 * Run this script using:
 * deno run --allow-net reverse-proxy-simulate.ts <proxyPort> <targetBaseURL>
 *
 * Example:
 * - If you want to call `http://localhost:8991/lib/pattern/my-pattern` and proxy
 *   requests to a SQLPage service running at `http://localhost:3000/lib/pattern/my-pattern`,
 *   you can run:
 *   deno run --allow-net reverse-proxy-simulate.ts 8991 http://localhost:3000
 *
 * Assumptions:
 * - The target service (e.g., SQLPage) must already be running and accessible.
 * - This proxy will forward all requests from the specified port to the target base URL.
 */

import { serve } from "https://deno.land/std@0.206.0/http/server.ts";

// Ensure required arguments are provided
if (Deno.args.length < 2) {
    console.error("Usage: deno run --allow-net reverse-proxy-simulate.ts <proxyPort> <targetBaseURL>");
    Deno.exit(1);
}

// Parse arguments: proxyPort (local listening port) and targetBaseURL
const [proxyPort, targetBaseURL] = Deno.args;

// Validate the target base URL
try {
    new URL(targetBaseURL);
} catch {
    console.error(`Invalid targetBaseURL: ${targetBaseURL}`);
    Deno.exit(1);
}

// Log the proxy setup
console.log(`Reverse proxy listening on: http://localhost:${proxyPort}`);
console.log(`Proxying requests to: ${targetBaseURL}`);

// Start the reverse proxy server
serve(async (req: Request) => {
    // Determine the full URL of the incoming request
    const incomingUrl = new URL(req.url);

    // Construct the proxied URL by replacing the origin with the target base URL
    const proxiedUrl = new URL(req.url.replace(incomingUrl.origin, targetBaseURL));

    console.log(`Proxying request: ${req.method} ${incomingUrl.href} -> ${proxiedUrl.href}`);

    try {
        // Create a proxied request with the same method, headers, and body
        const proxyRequest = new Request(proxiedUrl.toString(), {
            method: req.method,
            headers: req.headers,
            body: req.body,
        });

        // Fetch the response from the target service
        const response = await fetch(proxyRequest);

        // Add custom headers for debugging purposes
        const headers = new Headers(response.headers);
        headers.set("X-Proxy-By", "Deno Reverse Proxy");

        // Return the proxied response to the client
        return new Response(response.body, {
            status: response.status,
            headers,
        });
    } catch (error) {
        // Log and return an error response if something goes wrong
        console.error(`Error during proxying: ${error.message}`);
        return new Response("Proxy error: " + error.message, { status: 502 });
    }
}, { port: parseInt(proxyPort, 10) });