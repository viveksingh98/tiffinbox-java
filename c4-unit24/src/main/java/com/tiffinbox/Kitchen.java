package com.tiffinbox;

import java.util.Map;

/** The same three shapes Spring's proxies could not reach, in one plain class. price() reads a field. */
public class Kitchen {
    private final Map<String, Integer> menu = Map.of("Ravi", 340);
    public int price(String c) { return menu.get(c); }
    public int priceTwice(String c) { return price(c) + price(c); }       // self-invocation
}
