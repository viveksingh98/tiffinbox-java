package com.tiffinbox.web;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

/**
 * Course 8, unit 18 - Document and search, Section 4's first change to this folder: one day of TiffinBox's menu, a document in
 * MongoDB's collection menu. A document is one record that holds its own lists inside it, stored and read whole: this one holds the
 * day's items - one per meal type TiffinBox serves (VEG, NON_VEG, VEGAN, tiffinbox.meal-types) - and each item holds its own
 * allergens. No table held a menu before this unit; PostgreSQL stays the system of record for the customers and their pauses, and
 * the menu is new data, MongoDB's alone, under the profile "dev" (Menus).
 *
 * <p>Its id is the day, day-1 to day-30 (tiffinbox.days), a String the start chooses - so a start's fill writes the same ids every
 * time. An id left null is MongoDB's to choose: the mapper stores an ObjectId and Java reads a 24-character String back
 * (../c8-unit18, document). The mapper also writes _class, the type hint it reads the document back with: this record's full class
 * name, com.tiffinbox.web.MenuDay.
 *
 * <p>Why embedded: the items live inside the day's document, so one read by id returns the day whole - one command, one document
 * (../c8-unit18, oneread). The same menu in four tables (a menu, its items, the allergen names, and a table joining items to
 * allergens) is one statement with three joins and a row per item and allergen. The cost is the rename: an allergen's name is
 * written into every item that carries it, so renaming it rewrites every menu that names it - thirty documents - where the four
 * tables change one row (../c8-unit18, rename).
 *
 * <p>The items and prices are the menu's own: three dishes per meal type, one per day in turn, English names; a price in rupees per
 * meal type, as TiffinBox's prices are, and not a customer's (a customer's price is the seed's, V2__seed.sql). Every vegan dish
 * carries soy.
 */
@Document("menu")
public record MenuDay(@Id String id, List<MenuItem> items) {

    /** One item of a day's menu: an English dish name, a price in rupees and its allergens - embedded in the day's document. */
    public record MenuItem(String mealType, String name, int price, List<String> allergens) {
    }

    /** The menu's own prices, in rupees, one per meal type. */
    static final int VEG_PRICE = 110;
    static final int NON_VEG_PRICE = 160;
    static final int VEGAN_PRICE = 130;

    /** The three dishes per meal type, served in turn: day-1, day-4, day-7 ... the first; day-2 ... the second; day-3 ... the third. */
    private static final List<List<MenuItem>> TURNS = List.of(
            List.of(new MenuItem("VEG", "Vegetable curry with rice", VEG_PRICE, List.of("milk", "mustard")),
                    new MenuItem("NON_VEG", "Grilled chicken with rice", NON_VEG_PRICE, List.of("celery")),
                    new MenuItem("VEGAN", "Chickpea and tofu stew", VEGAN_PRICE, List.of("soy"))),
            List.of(new MenuItem("VEG", "Lentil soup with bread", VEG_PRICE, List.of("gluten", "celery")),
                    new MenuItem("NON_VEG", "Baked fish with potatoes", NON_VEG_PRICE, List.of("fish")),
                    new MenuItem("VEGAN", "Tofu and noodle stir-fry", VEGAN_PRICE, List.of("soy", "gluten"))),
            List.of(new MenuItem("VEG", "Spinach and cheese bake", VEG_PRICE, List.of("milk")),
                    new MenuItem("NON_VEG", "Egg fried rice", NON_VEG_PRICE, List.of("egg")),
                    new MenuItem("VEGAN", "Bean and tofu chili", VEGAN_PRICE, List.of("soy"))));

    /** The menu for days 1 to n (TiffinBoxServer passes tiffinbox.days): day-1 ... day-n, each with its turn's three items. */
    public static List<MenuDay> forDays(int n) {
        var out = new ArrayList<MenuDay>(n);
        for (int d = 1; d <= n; d++) {
            out.add(new MenuDay("day-" + d, TURNS.get((d - 1) % TURNS.size())));
        }
        return out;
    }
}
