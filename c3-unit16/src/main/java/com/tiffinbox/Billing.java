package com.tiffinbox;

import java.time.Clock;
import java.time.LocalDate;

/**
 * Subscription dates for one customer.
 *
 * <p>The only reason this class takes a Clock is testability, and that is reason enough.
 * A Clock is java.time's answer to "what time is it?" - Clock.systemDefaultZone() asks the
 * machine, Clock.fixed(...) always answers the same thing. Nothing below calls
 * LocalDate.now() with no argument, so nothing below can give a different answer tomorrow.
 */
public final class Billing {

    private final Clock clock;

    public Billing(Clock clock) {
        this.clock = clock;
    }

    public LocalDate today() {
        return LocalDate.now(clock);
    }

    /** Days between today and the last day of this month. The last day of the month is 0. */
    public int daysLeftInCycle() {
        LocalDate d = today();
        return d.lengthOfMonth() - d.getDayOfMonth();
    }

    /** The first day of next month. */
    public LocalDate nextInvoiceDate() {
        return today().withDayOfMonth(1).plusMonths(1);
    }
}
