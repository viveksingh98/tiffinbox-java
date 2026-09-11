void main() {
    List<String> customers = new ArrayList<>();
    customers.add("Ravi");
    customers.add("Meera");
    customers.add("Sunil");
    IO.println(customers);
    IO.println(customers.size() + " customers, first: " + customers.get(0));
    customers.remove("Meera");
    IO.println(customers.contains("Meera"));
    customers.add(0, "Meera");
    IO.println(customers.getFirst() + " ... " + customers.getLast());
    IO.println(customers.reversed());
}
