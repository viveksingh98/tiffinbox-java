// Shapes.java — four collection shapes an ArrayList cannot answer well.
// run: java Shapes.java        (JDK 25, compact source file)
import java.util.*;

enum MealType { VEG, NON_VEG, VEGAN }

record Order(String customer, int minutesLeft) {
    @Override public String toString() { return customer + "(" + minutesLeft + ")"; }
}

record Customer(String name, MealType type, int mealsPerDay, int pricePerMeal) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

void row(String label, Object value) {
    IO.println(String.format("%-18s: %s", label, value));
}

void main() {
    IO.println("-- ArrayDeque: a queue with two front doors --");
    Deque<String> deque = new ArrayDeque<>(List.of("Meera", "Priya", "Ravi"));
    deque.addFirst("Kiran");
    row("deque", deque);
    String first = deque.pollFirst(), last = deque.pollLast();
    row("pollFirst", first + "   pollLast: " + last);
    row("deque now", deque);

    Deque<String> empty = new ArrayDeque<>();
    row("peekFirst on empty", empty.peekFirst());
    try { empty.getFirst(); }
    catch (NoSuchElementException e) { row("getFirst on empty", e.getClass().getSimpleName()); }
    try { deque.addLast(null); }
    catch (NullPointerException e) { row("addLast(null)", e.getClass().getSimpleName()); }

    Deque<String> undo = new ArrayDeque<>();
    undo.push("meal");  undo.push("address");  undo.push("price");
    Stack<String> old = new Stack<>();
    old.push("meal");   old.push("address");   old.push("price");
    row("ArrayDeque, push", undo + "   pop: " + undo.peek());
    row("java.util.Stack ", old + "   pop: " + old.peek());

    IO.println("");
    IO.println("-- PriorityQueue: heap-ordered, not sorted --");
    List<Order> arrived = List.of(new Order("Meera", 20), new Order("Kiran", 12),
                                  new Order("Ravi", 25), new Order("Sunil", 8),
                                  new Order("Priya", 5));
    Queue<Order> pq = new PriorityQueue<>(Comparator.comparingInt(Order::minutesLeft));
    pq.addAll(arrived);
    row("added in order", arrived);
    row("printed", pq);
    row("stream().toList()", pq.stream().toList());
    row("peek", pq.peek());
    List<Order> polled = new ArrayList<>();
    while (!pq.isEmpty()) polled.add(pq.poll());
    row("polled", polled);

    IO.println("");
    IO.println("-- NavigableMap: the keys stay sorted --");
    NavigableMap<Integer, String> slots = new TreeMap<>();
    slots.put(780, "Ravi");  slots.put(720, "Meera");
    slots.put(810, "Sunil"); slots.put(750, "Priya");
    SortedMap<Integer, String> before13 = slots.headMap(780);
    row("slots", slots);
    row("firstEntry", slots.firstEntry());
    row("floorKey(765)", slots.floorKey(765));
    row("ceilingKey(765)", slots.ceilingKey(765));
    row("higherKey(780)", slots.higherKey(780));
    row("headMap(780)", before13);
    row("subMap(740, 800)", slots.subMap(740, 800));
    row("descendingMap", slots.descendingMap());
    slots.put(765, "Kiran");
    row("after put 765", slots);
    row("same headMap now", before13);

    IO.println("");
    IO.println("-- EnumMap / EnumSet: an array and a bitset --");
    List<Customer> today = List.of(new Customer("Priya", MealType.VEGAN, 1, 120),
                                   new Customer("Ravi",  MealType.VEG, 2, 120),
                                   new Customer("Sunil", MealType.NON_VEG, 3, 100),
                                   new Customer("Meera", MealType.VEG, 1, 150));
    Map<MealType, Integer> revenue = new EnumMap<>(MealType.class);
    List<MealType> putOrder = new ArrayList<>();
    for (Customer c : today) {
        if (!revenue.containsKey(c.type())) putOrder.add(c.type());
        revenue.merge(c.type(), c.monthlyBill(), Integer::sum);
    }
    row("put order", putOrder);
    row("EnumMap", revenue);
    EnumSet<MealType> meatFree = EnumSet.of(MealType.VEGAN, MealType.VEG);
    row("EnumSet", meatFree);
    row("complementOf", EnumSet.complementOf(meatFree));
    row("allOf", EnumSet.allOf(MealType.class));
    row("noneOf", EnumSet.noneOf(MealType.class));
    row("contains NON_VEG", meatFree.contains(MealType.NON_VEG));
    row("EnumSet class", meatFree.getClass().getName());
    // com.sun.source.tree.Tree.Kind is a JDK enum with 117 constants — more than 64.
    row("over 64 constants", EnumSet.noneOf(com.sun.source.tree.Tree.Kind.class).getClass().getName());
}
