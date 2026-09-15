package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

/** Three assertions in a row. The report will name exactly one problem. */
class StopsAtTheFirstTest {

    @Test
    void priyaIsCheckedThreeWays() {
        Customer priya = new Customer("Priya", 1, 120, "VEGAN");
        assertEquals("Priya", priya.name());
        assertEquals(9999, priya.monthlyBill());   // wrong on purpose
        assertEquals("VEG", priya.mealType());     // ALSO wrong, and you will not hear about it
    }
}
