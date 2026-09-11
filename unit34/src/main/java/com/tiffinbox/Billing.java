package com.tiffinbox;

public class Billing {

    public static int calculateBill(int mealsPerDay, int pricePerMeal, int days) {
        return mealsPerDay * pricePerMeal * days;
    }

    public static int calculateBill(int mealsPerDay, int pricePerMeal) {
        return calculateBill(mealsPerDay, pricePerMeal, 31);
    }
}
