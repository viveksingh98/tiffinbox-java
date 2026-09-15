package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/** The names a suite grows when nobody stops it. */
class SubscriptionTest {

    @Test
    void testOne() {
        Subscription s = new Subscription(new Customer("Ravi", 2, 120, "VEG"), 3);
        assertThat(s.bill()).isEqualTo(6480);
    }

    @Test
    void testTwo() {
        Subscription s = new Subscription(new Customer("Ravi", 2, 120, "VEG"), 30);
        assertThat(s.isActive()).isFalse();
    }
}
