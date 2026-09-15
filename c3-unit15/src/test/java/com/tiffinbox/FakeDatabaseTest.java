package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The fake: a real CustomerRepository over a real H2 database that happens to live in memory.
 * A fake is a working implementation with a shortcut taken - here, the shortcut is that the
 * data never reaches a disk. Nothing is stubbed, so nothing can be stubbed wrongly.
 */
class FakeDatabaseTest {

    private CustomerRepository repo;

    @BeforeEach
    void freshDatabase() throws Exception {
        Database db = new Database("jdbc:h2:mem:unit15;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        repo = new CustomerRepository(db);
    }

    @Test
    void readsTheSeededRoster() throws Exception {
        assertThat(repo.findAll())
            .extracting(Customer::name)
            .containsExactly("Meera", "Priya", "Ravi", "Sunil");
    }

    @Test
    void sumsTheMonthsRevenue() throws Exception {
        assertThat(repo.monthRevenue()).isEqualTo(24300);
        assertThat(repo.pausedDays()).isEqualTo(5);
    }
}
