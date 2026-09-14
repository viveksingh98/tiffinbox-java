package com.tiffinbox;

/**
 * A stretch of days one TiffinBox customer skipped.
 *
 * <p>Both ends count: a pause from day 14 to day 20 is seven days, not six.
 * Asha allows at most {@value #MAX_DAYS} paused days in one month.
 *
 * @since 1.0
 */
public class Pause {

    /** The longest pause Asha allows in one month. */
    public static final int MAX_DAYS = 14;

    private final String customer;
    private final int from;
    private final int to;

    /**
     * Records a pause for one customer.
     *
     * @param customer the customer who paused
     * @param from     the first paused day of the month, counted from 1
     * @param to       the last paused day, counted from 1, and included in the pause
     * @throws IllegalArgumentException if {@code to} is before {@code from},
     *         or if the pause is longer than {@value #MAX_DAYS} days
     */
    public Pause(String customer, int from, int to) {
        if (to < from) {
            throw new IllegalArgumentException("pause ends before it starts: " + from + " to " + to);
        }
        if (to - from + 1 > MAX_DAYS) {
            throw new IllegalArgumentException("pause longer than " + MAX_DAYS + " days: " + (to - from + 1));
        }
        this.customer = customer;
        this.from = from;
        this.to = to;
    }

    /**
     * Counts the paused days, both ends included.
     *
     * @return the number of paused days, at least 1
     */
    public int days() {
        return to - from + 1;
    }

    /**
     * Describes the pause in one line for Asha's report.
     *
     * @return one line naming the customer, the length and both ends
     * @see #days()
     */
    public String describe() {
        return customer + " paused " + days() + " days (" + from + " to " + to + ")";
    }
}
