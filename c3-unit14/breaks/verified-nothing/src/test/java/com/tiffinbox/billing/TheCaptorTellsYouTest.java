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
 * The same code, the same mock, one line different: the matcher is replaced by a captor, and
 * the captured value is asserted on. This test FAILS, and its failure is the artifact that
 * proves the green class next door was proving nothing.
 */
@ExtendWith(MockitoExtension.class)
class TheCaptorTellsYouTest {

    @Mock
    PaymentGateway gateway;

    @Captor
    ArgumentCaptor<Integer> paise;

    private static final Customer RAVI = new Customer("Ravi", 2, 120, "VEG");

    @Test
    void theRightAmountWasCharged() {
        new BillingService(gateway).chargeMonthly(RAVI);

        verify(gateway).charge(eq("Ravi"), paise.capture());
        assertThat(paise.getValue()).isEqualTo(7200);
    }
}
