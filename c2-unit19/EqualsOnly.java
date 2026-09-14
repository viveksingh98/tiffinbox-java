import java.util.*;
import java.util.concurrent.*;

/// TiffinBox: a subscription key with equals() and NO hashCode().
static class Sub {
    final String customer;
    final int meals;
    Sub(String customer, int meals) { this.customer = customer; this.meals = meals; }
    @Override public boolean equals(Object o) {
        return o instanceof Sub s && s.meals == meals && s.customer.equals(customer);
    }
    // hashCode() deliberately NOT written -> Object's identity hash is used
    @Override public String toString() { return customer + "(" + meals + ")"; }
}

record SubRecord(String customer, int meals) {}

record Order<K>(K customer, int value) {}

void main() {
    Sub a = new Sub("Ravi", 2);
    Sub b = new Sub("Ravi", 2);

    IO.println("a.equals(b)              : " + a.equals(b));
    IO.println("a.hashCode()==b.hashCode(): " + (a.hashCode() == b.hashCode()));

    Set<Sub> set = new HashSet<>(List.of(a, b));
    IO.println("HashSet size             : " + set.size() + "   <- two 'equal' objects, both stored");
    IO.println("set.contains(new Sub)    : " + set.contains(new Sub("Ravi", 2)));
    IO.println("List.contains(new Sub)   : " + List.of(a, b).contains(new Sub("Ravi", 2))
            + "   (List uses equals only)");

    SubRecord ra = new SubRecord("Ravi", 2);
    SubRecord rb = new SubRecord("Ravi", 2);
    IO.println("record equals            : " + ra.equals(rb));
    IO.println("record hashCodes match   : " + (ra.hashCode() == rb.hashCode()));
    IO.println("HashSet of records size  : " + new HashSet<>(List.of(ra, rb)).size());
    IO.println("SubRecord.hashCode()     : " + ra.hashCode());
    IO.println("Objects.hash(\"Ravi\", 2)  : " + Objects.hash("Ravi", 2));

    // ---- the merge line from the concurrent-collections lesson, unchanged ----
    IO.println("");
    var revenue = new ConcurrentHashMap<Sub, Integer>();
    for (Order<Sub> o : List.of(new Order<>(a, 7200), new Order<>(b, 7200))) {
        revenue.merge(o.customer(), o.value(), Integer::sum);
    }
    IO.println("CHM.merge twice, size    : " + revenue.size()
            + "   (that merge is only atomic, not correct)");
    IO.println("CHM values               : " + new ArrayList<>(revenue.values()));

    var safe = new ConcurrentHashMap<SubRecord, Integer>();
    for (Order<SubRecord> o : List.of(new Order<>(ra, 7200), new Order<>(rb, 7200))) {
        safe.merge(o.customer(), o.value(), Integer::sum);
    }
    IO.println("same with records, size  : " + safe.size()
            + "   values " + new ArrayList<>(safe.values()));
}
