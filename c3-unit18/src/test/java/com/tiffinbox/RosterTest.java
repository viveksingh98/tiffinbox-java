package com.tiffinbox;

import static com.tiffinbox.CustomerBuilder.aCustomer;
import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The fixed version of breaks/shared-state/. One field, no `static`, and a @BeforeEach that
 * replaces it before every test - so no test can see what another test did, whatever order
 * they run in.
 */
class RosterTest {

    private List<Customer> roster;

    @BeforeEach
    void freshRoster() {
        roster = new ArrayList<>(List.of(
            aCustomer().named("Ravi").build(),
            aCustomer().named("Meera").eating(1).atRupees(150).ofType("NON_VEG").build()));
    }

    @Test
    void startsWithTwoCustomers() {
        assertThat(roster).hasSize(2);
    }

    @Test
    void acceptsANewCustomer() {
        roster.add(aCustomer().named("Sunil").eating(3).atRupees(100).build());

        assertThat(roster).hasSize(3);
    }

    @Test
    void namesEveryCustomerItHolds() {
        assertThat(roster).extracting(Customer::name).containsExactly("Ravi", "Meera");
    }
}
