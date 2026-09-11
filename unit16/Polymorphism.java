void main() {
    var todaysMeals = List.of(new VegMeal("lentil rice"),
                              new NonVegMeal("chicken curry"),
                              new VeganMeal("vegetable stew"));
    int total = 0;
    for (Meal meal : todaysMeals) {
        IO.println(meal.label());
        total += meal.price();
    }
    IO.println("Total: " + total);

    Meal special = new VeganMeal("vegetable stew");
    IO.println(special.price());
}

class Meal {
    String dish;
    int basePrice;
    Meal(String dish, int basePrice) { this.dish = dish; this.basePrice = basePrice; }
    int price() { return basePrice; }
    String label() { return dish + " - " + price(); }
}

class VegMeal extends Meal {
    VegMeal(String dish) { super(dish, 120); }
}

class NonVegMeal extends Meal {
    NonVegMeal(String dish) { super(dish, 150); }
    @Override String label() { return super.label() + " (non-veg)"; }
}

class VeganMeal extends VegMeal {
    VeganMeal(String dish) { super(dish); }
    @Override int price() { return 130; }
    @Override String label() { return super.label() + " (no dairy, no eggs)"; }
}
