// EXERCISE 42 - "Clean the Sign-up Form" - START HERE. Run: java SignUpFormStarter.java
// Fill in the three TODO methods. Nothing else needs to change.
// Target output is in README.md. The worked solution is SignUpForm.java - open it last.

// TODO 1: tidy what a human typed into a name Asha can print.
//         "  meera " -> "Meera",  "RAVI" -> "Ravi",  "  " -> "Guest".
String tidyName(String typed) {
    return "?";
}

// TODO 2: true only for a real ten-digit phone number.
//         "9876543210" -> true,  "98765 43210" -> false,  "98765x4321" -> false.
boolean validPhone(String typed) {
    return false;
}

// TODO 3: how many vowels are in this text? a, e, i, o, u - either case.
int countVowels(String text) {
    return 0;
}

void main() {
    String[] typedNames = {"  meera ", "RAVI", "  ", "priya"};
    String[] typedPhones = {"9876543210", "98765 43210", "98765x4321", "0123456789"};
    String[] tidy = new String[typedNames.length];

    System.out.printf("%-8s %-14s %-6s %s%n", "NAME", "PHONE", "OK", "VOWELS");
    System.out.println("-".repeat(38));
    for (int i = 0; i < typedNames.length; i++) {
        tidy[i] = tidyName(typedNames[i]);
        System.out.printf("%-8s %-14s %-6b %d%n",
                tidy[i], typedPhones[i], validPhone(typedPhones[i]), countVowels(tidy[i]));
    }
    System.out.println("All names: " + String.join(", ", tidy));
}
