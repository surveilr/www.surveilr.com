#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { tapNB } from "../../std/notebook/mod.ts";
type TestCaseContext = tapNB.TestCaseContext;
export class SyntheticTestSuite extends tapNB.TestSuiteNotebook {
    // any method that ends in DDL, SQL, DML, or DQL will be "arbitrary SQL"
    // and included in the SQL stream before all the test cases

    "Check if a view 'threat_model' exists"(ctx: TestCaseContext) {
        const viewName = "threat_model";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'threat_model' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"threat_model_count">(ctx)`
            SELECT COUNT(*) AS threat_model_count FROM threat_model`
            .greaterThan("threat_model_count", 0);
    }

    "Check if a view 'sql_database' exists"(ctx: TestCaseContext) {
        const viewName = "sql_database";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'sql_database' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"sql_database_count">(ctx)`
            SELECT COUNT(*) AS sql_database_count FROM threat_model`
            .greaterThan("sql_database_count", 0);
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
