package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

class CycleTest {

    private static Billing on(LocalDate day) {
        return new Billing(Clock.fixed(day.atStartOfDay(ZoneOffset.UTC).toInstant(), ZoneOffset.UTC));
    }

    private static Billing on(String isoDate) {
        return new Billing(Clock.fixed(Instant.parse(isoDate + "T09:00:00Z"), ZoneOffset.UTC));
    }

    @Test
    void midSeptemberHasFifteenDaysLeft() {
        assertThat(on("2026-09-15").daysLeftInCycle()).isEqualTo(15);
    }

    @Test
    void theLastDayOfJanuaryHasNoDaysLeft() {
        assertThat(on("2026-01-31").daysLeftInCycle()).isZero();
    }

    /**
     * How many days of one year would have shown this bug? Counted here, not guessed: for
     * every day of 2026, compare what the class says with what the calendar says.
     */
    @Test
    void howOftenTheBugIsInvisible() {
        LocalDate day = LocalDate.of(2026, 1, 1);
        int total = 0;
        int agrees = 0;
        while (day.getYear() == 2026) {
            int said = on(day).daysLeftInCycle();
            int calendar = day.lengthOfMonth() - day.getDayOfMonth();
            total++;
            if (said == calendar) {
                agrees++;
            }
            day = day.plusDays(1);
        }
        System.out.printf("agrees with the calendar on %d of %d days in 2026%n", agrees, total);
        assertThat(agrees).isLessThan(total);
    }
}
