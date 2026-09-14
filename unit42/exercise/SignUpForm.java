// EXERCISE 42 — "Clean the Sign-up Form" · worked solution.
// Try it yourself first: write tidyName, validPhone and countVowels, then this table.
// Run: java SignUpForm.java

String tidyName(String typed) {
    String clean = typed.strip().toLowerCase();
    if (clean.isBlank()) return "Guest";
    return Character.toUpperCase(clean.charAt(0)) + clean.substring(1);
}

boolean validPhone(String typed) {
    String clean = typed.strip();
    if (clean.length() != 10) return false;
    for (int i = 0; i < clean.length(); i++) {
        if (!Character.isDigit(clean.charAt(i))) return false;
    }
    return true;
}

int countVowels(String text) {
    int found = 0;
    for (int i = 0; i < text.length(); i++) {
        if ("aeiou".indexOf(Character.toLowerCase(text.charAt(i))) >= 0) found++;
    }
    return found;
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
