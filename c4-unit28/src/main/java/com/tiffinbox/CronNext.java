package com.tiffinbox;

import java.time.LocalDateTime;
import org.springframework.scheduling.support.CronExpression;

/**
 * A cron expression is COMPUTED, never waited for (contract 2f.3). A video cannot wait for 11:30 on a
 * Monday; computing the next firings is deterministic, and it is the thing you actually need to check.
 */
public final class CronNext {
    private CronNext() { }
    public static void main(String[] args) {
        String expr = args.length > 0 ? args[0] : "0 30 11 * * MON-FRI";
        CronExpression cron = CronExpression.parse(expr);
        LocalDateTime t = LocalDateTime.of(2026, 9, 25, 12, 0);     // a Friday, just after lunch
        System.out.println("  \"" + expr + "\", computed from " + t + " " + t.getDayOfWeek() + ":");
        for (int i = 0; i < 4; i++) { t = cron.next(t); System.out.println("    next -> " + t + "  " + t.getDayOfWeek()); }
    }
}
