package com.tiffinbox;

/** The anchor record, carried from Course 1 all the way to here. */
public record Customer(String name, int mealsPerDay, int pricePerMeal, String mealType) {
    public int monthlyBill() {
        return mealsPerDay * pricePerMeal * 30;
    }
}
