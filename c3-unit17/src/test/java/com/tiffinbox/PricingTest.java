package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/**
 * Three tests. Every line of Pricing.tier runs, and every branch is taken both ways.
 * Ask JaCoCo and it will tell you so.
 */
class PricingTest {

    @Test
    void aBigSubscriptionIsGold() {
        assertThat(Pricing.tier(new Customer("Anita", 2, 200, "VEG"))).isEqualTo("GOLD");
    }

    @Test
    void aMiddlingSubscriptionIsSilver() {
        assertThat(Pricing.tier(new Customer("Sunil", 3, 100, "VEG"))).isEqualTo("SILVER");
    }

    @Test
    void aSmallSubscriptionIsBronze() {
        assertThat(Pricing.tier(new Customer("Meera", 1, 150, "NON_VEG"))).isEqualTo("BRONZE");
    }
}
