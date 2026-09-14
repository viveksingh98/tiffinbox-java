void main() {
    String[] menu = {"lentil rice", "bean curry", "chickpea curry", "vegetable stew",
                     "cottage cheese curry", "spiced rice", "combo plate"};
    var picker = new Random(42);
    for (int day = 1; day <= 5; day++) {
        IO.println("Day " + day + ": " + menu[picker.nextInt(menu.length)]);
    }
    IO.println("Dice: " + new Random(42).nextInt(1, 7));
}
