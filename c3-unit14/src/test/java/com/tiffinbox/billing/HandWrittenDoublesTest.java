package com.tiffinbox.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.tiffinbox.Customer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

/**
 * Four words, four classes, no framework. Every double below is a real PaymentGateway you
 * could have written yourself, and the difference between them is exactly what each one KNOWS.
 *
 *   dummy - knows nothing, does nothing, exists to fill a parameter
 *   stub  - knows one canned answer, and gives it to anyone who asks
 *   spy   - answers like a stub AND remembers who asked
 *   fake  - a working implementation, small enough to keep in memory
 *
 * The fifth word, mock, is the one Mockito is for, and it is in MockitoBasicsTest.
 */
class HandWrittenDoublesTest {

    /** DUMMY: every method throws. If the code under test touches it, the test fails loudly. */
    static final class DummyGateway implements PaymentGateway {
        public String charge(String customer, int paise) {
            throw new UnsupportedOperationException("dummy: nothing should have called charge");
        }
        public int balanceOf(String customer) {
            throw new UnsupportedOperationException("dummy: nothing should have called balanceOf");
        }
    }

    /** STUB: one canned answer. It has no memory and no opinion about who called it. */
    static final class StubGateway implements PaymentGateway {
        public String charge(String customer, int paise) { return "REF-STUB"; }
        public int balanceOf(String customer) { return 50_000; }
    }

    /** SPY: a stub that also writes down every call, so the test can look afterwards. */
    static final class SpyGateway implements PaymentGateway {
        final List<String> calls = new ArrayList<>();
        public String charge(String customer, int paise) {
            calls.add("charge(" + customer + ", " + paise + ")");
            return "REF-SPY";
        }
        public int balanceOf(String customer) {
            calls.add("balanceOf(" + customer + ")");
            return 50_000;
        }
    }

    /** FAKE: it really works. Balances go down, and an empty wallet is refused. */
    static final class FakeGateway implements PaymentGateway {
        private final Map<String, Integer> balances = new HashMap<>();
        private int nextRef = 1;
        FakeGateway(Map<String, Integer> opening) { balances.putAll(opening); }
        public String charge(String customer, int paise) {
            int balance = balances.getOrDefault(customer, 0);
            if (balance < paise) {
                throw new IllegalStateException(customer + " has " + balance + ", needs " + paise);
            }
            balances.put(customer, balance - paise);
            return "REF-FAKE-" + nextRef++;
        }
        public int balanceOf(String customer) { return balances.getOrDefault(customer, 0); }
    }

    private static final Customer RAVI = new Customer("Ravi", 2, 120, "VEG");
    private static final Customer MEERA = new Customer("Meera", 1, 150, "NON_VEG");

    @Test
    void aDummyProvesTheCodePathNeverTouchesTheGateway() {
        assertThat(new BillingService(new DummyGateway()).monthlyTotal(List.of(RAVI, MEERA)))
                .isEqualTo(11_700);
    }

    @Test
    void aStubGivesTheCodeSomethingToCarryOnWith() {
        assertThat(new BillingService(new StubGateway()).chargeMonthly(RAVI).reference())
                .isEqualTo("REF-STUB");
    }

    @Test
    void aSpyRemembersWhatItWasAsked() {
        SpyGateway spy = new SpyGateway();
        new BillingService(spy).chargeMonthly(RAVI);
        assertThat(spy.calls).containsExactly("charge(Ravi, 7200)");
    }

    @Test
    void aFakeCanFailTheWayTheRealThingFails() {
        FakeGateway wallet = new FakeGateway(Map.of("Ravi", 10_000, "Meera", 1_000));
        BillingService billing = new BillingService(wallet);

        billing.chargeMonthly(RAVI);
        assertThat(wallet.balanceOf("Ravi")).isEqualTo(2_800);

        assertThatThrownBy(() -> billing.chargeMonthly(MEERA))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Meera has 1000, needs 4500");
    }
}
