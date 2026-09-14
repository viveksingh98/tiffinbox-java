// CmeSilent.java — the same bug as OrderRail, one element further along: no exception at all.
// run: java CmeSilent.java        (JDK 25, compact source file)
import java.util.*;

void row(String label, Object value) {
    IO.println(String.format("%-31s: %s", label, value));
}

void main() {
    IO.println("-- the same bug with no exception --");
    List<String> queue = new ArrayList<>(List.of("Meera", "Priya", "Ravi", "Sunil"));
    row("list", queue);
    int visited = 0;
    for (String name : queue) {
        visited++;
        if (name.equals("Ravi")) queue.remove(name);
    }
    row("removed 'Ravi' (2nd from last)", "no exception");
    row("elements the loop visited", visited + " of 4");
    row("list now", queue);
    row("'Sunil' was never visited", queue.contains("Sunil"));

    IO.println("");
    IO.println("-- the two fixes, one line each --");
    List<String> a = new ArrayList<>(List.of("Meera", "Priya", "Ravi", "Sunil"));
    a.removeIf(n -> n.startsWith("P"));
    row("removeIf", a);
    List<String> b = new ArrayList<>(List.of("Meera", "Priya", "Ravi", "Sunil"));
    for (Iterator<String> it = b.iterator(); it.hasNext(); )
        if (it.next().startsWith("P")) it.remove();
    row("Iterator.remove", b);

    IO.println("");
    IO.println("-- one last impostor --");
    String[] backing = { "Meera", "Priya", "Ravi" };
    List<String> window = Arrays.asList(backing);
    row("Arrays.asList", window + "  class " + window.getClass().getSimpleName());
    row("its full name", window.getClass().getName());
    window.set(0, "Kiran");
    row("set(0, \"Kiran\")", window);
    row("the backing array now", Arrays.toString(backing));
    try { window.add("Sunil"); }
    catch (UnsupportedOperationException e) { row("add(\"Sunil\")", e.getClass().getSimpleName() + " (fixed size)"); }
    try { List.of("Meera").set(0, "Kiran"); }
    catch (UnsupportedOperationException e) { row("List.of(...).set(0, ...)", e.getClass().getSimpleName() + " (immutable)"); }
}
