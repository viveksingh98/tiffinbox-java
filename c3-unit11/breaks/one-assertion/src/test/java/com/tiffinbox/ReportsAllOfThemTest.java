package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

/** The same three checks, handed to assertAll. Same bug, a report that names both faults. */
class ReportsAllOfThemTest {

    @Test
    void priyaIsCheckedThreeWays() {
        Customer priya = new Customer("Priya", 1, 120, "VEGAN");
        assertAll("priya",
                () -> assertEquals("Priya", priya.name()),
                () -> assertEquals(9999, priya.monthlyBill()),
                () -> assertEquals("VEG", priya.mealType()));
    }
}
