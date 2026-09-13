import java.util.ArrayList;
import java.util.List;

public class Pollution {
    public static void main(String[] args) {
        List<Customer> customers = new ArrayList<>();
        customers.add(new Customer("Ravi", 2, 120, true));

        List raw = customers;               // raw type: checking switched off
        raw.add("Meera");                   // a String, into a List<Customer>

        IO.println("size: " + customers.size());
        for (Customer c : customers) {
            IO.println(c.name() + " -> " + c.monthlyBill());
        }
    }
}
