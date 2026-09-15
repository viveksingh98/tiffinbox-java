package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

/**
 * Step 1 was this line:
 *
 *     assertThat(roster()).extracting(Customer::name).contains("Suneel");
 *
 * which fails with:
 *
 *     Expecting ArrayList:
 *       ["Ravi", "Meera", "Sunil"]
 *     to contain:
 *       ["Suneel"]
 *     but could not find the following element(s):
 *       ["Suneel"]
 *
 * The roster is printed, so the typo is visible: Suneel, Sunil. Step 2 fixes it.
 */
class RosterTest {

    private static List<Customer> roster() {
        return new ArrayList<>(List.of(
                new Customer("Ravi", 2, 120, "VEG"),
                new Customer("Meera", 1, 150, "NON_VEG"),
                new Customer("Sunil", 3, 100, "VEG")));
    }

    @Test
    void theKitchenKnowsAboutSunil() {
        assertThat(roster()).extracting(Customer::name).contains("Sunil");
    }
}
