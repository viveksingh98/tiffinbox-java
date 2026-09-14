void main() {
    String typed = "  Cottage Cheese Curry  ";
    String clean = typed.strip();
    IO.println("[" + typed.trim() + "]");
    IO.println("[" + clean + "]");
    IO.println("lower  : " + clean.toLowerCase());
    IO.println("replace: " + clean.replace("Curry", "Stew"));
    IO.println("every one: " + "curry, curry, curry".replace("curry", "stew"));
    IO.println("indexOf(\"Cheese\")   : " + clean.indexOf("Cheese"));
    IO.println("indexOf('e')        : " + clean.indexOf('e'));
    IO.println("lastIndexOf('e')    : " + clean.lastIndexOf('e'));
    IO.println("indexOf(\"chicken\")  : " + clean.indexOf("chicken"));
    IO.println("\"\".isEmpty()   : " + "".isEmpty());
    IO.println("\"   \".isEmpty(): " + "   ".isEmpty());
    IO.println("\"   \".isBlank(): " + "   ".isBlank());
    IO.println("-".repeat(28));
    IO.println("valueOf(7200) : " + String.valueOf(7200));
    IO.println("join: " + String.join(", ", "Ravi", "Meera", "Sunil"));
    String row = "Ravi,2,120,";
    IO.println("split default: " + Arrays.toString(row.split(",")) + " length " + row.split(",").length);
    IO.println("split(-1)    : " + Arrays.toString(row.split(",", -1)) + " length " + row.split(",", -1).length);
    String wide = " Ravi ";
    IO.println("trim  [" + wide.trim() + "] length " + wide.trim().length());
    IO.println("strip [" + wide.strip() + "] length " + wide.strip().length());
}
