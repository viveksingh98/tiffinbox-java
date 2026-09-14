import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/** A record whose List component leaks through the constructor AND the accessor. */
record Subscription(String customer, List<String> meals) { }

/** The same record with a compact constructor. Five characters of syntax. */
record SafeSubscription(String customer, List<String> meals) {
    SafeSubscription {
        meals = List.copyOf(meals);
    }
}

void main() {
    List<String> plan = new ArrayList<>(List.of("VEG", "VEG", "NON_VEG"));
    Subscription s = new Subscription("Meera", plan);
    IO.println("built:            " + s);

    plan.add("VEGAN");                        // door 1: the caller still holds the list
    IO.println("after caller add: " + s);

    s.meals().add("VEG");                     // door 2: the accessor hands the same list back
    IO.println("after getter add: " + s);

    Set<Subscription> active = new HashSet<>();
    active.add(s);
    IO.println("in a HashSet:     " + active.contains(s));
    int before = s.hashCode();
    s.meals().add("VEG");                     // one add, nobody touched the set
    IO.println("after one mutate: " + active.contains(s));
    IO.println("hashCode before:  " + before);
    IO.println("hashCode after:   " + s.hashCode());
    IO.println("Objects.hash(..): " + Objects.hash(s.customer(), s.meals()));

    // ---- the fix ----
    List<String> plan2 = new ArrayList<>(List.of("VEG", "VEG", "NON_VEG"));
    SafeSubscription safe = new SafeSubscription("Meera", plan2);
    plan2.add("VEGAN");
    IO.println("safe, caller add: " + safe);
    try {
        safe.meals().add("VEG");
    } catch (UnsupportedOperationException e) {
        IO.println("safe, getter add: UnsupportedOperationException (message: " + e.getMessage() + ")");
    }
}
