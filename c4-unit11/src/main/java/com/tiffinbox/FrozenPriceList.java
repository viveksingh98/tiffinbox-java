package com.tiffinbox;

/**
 * The same price list with the door shut. It is a HAND-WRITTEN substitution, not an
 * interception: there is no generated class here and nothing wraps a method call. A
 * BeanPostProcessor is allowed to hand back a different object, and this is the plainest
 * possible example of it doing so.
 */
public final class FrozenPriceList extends PriceList {

    FrozenPriceList(PriceList source) {
        prices.putAll(source.all());
    }

    @Override public PriceList set(String meal, int paise) {
        throw new UnsupportedOperationException("the price list was frozen at startup");
    }
}
