package com.tiffinbox.web;

/**
 * Course 8, unit 22: the event DishService publishes when it saves a dish row - the row's id (PostgreSQL's identity), its name, meal
 * type and price. DishIndexSync hears it after the transaction commits, and copies the row into the index.
 */
public record DishSaved(long id, String name, String mealType, int price) {
}
