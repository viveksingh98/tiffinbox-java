// EXERCISE 40 - "The Party Box" - START HERE. Run: java PartyBoxStarter.java
// Fill in the four TODO methods. Nothing else needs to change.
// Target output is in README.md. The worked solution is PartyBox.java - open it last.
record Item(String name, int price, List<Item> parts) { }

// TODO 1 (recursive): how many actual meals are in this item, at any depth?
int countMeals(Item item) {
    return 0;
}

// TODO 2 (recursive): how many layers of box? A bare meal is 1.
int depth(Item item) {
    return 0;
}

// TODO 3 (varargs): the smallest of however many prices. No prices at all -> 0.
int cheapest(int... prices) {
    return 0;
}

// TODO 4 (nested loop): the day with the most meals, both types added together.
String busiestDay(int[][] week, String[] days) {
    return "?";
}

void main() {
    var rice  = new Item("lentil rice", 120, List.of());
    var beans = new Item("bean curry", 60, List.of());
    var stew  = new Item("vegetable stew", 90, List.of());
    var plate = new Item("veg plate", 0, List.of(rice, beans));
    var party = new Item("party box", 0, List.of(plate, stew));

    int[][] week = { {40,12}, {38,10}, {42,14}, {41,9}, {45,18}, {52,22}, {30,6} };
    String[] days = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};

    IO.println("Meals in the box: " + countMeals(party));
    IO.println("Nesting depth   : " + depth(party));
    IO.println("Cheapest of 120, 60, 90: " + cheapest(120, 60, 90));
    IO.println("Cheapest of nothing    : " + cheapest());
    IO.println("Busiest day     : " + busiestDay(week, days));
    IO.println("Grid            : " + Arrays.deepToString(week));
}
