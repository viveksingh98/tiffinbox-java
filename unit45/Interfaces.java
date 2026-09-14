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

void main() {
    Payable ravi  = Payable.of("Ravi", 7200);
    Payable sunil = Payable.of("Sunil", 8800);
    IO.println(ravi.receipt());
    IO.println(sunil.reminder());
    IO.println("Payable.of made a: " + ravi.getClass().getName());
}
