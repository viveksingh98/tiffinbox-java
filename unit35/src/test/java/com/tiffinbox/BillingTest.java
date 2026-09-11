package com.tiffinbox;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class BillingTest {

    @Test
    void defaultMonthIsThirtyDays() {
        assertEquals(7200, Billing.calculateBill(2, 120));
    }

    @Test
    void nonVegSingleMeal() {
        assertEquals(4500, Billing.calculateBill(1, 150, 30));
    }

    @Test
    void rejectsImpossibleMeals() {
        var e = assertThrows(IllegalArgumentException.class, () -> Billing.calculateBill(-5, 120, 30));
        assertEquals("meals a day must be 1 to 3, got -5", e.getMessage());
    }
}
