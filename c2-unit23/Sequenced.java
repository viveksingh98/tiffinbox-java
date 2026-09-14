// Sequenced.java — first, last and reversed since JDK 21, plus the Arrays toolbox.
// run: java Sequenced.java        (JDK 25, compact source file)
import java.util.*;

void row(String label, Object value) {
    IO.println(String.format("%-20s: %s", label, value));
}

void main() {
    IO.println("-- SequencedCollection (JDK 21) --");
    List<String> route = new ArrayList<>(List.of("Meera", "Priya", "Ravi", "Sunil"));
    row("getFirst()", route.getFirst());
    row("getLast()", route.getLast());
    row("reversed()", route.reversed());
    row("the old way", route.get(route.size() - 1));

    LinkedHashSet<String> seen = new LinkedHashSet<>(List.of("Meera", "Priya", "Ravi"));
    row("LinkedHashSet", seen.getFirst() + "  last: " + seen.getLast());
    LinkedHashMap<String, Integer> slots = new LinkedHashMap<>();
    slots.put("Meera", 720); slots.put("Priya", 750); slots.put("Ravi", 780);
    row("LinkedHashMap", slots.firstEntry() + "  last: " + slots.lastEntry());
    row("reversed map", slots.reversed());

    IO.println("");
    IO.println("-- the Arrays toolbox --");
    int[] bills = { 3600, 4500, 7200, 7200, 9000 };
    row("Arrays.toString", Arrays.toString(bills));
    row("binarySearch(7200)", Arrays.binarySearch(bills, 7200));
    row("binarySearch(5000)", Arrays.binarySearch(bills, 5000) + "   (-(insertion point) - 1)");
    row("Arrays.stream sum", Arrays.stream(bills).sum());
    int[] same = { 3600, 4500, 7200, 7200, 9000 };
    row("Arrays.equals", Arrays.equals(bills, same));
    row("bills.equals(same)", bills.equals(same));
    int[] other = { 3600, 5000, 7200, 7200, 9000 };
    row("Arrays.mismatch", Arrays.mismatch(bills, other));
    String[][] grid = { { "Meera", "VEG" }, { "Ravi", "NON_VEG" } };
    row("Arrays.deepToString", Arrays.deepToString(grid));
    row("Arrays.toString 2-D", Arrays.toString(grid));
}
