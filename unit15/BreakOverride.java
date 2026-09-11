void main() {
    IO.println(new VeganMeal("vegetable stew").label());
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

class VeganMeal extends VegMeal {
    VeganMeal(String dish) { super(dish); }
    @Override int prise() { return 130; }
    @Override String label() { return super.label() + " (no dairy, no eggs)"; }
}
