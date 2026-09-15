package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * The first real test in TiffinBox. Every println below is here so the LIFECYCLE is visible
 * as output rather than described on a slide: run it and read the order Jupiter used.
 */
class CustomerTest {

    @BeforeAll
    static void beforeAll() {
        System.out.println("@BeforeAll   - once, before anything in this class");
    }

    @BeforeEach
    void beforeEach() {
        System.out.println("  @BeforeEach - a fresh start for one test");
    }

    @AfterEach
    void afterEach() {
        System.out.println("  @AfterEach  - even if the test failed");
    }

    @AfterAll
    static void afterAll() {
        System.out.println("@AfterAll    - once, after everything in this class");
    }

    @Test
    void monthlyBillIsMealsTimesPriceTimesThirty() {
        System.out.println("    test: monthlyBill");
        assertEquals(7200, new Customer("Ravi", 2, 120, "VEG").monthlyBill());
    }

    /**
     * assertAll runs EVERY assertion and reports every failure. Three separate
     * assertEquals calls would stop at the first one and hide the rest.
     */
    @Test
    void oneCustomerCheckedThreeWays() {
        System.out.println("    test: assertAll");
        Customer meera = new Customer("Meera", 1, 150, "NON_VEG");
        assertAll("meera",
                () -> assertEquals("Meera", meera.name()),
                () -> assertEquals(4500, meera.monthlyBill()),
                () -> assertEquals("NON_VEG", meera.mealType()));
    }

    /** assertThrows returns the exception, so the message can be checked too. */
    @Test
    void anEmptyRailRefusesToCookNothing() {
        System.out.println("    test: assertThrows");
        IllegalArgumentException boom = assertThrows(IllegalArgumentException.class,
                () -> java.util.List.of(1, 2, 3).subList(2, 1));
        assertEquals("fromIndex(2) > toIndex(1)", boom.getMessage());
    }

    /**
     * An assumption is not an assertion. A false assumption ABORTS the test - the report
     * says skipped, not failed - and nothing after this line runs.
     */
    @Test
    void h2OnlyWhenTheDriverIsPresent() {
        System.out.println("    test: assumeTrue");
        assumeTrue(System.getProperty("tiffinbox.db") != null,
                "no tiffinbox.db property, so there is nothing to connect to");
        throw new IllegalStateException("never reached unless -Dtiffinbox.db is set");
    }
}
