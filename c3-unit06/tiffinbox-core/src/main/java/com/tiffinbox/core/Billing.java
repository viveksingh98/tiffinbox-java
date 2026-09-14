package com.tiffinbox.core;

/** The one price table TiffinBox bills from. */
public final class Billing {

    private Billing() {
    }

    public static int pricePerMeal(String plan) {
        return switch (plan) {
            case "VEG" -> 60;
            case "NON_VEG" -> 90;
            case "VEGAN" -> 75;
            default -> throw new IllegalArgumentException(plan);
        };
    }

    public static int monthlyBill(String plan, int mealsPerDay, int days) {
        return pricePerMeal(plan) * mealsPerDay * days;
    }
}
