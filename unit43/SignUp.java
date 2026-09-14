void main() {
    var in = new Scanner(System.in);
    System.out.print("Customer name: ");
    String name = in.nextLine();
    System.out.print("Meals per day: ");
    int meals = Integer.parseInt(in.nextLine());
    IO.println("Welcome " + name + " - " + meals + " meals a day, " + (meals * 120 * 30) + " a month.");
}
