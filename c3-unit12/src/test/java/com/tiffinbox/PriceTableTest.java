package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.stream.Stream;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.MethodSource;

/**
 * The TiffinBox price table, one case per row. Five rows, five test cases, six lines of code.
 * Every case is reported separately by the runner - that is the whole point, and the count
 * on the Results: line is the proof.
 */
class PriceTableTest {

    @ParameterizedTest
    @CsvSource({
        "2, 120,  7200",
        "1, 150,  4500",
        "3, 100,  9000",
        "1, 120,  3600",
        "4,  90, 10800"
    })
    void monthlyBillIsMealsTimesPriceTimesThirty(int mealsPerDay, int pricePerMeal, int expected) {
        assertEquals(expected, new Customer("row", mealsPerDay, pricePerMeal, "VEG").monthlyBill());
    }

    /**
     * A CSV row is text. These cases are whole Customer records with a String field that
     * contains a comma, which is exactly what a CSV cannot carry without escaping.
     */
    static Stream<Arguments> plansThatCsvCannotHold() {
        return Stream.of(
            Arguments.of(new Customer("Ravi, Jr.", 2, 120, "VEG"), 7200),
            Arguments.of(new Customer("Meera", 1, 150, "NON_VEG"), 4500),
            Arguments.of(new Customer("Sunil", 3, 100, "VEG"), 9000));
    }

    @ParameterizedTest
    @MethodSource("plansThatCsvCannotHold")
    void recordsCarryTheirOwnTypes(Customer c, int expected) {
        assertEquals(expected, c.monthlyBill());
    }
}
