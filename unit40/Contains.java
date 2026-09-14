// The same three questions, a different answer shape.
// totalOf adds numbers up; contains stops at the first yes.
record Item(String name, int price, List<Item> parts) { }

boolean contains(Item item, String dish) {
    if (item.parts().isEmpty()) return item.name().equals(dish);  // 1. smallest input: is this it?
    for (var part : item.parts()) {                               // 2. smaller: one part at a time
        if (contains(part, dish)) return true;                    // 3. combine: any one is enough
    }
    return false;
}

void main() {
    var rice  = new Item("lentil rice", 120, List.of());
    var beans = new Item("bean curry", 60, List.of());
    var stew  = new Item("vegetable stew", 90, List.of());
    var vegPlate = new Item("veg plate", 0, List.of(rice, beans));
    var lunch    = new Item("family lunch", 0, List.of(vegPlate, stew));

    IO.println("bean curry in the lunch?  " + contains(lunch, "bean curry"));
    IO.println("spiced rice in the lunch? " + contains(lunch, "spiced rice"));
}
