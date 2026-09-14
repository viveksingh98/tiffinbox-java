void main(String[] args) {
    IO.println("args.length = " + args.length);
    IO.println("args        = " + Arrays.toString(args));
    if (args.length < 3) {
        IO.println("Usage: java Bill.java <name> <mealsPerDay> <pricePerMeal>");
        return;
    }
    String name = args[0];
    int meals = Integer.parseInt(args[1]);
    int price = Integer.parseInt(args[2]);
    IO.println(name + " owes " + (meals * price * 30) + " this month.");
}
