package com.tiffinbox;

import java.time.LocalDateTime;
import org.springframework.scheduling.support.CronExpression;

/**
 * A cron expression is COMPUTED, never waited for (contract 2f.3). A video cannot wait for 11:30 on a
 * Monday; computing the next firings is deterministic, and it is the thing you actually need to check.
 * Spring's six fields: second minute hour day-of-month month day-of-week. And the rule is read in a
 * TIME ZONE - the server's, unless @Scheduled(zone = ...) says otherwise; the last line shows why it matters.
 */
public final class CronNext {
    private CronNext() { }
    public static void main(String[] args) {
        String expr = args.length > 0 ? args[0] : "0 30 11 * * MON-FRI";
        CronExpression cron = CronExpression.parse(expr);
        LocalDateTime t = LocalDateTime.of(2026, 9, 25, 12, 0);     // a Friday, just after lunch
        System.out.println("  \"" + expr + "\", computed from " + t + " " + t.getDayOfWeek() + ":");
        for (int i = 0; i < 4; i++) { t = cron.next(t); System.out.println("    next -> " + t + "  " + t.getDayOfWeek()); }
        if (args.length == 0) {
            // ZONE (added after the section's RED review): the rule is read in the scheduler's time zone.
            java.time.ZonedDateTime utc = java.time.ZonedDateTime.of(LocalDateTime.of(2026, 9, 25, 12, 0), java.time.ZoneOffset.UTC);
            java.time.ZonedDateTime n = cron.next(utc);
            System.out.println("  the same rule on a server in UTC: next -> " + n.toLocalDateTime() + " UTC"
                    + "  = " + n.withZoneSameInstant(java.time.ZoneId.of("Asia/Kolkata")).toLocalDateTime() + " in Kolkata");
        }
    }
}
