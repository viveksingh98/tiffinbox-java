void main() {
    Meal special = new JainMeal("kadhi");
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

class JainMeal extends VegMeal {
    JainMeal(String dish) { super(dish); }
    @Override int price() { return 130; }
    String kitchenNote() { return "Jain: no onion, no garlic"; }
}
