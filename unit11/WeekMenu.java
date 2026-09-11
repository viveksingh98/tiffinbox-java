void main() {
    String[] menu = {"lentil rice", "bean curry", "chickpeas", "vegetable stew", "cottage cheese", "spiced rice", "combo plate"};
    IO.println("Monday: " + menu[0]);
    IO.println("Days: " + menu.length);
    menu[2] = "chickpea curry";
    for (var dish : menu) {
        IO.println("- " + dish);
    }
    IO.println(Arrays.toString(menu));
    IO.println(menu);
}
