package com.tiffinbox;

/**
 * One TiffinBox customer and the money they owe.
 *
 * <p>Asha bills a full month of {@value #DAYS_IN_MONTH} days
 * up front and refunds the days a customer paused.
 *
 * @since 1.0
 */
public class Customer {

    /** Days Asha bills in a month - February included, her rule. */
    public static final int DAYS_IN_MONTH = 30;

    private final String name;
    private final int mealsPerDay;
    private final int pricePerMeal;

    /**
     * Creates a customer on a daily plan.
     *
     * @param name         the customer's name, as Asha writes it on the lid
     * @param mealsPerDay  meals delivered each day, 1 to 3
     * @param pricePerMeal price of one meal in whole rupees
     */
    public Customer(String name, int mealsPerDay, int pricePerMeal) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
        this.pricePerMeal = pricePerMeal;
    }

    /**
     * Bills this customer for a number of delivered days.
     *
     * @param days days actually delivered, 0 to {@value #DAYS_IN_MONTH}
     * @return the bill in whole rupees
     * @throws IllegalArgumentException if {@code days} is negative
     * @see #monthlyBill()
     */
    public int billFor(int days) {
        if (days < 0) throw new IllegalArgumentException("days cannot be negative: " + days);
        return days * mealsPerDay * pricePerMeal;
    }

    /**
     * Bills a full month with nothing paused.
     *
     * @return the bill in whole rupees
     * @see #billFor(int)
     */
    public int monthlyBill() {
        return billFor(DAYS_IN_MONTH);
    }

    /**
     * The name Asha writes on the lid.
     *
     * @return the customer's name
     */
    public String name() {
        return name;
    }
}
