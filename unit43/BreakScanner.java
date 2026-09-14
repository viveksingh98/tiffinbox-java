void main() {
    var in = new Scanner(System.in);
    System.out.print("Meals per day: ");
    int meals = in.nextInt();
    System.out.print("Customer name: ");
    String name = in.nextLine();
    IO.println("Welcome [" + name + "] - " + meals + " meals a day.");
}
