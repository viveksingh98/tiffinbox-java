package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/**
 * TWO test methods are declared below. Run it and read the Tests run: count.
 *
 * <p>plansOnHold() returns the plans a filter left behind, and today the filter leaves
 * nothing behind. JUnit 6 refuses an empty case source by default - it reports a
 * Configuration error and the build fails. allowZeroInvocations = true is the switch that
 * turns that refusal off, and with it on, the method simply is not in the count any more.
 */
class EmptySourceTest {

    /** Pretend this reads a real feed. Today it comes back empty. */
    static Stream<Arguments> plansOnHold() {
        return List.<Arguments>of().stream();
    }

    @ParameterizedTest(allowZeroInvocations = true)
    @MethodSource("plansOnHold")
    void heldPlansStillBillCorrectly(Customer c, int expected) {
        assertEquals(expected, c.monthlyBill());
    }

    @Test
    void oneOrdinaryTestSoTheClassIsNotEmpty() {
        assertEquals(7200, new Customer("Ravi", 2, 120, "VEG").monthlyBill());
    }
}
