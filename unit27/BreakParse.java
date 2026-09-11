void main() throws IOException {
    var path = Path.of("customers.csv");
    Files.writeString(path, "name,mealsPerDay,pricePerMeal,isVeg\nRavi,2,120,true\nMeera,1,150,false\nSunil,two,120,true\n");
    var customers = load(path);
    IO.println(customers.size() + " customers loaded");
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
