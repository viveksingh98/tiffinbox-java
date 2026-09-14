// EXERCISE 43 - "Sign Priya Up, Both Ways" - START HERE. Run: java SignUpStarter.java
// Fill in the three TODO methods. Target output is in README.md.
// The worked solution is SignUp.java - open it last.
// Rule: no nextInt() anywhere in this file.

void main(String[] args) {
    // TODO 1: branch on args.length.
    //   3 arguments -> register(args[0], args[1], args[2]) and return
    //   0 arguments -> ask the three questions with ask(), then register
    //   anything else -> the usage line below, and return
    // Each ask() can come back null (the input was closed). Stop straight away when it does,
    // or you will print all three prompts into a void.
    IO.println("Usage: java SignUpStarter.java <name> <mealsPerDay> <pricePerMeal>");
}

// TODO 2: print the prompt with no line break after it, then read one line and strip it.
//         If there is no line to read, print "(input closed - nothing saved)" and return null.
String ask(Scanner in, String prompt) {
    return null;
}

// TODO 3: turn three pieces of text into one registration.
//         Not a number      -> "Error: not a number - " + the exception's own message
//         Meals outside 1-3 -> "Error: meals a day must be 1 to 3, got " + meals
//         Otherwise         -> "Welcome <name> - <meals> meals a day, <meals * price * 30> a month."
void register(String name, String mealsText, String priceText) {
}
