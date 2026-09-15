package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

/**
 * Three tests. All three pass. The method they are testing is wrong.
 *
 * <p>Ravi eats two meals a day at 120 rupees. His monthly bill should be 7200 and this code
 * returns 7440. Read each test below and ask the only question that matters: what would this
 * test have to see before it failed?
 */
class GreenForNothingTest {

    private static final Customer RAVI = new Customer("Ravi", 2, 120, "VEG");

    /** No assertion at all. The method is called. Nothing is checked. The runner says PASS. */
    @Test
    void theBillCanBeCalculated() {
        RAVI.monthlyBill();
    }

    /**
     * An assertion that cannot fail. Any bill above zero satisfies it, and every bill this
     * method could ever return is above zero - so this is assertTrue(true) wearing a costume.
     */
    @Test
    void theBillIsAPositiveNumber() {
        assertTrue(RAVI.monthlyBill() > 0);
    }

    /** Checking that nothing was thrown. Arithmetic does not throw, so this is free. */
    @Test
    void billingDoesNotBlowUp() {
        assertDoesNotThrow(RAVI::monthlyBill);
    }
}
