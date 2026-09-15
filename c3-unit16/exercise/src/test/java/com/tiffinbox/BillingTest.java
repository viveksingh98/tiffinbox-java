package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

/** Do not change this file. It is the specification: two dates, two answers, every day. */
class BillingTest {

    private static Billing on(String isoDate) {
        return new Billing(Clock.fixed(Instant.parse(isoDate + "T09:00:00Z"), ZoneOffset.UTC));
    }

    @Test
    void theLastDayOfJanuaryHasNoDaysLeft() {
        assertThat(on("2026-01-31").daysLeftInCycle()).isZero();
    }

    @Test
    void theInvoiceIsTheFirstOfNextMonth() {
        assertThat(on("2026-12-09").nextInvoiceDate()).isEqualTo(LocalDate.of(2027, 1, 1));
    }
}
