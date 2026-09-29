package com.tiffinbox.kitchen;

/** What the starter hands to every application that adds it: a kitchen with a name and some cooks. */
public class Kitchen {
    private final String name;
    private final int cooks;

    public Kitchen(String name, int cooks) {
        this.name = name;
        this.cooks = cooks;
    }

    public String describe() {
        return name + " with " + cooks + " cooks";
    }
}
