package com.tiffinbox.app;

import com.tiffinbox.menu.Meal;
import com.tiffinbox.special.VeganMeal;

public class Main {
    public static void main(String[] args) {
        Meal      plain = new Meal();
        VeganMeal vegan = new VeganMeal();
        System.out.printf("Meal      %d%n", plain.price());
        System.out.printf("VeganMeal %d%n", vegan.price());
        System.out.printf("dish      %s%n", plain.dish);
    }
}
