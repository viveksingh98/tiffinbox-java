package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;

/** One order. The spice level arrives from a file as text and has to be a Spice by the time it
 *  gets here. Nothing in this class changes. */
public class Order {

    private final String customer;
    private final Spice spice;

    public Order(@Value("${tiffinbox.customer}") String customer,
                 @Value("${tiffinbox.spice}") Spice spice) {
        this.customer = customer;
        this.spice = spice;
    }

    @Override public String toString() {
        return "Order[customer=" + customer + ", spice=" + spice + "]";
    }
}
