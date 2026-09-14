import java.util.*;

record Customer(String name, int mealsPerDay, int pricePerMeal) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

void main() {
    Customer ravi  = new Customer("Ravi",  2, 120);   // 2 x 120 x 30 = 7200
    Customer kiran = new Customer("Kiran", 3,  80);   // 3 x  80 x 30 = 7200

    IO.println("ravi.equals(kiran):  " + ravi.equals(kiran));
    IO.println("same bill:           " + (ravi.monthlyBill() == kiran.monthlyBill()));
    IO.println("HashSet size:        " + new HashSet<>(List.of(ravi, kiran)).size());

    var tree = new TreeSet<Customer>(Comparator.comparingInt(Customer::monthlyBill));
    tree.add(ravi);
    tree.add(kiran);
    IO.println("TreeSet size:        " + tree.size());
    IO.println("TreeSet contents:    " + tree);
    IO.println("tree.contains(kiran):" + tree.contains(kiran));

    var fixed = new TreeSet<Customer>(
            Comparator.comparingInt(Customer::monthlyBill).thenComparing(Customer::name));
    fixed.add(ravi);
    fixed.add(kiran);
    IO.println("tie-broken size:     " + fixed.size());

    var book = new TreeMap<String, Integer>(String.CASE_INSENSITIVE_ORDER);
    book.put("Ravi", 7200);
    IO.println("book.get(\"ravi\"):    " + book.get("ravi"));
    IO.println("\"ravi\".equals(\"Ravi\"): " + "ravi".equals("Ravi"));
}
