void main() {
    String name = IO.readln("Customer name: ");
    int meals = Integer.parseInt(IO.readln("Meals per day: "));
    IO.println("Welcome " + name + " - " + meals + " meals a day, " + (meals * 120 * 30) + " a month.");
}
