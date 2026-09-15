package com.tiffinbox;

import org.junit.jupiter.api.Test;

import java.sql.Driver;
import java.util.ArrayList;
import java.util.List;
import java.util.ServiceLoader;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The two things a packaging step can silently lose, asserted here so the build goes red
 * before the jar does.
 */
class PackagedAppTest {

    @Test
    void aJdbcDriverIsRegisteredAsAService() {
        List<String> providers = new ArrayList<>();
        for (Driver d : ServiceLoader.load(Driver.class)) {
            providers.add(d.getClass().getName());
        }
        assertThat(providers).contains("org.h2.Driver");
    }

    @Test
    void theSeededDashboardIsTheOneEveryUnitHasSeen() throws Exception {
        var db = new Database("jdbc:h2:mem:unit23test;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        Dashboard.View v = new Dashboard(new CustomerRepository(db)).load();

        assertThat(v.customers()).hasSize(4);
        assertThat(v.monthRevenue()).isPositive();
    }
}
