void main() throws IOException {
    var path = Path.of("customers.csv");
    Files.writeString(path, """
        name,mealsPerDay,pricePerMeal,isVeg
        Ravi,2,120,true
        Meera,1,150,false
        Sunil,1,120,true
        """);
    var customers = load(path);
    int total = 0;
    for (var c : customers) {
        IO.println(c.name() + ": " + c.monthlyBill());
        total += c.monthlyBill();
    }
    IO.println(customers.size() + " customers, " + total + " a month");
}

List<Customer> load(Path path) throws IOException {
    var customers = new ArrayList<Customer>();
    var lines = Files.readAllLines(path);
    for (int i = 1; i < lines.size(); i++) customers.add(parse(lines.get(i)));
    return customers;
}

Customer parse(String line) {
    var p = line.split(",");
    return new Customer(p[0].trim(), Integer.parseInt(p[1].trim()),
            Integer.parseInt(p[2].trim()), Boolean.parseBoolean(p[3].trim()));
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}
