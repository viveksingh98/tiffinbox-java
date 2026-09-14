void main() {
    String[] menu = {"lentil rice", "bean curry", "chickpea curry", "vegetable stew",
                     "cottage cheese curry", "spiced rice", "combo plate"};
    var picker = new Random();
    for (int day = 1; day <= 3; day++) {
        IO.println("Day " + day + ": " + menu[picker.nextInt(menu.length)]);
    }
    IO.println("Math.random(): " + Math.random());
    IO.println("Dice roll:     " + new Random().nextInt(1, 7));
}
