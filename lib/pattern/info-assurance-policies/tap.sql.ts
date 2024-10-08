import { tapNB } from "../../std/notebook/mod.ts";
type TestCaseContext = tapNB.TestCaseContext;
export class SyntheticTestSuite extends tapNB.TestSuiteNotebook {
    // any method that ends in DDL, SQL, DML, or DQL will be "arbitrary SQL"
    // and included in the SQL stream before all the test cases

    "Check if a view 'policy_dashboard' exists"(ctx: TestCaseContext) {
        const viewName = "policy_dashboard";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'policy_dashboard' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"policy_dashboard_count">(ctx)`
            SELECT COUNT(*) AS policy_dashboard_count FROM policy_dashboard`
            .greaterThan("policy_dashboard_count", 0);
    }

    "Check if a view 'policy_detail' exists"(ctx: TestCaseContext) {
        const viewName = "policy_detail";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'policy_detail' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"policy_detail_count">(ctx)`
            SELECT COUNT(*) AS policy_detail_count FROM policy_detail`
            .greaterThan("policy_detail_count", 0);
    }

    "Check if a view 'policy_list' exists"(ctx: TestCaseContext) {
        const viewName = "policy_list";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'policy_list' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"policy_list_count">(ctx)`
            SELECT COUNT(*) AS policy_list_count FROM policy_list`
            .greaterThan("policy_list_count", 0);
    }

    "Check if a view 'vigetallviews' exists"(ctx: TestCaseContext) {
        const viewName = "vigetallviews";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'vigetallviews' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"vigetallviews_count">(ctx)`
            SELECT COUNT(*) AS vigetallviews_count FROM vigetallviews`
            .greaterThan("vigetallviews_count", 0);
    }

    "Check if a view 'viup_time' exists"(ctx: TestCaseContext) {
        const viewName = "viup_time";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'viup_time' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"viup_time_count">(ctx)`
            SELECT COUNT(*) AS viup_time_count FROM viup_time`
            .greaterThan("viup_time_count", 0);
    }

    "Check if a view 'viLog' exists"(ctx: TestCaseContext) {
        const viewName = "viLog";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'viLog' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"viLog_count">(ctx)`
            SELECT COUNT(*) AS viLog_count FROM viLog`
            .greaterThan("viLog_count", 0);
    }

    "Check if a view 'viencrypted_passwords' exists"(ctx: TestCaseContext) {
        const viewName = "viencrypted_passwords";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'viencrypted_passwords' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"viencrypted_passwords_count">(ctx)`
            SELECT COUNT(*) AS viencrypted_passwords_count FROM viencrypted_passwords`
            .greaterThan("viencrypted_passwords_count", 0);
    }

    "Check if a view 'vinetwork_log' exists"(ctx: TestCaseContext) {
        const viewName = "vinetwork_log";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'vinetwork_log' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"vinetwork_log_count">(ctx)`
            SELECT COUNT(*) AS vinetwork_log_count FROM vinetwork_log`
            .greaterThan("vinetwork_log_count", 0);
    }

    "Check if a view 'vissl_certificate' exists"(ctx: TestCaseContext) {
        const viewName = "vissl_certificate";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'vissl_certificate' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"vissl_certificate_count">(ctx)`
            SELECT COUNT(*) AS vissl_certificate_count FROM vissl_certificate`
            .greaterThan("vissl_certificate_count", 0);
    }

    "Check if a view 'vistorage_available' exists"(ctx: TestCaseContext) {
        const viewName = "vistorage_available";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'vistorage_available' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"vistorage_available_count">(ctx)`
            SELECT COUNT(*) AS vistorage_available_count FROM vistorage_available`
            .greaterThan("vistorage_available_count", 0);
    }

    "Check if a view 'viram_utilization' exists"(ctx: TestCaseContext) {
        const viewName = "viram_utilization";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'viram_utilization' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"viram_utilization_count">(ctx)`
            SELECT COUNT(*) AS viram_utilization_count FROM viram_utilization`
            .greaterThan("viram_utilization_count", 0);
    }

    "Check if a view 'vicpu_infomation' exists"(ctx: TestCaseContext) {
        const viewName = "vicpu_infomation";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'vicpu_infomation' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"vicpu_infomation_count">(ctx)`
            SELECT COUNT(*) AS vicpu_infomation_count FROM vicpu_infomation`
            .greaterThan("vicpu_infomation_count", 0);
    }

    "Check if a view 'viaccounts_removed' exists"(ctx: TestCaseContext) {
        const viewName = "viaccounts_removed";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'viaccounts_removed' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"viaccounts_removed_count">(ctx)`
            SELECT COUNT(*) AS viaccounts_removed_count FROM viaccounts_removed`
            .greaterThan("viaccounts_removed_count", 0);
    }

    "Check if a view 'vissh_settings' exists"(ctx: TestCaseContext) {
        const viewName = "vissh_settings";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'vissh_settings' view has values "(ctx: TestCaseContext) {
        return this.assertThat<"vissh_settings_count">(ctx)`
            SELECT COUNT(*) AS vissh_settings_count FROM vissh_settings`
            .greaterThan("vissh_settings_count", 0);
    }

    "Check if a view 'viunsuccessful_attempts_log' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "viunsuccessful_attempts_log";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'viunsuccessful_attempts_log' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"viunsuccessful_attempts_log_count">(ctx)`
            SELECT COUNT(*) AS viunsuccessful_attempts_log_count FROM viunsuccessful_attempts_log`
            .greaterThan("viunsuccessful_attempts_log_count", 0);
    }

    "Check if a view 'viauthentication' exists"(
        ctx: TestCaseContext,
    ) {
        const viewName = "viauthentication";
        return this.assertThat(ctx)`
            SELECT count(name) as exist FROM sqlite_master WHERE type = 'view' AND name = '${viewName}'`
            .case(
                `exist = 1`,
                `View "${viewName}" exists in the DB`,
                `View "${viewName}" not exists in the DB`,
            );
    }

    "Ensure 'viauthentication' view has values "(
        ctx: TestCaseContext,
    ) {
        return this.assertThat<"viauthentication_count">(ctx)`
            SELECT COUNT(*) AS viauthentication_count FROM viauthentication`
            .greaterThan("viauthentication_count", 0);
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
