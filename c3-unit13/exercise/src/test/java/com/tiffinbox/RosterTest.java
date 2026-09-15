package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

/**
 * This test fails. Its message is:
 *
 *     expected: <true> but was: <false>
 *
 * That is everything it has to say. Somewhere in here a name is wrong and you cannot tell
 * which one from the report.
 *
 * TODO: rewrite the ONE assertion below with AssertJ, so that the failure names the roster.
 *       Then read the new message and fix what it shows you.
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
        assertTrue(roster().stream().anyMatch(c -> c.name().equals("Suneel")));
    }
}
