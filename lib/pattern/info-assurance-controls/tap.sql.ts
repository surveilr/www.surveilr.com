import { tapNB } from "../../std/notebook/mod.ts";
type TestCaseContext = tapNB.TestCaseContext;
export class SyntheticTestSuite extends tapNB.TestSuiteNotebook {
    // any method that ends in DDL, SQL, DML, or DQL will be "arbitrary SQL"
    // and included in the SQL stream before all the test cases

    "Check if a view 'control_regimes' exists"(ctx: TestCaseContext) {
        const viewName = "control_regimes";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'control_regimes' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"control_regimes_count">(ctx)`
            SELECT COUNT(*) AS control_regimes_count FROM control_regimes`
            .greaterThan("control_regimes_count", 0);
    }

    "Check if a view 'control_group' exists"(ctx: TestCaseContext) {
        const viewName = "control_group";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'control_group' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"control_group_count">(ctx)`
            SELECT COUNT(*) AS control_group_count FROM control_group`
            .greaterThan("control_group_count", 0);
    }

    "Check if a view 'control' exists"(ctx: TestCaseContext) {
        const viewName = "control";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'control' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"control_count">(ctx)`
            SELECT COUNT(*) AS control_count FROM control`
            .greaterThan("control_count", 0);
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
