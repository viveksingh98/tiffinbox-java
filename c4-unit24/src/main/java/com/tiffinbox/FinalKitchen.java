package com.tiffinbox;

import java.util.Map;

/** Identical to Kitchen.price except for `final` - one variable. It reads the same field. */
public class FinalKitchen {
    private final Map<String, Integer> menu = Map.of("Ravi", 340);
    public final int price(String c) { return menu.get(c); }
}
