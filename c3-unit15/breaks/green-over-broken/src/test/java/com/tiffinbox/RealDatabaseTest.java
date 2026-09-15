package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/** The same repository, the same method, against a database that has opinions. */
class RealDatabaseTest {

    @Test
    void findAllReturnsTheRoster() throws Exception {
        Database db = new Database("jdbc:h2:mem:broken;DB_CLOSE_DELAY=-1");
        db.createAndSeed();

        assertThat(new CustomerRepository(db).findAll())
            .extracting(Customer::name)
            .containsExactly("Meera", "Priya", "Ravi", "Sunil");
    }
}
