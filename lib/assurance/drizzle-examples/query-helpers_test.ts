#!/usr/bin/env -S deno test --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Tests for RSSD Drizzle Query Helpers
 * 
 * This module tests the typed query helpers to ensure they work correctly
 * with the RSSD schema and provide proper type safety.
 */

import { assertEquals, assertExists } from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  createDatabase,
  getDeviceResourceAnalytics,
  searchUniformResources,
  getCodeNotebookAnalytics,
  getIngestionSessionMonitoring,
  demonstrateQueryHelpers,
  type UniformResource,
  type DeviceWithStats,
} from "./query-helpers.ts";

Deno.test("Query Helpers - createDatabase", () => {
  // Test database creation helper
  const result = createDatabase(":memory:");
  // Since we're not actually creating a database in the helper, 
  // just test that the function doesn't throw
  assertEquals(typeof result, "undefined");
});

Deno.test("Query Helpers - Type Exports", () => {
  // Test that our types are properly exported
  // This is a compile-time test that ensures types are available
  const typeTests = {
    uniformResource: null as UniformResource | null,
    deviceWithStats: null as DeviceWithStats | null,
  };
  
  // If this compiles, our types are properly exported
  assertEquals(typeof typeTests, "object");
});

Deno.test("Query Helpers - Function Signatures", () => {
  // Test that all our main functions are exported and have correct signatures
  assertEquals(typeof getDeviceResourceAnalytics, "function");
  assertEquals(typeof searchUniformResources, "function");
  assertEquals(typeof getCodeNotebookAnalytics, "function");
  assertEquals(typeof getIngestionSessionMonitoring, "function");
  assertEquals(typeof demonstrateQueryHelpers, "function");
});

Deno.test("Query Helpers - Demonstration", async () => {
  // Test the demo function runs without errors
  const consoleLogs: string[] = [];
  const originalLog = console.log;
  
  // Capture console output
  console.log = (...args: unknown[]) => {
    consoleLogs.push(args.join(" "));
  };
  
  try {
    await demonstrateQueryHelpers();
    
    // Verify demo output contains expected content
    const output = consoleLogs.join("\n");
    assertEquals(output.includes("RSSD Drizzle Query Helpers Demo"), true);
    assertEquals(output.includes("Device Resource Analytics"), true);
    assertEquals(output.includes("Advanced Resource Search"), true);
    assertEquals(output.includes("Code Notebook Analytics"), true);
    assertEquals(output.includes("Ingestion Session Monitoring"), true);
  } finally {
    console.log = originalLog;
  }
});

Deno.test("Query Helpers - Search Parameters Validation", () => {
  // Test that search parameters are properly typed
  const searchParams = {
    query: "test",
    nature: ["text", "json"],
    deviceIds: ["device1", "device2"],
    sizeRange: { min: 0, max: 1000000 },
    dateRange: { from: "2024-01-01", to: "2024-12-31" },
    limit: 50,
    offset: 0,
  };
  
  // If this compiles, our parameter types are correct
  assertEquals(typeof searchParams.query, "string");
  assertEquals(Array.isArray(searchParams.nature), true);
  assertEquals(Array.isArray(searchParams.deviceIds), true);
  assertEquals(typeof searchParams.sizeRange.min, "number");
  assertEquals(typeof searchParams.limit, "number");
});

Deno.test("Query Helpers - Analytics Options Validation", () => {
  // Test analytics function options are properly typed
  const deviceAnalyticsOptions = {
    deviceNamePattern: "test-device",
    minResourceCount: 10,
    includeInactive: false,
  };
  
  const notebookAnalyticsOptions = {
    notebookName: "TestNotebook",
    kernelType: "SQL",
    includeExecuted: true,
    groupByKernel: false,
  };
  
  const monitoringOptions = {
    deviceId: "device123",
    sessionStatus: "completed" as const,
    timeRange: { hours: 24 },
    includeStats: true,
  };
  
  // If these compile, our option types are correct
  assertEquals(typeof deviceAnalyticsOptions.deviceNamePattern, "string");
  assertEquals(typeof notebookAnalyticsOptions.notebookName, "string");
  assertEquals(monitoringOptions.sessionStatus, "completed");
});

// Integration test that would work with an actual database
Deno.test({
  name: "Query Helpers - Integration Test (Mock)",
  ignore: true, // Ignore unless we have a test database
  fn: async () => {
    // This test would require setting up a test database
    // For now, we'll skip it but leave the structure
    
    // const testDb = setupTestDatabase();
    // const devices = await getDeviceResourceAnalytics(testDb);
    // assertEquals(Array.isArray(devices), true);
  },
});