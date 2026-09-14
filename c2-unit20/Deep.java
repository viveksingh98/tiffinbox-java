import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/** The types that were already deeply immutable: their methods return a NEW object. */
void main() {
    String name = "Meera";
    name.toUpperCase();                              // return value thrown away on purpose
    IO.println("String     : " + name);

    LocalDate start = LocalDate.of(2026, 9, 14);
    start.plusDays(30);
    IO.println("LocalDate  : " + start);

    BigDecimal bill = new BigDecimal("120.00");
    bill.add(new BigDecimal("30"));
    IO.println("BigDecimal : " + bill);

    List<String> plan = List.of("VEG", "NON_VEG");
    IO.println("List.of    : " + plan + "  add -> " + refused(plan));
}

String refused(List<String> l) {
    try {
        l.add("VEGAN");
        return "accepted (!)";
    } catch (UnsupportedOperationException e) {
        return "UnsupportedOperationException";
    }
}
