package com.tiffinbox.api;

import com.tiffinbox.api.internal.PriceCard;

public final class Billing {
    private Billing() { }

    public static int monthlyBill(Customer c) {
        return PriceCard.pricePerMeal(c.plan().name()) * 2 * 30;
    }
}
