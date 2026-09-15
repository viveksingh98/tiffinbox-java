package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

/**
 * Every date in here is a value the test chose. Run this class in any month of any year and
 * it produces the same result, because the only calendar it can see is the one it was handed.
 */
class BillingTest {

    private static Billing on(String isoDate) {
        return new Billing(Clock.fixed(Instant.parse(isoDate + "T09:00:00Z"), ZoneOffset.UTC));
    }

    @Test
    void theLastDayOfAThirtyOneDayMonthHasNoDaysLeft() {
        assertThat(on("2026-01-31").daysLeftInCycle()).isZero();
    }

    @Test
    void theLastDayOfFebruaryHasNoDaysLeft() {
        assertThat(on("2026-02-28").daysLeftInCycle()).isZero();
    }

    @Test
    void midSeptemberHasFifteenDaysLeft() {
        assertThat(on("2026-09-15").daysLeftInCycle()).isEqualTo(15);
    }

    @Test
    void theInvoiceIsAlwaysTheFirstOfNextMonth() {
        assertThat(on("2026-01-31").nextInvoiceDate()).isEqualTo(LocalDate.of(2026, 2, 1));
        assertThat(on("2026-12-09").nextInvoiceDate()).isEqualTo(LocalDate.of(2027, 1, 1));
    }
}
