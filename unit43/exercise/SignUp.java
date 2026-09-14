void main(String[] args) {
    if (args.length == 3) {
        register(args[0], args[1], args[2]);
        return;
    }
    if (args.length != 0) {
        IO.println("Usage: java SignUp.java <name> <mealsPerDay> <pricePerMeal>");
        return;
    }
    var in = new Scanner(System.in);
    String name = ask(in, "Customer name: ");
    if (name == null) return;
    String meals = ask(in, "Meals per day (1-3): ");
    if (meals == null) return;
    String price = ask(in, "Price per meal: ");
    if (price == null) return;
    register(name, meals, price);
}

String ask(Scanner in, String prompt) {
    System.out.print(prompt);
    if (!in.hasNextLine()) {
        IO.println("(input closed - nothing saved)");
        return null;
    }
    return in.nextLine().strip();
}

void register(String name, String mealsText, String priceText) {
    int meals;
    int price;
    try {
        meals = Integer.parseInt(mealsText);
        price = Integer.parseInt(priceText);
    } catch (NumberFormatException e) {
        IO.println("Error: not a number - " + e.getMessage());
        return;
    }
    if (meals < 1 || meals > 3) {
        IO.println("Error: meals a day must be 1 to 3, got " + meals);
        return;
    }
    System.out.printf("Welcome %s - %d meals a day, %d a month.%n", name, meals, meals * price * 30);
}

// ── HOW THIS IS PUT TOGETHER (read after your six runs match) ────────────────
// main(String[] args) branches on args.length: 3 -> register, 0 -> ask, anything
//   else -> the usage line. Each ask() can return null, so main returns the moment
//   one does — that is what makes run 3 print ONE prompt instead of three.
// ask(Scanner, String) prints the prompt with System.out.print (no line break),
//   then guards with !in.hasNextLine(): print "(input closed - nothing saved)" and
//   return null. Otherwise in.nextLine().strip().
// register(String, String, String) wraps BOTH Integer.parseInt calls in one try,
//   catches NumberFormatException and prints "Error: not a number - " + e.getMessage()
//   — the text after the dash is Java's, not ours — then checks the 1-to-3 rule, then
//   prints with System.out.printf.
// No nextInt() anywhere: nextLine() reads the whole line, so nothing is left behind
//   in the buffer for the next read to trip over (slide 2).
