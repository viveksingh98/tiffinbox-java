package com.tiffinbox;

/**
 * One customer's month.
 *
 * <p>The rules, as agreed: a paused day is not billed, and a subscription paused for thirty
 * days or more is no longer active. Two rules, two mistakes below.
 */
public record Subscription(Customer customer, int pausedDays) {

    public int bill() {
        return customer.monthlyBill();
    }

    public boolean isActive() {
        return pausedDays <= 30;
    }
}
