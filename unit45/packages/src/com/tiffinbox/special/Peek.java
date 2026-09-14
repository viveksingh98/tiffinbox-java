package com.tiffinbox.special;

import com.tiffinbox.menu.Meal;

public class Peek extends Meal {
    public int mine()                   { return basePrice; }
    public int someoneElses(Meal other) { return other.basePrice; }
}
