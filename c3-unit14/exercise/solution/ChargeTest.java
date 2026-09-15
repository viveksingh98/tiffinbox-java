package com.tiffinbox.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import com.tiffinbox.Customer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * One line different from the starting state, and now the test fails:
 *
 *     [ERROR]   ChargeTest.raviIsChargedHisMonthlyBill
 *     expected: 7200
 *      but was: 120
 *
 * (The line number depends on where you put the assertion, so it is left off here on purpose -
 * the two lines under it are the acceptance.)
 *
 * anyInt() asked "did a charge of some amount happen?" - and charging is the only thing this
 * service does, so the answer was always going to be yes. The captor asks "which amount?".
 */
@ExtendWith(MockitoExtension.class)
class ChargeTest {

    @Mock
    PaymentGateway gateway;

    @Captor
    ArgumentCaptor<Integer> paise;

    private static final Customer RAVI = new Customer("Ravi", 2, 120, "VEG");

    @Test
    void raviIsChargedHisMonthlyBill() {
        new BillingService(gateway).chargeMonthly(RAVI);

        verify(gateway).charge(eq("Ravi"), paise.capture());
        assertThat(paise.getValue()).isEqualTo(7200);
    }
}
