void main() {
    String name = "Meera";
    char first = name.charAt(0);
    IO.println("First letter: " + first);
    IO.println("Initial + dot: " + first + ".");
    for (int i = 0; i < name.length(); i++) {
        IO.println(i + " -> " + name.charAt(i));
    }
    IO.println("'M' as a number: " + (int) 'M');
    IO.println("(char)(77)     : " + (char) 77);
    IO.println("'M' + 1        : " + ('M' + 1));
    IO.println("(char)('M' + 1): " + (char) ('M' + 1));
    IO.println("'m' - 'M'      : " + ('m' - 'M'));

    String typed = "98765x4321";
    int digits = 0;
    for (int i = 0; i < typed.length(); i++) {
        char c = typed.charAt(i);
        if (Character.isDigit(c)) digits++;
        else IO.println("Not a digit at " + i + ": " + c);
    }
    IO.println("Digits found: " + digits + " of " + typed.length());
    IO.println("isLetter('x') : " + Character.isLetter('x'));
    IO.println("toUpperCase('x'): " + Character.toUpperCase('x'));
}
