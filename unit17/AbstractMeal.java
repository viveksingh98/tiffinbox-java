void main() {
    Meal stew = new VeganMeal("vegetable stew");
    IO.println(stew.label());
}

abstract class Meal {
    String dish;
    Meal(String dish) { this.dish = dish; }
    abstract int price();
    String label() { return dish + " - " + price(); }
}

class VegMeal extends Meal {
    VegMeal(String dish) { super(dish); }
    @Override int price() { return 120; }
}

class VeganMeal extends VegMeal {
    VeganMeal(String dish) { super(dish); }
    @Override int price() { return 130; }
}
