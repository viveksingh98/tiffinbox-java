void main() {
    var ravi = new Customer("Ravi", 2);
    var meera = new Customer("Meera", 1);
    ravi.setMealsPerDay(3);
    IO.println(ravi.getName() + " eats " + ravi.getMealsPerDay());
    ravi.setMealsPerDay(-5);
    IO.println(ravi.getName() + " still eats " + ravi.getMealsPerDay());
    IO.println("Customers: " + Customer.count());
}
