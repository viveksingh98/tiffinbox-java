package com.tiffinbox.menu;

/** Slide 2, break (a): the SAME class with `protected` taken off basePrice. */
public class Meal {

    private   int    kitchenCost = 70;
              int    basePrice   = 120;           // protected removed -> package-private
              int    packedToday = 48;
    public    String dish        = "lentil rice";

    public int price()  { return basePrice; }
    public int margin() { return basePrice - kitchenCost; }
}
