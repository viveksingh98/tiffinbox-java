void main() {
    String[] menu = {"dal rice", "rajma chawal", "chole", "kadhi", "paneer", "biryani", "thali"};
    IO.println("Monday: " + menu[0]);
    IO.println("Days: " + menu.length);
    menu[2] = "chole bhature";
    for (var dish : menu) {
        IO.println("- " + dish);
    }
    IO.println(Arrays.toString(menu));
    IO.println(menu);
}
