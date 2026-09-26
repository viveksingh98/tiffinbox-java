package com.tiffinbox;

/** The real thing. Still knows nothing about what stands in front of it. */
public class BillingService implements Billing {
    @Override public int price(String customer) { return 340; }
}
