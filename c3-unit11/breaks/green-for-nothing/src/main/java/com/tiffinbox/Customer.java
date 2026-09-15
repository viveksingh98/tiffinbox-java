package com.tiffinbox;

/** One character wrong: a billing month here is 31 days. Every customer is overcharged. */
public record Customer(String name, int mealsPerDay, int pricePerMeal, String mealType) {
    public int monthlyBill() {
        return mealsPerDay * pricePerMeal * 31;   // wrong on purpose: should be 30
    }
}
