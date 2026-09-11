package com.tiffinbox;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class CustomerTest {

    @Test
    void raviPaysSeventyTwoHundred() {
        assertEquals(7200, new Customer("Ravi", 2, 120, true).monthlyBill());
    }

    @Test
    void csvRoundTripKeepsEveryField() {
        var meera = new Customer("Meera", 1, 150, false);
        assertEquals("Meera,1,150,false", meera.toCsv());
        assertEquals(meera, Customer.fromCsv(meera.toCsv()));
    }

    @Test
    void rejectsImpossibleMeals() {
        var e = assertThrows(TiffinBoxException.class, () -> new Customer("Ravi", -5, 120, true));
        assertEquals("meals a day must be 1 to 3, got -5", e.getMessage());
    }
}
