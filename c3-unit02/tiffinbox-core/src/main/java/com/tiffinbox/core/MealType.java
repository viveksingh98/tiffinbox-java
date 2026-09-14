package com.tiffinbox.core;

/** What a customer ordered, and what one meal of it costs. */
public enum MealType {
    VEG(60),
    NON_VEG(90),
    VEGAN(75);

    private final int pricePerMeal;

    MealType(int pricePerMeal) {
        this.pricePerMeal = pricePerMeal;
    }

    public int pricePerMeal() {
        return pricePerMeal;
    }
}
