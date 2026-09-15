package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.DynamicTest.dynamicTest;

import java.sql.SQLException;
import java.util.List;
import java.util.stream.Stream;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.TestFactory;

/**
 * The cases are not in this file. They are rows in a database, and nobody knows how many
 * there are until the connection is open. A @TestFactory returns tests that were BUILT
 * while the suite was running - one per row, each with its own name and its own result.
 */
class RosterFactoryTest {

    @TestFactory
    Stream<DynamicTest> everySeededCustomerBillsAtLeastTheMinimumPlan() throws SQLException {
        var db = new Database("jdbc:h2:mem:unit12roster;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        List<Customer> roster = new CustomerRepository(db).findAll();
        return roster.stream().map(c -> dynamicTest(
                c.name() + " bills " + c.monthlyBill(),
                () -> assertTrue(c.monthlyBill() >= 3000,
                        c.name() + " is below the 3000 minimum plan")));
    }
}
