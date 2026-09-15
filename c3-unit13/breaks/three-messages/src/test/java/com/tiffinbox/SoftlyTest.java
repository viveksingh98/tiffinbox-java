package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.api.Test;

/**
 * Three things wrong with one customer. A chain of separate assertThat statements throws on
 * the first one and you never hear about the other two. SoftAssertions collects them and
 * reports all three in one message, numbered.
 */
class SoftlyTest {

    private static final Customer PRIYA = new Customer("Priya", 1, 120, "VEGAN");

    @Test
    void hardChainStopsAtTheFirst() {
        assertThat(PRIYA.name()).isEqualTo("Priyanka");
        assertThat(PRIYA.monthlyBill()).isEqualTo(9999);
        assertThat(PRIYA.mealType()).isEqualTo("VEG");
    }

    @Test
    void softlyCollectsThemAll() {
        SoftAssertions softly = new SoftAssertions();
        softly.assertThat(PRIYA.name()).isEqualTo("Priyanka");
        softly.assertThat(PRIYA.monthlyBill()).isEqualTo(9999);
        softly.assertThat(PRIYA.mealType()).isEqualTo("VEG");
        softly.assertAll();
    }
}
