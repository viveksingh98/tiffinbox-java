package com.tiffinbox.report;

import com.tiffinbox.core.Customer;

/** Compiles against tiffinbox-core, which this project never built. */
public final class MonthEnd {

    public static void main(String[] args) {
        Customer c = new Customer("Meera", "VEG", 2);
        System.out.println(c.name() + " -> " + c.monthlyBill(30));
    }
}
