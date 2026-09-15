package com.tiffinbox;

import java.time.Clock;
import java.time.LocalDate;

/** One field, one constructor parameter, one argument. That is the whole seam. */
public final class Billing {

    private final Clock clock;

    public Billing(Clock clock) {
        this.clock = clock;
    }

    public LocalDate today() {
        return LocalDate.now(clock);
    }

    public int daysLeftInCycle() {
        LocalDate d = today();
        return d.lengthOfMonth() - d.getDayOfMonth();
    }

    public LocalDate nextInvoiceDate() {
        return today().withDayOfMonth(1).plusMonths(1);
    }
}
