package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

/**
 * One list, built once, shared by three tests - and one of the three adds to it.
 *
 * <p>Whether this class passes depends entirely on which test runs first. Nothing here is
 * random: JUnit's default order is a hash of the method names, so it is the same every
 * time on the same JUnit. Change the order on purpose and the result changes with it.
 */
class RosterTest {

    private static final List<Customer> ROSTER = new ArrayList<>(List.of(
        new Customer("Ravi", 2, 120, "VEG"),
        new Customer("Meera", 1, 150, "NON_VEG")));

    @Test
    void startsWithTwoCustomers() {
        assertThat(ROSTER).hasSize(2);
    }

    @Test
    void acceptsANewCustomer() {
        ROSTER.add(new Customer("Sunil", 3, 100, "VEG"));

        assertThat(ROSTER).hasSize(3);
    }

    @Test
    void namesEveryCustomerItHolds() {
        assertThat(ROSTER).extracting(Customer::name).containsExactly("Ravi", "Meera");
    }
}
