void main() {
    var customers = new ArrayList<>(List.of("Ravi", "Meera", "Sunil"));
    customers.removeIf(name -> name.equals("Ravi"));
    IO.println(customers);
}
