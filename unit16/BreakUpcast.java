void main() {
    Meal special = new VeganMeal("vegetable stew");
    IO.println(special.kitchenNote());
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
    @Override int price() { return 130; }
    String kitchenNote() { return "Vegan: no dairy, no eggs"; }
}
