package com.tiffinbox;

/** What a bill costs. An interface, so the proxy can stand in for it. */
public interface Billing {
    int price(String customer);
}
