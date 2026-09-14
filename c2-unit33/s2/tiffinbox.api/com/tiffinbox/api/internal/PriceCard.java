package com.tiffinbox.api.internal;

public final class PriceCard {
    private PriceCard() { }

    public static int pricePerMeal(String plan) {
        return switch (plan) {
            case "VEG"     -> 60;
            case "NON_VEG" -> 90;
            case "VEGAN"   -> 75;
            default -> throw new IllegalArgumentException("unknown plan: " + plan);
        };
    }
}
