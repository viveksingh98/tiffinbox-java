package com.tiffinbox;

/** The real thing. It knows nothing about anything standing in front of it. */
public class KitchenRail implements Rail {
    @Override public String place(String customer) { return "cooking for " + customer; }
}
