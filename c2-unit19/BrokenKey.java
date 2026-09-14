import java.util.*;

/// A key class that is correct on the day it is written:
/// equals and hashCode agree, and both are built from `name`.
static class Customer {
    String name;                 // <- not final. That is the whole bug.
    final int mealsPerDay;
    Customer(String name, int mealsPerDay) { this.name = name; this.mealsPerDay = mealsPerDay; }
    @Override public boolean equals(Object o) {
        return o instanceof Customer c && c.name.equals(name);
    }
    @Override public int hashCode() { return name.hashCode(); }
    @Override public String toString() { return name + "(" + mealsPerDay + ")"; }
}

void main() {
    var subs = new HashMap<Customer, Integer>();
    Customer ravi = new Customer("Ravi", 2);

    IO.println("hashCode when stored:  " + ravi.hashCode());
    subs.put(ravi, 7200);
    IO.println("get(ravi):             " + subs.get(ravi));

    ravi.name = "Ravi Kumar";            // the customer edited their profile

    IO.println("hashCode now:          " + ravi.hashCode());
    IO.println("get(ravi):             " + subs.get(ravi));
    IO.println("containsKey(ravi):     " + subs.containsKey(ravi));
    IO.println("remove(ravi):          " + subs.remove(ravi));
    IO.println("subs.size():           " + subs.size());
    IO.println("subs.entrySet():       " + subs.entrySet());
    IO.println("get(new Ravi Kumar):   " + subs.get(new Customer("Ravi Kumar", 2)));
    IO.println("get(new Ravi):         " + subs.get(new Customer("Ravi", 2)));
}
