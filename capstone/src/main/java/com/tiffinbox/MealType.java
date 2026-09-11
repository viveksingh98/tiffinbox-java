package com.tiffinbox;

public enum MealType {
    VEG(120), NON_VEG(150);

    private final int defaultPrice;

    MealType(int defaultPrice) {
        this.defaultPrice = defaultPrice;
    }

    public int defaultPrice() {
        return defaultPrice;
    }

    public static MealType of(boolean isVeg) {
        return isVeg ? VEG : NON_VEG;
    }
}
