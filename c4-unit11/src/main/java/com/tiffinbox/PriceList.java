package com.tiffinbox;

import java.util.LinkedHashMap;
import java.util.Map;

/** What a meal costs. Written once at startup; read for ever afterwards. */
public class PriceList {

    protected final Map<String, Integer> prices = new LinkedHashMap<>();

    public PriceList set(String meal, int paise) { prices.put(meal, paise); return this; }

    public int priceOf(String meal) { return prices.getOrDefault(meal, 0); }

    public Map<String, Integer> all() { return Map.copyOf(prices); }
}
