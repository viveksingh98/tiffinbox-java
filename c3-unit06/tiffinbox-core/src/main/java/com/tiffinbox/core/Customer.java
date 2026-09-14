package com.tiffinbox.core;

public record Customer(String name, String plan, int mealsPerDay) {
    public int monthlyBill(int days) {
        return Billing.monthlyBill(plan, mealsPerDay, days);
    }
}
