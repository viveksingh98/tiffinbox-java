package com.tiffinbox;

public class BillingService implements Billing {
    @Override public int price(String customer) { return 340; }
    @Audited @Override public int refund(String customer) { return -340; }
}
