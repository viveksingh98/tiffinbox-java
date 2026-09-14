// The string pool: what == really compares.
// Run:  java Intern.java
void main() {
    String a = "Ravi";
    String b = "Ravi";
    String c = new String("Ravi");
    String folded = "Ra" + "vi";
    String part = "Ra";
    String built = part + "vi";

    IO.println("a == b            (two literals)      : " + (a == b));
    IO.println("a == c            (new String)        : " + (a == c));
    IO.println("a.equals(c)                           : " + a.equals(c));
    IO.println("identityHashCode(a) == that of c      : "
            + (System.identityHashCode(a) == System.identityHashCode(c)));
    IO.println("a == folded       (\"Ra\" + \"vi\")       : " + (a == folded));
    IO.println("a == built        (part + \"vi\")       : " + (a == built));
    IO.println("a == c.intern()                       : " + (a == c.intern()));
    IO.println("a == built.intern()                   : " + (a == built.intern()));
    IO.println("built.intern() == c.intern()          : " + (built.intern() == c.intern()));
}
