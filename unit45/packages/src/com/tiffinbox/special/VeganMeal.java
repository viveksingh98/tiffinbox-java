package com.tiffinbox.special;

import com.tiffinbox.menu.Meal;

public class VeganMeal extends Meal {
    @Override
    public int price() { return basePrice + 10; }
}
