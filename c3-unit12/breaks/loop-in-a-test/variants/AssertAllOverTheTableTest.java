package com.tiffinbox;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Arrays;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;

/**
 * NOT COMPILED BY THIS PROJECT - it lives outside src/ on purpose, so `mvn test` here still runs
 * exactly the two classes the slide compares. ./receipts.sh assertall copies the project, keeps
 * only this class, and runs it.
 *
 * The previous unit's answer to "the failing assert ends the method, and the rows behind it never
 * ran" was assertAll. Hoisted OUT of the loop - one Executable per row, which is the only placement
 * that helps; wrapped round the loop BODY it still stops at the first row - every row runs and every
 * mismatch is named. And the runner still counts ONE test, because one @Test method is still one
 * thing you told it to be right about. That is the point of the slide this receipt sits under:
 * assertAll fixes the message, not the count.
 */
class AssertAllOverTheTableTest {

    private static final int[][] TABLE = {
        {2, 120,  7200},
        {1, 150,  4500},
        {3, 100,  9000},
        {1, 120,  3600},
        {4,  90, 10800}
    };

    @Test
    void everyRowInThePriceTable() {
        assertAll(Arrays.stream(TABLE).map(row -> (Executable) () ->
            assertEquals(row[2], new Customer("row", row[0], row[1], "VEG").monthlyBill())));
    }
}
