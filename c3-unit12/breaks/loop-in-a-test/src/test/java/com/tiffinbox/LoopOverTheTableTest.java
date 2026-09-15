package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

/** The table, walked by a for loop inside ONE test method. */
class LoopOverTheTableTest {

    private static final int[][] TABLE = {
        {2, 120,  7200},
        {1, 150,  4500},
        {3, 100,  9000},
        {1, 120,  3600},
        {4,  90, 10800}
    };

    @Test
    void everyRowInThePriceTable() {
        for (int[] row : TABLE) {
            assertEquals(row[2], new Customer("row", row[0], row[1], "VEG").monthlyBill());
        }
    }
}
