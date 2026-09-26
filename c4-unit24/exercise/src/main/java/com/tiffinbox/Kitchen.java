package com.tiffinbox;

/** The same three shapes Spring's proxies could not reach, in one plain class. */
public class Kitchen {
    public int price(String c) { return 340; }
    public int priceTwice(String c) { return price(c) + price(c); }       // self-invocation
}
