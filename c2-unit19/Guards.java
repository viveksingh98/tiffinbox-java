import java.util.*;

record Customer(String name, int mealsPerDay, int pricePerMeal) {
    Customer {                                   // compact constructor
        Objects.requireNonNull(name, "customer name must not be null");
        if (mealsPerDay < 1 || mealsPerDay > 3)
            throw new IllegalArgumentException("mealsPerDay must be 1..3, got " + mealsPerDay);
    }
}

static boolean assertionsOn() {
    boolean on = false;
    assert on = true;        // the one sanctioned side effect inside an assert
    return on;
}

void main() {
    var menu = List.of("Garden Bowl", "Grilled Wrap", "Soup of the Day");
    int slot = 3;

    IO.println("assertions enabled:  " + assertionsOn());
    assert slot < menu.size() : "menu slot out of range: " + slot;
    IO.println("past the assert, slot = " + slot);

    try { Objects.checkIndex(slot, menu.size()); }
    catch (IndexOutOfBoundsException e) { IO.println("checkIndex:          " + e); }

    try { new Customer(null, 2, 120); }
    catch (NullPointerException e) { IO.println("requireNonNull:      " + e.getMessage()); }

    try { new Customer("Kiran", 5, 80); }
    catch (IllegalArgumentException e) { IO.println("compact ctor:        " + e.getMessage()); }

    String missing = null;
    try { missing.length(); }
    catch (NullPointerException e) { IO.println("helpful NPE:         " + e.getMessage()); }
}
