void main() {
    var ravi = new Customer();   // no arguments
    IO.println(ravi.name);
}

class Customer {
    String name;

    Customer(String name) {
        this.name = name;
    }
}
