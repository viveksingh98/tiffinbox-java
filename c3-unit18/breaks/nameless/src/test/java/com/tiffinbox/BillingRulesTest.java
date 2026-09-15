package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

/**
 * Byte for byte the same two assertions as SubscriptionTest. Only the names changed.
 */
@DisplayName("billing rules")
class BillingRulesTest {

    @Nested
    @DisplayName("a subscription with paused days")
    class WithPausedDays {

        @Test
        void doesNotBillThePausedDays() {
            Subscription s = new Subscription(new Customer("Ravi", 2, 120, "VEG"), 3);
            assertThat(s.bill()).isEqualTo(6480);
        }
    }

    @Nested
    @DisplayName("a subscription paused for a whole month")
    class PausedForAWholeMonth {

        @Test
        void isNoLongerActive() {
            Subscription s = new Subscription(new Customer("Ravi", 2, 120, "VEG"), 30);
            assertThat(s.isActive()).isFalse();
        }
    }
}
