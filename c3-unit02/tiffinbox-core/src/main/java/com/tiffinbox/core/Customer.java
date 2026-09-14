package com.tiffinbox.core;

/** One TiffinBox subscriber. Core owns the shape of the data and nothing else. */
public record Customer(String name, MealType mealType, int mealsPerDay) {

    public Customer {
        if (mealsPerDay < 1) {
            throw new IllegalArgumentException("mealsPerDay must be at least 1");
        }
    }

    public int dailyCost() {
        return mealType.pricePerMeal() * mealsPerDay;
    }
}
