package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

/**
 * One bug: Priya is not in the roster. Three tests, three assertions, three failures - and
 * three completely different amounts of help. Read the messages, not the code.
 */
class ThreeMessagesTest {

    private static List<Customer> roster() {
        return new ArrayList<>(List.of(
                new Customer("Ravi", 2, 120, "VEG"),
                new Customer("Meera", 1, 150, "NON_VEG"),
                new Customer("Sunil", 3, 100, "VEG")));
    }

    /** Java's own assert keyword. Surefire runs the forked JVM with assertions enabled. */
    @Test
    void bareAssert() {
        assert roster().stream().anyMatch(c -> c.name().equals("Priya"));
    }

    /** JUnit's assertTrue. It is handed a boolean, so a boolean is all it can report. */
    @Test
    void junitAssertTrue() {
        assertTrue(roster().stream().anyMatch(c -> c.name().equals("Priya")));
    }

    /** AssertJ is handed the LIST, so it can print the list. */
    @Test
    void assertJChain() {
        assertThat(roster()).extracting(Customer::name).contains("Priya");
    }
}
