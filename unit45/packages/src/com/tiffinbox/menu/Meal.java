package com.tiffinbox.menu;

/** One meal on Asha's menu. Four fields, four different doors. */
public class Meal {

    private   int    kitchenCost = 70;            // this class only
    protected int    basePrice   = 120;           // + subclasses, wherever they live
              int    packedToday = 48;            // no modifier = this package only
    public    String dish        = "lentil rice"; // anyone, anywhere

    public int price()  { return basePrice; }
    public int margin() { return basePrice - kitchenCost; }
}
