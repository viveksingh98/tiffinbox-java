void main() {
    var customers = new ArrayList<>(List.of("Ravi", "Meera", "Sunil"));
    for (var name : customers) { if (name.equals("Ravi")) customers.remove(name); }
}
