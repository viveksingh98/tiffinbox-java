package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/**
 * Two methods, the same four rows, the same wrong row 4. One takes JUnit's default display
 * name; the other spells its own. Read the CONSOLE output of both, then read
 * target/surefire-reports/TEST-com.tiffinbox.NamedCasesTest.xml.
 *
 * <p>This project deliberately has NO statelessTestsetReporter block in its pom.xml. The one
 * in c3-unit12/pom.xml is what the unit adds, and the difference is only ever visible in the
 * XML - never on the console.
 */
class NamedCasesTest {

    @ParameterizedTest
    @CsvSource({"2, 120, 7200", "1, 150, 4500", "3, 100, 9000", "1, 120, 9999"})
    void defaultName(int mealsPerDay, int pricePerMeal, int expected) {
        assertEquals(expected, new Customer("row", mealsPerDay, pricePerMeal, "VEG").monthlyBill());
    }

    @ParameterizedTest(name = "{0} meals x {1} rupees -> {2}")
    @CsvSource({"2, 120, 7200", "1, 150, 4500", "3, 100, 9000", "1, 120, 9999"})
    void namedPattern(int mealsPerDay, int pricePerMeal, int expected) {
        assertEquals(expected, new Customer("row", mealsPerDay, pricePerMeal, "VEG").monthlyBill());
    }
}
