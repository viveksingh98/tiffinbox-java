package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/**
 * The same customer, named field by field. There is no order left to get wrong, because
 * there is no order: eating(2) and atRupees(120) mean what they say wherever they appear.
 */
class BuiltTest {

    @Test
    void theBillIsRight() {
        Customer ravi = CustomerBuilder.aCustomer().named("Ravi").eating(2).atRupees(120).build();

        assertThat(ravi.monthlyBill()).isEqualTo(7200);
    }

    @Test
    void theCustomerIsToo() {
        Customer ravi = CustomerBuilder.aCustomer().named("Ravi").eating(2).atRupees(120).build();

        assertThat(ravi.mealsPerDay()).isEqualTo(2);
        assertThat(ravi.pricePerMeal()).isEqualTo(120);
    }
}
