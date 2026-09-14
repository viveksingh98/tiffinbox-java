// EXERCISE 40 - "The Party Box" - WORKED SOLUTION.
// Try PartyBoxStarter.java yourself first. Run: java PartyBox.java
record Item(String name, int price, List<Item> parts) { }

// recursive: how many actual meals, at any depth
int countMeals(Item item) {
    if (item.parts().isEmpty()) return 1;              // base case: a meal is one meal
    int meals = 0;
    for (var part : item.parts()) meals += countMeals(part);
    return meals;
}

// recursive: how many layers of box
int depth(Item item) {
    if (item.parts().isEmpty()) return 1;              // base case: a meal is one layer
    int deepest = 0;
    for (var part : item.parts()) {
        int d = depth(part);
        if (d > deepest) deepest = d;              // no Math yet - that is Unit 41
    }
    return deepest + 1;
}

// varargs: the smallest price, 0 when nothing is handed in
int cheapest(int... prices) {
    if (prices.length == 0) return 0;                  // guard first: there is no smallest of nothing
    int best = prices[0];
    for (int price : prices) {
        if (price < best) best = price;           // no Math yet - that is Unit 41
    }
    return best;
}

// nested loop: the day with the most meals of both types together
String busiestDay(int[][] week, String[] days) {
    int best = 0, bestTotal = 0;
    for (int day = 0; day < week.length; day++) {
        int total = 0;
        for (int type = 0; type < week[day].length; type++) total += week[day][type];
        if (total > bestTotal) { bestTotal = total; best = day; }
    }
    return days[best] + " (" + bestTotal + " meals)";
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
