package com.tiffinbox.billing;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import com.tiffinbox.Customer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * This class is GREEN. The BillingService beside it charges one meal instead of a month.
 *
 * <p>Both tests verify that charge() was called. Neither of them says anything about the
 * number that was passed, and charging is the only thing this service does - so a call of
 * that shape was going to happen whatever the code did.
 */
@ExtendWith(MockitoExtension.class)
class GreenAndWrongTest {

    @Mock
    PaymentGateway gateway;

    private static final Customer RAVI = new Customer("Ravi", 2, 120, "VEG");

    @Test
    void theGatewayWasCalled() {
        new BillingService(gateway).chargeMonthly(RAVI);
        verify(gateway).charge(anyString(), anyInt());
    }

    @Test
    void theRightCustomerWasCharged() {
        new BillingService(gateway).chargeMonthly(RAVI);
        verify(gateway).charge(eq("Ravi"), anyInt());
    }
}
