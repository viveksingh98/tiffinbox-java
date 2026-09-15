package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/**
 * Customer takes (String, int, int, String). The two ints are meals per day and rupees per
 * meal, and they are written here the wrong way round. It compiles. The bill is even right,
 * because two times a hundred and twenty is a hundred and twenty times two.
 */
class PositionalTest {

    @Test
    void theBillIsRight() {
        Customer ravi = new Customer("Ravi", 120, 2, "VEG");

        assertThat(ravi.monthlyBill()).isEqualTo(7200);
    }

    @Test
    void theCustomerIsNot() {
        Customer ravi = new Customer("Ravi", 120, 2, "VEG");

        assertThat(ravi.mealsPerDay()).isEqualTo(2);
    }
}
