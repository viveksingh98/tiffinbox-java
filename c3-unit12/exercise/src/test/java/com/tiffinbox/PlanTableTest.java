package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

/**
 * TODO: the five rows below are five cases. The runner currently sees ONE test.
 *       Turn this into a @ParameterizedTest with a @CsvSource so the runner reports five.
 *       Nothing about the rows or the expected values changes - only who does the looping.
 */
class PlanTableTest {

    private static final int[][] TABLE = {
        {2, 120,  7200},
        {1, 150,  4500},
        {3, 100,  9000},
        {1, 120,  3600},
        {4,  90, 10800}
    };

    @Test
    void everyRowInThePlanTable() {
        for (int[] row : TABLE) {
            assertEquals(row[2], new Customer("row", row[0], row[1], "VEG").monthlyBill());
        }
    }
}
