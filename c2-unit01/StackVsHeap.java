void main() {
    var ravi = new Customer("Ravi", 2);
    int total = bill(ravi, 120);
    IO.println(ravi + " -> " + total);

    var same = ravi;
    IO.println("same object? " + (same == ravi));
}

int bill(Customer c, int price) {
    int days = 30;
    return c.mealsPerDay() * price * days;
}

record Customer(String name, int mealsPerDay) {}
