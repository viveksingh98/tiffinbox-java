package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/**
 * Two identical parameterized tests. One takes JUnit's default display name; the other
 * spells its own with name = "...". Look at what surefire's CONSOLE prints for each, and
 * then at what target/surefire-reports/*.xml has for each. They are not the same thing.
 */
class DisplayNameTest {

    @ParameterizedTest
    @CsvSource({"2, 120, 7200", "1, 150, 4500", "3, 100, 9000", "1, 120, 3600"})
    void defaultName(int mealsPerDay, int pricePerMeal, int expected) {
        assertEquals(expected, new Customer("row", mealsPerDay, pricePerMeal, "VEG").monthlyBill());
    }

    @ParameterizedTest(name = "{0} meals x {1} rupees -> {2}")
    @CsvSource({"2, 120, 7200", "1, 150, 4500", "3, 100, 9000", "1, 120, 3600"})
    void namedPattern(int mealsPerDay, int pricePerMeal, int expected) {
        assertEquals(expected, new Customer("row", mealsPerDay, pricePerMeal, "VEG").monthlyBill());
    }
}
