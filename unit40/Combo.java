// A box that can hold other boxes. Run: java Combo.java
record Item(String name, int price, List<Item> parts) { }

int totalOf(Item item) {
    if (item.parts().isEmpty()) return item.price();   // base case: stop here
    int total = 0;
    for (var part : item.parts()) total += totalOf(part);   // recursive case
    return total;
}

void main() {
    var rice  = new Item("lentil rice", 120, List.of());
    var beans = new Item("bean curry", 60, List.of());
    var stew  = new Item("vegetable stew", 90, List.of());
    var vegPlate = new Item("veg plate", 0, List.of(rice, beans));
    var lunch    = new Item("family lunch", 0, List.of(vegPlate, stew));
    IO.println("Family lunch costs " + totalOf(lunch));
}
