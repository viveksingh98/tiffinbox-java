package com.tiffinbox;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * One green test, so that the throwaway repositories this unit builds are built around a
 * project that really compiles and really produces a `target/` - which is the thing the
 * .gitignore beat is about.
 */
class DashboardTest {

    @Test
    void theSeededDashboardLoads() throws Exception {
        var db = new Database("jdbc:h2:mem:unit24test;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        Dashboard.View v = new Dashboard(new CustomerRepository(db)).load();
        assertThat(v.customers()).hasSize(4);
        assertThat(v.monthRevenue()).isPositive();
    }
}
