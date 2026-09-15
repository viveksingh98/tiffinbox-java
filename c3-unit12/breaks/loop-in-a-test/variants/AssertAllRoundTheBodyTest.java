package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

/**
 * NOT COMPILED BY THIS PROJECT - it lives outside src/ for the same reason its sibling does.
 *
 * The obvious wrong way to apply assertAll to a loop: wrapped round the loop BODY. It reads like
 * the fix and is not one - the first row still throws out of the whole method, so the four rows
 * behind it still never run. ./receipts.sh assertall runs this beside the hoisted version and
 * prints both row counts, so the difference between them is measured rather than asserted.
 */
class AssertAllRoundTheBodyTest {

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
            assertAll(() ->
                assertEquals(row[2], new Customer("row", row[0], row[1], "VEG").monthlyBill()));
        }
    }
}
