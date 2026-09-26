package com.tiffinbox;

/** Prices a bill. A customer called "nobody" is refused, so @AfterThrowing has something to see. */
public interface Billing {
    int price(String customer);
}
