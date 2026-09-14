// The same recursion, printing its own call stack. Run: java ComboTrace.java
record Item(String name, int price, List<Item> parts) { }

int totalOf(Item item, String pad) {
    IO.println(pad + "-> totalOf(" + item.name() + ")");
    if (item.parts().isEmpty()) {
        IO.println(pad + "<- " + item.price() + " (base case)");
        return item.price();
    }
    int total = 0;
    for (var part : item.parts()) total += totalOf(part, pad + "  ");
    IO.println(pad + "<- " + total);
    return total;
}

void main() {
    var rice  = new Item("lentil rice", 120, List.of());
    var beans = new Item("bean curry", 60, List.of());
    var stew  = new Item("vegetable stew", 90, List.of());
    var vegPlate = new Item("veg plate", 0, List.of(rice, beans));
    var lunch    = new Item("family lunch", 0, List.of(vegPlate, stew));
    totalOf(lunch, "");
}
