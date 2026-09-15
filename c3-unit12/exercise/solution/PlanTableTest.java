package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** The five rows, handed to the runner one at a time. Same rows, same numbers, five results. */
class PlanTableTest {

    @ParameterizedTest
    @CsvSource({
        "2, 120,  7200",
        "1, 150,  4500",
        "3, 100,  9000",
        "1, 120,  3600",
        "4,  90, 10800"
    })
    void everyRowInThePlanTable(int mealsPerDay, int pricePerMeal, int expected) {
        assertEquals(expected, new Customer("row", mealsPerDay, pricePerMeal, "VEG").monthlyBill());
    }
}
