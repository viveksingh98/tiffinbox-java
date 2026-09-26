package com.tiffinbox;

public interface Billing {
    int price(String customer);
    int refund(String customer);
}
