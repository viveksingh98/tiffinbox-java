package com.tiffinbox;

public class BillingService implements Billing {
    @Override public int price(String customer) {
        System.out.println("      (the real method ran for " + customer + ")");
        if ("nobody".equals(customer)) throw new IllegalArgumentException("no customer called nobody");
        return 340;
    }
}
