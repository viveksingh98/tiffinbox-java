void main() {
    Meal kadhi = new JainMeal("kadhi");
    IO.println(kadhi.label());
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

class JainMeal extends VegMeal {
    JainMeal(String dish) { super(dish); }
    @Override int price() { return 130; }
}
