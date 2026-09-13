import java.util.List;

public class Bills {
    static List<Customer> customers;

    static int first(List<Customer> customers) {
        Customer c = customers.get(0);
        return c.monthlyBill();
    }
}
