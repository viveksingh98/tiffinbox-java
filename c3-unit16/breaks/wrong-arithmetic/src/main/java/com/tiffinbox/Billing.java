package com.tiffinbox;

import java.time.Clock;
import java.time.LocalDate;

/** The same class, with one plausible line in it: months are thirty days long. */
public final class Billing {

    private final Clock clock;

    public Billing(Clock clock) {
        this.clock = clock;
    }

    public LocalDate today() {
        return LocalDate.now(clock);
    }

    public int daysLeftInCycle() {
        return 30 - today().getDayOfMonth();
    }
}
