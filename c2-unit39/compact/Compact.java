record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {}

void main() throws Exception {
    IO.println("nested as:  " + new Customer("Ravi", 2, 120, true).getClass().getName());
    IO.println("forName:    " + Class.forName("Customer"));
}
