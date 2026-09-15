package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

/**
 * The honest half of the comparison. JUnit's assertEquals is NOT useless - handed two records
 * it prints both of them in full. What it does not do is tell you WHICH FIELD differs, and on
 * a record with a dozen components that is the whole job.
 */
class RecordMessagesTest {

    private static final Customer EXPECTED = new Customer("Ravi", 2, 120, "VEGAN");
    private static final Customer ACTUAL   = new Customer("Ravi", 2, 120, "VEG");

    @Test
    void junitAssertEqualsOnRecords() {
        assertEquals(EXPECTED, ACTUAL);
    }

    @Test
    void assertJRecursive() {
        assertThat(ACTUAL).usingRecursiveComparison().isEqualTo(EXPECTED);
    }
}
