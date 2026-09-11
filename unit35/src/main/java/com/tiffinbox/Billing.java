package com.tiffinbox;

public class Billing {

    public static int calculateBill(int mealsPerDay, int pricePerMeal, int days) {
        if (mealsPerDay < 1 || mealsPerDay > 3) {
            throw new IllegalArgumentException("meals a day must be 1 to 3, got " + mealsPerDay);
        }
        return mealsPerDay * pricePerMeal * days;
    }

    public static int calculateBill(int mealsPerDay, int pricePerMeal) {
        return calculateBill(mealsPerDay, pricePerMeal, 30);
    }
}
