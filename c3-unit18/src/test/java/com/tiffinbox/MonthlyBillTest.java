package com.tiffinbox;

import static com.tiffinbox.CustomerBuilder.aCustomer;
import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

/**
 * The naming convention this unit argues for: the class names the thing under test, the
 * nested class names the situation, and the method names the expected behaviour. Read the
 * three together in a failure report and you have a sentence.
 */
@DisplayName("monthly bill")
class MonthlyBillTest {

    @Nested
    @DisplayName("for a customer eating every day")
    class EveryDay {

        @Test
        void multipliesMealsByPriceByThirty() {
            assertThat(aCustomer().eating(2).atRupees(120).build().monthlyBill()).isEqualTo(7200);
        }

        @Test
        void countsThePriceOfEachMealNotTheDay() {
            assertThat(aCustomer().eating(3).atRupees(100).build().monthlyBill()).isEqualTo(9000);
        }
    }

    @Nested
    @DisplayName("for a customer who has paused")
    class Paused {

        @Test
        void billsNothingWhenNoMealsAreTaken() {
            assertThat(aCustomer().eating(0).atRupees(120).build().monthlyBill()).isZero();
        }
    }
}
