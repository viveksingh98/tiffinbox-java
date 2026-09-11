void main() {
    var customers = new ArrayList<Customer>();
    customers.add(new Customer("Ravi", 7200));
    IO.println(max(customers));
}

<T extends Comparable<T>> T max(List<T> list) {
    T best = list.getFirst();
    for (var item : list) if (item.compareTo(best) > 0) best = item;
    return best;
}

record Customer(String name, int bill) {}
