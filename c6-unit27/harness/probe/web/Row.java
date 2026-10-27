package probe.web;

/** One customer in Core Java II's files (www/customers.json and one file each): Jackson reads the JSON straight into it. */
public record Row(String name, int mealsPerDay, int pricePerMeal, boolean veg) { }
