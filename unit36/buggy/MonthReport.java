package com.tiffinbox;

public class MonthReport {
    public static void main(String[] args) {
        int mealsPerDay = 2;
        int pricePerMeal = 120;
        int daysInMonth = 30;
        int total = 0;

        for (int day = 1; day < daysInMonth; day++) {
            total += mealsPerDay * pricePerMeal;
        }
        IO.println("September total: " + total);
        IO.println("Formula says:    " + Billing.calculateBill(mealsPerDay, pricePerMeal, daysInMonth));
    }
}
