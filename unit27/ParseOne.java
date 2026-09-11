void main() {
    String line = "Ravi,2,120,true";
    String[] parts = line.split(",");
    IO.println(parts.length + " parts, first: " + parts[0]);
    int mealsPerDay = Integer.parseInt(parts[1]);
    int pricePerMeal = Integer.parseInt(parts[2]);
    boolean isVeg = Boolean.parseBoolean(parts[3]);
    var ravi = new Customer(parts[0], mealsPerDay, pricePerMeal, isVeg);
    IO.println(ravi);
    IO.println("Monthly: " + ravi.monthlyBill());
    IO.println(parts[1] + 1);
    IO.println(mealsPerDay + 1);
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}
