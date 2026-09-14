package com.tiffinbox;

import com.fasterxml.jackson.annotation.JsonProperty;

/** TiffinBox's customer. The app's JSON calls the flag "veg"; the record calls it isVeg. */
public record Customer(String name,
                       int mealsPerDay,
                       int pricePerMeal,
                       @JsonProperty("veg") boolean isVeg) {

    public int monthlyBill() {
        return mealsPerDay * pricePerMeal * 30;
    }

    public String mealType() {
        return isVeg ? "VEG" : "NON_VEG";
    }
}
