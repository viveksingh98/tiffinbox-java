void main() {
    var ravi = new Customer("Ravi", 2, 120, true);
    Predicate<Customer> isVeg = new Predicate<>() {
        @Override
        public boolean test(Customer c) {
            return c.isVeg();
        }
    };
    IO.println(isVeg.test(ravi));
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}
