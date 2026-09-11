package com.tiffinbox;

public record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {

    public static final int DAYS_IN_MONTH = 30;
    public static final String CSV_HEADER = "name,mealsPerDay,pricePerMeal,isVeg";

    public Customer {
        if (name == null || name.isBlank()) {
            throw new TiffinBoxException("name must not be blank");
        }
        if (mealsPerDay < 1 || mealsPerDay > 3) {
            throw new TiffinBoxException("meals a day must be 1 to 3, got " + mealsPerDay);
        }
        if (pricePerMeal < 1) {
            throw new TiffinBoxException("price per meal must be positive, got " + pricePerMeal);
        }
        name = name.trim();
    }

    public int monthlyBill() {
        return billFor(DAYS_IN_MONTH);
    }

    public int billFor(int days) {
        return mealsPerDay * pricePerMeal * days;
    }

    public MealType mealType() {
        return MealType.of(isVeg);
    }

    public String toCsv() {
        return name + "," + mealsPerDay + "," + pricePerMeal + "," + isVeg;
    }

    public static Customer fromCsv(String line) {
        var p = line.split(",");
        if (p.length != 4) {
            throw new TiffinBoxException("expected 4 fields, got " + p.length);
        }
        return new Customer(p[0].trim(),
                Integer.parseInt(p[1].trim()),
                Integer.parseInt(p[2].trim()),
                Boolean.parseBoolean(p[3].trim()));
    }
}
