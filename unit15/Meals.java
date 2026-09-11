void main() {
    IO.println(new VegMeal("dal rice").label());
    IO.println(new NonVegMeal("chicken curry").label());
    IO.println(new JainMeal("kadhi").label());
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

class JainMeal extends VegMeal {
    JainMeal(String dish) { super(dish); }
    @Override int price() { return 130; }
    @Override String label() { return super.label() + " (no onion, no garlic)"; }
}
