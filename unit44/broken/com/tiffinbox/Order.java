package com.tiffinbox;

/**
 * A single delivery, billed on its own.
 */
public class Order {

    /**
     * Bills one order.
     *
     * @param days days actually delivered
     * @return the bill in whole rupees
     */
    public int billFor(String customer, int days) {
        return days * 120;
    }
}
