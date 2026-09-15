package com.tiffinbox.billing;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import com.tiffinbox.Customer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * This test passes. The service it is testing charges the wrong amount.
 *
 * TODO: replace anyInt() with an ArgumentCaptor<Integer>, capture the value the code really
 *       passed, and assert that Ravi was charged his monthly bill of 7200. Import
 *       org.assertj.core.api.Assertions.assertThat, or JUnit's assertEquals - either is fine.
 *       The test must FAIL when you are done. That failure is the answer.
 */
@ExtendWith(MockitoExtension.class)
class ChargeTest {

    @Mock
    PaymentGateway gateway;

    private static final Customer RAVI = new Customer("Ravi", 2, 120, "VEG");

    @Test
    void raviIsChargedHisMonthlyBill() {
        new BillingService(gateway).chargeMonthly(RAVI);

        verify(gateway).charge(eq("Ravi"), anyInt());
    }
}
