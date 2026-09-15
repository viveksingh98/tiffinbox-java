package com.tiffinbox;

import java.time.LocalDate;

/**
 * TODO: this class asks the machine what day it is. Give it a java.time.Clock instead -
 * a constructor parameter, a field, and LocalDate.now(clock) in place of LocalDate.now().
 * Change nothing else: the arithmetic below is already correct.
 */
public final class Billing {

    public LocalDate today() {
        return LocalDate.now();
    }

    public int daysLeftInCycle() {
        LocalDate d = today();
        return d.lengthOfMonth() - d.getDayOfMonth();
    }

    public LocalDate nextInvoiceDate() {
        return today().withDayOfMonth(1).plusMonths(1);
    }
}
