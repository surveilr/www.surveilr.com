#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { tapNB } from "../../std/notebook/mod.ts";
type TestCaseContext = tapNB.TestCaseContext;
export class SyntheticTestSuite extends tapNB.TestSuiteNotebook {
    // any method that ends in DDL, SQL, DML, or DQL will be "arbitrary SQL"
    // and included in the SQL stream before all the test cases

    "Check if a view 'border_boundary' exists"(ctx: TestCaseContext) {
        const viewName = "border_boundary";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure at least four boundaries"(ctx: TestCaseContext) {
        return this.assertThat<"boundary_count">(ctx)`
            SELECT COUNT(*) AS boundary_count FROM border_boundary`
            .equals("boundary_count", 4);
    }

    "Check if a baundary named 'User Trust Boundary' exists in the View"(
        ctx: TestCaseContext,
    ) {
        const checkBoundary = "User Trust Boundary";
        return this.assertThat<"boundary_name">(ctx)`
            SELECT name as boundary_name
              FROM border_boundary
             WHERE name = '${checkBoundary}'`
            .equals("boundary_name", `'${checkBoundary}'`);
    }

    "Check if a baundary named 'DigitalOcean Trust Boundary' exists in the View"(
        ctx: TestCaseContext,
    ) {
        const checkBoundary = "DigitalOcean Trust Boundary";
        return this.assertThat<"boundary_name">(ctx)`
            SELECT name as boundary_name
              FROM border_boundary
             WHERE name = '${checkBoundary}'`
            .equals("boundary_name", `'${checkBoundary}'`);
    }

    "Check if a baundary named 'FCR Trust Boundary' exists in the View"(
        ctx: TestCaseContext,
    ) {
        const checkBoundary = "FCR Trust Boundary";
        return this.assertThat<"boundary_name">(ctx)`
            SELECT name as boundary_name
              FROM border_boundary
             WHERE name = '${checkBoundary}'`
            .equals("boundary_name", `'${checkBoundary}'`);
    }

    "Check if a baundary named 'Hetzner Trust Boundary' exists in the View"(
        ctx: TestCaseContext,
    ) {
        const checkBoundary = "Hetzner Trust Boundary";
        return this.assertThat<"boundary_name">(ctx)`
            SELECT name as boundary_name
              FROM border_boundary
             WHERE name = '${checkBoundary}'`
            .equals("boundary_name", `'${checkBoundary}'`);
    }

    "Check if a view 'asset_service_view' exists"(ctx: TestCaseContext) {
        const viewName = "asset_service_view";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Check if a view 'server_data' exists"(ctx: TestCaseContext) {
        const viewName = "server_data";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Check if a view 'security_incident_response_view' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "security_incident_response_view";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Check if a view 'security_impact_analysis_view' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "security_impact_analysis_view";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
    const SQL = await tapNB.TestSuiteNotebook.SQL(
        new SyntheticTestSuite("synthetic_test_suite"),
    );

    console.log(SQL.join("\n"));
    console.log(`SELECT * FROM synthetic_test_suite;`);
}
