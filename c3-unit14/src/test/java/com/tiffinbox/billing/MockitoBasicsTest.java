package com.tiffinbox.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.tiffinbox.Customer;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * The fifth word. A MOCK is a double the framework writes for you at run time, and whose
 * calls the framework remembers so you can assert on them afterwards.
 *
 * <p>An EXTENSION is a class you plug into JUnit's test lifecycle so it can do work around
 * your test. MockitoExtension is the one that creates the @Mock fields before each test and
 * checks the bookkeeping after it; @ExtendWith above is the plug.
 *
 * <p>Two different mistakes, two different symptoms. Drop mockito-junit-jupiter from the POM
 * and this file does not compile at all ("package org.mockito.junit.jupiter does not exist").
 * Keep the artifact and delete the @ExtendWith, and it compiles, runs, and every @Mock field
 * is null - the registration is what creates them, not the dependency.
 */
@ExtendWith(MockitoExtension.class)
class MockitoBasicsTest {

    @Mock
    PaymentGateway gateway;

    @Captor
    ArgumentCaptor<Integer> paise;

    private static final Customer RAVI = new Customer("Ravi", 2, 120, "VEG");
    private static final Customer MEERA = new Customer("Meera", 1, 150, "NON_VEG");

    /** when(...).thenReturn(...) is the stub half: one canned answer, for one call shape. */
    @Test
    void whenThenReturnIsTheStubHalf() {
        when(gateway.charge("Ravi", 7200)).thenReturn("REF-9001");

        assertThat(new BillingService(gateway).chargeMonthly(RAVI).reference())
                .isEqualTo("REF-9001");
    }

    /** An unstubbed method is not an error. It returns the type's default - here, null. */
    @Test
    void anUnstubbedCallReturnsTheTypesDefault() {
        assertThat(new BillingService(gateway).chargeMonthly(RAVI).reference()).isNull();
    }

    /** verify is the spy half: it asks the framework what it remembers. */
    @Test
    void verifyIsTheSpyHalf() {
        new BillingService(gateway).chargeMonthly(MEERA);

        verify(gateway).charge("Meera", 4500);
        verify(gateway, never()).balanceOf("Meera");
    }

    /** A dummy, done by framework: nothing is stubbed and nothing may be called. */
    @Test
    void aMockUsedAsADummy() {
        assertThat(new BillingService(gateway).monthlyTotal(List.of(RAVI, MEERA)))
                .isEqualTo(11_700);

        verify(gateway, never()).charge(eq("Ravi"), anyInt());
    }

    /**
     * The captor is the one that answers "what did the code ACTUALLY pass?". verify with a
     * matcher only asks whether a call of that SHAPE happened; the captor hands you the value.
     */
    @Test
    void theCaptorHandsYouTheValueThatWasPassed() {
        new BillingService(gateway).chargeMonthly(RAVI);

        verify(gateway).charge(eq("Ravi"), paise.capture());
        assertThat(paise.getValue()).isEqualTo(7200);
    }
}
