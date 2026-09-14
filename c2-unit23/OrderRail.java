// OrderRail.java — a class of your own in a for-each loop, then the loud failure.
// run: java OrderRail.java        (JDK 25, compact source file; exits 1 on purpose)
import java.util.*;

record Slip(String customer, int meals) {
    @Override public String toString() { return customer + " x" + meals; }
}

/** A fixed rail of order slips. Not a Collection — just two methods. */
final class Rail implements Iterable<Slip> {
    private final Slip[] slips;
    Rail(Slip... slips) { this.slips = slips; }

    @Override public Iterator<Slip> iterator() {
        return new Iterator<Slip>() {
            private int at = 0;
            @Override public boolean hasNext() { return at < slips.length; }
            @Override public Slip next() {
                if (at >= slips.length) throw new NoSuchElementException("rail is empty");
                return slips[at++];
            }
        };
    }
}

void row(String label, Object value) {
    IO.println(String.format("%-18s: %s", label, value));
}

void main() {
    IO.println("-- your own Iterable in a for-each loop --");
    Rail rail = new Rail(new Slip("Meera", 1), new Slip("Priya", 1),
                         new Slip("Ravi", 2), new Slip("Sunil", 3));
    int meals = 0;
    for (Slip s : rail) meals += s.meals();
    row("meals on the rail", meals);

    int slips = 0;
    for (Slip s : rail) slips++;
    row("a second walk", slips + " slips (a fresh Iterator each time)");

    Iterator<Slip> done = new Rail().iterator();
    row("hasNext", done.hasNext());
    try { done.next(); }
    catch (NoSuchElementException e) { row("past the end", e.getClass().getSimpleName() + ": " + e.getMessage()); }

    IO.println("");
    IO.println("now the loop everybody writes first:");
    List<String> queue = new ArrayList<>(List.of("Meera", "Priya", "Ravi", "Sunil"));
    for (String name : queue) {
        if (name.startsWith("P")) queue.remove(name);
    }
    IO.println("never reached: " + queue);
}
