void main() {
    var ravi = new Customer("Ravi");
    IO.println(ravi.name);
}

class Customer {
    String name;

    Customer(String name) {
        name = name;   // forgot this.
    }
}
