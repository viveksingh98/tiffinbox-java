// EXERCISE 45 — "Tidy Asha's Kitchen" (worked solution).
// One compact file, four shapes, nothing printed anywhere except main().

interface Payable {
    String who();
    int amountDue();

    static Payable of(String who, int amount) {
        return new Payable() {
            @Override public String who()    { return who; }
            @Override public int amountDue() { return amount; }
        };
    }

    default String receipt()  { return row("DUE"); }
    default String reminder() { return row("REMINDER"); }

    private String row(String tag) { return "%-9s %-8s %6d".formatted(tag, who(), amountDue()); }
}

abstract class Meal {
    protected int basePrice;
    Meal(int basePrice) { this.basePrice = basePrice; }
    final int deliveryFee() { return 20; }
    abstract int price();
}

final class VeganMeal extends Meal {
    VeganMeal() { super(130); }
    @Override int price() { return basePrice + deliveryFee() - 10; }
}

static final class Receipt {
    private final String name;
    private final int    amount;
    private final String note;

    private Receipt(Builder b) { this.name = b.name; this.amount = b.amount; this.note = b.note; }

    String line() { return name + " | " + amount + " | " + note; }

    static class Builder {
        private String name   = "Guest";
        private int    amount = 0;
        private String note   = "-";
        Builder name(String n)   { this.name = n;   return this; }
        Builder amount(int a)    { this.amount = a; return this; }
        Builder note(String s)   { this.note = s;   return this; }
        Receipt build()          { return new Receipt(this); }
    }
}

void main() {
    IO.println(Payable.of("Ravi", 7200).receipt());
    IO.println(Payable.of("Sunil", 8800).reminder());

    VeganMeal vegan = new VeganMeal();
    IO.println("Vegan meal price: " + vegan.price() + " (delivery " + vegan.deliveryFee() + ")");

    IO.println(new Receipt.Builder().name("Priya").amount(7200).note("paid by UPI").build().line());
    IO.println(new Receipt.Builder().build().line());

    IO.println("VeganMeal is final: " + Modifier.isFinal(VeganMeal.class.getModifiers()));
    IO.println("Payable.of returns: " + Payable.of("Ravi", 7200).getClass().getName());
}

// ── THE TRAP THIS EXERCISE EXISTS FOR ────────────────────────────────────────
// Line 33 says `static final class Receipt {`. Drop the `static` - write either
//
//     final class Receipt {          (or just)   class Receipt {
//
// …and the file stops compiling, on line 49, with this exact message:
//
//     Kitchen.java:49: error: non-static variable this cannot be referenced from a static context
//             Receipt build()          { return new Receipt(this); }
//                                               ^
//     1 error
//     error: compilation failed
//
// (Measured for BOTH spellings - the `final` makes no difference.)
// Why: in a compact source file every "top-level" class is an INNER class of the
// implicit class (proved with javap in ImplicitNesting.java), so `new Receipt(...)`
// needs an enclosing instance — and the static Builder has none to hand it.
// `static` in front of Receipt gives it no outer object to want. That is slide 5.
