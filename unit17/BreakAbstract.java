void main() {
    Meal mystery = new Meal("mystery");
    IO.println(mystery.label());
}

abstract class Meal {
    String dish;
    Meal(String dish) { this.dish = dish; }
    abstract int price();
    String label() { return dish + " - " + price(); }
}
