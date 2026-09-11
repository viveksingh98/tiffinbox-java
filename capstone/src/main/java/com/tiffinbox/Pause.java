package com.tiffinbox;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public record Pause(String customer, LocalDate from, LocalDate to) {

    public Pause {
        if (to.isBefore(from)) {
            throw new TiffinBoxException("pause ends before it starts: " + from + " to " + to);
        }
        if (ChronoUnit.DAYS.between(from, to) >= Customer.DAYS_IN_MONTH) {
            throw new TiffinBoxException("a pause cannot cover a whole month: " + from + " to " + to);
        }
    }

    public int days() {
        return (int) ChronoUnit.DAYS.between(from, to) + 1;
    }
}
