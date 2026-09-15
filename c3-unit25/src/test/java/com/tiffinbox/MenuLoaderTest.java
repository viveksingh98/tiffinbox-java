package com.tiffinbox;

import com.tiffinbox.ci.MenuLoader;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * This test passes on a Mac and fails on a Linux runner, and nothing in it is wrong.
 * That is the unit.
 */
class MenuLoaderTest {

    @Test
    void theMenuDeclaresThreeMealTypes() throws Exception {
        assertThat(MenuLoader.mealTypes()).isEqualTo(3);
    }

    @Test
    void theDashboardStillLoads() throws Exception {
        var db = new Database("jdbc:h2:mem:unit25test;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        Dashboard.View v = new Dashboard(new CustomerRepository(db)).load();
        assertThat(v.customers()).hasSize(4);
    }
}
